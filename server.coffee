# Requirements
fs = require 'fs'
toml = require 'tomljs'
io = require 'socket.io'

# Globals
servers = {}
viewers = []

# Reading the config
try
    file = fs.readFileSync('config.toml').toString()
    config = toml file
    #console.log config
catch error
    console.log 'Error: Configuration file not found!'
    process.exit(-1)

# Startup
console.log 'server stuff'
server = io.listen(3333)

# Connection handling
server.on 'connection', (socket) ->
    socket.on 'register', (type, name, callback) ->
        if type == 'server'
            console.log "[register] #{type}: #{name}"
            servers[name] = socket
            callback 'ack'
        else if type == 'viewer'
            if name != config.key
                socket.disconnect()
            else
                console.log "[register] #{type} #{socket.id}"
                viewers.push socket.id
                callback 'ack'

    socket.on 'get_info', (options, callback) ->
        if socket.id in viewers
            server = options['server']
            servers[server].emit 'info', (data) =>
                callback(data)
        else
            callback({ error: 'You need to register first!'})
