require! {
  './resources'
  './handlers'
  mw: './middleware'
}
global <<< require './helpers' # pull helpers (common) into global (play nice :)

# <API RESOURCES>
# ---------
app.resource \posts   resources.posts
app.resource \threads resources.threads

# <PAGE HANDLERS & MISC.>
# ---------
app.get '/', mw.add-js(["#{cvars.cache4_url}/js/layout.js"]), mw.add-css(['/dynamic/css/layout.styl,theme.styl']), handlers.homepage
app.get '/hello' handlers.hello

# UI SKETCH UP:
#
# Connect to a social network:
# Facebook, Twitter
# OR
# Register @ <Forum Name>.com
app.post '/ajax/register', handlers.register

# dynamic serving
app.get '/dynamic/css/:file' handlers.stylus
