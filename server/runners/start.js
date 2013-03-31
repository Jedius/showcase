require('coffee-script')
var options = JSON.parse(process.env.options);
var Server = require('../server');
var server = new Server(options);
server.start()
