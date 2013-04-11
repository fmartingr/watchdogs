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

config_file = 'watchdogs.toml'
if process.argv[2]
    config_file = process.argv[2]

# Globals
SERVERS     = {}  # Registed servers
INFO        = {}  # Cached info of servers
VIEWERS     = []  # Registed viewers
_UPDATERS   = {}  # setTimeout IDs

# Reading the config
try
    file = fs.readFileSync(config_file).toString()
    config = toml file
    #console.log config
catch error
    console.log 'Error: Configuration file not found!'
    process.exit -1

# Startup
app.get '/viewer', (request, response) ->
    if request.query.key == config.key
        file = __dirname + '/../lib/viewer.js'
        handler = fs.createReadStream file

        handler.pipe response
    else
        response.end "Invalid key."

# Connection handling
io.on 'connection', (socket) ->
    socket.on 'register', (type, name, callback) ->
        socket._type = type
        if type == 'server'
            console.log "[register] #{type}: #{name}"
            socket._name = name
            SERVERS[name] = socket

            socket._sendUpdate = ->
                for viewer in VIEWERS
                    viewer.emit 'update', this._name, INFO[this._name]

            socket._update = (callback) ->
                this.emit 'info', (data) ->
                    INFO[this._name] = data
                    if callback
                        callback data
                    this._sendUpdate()
            socket._update()
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
        if socket._type == 'server'
            clearInterval _UPDATERS[socket._name]
            _UPDATERS[socket._name] = null
            INFO[socket._name].status = 'offline'
            socket._sendUpdate()

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
            | WatchDogs Server [ONLINE]
            | Scripts to include in your application:
            | http://#{config.hostname}/socket.io/socket.io.js
            | http://#{config.hostname}/viewer?key=#{config.key}
            -------------------------------------------------------------
            """
