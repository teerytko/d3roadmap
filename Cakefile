{spawn} = require 'child_process'

binDir = './node_modules/.bin'
nodeDev = "#{binDir}/node-dev"
coffee = "#{binDir}/coffee"
mocha = "#{binDir}/mocha"
npmedge = "#{binDir}/npmedge"

option '-p', '--port [PORT_NUMBER]', 'set the port number for `start`'
option '-s', '--settings [SETTINGS_NAME]', 'set the settings file for `start`'
option '-e', '--environment [ENVIRONMENT_NAME]', 'set the environment for `start`'
task 'start', 'start the server', (options) ->
  process.env.NODE_ENV = options.environment ? 'development'
  process.env.PORT = options.port if options.port
  process.env.SETTINGS_NAME = options.settings if options.settings
  console.log "Test run #{nodeDev}"
  spawn nodeDev, ['server.coffee'], stdio: 'inherit'

option '-t', '--testfile [FILENAME]', 'set the filename for `test`'
task 'test', 'run the tests', (options) ->
  process.env.NODE_ENV = 'test'
  args = [
    '--compilers', 'coffee:coffee-script'
    '--require', 'should'
    '--reporter', 'list'
    '--ignore-leaks'
  ]
  if options.testfile
    args.push options.testfile
  else
    args.push '--recursive'
    args.push './serversrc/test'
  console.log "running mocha #{args.join(' ')}"
  spawn mocha, args, stdio: 'inherit'

task 'build', 'Build the coffee files to js', (options) ->
  process.env.NODE_ENV = options.environment ? 'development'
  args = [
    '--compile',
    '--output', 'dist/js'
    'uisrc',
  ]
  spawn coffee, args, stdio: 'inherit'

task 'watch', 'Start coffee --watch for the coffee files to js', (options) ->
  process.env.NODE_ENV = options.environment ? 'development'
  args = [
    '--compile',
    '--watch',
    '--output', 'dist/js'
    'uisrc'
  ]
  spawn coffee, args, stdio: 'inherit'

task 'update', 'update all packages and run npmedge', ->
  (spawn 'npm', ['install', '-q'], stdio: 'inherit').on 'exit', ->
    (spawn 'npm', ['update', '-q'], stdio: 'inherit').on 'exit', ->
      spawn npmedge, [], stdio: 'inherit'
