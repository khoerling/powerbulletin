require! {
  pg: \./postgres
  v: \./varnish
  c: \./cache
  h: \./server-helpers
  sioa: \socket.io-announce
  auth: \./auth
  async
  #\stylus # pull in stylus when accepting user's own stylesheets
}

announce = sioa.create-client!

ban-all-domains = (site-id) ->
  # varnish ban site's domains
  err, domains <- db.domains-by-site-id site-id
  if err then return next err
  for d in domains then v.ban-domain d.name

@sites =
  update: (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard

    # get site
    site = res.vars.site
    err, site <- db.site-by-id site.id
    if err then return next err

    # save site
    switch req.body.action
    | \general =>
      should-ban = false
      for f in [\postsPerPage \inviteOnly \private \analytics]
        if site.config[f] isnt req.body[f] then should-ban = true
      # save specific keys
      site.config <<< { [k, val] for k, val of req.body when k in
        [\postsPerPage \metaKeywords \inviteOnly \private \analytics] }
      for c in [\inviteOnly \private] # uncheck checkboxes?
        delete site.config[c] unless req.body[c]
      for s in [\private \analytics] # tampering
        delete site.config[s] unless s in site.subscriptions
      console.log \updating:, site.config
      err, r <- db.site-update site
      if err then return next err
      ban-all-domains site.id if should-ban # varnish ban
      res.json success:true

    | \menu =>
      # save site config
      site.config.menu = req.body.menu
      err, r <- db.site-update site
      if err then return next err
      # TODO sync live menu with config
      # - forums
      # - pages
      ban-all-domains site.id # varnish ban
      res.json success:true

    | \domains =>
      # find domain
      err, domain <- db.domain-by-id req.body.domain
      if err then return next err

      # does site own domain?
      err, domains <- db.domains-by-site-id domain.site_id
      if err then return next err
      unless find (.site_id is domain.site_id) domains then return next 404

      # extract specific keys
      auths = [
        \facebookClientId
        \facebookClientSecret
        \twitterConsumerKey
        \twitterConsumerSecret
        \googleConsumerKey
        \googleConsumerSecret]
      domain.config <<< { [k, v] for k, v of req.body when k in auths}

      # generate domain-specific css
      const suffix = \Secret
      domain.config.stylus = auths
        |> filter (-> it.index-of(suffix) isnt -1 and req.body[it])                # only auths with values
        |> map (-> ".has-#{take-while (-> it in [\a to \z]), it}{display:inline}") # make css selectors
        |> join ''
      if domain.config.stylus.length then domain.config.stylus += '.has-auth{display:block}'
      err, r <- db.domain-update domain # save!
      if err then return next err
      db.sites.save-stylus domain.name, domain.config.stylus
      res.json success:true
@users =
  create : (req, res, next) ->
    user   = req.user
    site   = res.vars.site
    emails = req.body.emails.to-string!

    # guards
    if not user?rights?super then return next 404
    if not emails.length then return res.json {success:false, msg:'Who to invite?'}
    emails = emails.split ','

    # generate new users + email w/ inbound verify-&-choose-user-name link
    switch req.body.action
    | \invites =>
      register = (email, cb) ->
        (err, new-user) <- register-local-user site, email, email, email
        u = if err?name then err else new-user
        if err and !u
          cb err
        else # resend email if already registered
          if u.verify then
            auth.send-invite-email site, user, u, req.body.message
            cb(if err then "Re-invited #{u.name}" else null)
          else
            cb "#{u.name} is registered!"

      (err, r) <- async.each emails, register
      if err then return res.json {success:false, msg:err}
      res.json success:true

    | otherwise =>
      user = req.params.user
      # munge data
      (err, user) <- db.find-or-create user
      res.json user
@posts =
  index   : (req, res) ->
    res.locals.fid = req.query.fid
    res.locals.pid = req.query.pid
    res.render \post-new
  create  : (req, res, next) ->
    return next 404 unless req.user
    db = pg.procs
    post          = req.body
    post.user_id  = req.user.id
    post.html     = h.html post.body
    post.ip       = res.vars.remote-ip
    post.tags     = h.hash-tags post.body
    post.forum_id = post.forum_id
    unless post.user_id and req.user.transient
      # if no user_id, try transient_owner
      post.transient_owner = req.user.transient_id

    err, ap-res <- db.add-post post
    if err then return next err

    if ap-res.success # if success then blow cache
      post.id = ap-res.id
      c.invalidate-post post.id, req.user.name # blow cache!

    unless post.parent_id
      err, new-post <- db.post post.id
      if err then return next err
      announce.emit \thread-create new-post
    else
      err, new-post <- db.post post.id
      if err then return next err
      new-post.posts = []
      announce.emit \post-create new-post

    res.json ap-res
  show    : (req, res, next) ->
    db = pg.procs
    if post-id = parse-int(req.params.post)
      err, post <- db.post post-id
      if err then return next err
      res.json post
    else
      return next 404
  update  : (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard
    # is_owner req?user
    err, owns-post <- db.owns-post req.body.id, req.user?id
    if err then return next err
    return next 404 unless owns-post?length
    # TODO secure & csrf
    # save post
    req.body.user_id = req.user.id
    req.body.html = h.html req.body.body
    post = req.body
    err, r <- db.edit-post(req.user, post)
    if err then return next err

    if r.success
      # blow cache !
      c.invalidate-post post.id, req.user.name

    res.json r
  destroy : (req, res, next) ->
    db = pg.procs
    if post-id = parse-int req.params.post
      # guard is post owner or super
      err, owns-post <- db.owns-post post-id, req.user?id
      if err then return next err
      return next 404 unless owns-post.length or !req?user?rights?super
      # we don't really destroy, we just archive
      err <- db.archive-post post-id
      if err then return next err
      res.json {success: true}
    else
      next 404
@products =
  show: (req, res, next) ->
    return next 404 unless id = req.params.product
    err, product <- db.products.find-one {
      criteria: {id}
      columns: [\id \description \price \config]
    }
    if err then return next err
    if product
      product.config = JSON.parse product.config # p00f--json'ify
      res.json product
    else
      next 404
@conversations =
  show: (req, res, next) ->
    id = req.params.conversation
    limit = 4
    err, c <~ db.conversation-by-id id
    if err
      console.error \conversations-show, req.path, err
      res.json success: false
      return
    if c
      err, messages <- db.messages-by-cid c.id, (req.query.last || null), limit
      if err
        console.error \conversations-show, req.path, err
        res.json success: false
        return
      c.messages = messages |> map (-> it.body = format.chat-message it.body; it)
      c.success = true
      res.json c
    else
      console.error \conversations-show, "nothing"
      res.json success: false


# vim:fdm=indent
