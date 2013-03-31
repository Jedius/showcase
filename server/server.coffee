module.exports = class Server

  #node modules
  http: require 'http'
  express: require 'express'
  spawn: require('child_process').spawn

  #app modules
  globals: require './globals'
  config: require './config'

  constructor: (options) ->
    @options = options
    global.glob = @globals
    glob.server = @
    glob.options = @options
    @router = new (require './router')
    @build = new (require './build')(@options)

    @port = @options.port or glob.config.server.port
    @app = @express()
    @app.configure =>
      @app.set 'port', @port
      @app.set 'views', @config.path.views
      @app.set 'view engine', 'jade'
      @app.use @express.favicon()
      @app.use @express.cookieParser()
      @app.use @express.bodyParser()
      @app.use @express.methodOverride()
      @app.use @app.router
      @app.use @express.static @config.path.public
      @app.use @express.errorHandler
        dumpExceptions: true
        showStack: true

  listen: (cb)->
    @router.init @app, =>
      server = @http.createServer(@app)
      server.listen @port, =>
        console.log  'server start on port '+@port
        cb() if cb

  startSrcServer: (cb)->
    console.log @options.path.runner.server
    if @options.path.runner.server
      @srcServer = @spawn 'node', [@options.path.runner.server],
        stdio: 'inherit'
        stderr: 'inherit'
      process.on 'SIGTERM', =>
        @srcServer.kill()
        process.exit()
    cb() if cb

  show_lint_errors: (cb)->
    if @lint_errors
      errors = false
      length = 0
      for path of @lint_errors
        if @lint_errors[path][0]
          errors = true
        else
          length++

      if errors
        console.log "Lint: #{length} files success,"
        for path of @lint_errors
          if @lint_errors[path][0]
            console.log "  #{path}:"
            for error in @lint_errors[path]
              console.log "    #{error.lineNumber}: #{error.message}"
      else
        console.log "Lint: #{length} files success"
    cb() if cb

  start: (cb)->
    @build.compile (err)=>
      @listen (err)=>
        #@build.report (err)=>
          #@build.spec (err)=>
        @show_lint_errors (err)=>
          @startSrcServer (err)=>
            cb() if cb
