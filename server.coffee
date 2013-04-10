# Requirements
fs = require 'fs'
toml = require 'tomljs'
express = require 'express'
http = require 'http'
socketio = require 'socket.io'
fs = require 'fs'

# Server
app = express()
server = http.createServer app
io = socketio.listen server

# Globals
SERVERS     = {}  # Registed servers
INFO        = {}  # Cached info of servers
VIEWERS     = []  # Registed viewers
_UPDATERS   = {}  # setTimeout IDs

# Reading the config
try
    file = fs.readFileSync('config.toml').toString()
    config = toml file
    #console.log config
catch error
    console.log 'Error: Configuration file not found!'
    process.exit(-1)

# Startup
app.get '/viewer', (request, response) ->
    if request.query.key == config.key
        file = __dirname + '/viewer.js'
        handler = fs.createReadStream file

        handler.pipe response
    else
        response.end "Invalid key."

# Connection handling
io.on 'connection', (socket) ->
    socket.on 'register', (type, name, callback) ->
        if type == 'server'
            console.log "[register] #{type}: #{name}"
            socket._name = name
            SERVERS[name] = socket

            socket._update = (callback) ->
                this.emit 'info', (data) ->
                    INFO[this._name] = data
                    if callback
                        callback data
                    for viewer in VIEWERS
                        viewer.emit 'update', this._name, data

            _UPDATERS[name] = setInterval ->
                socket._update()
            , config.update_interval*1000

            callback 'ack'
        else
            if name != config.key
                callback 'Invalid key.'
                socket.disconnect()
            else
                console.log "[register] #{type} #{socket.id}"
                VIEWERS.push socket
                callback 'ack'

    socket.on 'disconnect', ->
        clearInterval _UPDATERS[socket._name]
        _UPDATERS[socket._name] = null

    socket.on 'getServers', (callback) ->
        if socket.id in VIEWERS
            callback(SERVERS)
        else
            callback error: 'Not registered.'

    socket.on 'getInfo', (name, callback) ->
        if socket.id in VIEWERS
            if name of SERVERS
                if config.cache_updates
                    callback INFO[name]
                else
                    SERVERS[name]._update (data) =>
                        callback(data)
            else
                callback error: 'Server not found!'
        else
            callback error: 'Not registered.'

# Listen
server.listen config.port

console.log """
            -------------------------------------------------------------
            | WatchDog Server [ONLINE]
            | Scripts to include in your application:
            | http://#{config.hostname}/socket.io/socket.io.js
            | http://#{config.hostname}/viewer?key=#{config.key}
            -------------------------------------------------------------
            """
