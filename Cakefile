{spawn} = require 'child_process'

binDir = './node_modules/.bin'
nodeDev = "#{binDir}/node-dev"
coffee = "#{binDir}/coffee"
mocha = "#{binDir}/mocha"
npmedge = "#{binDir}/npmedge"

distpath = "dist"
csspath = "#{distpath}/css/"
jspath = "#{distpath}/js/"

option '-p', '--port [PORT_NUMBER]', 'set the port number for `start`'
option '-s', '--settings [SETTINGS_NAME]', 'set the settings file for `start`'
option '-e', '--environment [ENVIRONMENT_NAME]', 'set the environment for `start`'
task 'start', 'start the server', (options) ->
  process.env.NODE_ENV = options.environment ? 'development'
  process.env.PORT = options.port if options.port
  process.env.SETTINGS_NAME = options.settings if options.settings
  console.log "Test run #{nodeDev}"
  spawn nodeDev, ['server.coffee'], stdio: 'inherit'
  invoke 'watch'

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

task 'clean', 'Clean the output files', (options) ->
  spawn "rm", ['-rf', distpath], stdio: 'inherit'

task 'distcss', 'Copy / build css files', (options) ->
  spawn "mkdir", ['-p', distpath], stdio: 'inherit'
  spawn "cp", ["-a", "public/css/", distpath], stdio: 'inherit'

task 'distjs', 'Build the coffee files single distributable js', (options) ->
  args = [
    '--compile',
    '--join', "#{jspath}/roadmap.js"
    'uisrc/roadmap.coffee'
  ]
  spawn coffee, args, stdio: 'inherit'

task 'dist', 'Build distributable files', (options) ->
  invoke 'distjs'
  invoke 'distcss'

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
