module.exports = (options)->
  path = __dirname+'/server/watcher'
  process.stdout.write '\u001B[2J\u001B[0;0f'
  watcher = new (require(path))(options)

