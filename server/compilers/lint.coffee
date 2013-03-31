module.exports = class Lint

  fs: require 'fs'
  coffeelint: require 'coffeelint'
  spawn: require('child_process').spawn
  jslint: glob.config.bin.jslint
  utils: new (require '../utils')

  getFiles: (extension,cb)->
    files = []
    if glob.config.lint? and glob.config.lint[0]
      @utils.getDirs glob.options.watch.dirs, (_files)=>
        for file in _files
          if file.substr(-extension.length) is extension
            files.push file
        cb files if cb
    else
      cb files if cb

  compile: (cb)=>
    @getFiles 'coffee',(files)=>
      if files[0]
        errors = {}
        for file in files
          content = @fs.readFileSync file, 'utf-8'
          path = file.split(glob.config.root)[1].substring(1)
          errors[path] = @coffeelint.lint content
        glob.server.lint_errors = errors
        cb() if cb
      else
        cb() if cb

  js: (cb)=>
    @getFiles 'js',(files)=>
      if files[0]
        errors = ''
        options = ['--indent','2','--color','--node','true','--predef','describe']
        for file in files
          options.push file
        proc = @spawn @jslint, options,
          stdio: 'inherit'
          stderr: 'inherit'
        proc.on 'exit', =>
          #glob.server.lint_errors = errors
          cb() if cb
      else
        cb() if cb
