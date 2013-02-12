
layout-static = (w, mutator) ->
  # indicate current
  w.marshal \mutator, mutator     # js
  w.$ \html .attr(\class mutator) # stylus
  # handle forum background
  w.$ '.bg-set' .remove!
  w.$ '.bg' .each -> w.$ this .add-class \bg-set .remove!prepend-to w.$ 'body' # position behind

flip-background = (w, cur, direction='down') ->
  clear-timeout w.bg-anim if w.bg-anim
  last = w.$ '.bg.active'
  unless last.length
    next = w.$ '#forum'+"_bg_#{cur.data \id}"
    next.add-class \active
  else
    w.bg-anim := set-timeout (->
      next = w.$ '#forum'+"_bg_#{cur.data \id}"

      last.css \top if direction is \down then -300 else 300 # stage animation
      last.remove-class \active
      next.add-class 'active visible' # ... and switch!
      w.bg-anim = 0
    ), 300


@homepage =
  static:
    (window, next) ->
      window.render-jade 'main_content' \homepage
      layout-static window, \homepage
      next!
  on-load:
    (window, next) ->
      window.$ '.forum .container' .masonry(
        item-selector: '.post'
        is-animated:   true
        is-fit-width:  true
        is-resizable:  true)
      #{{{ Waypoints
      set-timeout (->
        # sticky forum headers
        $ = window.$
        $ '.forum .header' .waypoint \sticky { offset: -100 }

        # forum switches
        $ '.forum' .waypoint {
          offset  : '33%',
          handler : (direction) ->
            e   = $ this
            eid = e.attr \id

            # handle menu active
            id = if direction is \down then eid else
              $ '#'+eid .prevAll '.forum:first' .attr \id
            return unless id # guard
            $ 'header .menu' .find '.active' .remove-class \active # remove prev
            cur = $ 'header .menu'
              .find ".#{id.replace /_/ \-}"
              .add-class \active # ...and activate!

            # handle forum headers
            $ '.forum .invisible' .remove-class \invisible
            $ '.forum .stuck'     .remove-class \stuck
            # TODO if direction is \up stick last forum

            flip-background window, cur, direction
        }), 100

      awesome-scroll-to "forum_#{}"
      #}}}
      next!
  on-unload:
    (window, next) ->
      window.$ '.forum .container' .masonry(\destroy)
      window.$ '.forum .header' .waypoint(\destroy)
      window.$ '.forum' .waypoint(\destroy)
      next!

@forum =
  static:
    (window, next) ->
      window.render-jade 'left_content' \nav
      window.render-jade 'main_content' \posts
      window.marshal \active @active.id
      layout-static window, \forum
      next!
  on-load:
    (window, next) ->
      window.$ 'header .menu .active' .remove-class \active
      cur = window.$ "header .menu .forum-#{window.active}"
      cur.add-class \active
      flip-background window, cur
      next!
  on-mutate:
    (window, next) ->
      #window.awesome-scroll-to \body 300
      window.scroll-to 0  0
      window.s
      next!

@search =
  static:
    (window, next) ->
      next!
  on-load:
    (window, next) ->
      next!
  on-initial:
    (window, next) ->
      # set initial state
      next!
  on-mutate:
    (window, next) ->
      next!

# vim:fdm=marker
