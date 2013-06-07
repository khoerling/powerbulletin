require! {
  sio: 'socket.io'
  crc32: 'express/node_modules/buffer-crc32'
  cookie: 'express/node_modules/cookie'
  connect: 'express/node_modules/connect'
  RedisStore: 'socket.io/lib/stores/redis'
  redis: 'socket.io/node_modules/redis'
  '../component/Chat'
}

# might need to put this somewhere more persistent
@state = {}

enter-site = (socket, site, user) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  @state[s].users[user.name] = u = { id: user.id, name: user.name }
  socket.join(s)
  socket.in(s).broadcast.emit \enter-site, u

leave-site = (socket, site, user) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  delete @state[s].users[user.name]
  socket.leave(s)
  console.log "leaving #{s}"
  socket.in(s).broadcast.emit \leave-site, { id: user.id, name: user.name }

in-site = (socket, site) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  users = keys @state[s].users
  users.for-each (name) ~>
    u = @state[s].users[name]
    console.warn \enter-site, \on-connect, u
    socket.in(s).emit \enter-site, u # not braoadcast

user-from-session = (s, cb) ->
  unless s?passport?user
    return cb null, {id:0, name:\Anonymous, guest:true}
  [name, site_id] = s?passport?user?split \:
  #console.warn "deserialize", name, site_id
  (err, user) <- db.usr {name, site_id}
  cb err, user

site-by-domain = (domain, cb) ->
  if not domain
    cb null null
  else
    db.site-by-domain domain, cb

@init = (server) ->
  io = sio.listen server
  io.set 'log level', 1

  redis-pub    = redis.create-client!
  redis-sub    = redis.create-client!
  redis-client = redis.create-client!
  redis-store  = new RedisStore({ redis, redis-pub, redis-sub, redis-client })
  io.set \store, redis-store

  io.set \authorization, (handshake, accept) ->
    if handshake.headers.cookie
      handshake.cookies = cookie.parse handshake.headers.cookie
      connect-cookie = handshake.cookies['connect.sess']
      unless connect-cookie then return accept("no connect session cookie", false) # guard
      unsigned = connect.utils.parse-signed-cookie connect-cookie, cvars.secret

      if unsigned
        original-hash = crc32.signed unsigned
        session = connect.utils.parse-JSON-cookie(unsigned) || {}
        #console.log \session, session
        handshake.session = session
        handshake.domain  = handshake.headers.host
        return accept(null, true)
      else
        return accept("bad session?", false)
    else
      return accept("no cookies", false)

  io.on \connection, (socket) ->
    var search-room

    err, user <- user-from-session socket.handshake.session
    if err then console.warn err

    err, site <- site-by-domain socket.handshake.domain
    if err then console.warn err

    if user and site
      #console.warn { site: site.name, user: user.name }
      enter-site socket, site, user
    if site
      #console.warn { site: site.name }
      in-site socket, site

    socket.on \disconnect, ->
      console.warn \disconnected
      if user and site
        leave-site socket, site, user
      if search-room
        socket.leave search-room

    socket.on \online-now, ->
      if site
        in-site socket, site

    socket.on \debug, ->
      socket.emit \debug, 'hi'
      socket.emit \debug, socket.manager.rooms
      socket.in('1').emit \debug, 'hi again to 1'

    # client no longer needs realtime query updates (navigated away from search page)
    socket.on \search-end, ->
      if search-room
        socket.emit \debug, "leaving room: #{search-room}"
        socket.leave search-room
        search-room := null

    # client will get subscribed to said query room
    socket.on \search, (searchopts) ->
      if search-room
        socket.emit \debug, "leaving room: #{search-room}"
        socket.leave search-room
        search-room := null

      # same thing as jquery's $.param
      param = (obj) -> ["#{k}=#{v}" for k,v of obj].join('&')

      search-room := "#{site.id}/search/#{encode-URI-component(param(searchopts))}"

      socket.emit \debug, "joining room: #{search-room}"
      socket.join search-room

      # register search with the search notifier
      io.sockets.emit \register-search, {searchopts, site-id: site.id, room: search-room}

    #Chat.server-socket-init socket
    socket.on \chat_message, (message, cb) ->
      # create conversation if it doesn't already exist
      # join the room for the channel if we haven't already joined
      # broadcast message to channel
