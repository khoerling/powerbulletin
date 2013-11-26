define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  ch: './client-helpers'
  ChatPanel: '../component/ChatPanel'
  \./globals
  mutants: \../shared/pb-mutants
}

{render-and-append} = require \../shared/shared-helpers

####  main  ;,.. ___  _
init = -> # export socket to window + init
  if sock = window.socket = io?connect!
    init-with-socket sock
  sock
main = ->
  <- ch.lazy-load-socketio # first try
  unless init!
    set-timeout (-> # static crashed or otherwise 50x'd--try again:
      <- ch.lazy-load-socketio
      init!) 3000ms
main!


# https://github.com/LearnBoost/socket.io/wiki/Exposed-events
# socket.on \event-name, (message, cb) ->
function init-with-socket s
  s.on \connect, ->
    globals.r-socket s
    #console.log \connected

  s.on \disconnect, ->
    #console.log \disconnected

  s.on \enter-site, (message, cb) ->
    #console.warn \enter-site, message
    ch.set-online-user message?id

  s.on \leave-site, (message, cb) ->
    #console.warn \leave-site, message
    $ "[data-user-id=#{message.id}] .profile.photo" .remove-class \online

  s.on \menu-update, (menu, cb) ->
    $ \#menu .html jade.templates.menu {menu}
    window.component.main-menu.detach!attach!

  s.on \thread-impression (thread, cb) ->
    if thread.forum_id is window.active-forum-id
      $ "\#left_container ul.threads li[data-id=#{thread.id}] span.views"
        .html "#{thread.views}<i>views</i>"

  s.on \thread-create (thread, cb) ->
    if window.active-forum-id is thread?forum_id
      $ui.trigger \thread-create, thread

  s.on \post-create (post, cb) ->
    # only real-time posts for users':
    # - currently active thread
    # - own posts on profile pages
    window.active-thread-id ||= -1
    if post.thread_id is window.active-thread-id or (post.user_id is user.id and window.mutator is \profile)
      return if $ "post_#{post.id}" .length # guard (exists)

      # update post count
      pc = $ "\#left_container ul.threads li[data-id=#{post.thread_id}] span.post-count"
      pc.html ("#{(parse-int pc.text!) + 1} <i>posts</i>")

      # & render new post
      sel = "\#post_#{post.parent_id} + .children"
      animate-in = (e) -> $ e .add-class \post-animate-in
      render-and-append(
        window, $(sel), \post, post:post, (new-post) ->
          if post.user_id is user?id # & scroll-to
            mutants.forum.on-personalize window, user, (->) # enable edit, etc...
            set-timeout (-> animate-in new-post), 250ms
            if window.mutator is \forum then awesome-scroll-to new-post, 300ms
          else
            animate-in new-post)

  s.on \new-hit, (hit) ->
    hs = hit._source
    window.new-hits++
    window.$new-hits.prepend jade.templates.post({post: hs})

    # XXX: find out better place to declare these?
    # @beppusan, don't judge me for using onclick attributes ;)
    window.show-new-hits = ->
      <- window.awesome-scroll-to \#main_content, null
      $('#new_posts').html('').append(window.$new-hits).effect(\flash)
      return false # just in case its used in a click handler
    window.hide-new-hits = ->
      $('#new_posts').html('')
      return false # just in case its used in a click handler

    # FIXME move to jade, even if only for consistency and ajax instead of reloading
    suffix = if window.new-hits is 1 then '' else \s
    realtime-html = """
    <a href="#" onclick="showNewHits()">
      #{window.new-hits} new result#suffix
    </a>
    """

    # fills in top of search page with new hits total
    $ \#new_hit_count
      ..find \.count .html window.new-hits
      ..show!effect \highlight

    # fills in breadcrumb (selectors are poorly named ATM)
    $ \#new_hits .html realtime-html
    $ \#breadcrumb .slide-down 300ms

  # <profile-related updates>
  s.on \new-profile-title, (user) ->
    $ "[data-user-id=#{user.id}] .user-title" .html user.title
  s.on \new-profile-photo, (user) -> # TODO smoothly load image
    $ "[data-user-id=#{user.id}]" .find('.profile img').attr \src, "#{cache-url}#{user.photo}"
    if window?user?id is user.id
      $ \#profile .attr \src, "#{cache-url}#{user.photo}"

  s.on \debug, (message, cb) ->
    console?log \debug, message

  ChatPanel.client-socket-init s


# vim:fdm=indent
