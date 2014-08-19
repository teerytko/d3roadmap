fs      = require('fs')
mongodb = require('mongodb')
create_app = require('./serversrc/app')
extend   = require('./serversrc/utils').extend

APPROOT       = __dirname
SETTINGS_NAME = process.env.SETTINGS_NAME || 'settings.json'
SECRET_NAME   = process.env.SECRET_NAME ||'secret.json'
SETTINGS_FILE = "#{APPROOT}/#{SETTINGS_NAME}"
PACKAGE_FILE = "#{APPROOT}/package.json"
SECRET_FILE   = "#{APPROOT}/#{SECRET_NAME}"

settings = JSON.parse fs.readFileSync(SETTINGS_FILE)
if fs.existsSync(SECRET_FILE) == true
  secret = JSON.parse fs.readFileSync(SECRET_FILE)
  settings = extend(settings, secret) 

packdata = JSON.parse fs.readFileSync(PACKAGE_FILE, 'ascii')
settings.root = APPROOT
settings.version = packdata.version

env  = process.env.NODE_ENV || 'development'
port = process.env.PORT || settings.server.port

console.log "Starting #{packdata.version}-#{env}"
console.log "Connecting to mongo #{settings.db.server}"
mongodb.MongoClient.connect settings.db.server, settings.db.options, (err, db) ->
  if err?
    console.log "Mongo connection failed #{err}"
    return
  else
    app = create_app({db: db, settings: settings})
    app.createServer()
