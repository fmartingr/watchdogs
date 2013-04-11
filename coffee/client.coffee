# Requirements
fs = require 'fs'
toml = require 'tomljs'
io = require 'socket.io-client'
os = require 'os'

# Reading the config

config_file = 'watchdogs.toml'
if process.argv[2]
    config_file = process.argv[2]

try
    file = fs.readFileSync(config_file).toString()
    config = toml file
catch error
    console.log 'Error: Configuration file not found!'
    process.exit(-1)

# Functions 
getSystemInfo = ->
    sysinfo = {}

    sysinfo.status = 'online'

    if 'hostname' in config.expose
        sysinfo.hostname = os.hostname()
    
    if 'type' in config.expose
        sysinfo.type = os.type()
        
    if 'platform' in config.expose
        sysinfo.platform = os.platform()
        
    if 'arch' in config.expose
        sysinfo.arch = os.arch()
        
    if 'uptime' in config.expose
        sysinfo.uptime = os.uptime()
        
    if 'load' in config.expose
        sysinfo.load = os.loadavg()
        
    if 'memory' in config.expose
        sysinfo.total_memory = os.totalmem()
        sysinfo.free_memory = os.freemem()
        
    return sysinfo

# Startup
socket = io.connect 'http://' + config.server
#io.transports = ['xhr-polling'] # AppFog ?

# Connection handling and register on server
socket.on 'connect', ->
    socket.emit 'register', 'server', config.name, (res) ->
        if res == 'ack'
            console.log 'Registered on server.'

# Methods
socket.on 'info', (callback) ->
    callback getSystemInfo()

# Other
socket.on 'disconnect', ->
    # Stuff

socket.on 'error', (error) ->
    console.log 'ERROR: Could not connect to server: ' + error
