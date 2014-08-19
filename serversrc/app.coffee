
"""
 Module dependencies.
"""

express = require('express')
routes = require('./routes')
user = require('./routes/user')
http = require('http')
path = require('path')
MongoStore = require('connect-mongo')(express)
flash = require 'connect-flash'
PORT = 3300
PORT_TEST = PORT + 1
myapp = null
myoptions = {}


get_app = (options = {}) ->
  if myapp != null and myoptions != options
    myapp = null
  if myapp == null
      myapp = new Application(options)
  return myapp

class Application
  constructor: (options = {}) ->
    @app = express()
    myoptions = options
    for key in Object.keys(options)
      value = options[key]
      console.log "setting app.locals['#{key}'] = #{value}"
      @app.locals[key] = value
    sessionstore = null    
    if @app.locals.db?
      sessionstore = new MongoStore({db: @app.locals.db, auto_reconnect: true})

    @app.set 'port', process.env.PORT || 3000
    @app.set 'views', __dirname + '/views'
    @app.set 'view engine', 'jade'
    @app.use express.favicon()
    @app.use express.logger('dev')
    @app.use express.bodyParser()
    @app.use express.cookieParser '5V011c5ISyLLEG353neFwbuWL24MC3P1'
    @app.use express.session {store: sessionstore}
    @app.use flash() 
    @app.use @app.router
    @app.use express.static(path.join(__dirname, '../public'))
    @app.use express.static(path.join(__dirname, '../dist'))
    @app.get '/', routes.index
    @app.get '/users', user.list

  createServer: () ->
    # development only
    self = @
    if 'development' == @app.get('env')
      @app.use express.errorHandler()
    http.createServer(@app).listen @app.get('port'), () ->
      console.log 'Express server listening on port ' + self.app.get('port')

module.exports = get_app
