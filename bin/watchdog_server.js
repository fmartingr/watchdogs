// Generated by CoffeeScript 1.6.1
(function() {
  var INFO, SERVERS, VIEWERS, app, config, config_file, express, file, fs, http, io, server, socketio, toml, _UPDATERS,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  toml = require('tomljs');

  express = require('express');

  http = require('http');

  socketio = require('socket.io');

  fs = require('fs');

  app = express();

  server = http.createServer(app);

  io = socketio.listen(server);

  config_file = 'watchdog.toml';

  if (process.argv[2]) {
    config_file = process.argv[2];
  }

  SERVERS = {};

  INFO = {};

  VIEWERS = [];

  _UPDATERS = {};

  try {
    file = fs.readFileSync(config_file).toString();
    config = toml(file);
  } catch (error) {
    console.log('Error: Configuration file not found!');
    process.exit(-1);
  }

  app.get('/viewer', function(request, response) {
    var handler;
    if (request.query.key === config.key) {
      file = __dirname + '/../lib/viewer.js';
      handler = fs.createReadStream(file);
      return handler.pipe(response);
    } else {
      return response.end("Invalid key.");
    }
  });

  io.on('connection', function(socket) {
    socket.on('register', function(type, name, callback) {
      socket._type = type;
      if (type === 'server') {
        console.log("[register] " + type + ": " + name);
        socket._name = name;
        SERVERS[name] = socket;
        socket._sendUpdate = function() {
          var viewer, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = VIEWERS.length; _i < _len; _i++) {
            viewer = VIEWERS[_i];
            _results.push(viewer.emit('update', this._name, INFO[this._name]));
          }
          return _results;
        };
        socket._update = function(callback) {
          return this.emit('info', function(data) {
            INFO[this._name] = data;
            if (callback) {
              callback(data);
            }
            return this._sendUpdate();
          });
        };
        socket._update();
        _UPDATERS[name] = setInterval(function() {
          return socket._update();
        }, config.update_interval * 1000);
        return callback('ack');
      } else {
        if (name !== config.key) {
          callback('Invalid key.');
          return socket.disconnect();
        } else {
          console.log("[register] " + type + " " + socket.id);
          VIEWERS.push(socket);
          return callback('ack');
        }
      }
    });
    socket.on('disconnect', function() {
      if (socket._type === 'server') {
        clearInterval(_UPDATERS[socket._name]);
        _UPDATERS[socket._name] = null;
        INFO[socket._name].status = 'offline';
        return socket._sendUpdate();
      }
    });
    socket.on('getServers', function(callback) {
      var _ref;
      if (_ref = socket.id, __indexOf.call(VIEWERS, _ref) >= 0) {
        return callback(SERVERS);
      } else {
        return callback({
          error: 'Not registered.'
        });
      }
    });
    return socket.on('getInfo', function(name, callback) {
      var _ref,
        _this = this;
      if (_ref = socket.id, __indexOf.call(VIEWERS, _ref) >= 0) {
        if (name in SERVERS) {
          if (config.cache_updates) {
            return callback(INFO[name]);
          } else {
            return SERVERS[name]._update(function(data) {
              return callback(data);
            });
          }
        } else {
          return callback({
            error: 'Server not found!'
          });
        }
      } else {
        return callback({
          error: 'Not registered.'
        });
      }
    });
  });

  server.listen(config.port);

  console.log("-------------------------------------------------------------\n| WatchDog Server [ONLINE]\n| Scripts to include in your application:\n| http://" + config.hostname + "/socket.io/socket.io.js\n| http://" + config.hostname + "/viewer?key=" + config.key + "\n-------------------------------------------------------------");

}).call(this);