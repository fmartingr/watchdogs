
# From: http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values
getParameterByName = (name, url) ->
    param = ''
    name = name.replace(/[\[]/, "\\\[").replace /[\]]/, "\\\]"
    regexS = "[\\?&]" + name + "=([^&#]*)"
    regex = new RegExp regexS
    results = regex.exec url
    if results != null
        param = decodeURIComponent results[1].replace(/\+/g, " ")
    return param

getHostInfo = ->
    hostname = ''
    scripts = document.getElementsByTagName 'script'
    for script in scripts
        if script.src.indexOf('/viewer') > 0
            hostname = script.src.substr 0, script.src.lastIndexOf('/')
            key = getParameterByName 'key', script.src
            break
    return hostname: hostname, key: key

watchdogs = 
    socket: null
    servers: {}

    getServers: ->
        this.socket.emit 'getServers'

    getServerInfo: (name) ->
        this.socket.emit 'getInfo', name, (result) =>
            this.servers[name] = result
            this.onupdate name

    # Startup
    start: ->
        this.socket.on 'update', (name, info) =>
            this.servers[name] = info
            this.onupdate name

    # Handlers
    onupdate: (name) ->
        console.log "Server updated: #{name}"


window.addEventListener 'DOMContentLoaded', ->
    server = getHostInfo()
    socket = io.connect(server.hostname)
    socket.on 'connect', ->
        socket.emit 'register', 'viewer', server.key, (res) ->
            if res != 'ack'
                console.error 'Error registering on server.'
            else
                loadEvent = document.createEvent "Event"
                window.watchdogs = watchdogs
                window.watchdogs.socket = socket
                window.watchdogs.start()
                loadEvent.initEvent "WatchdogsLoaded", true, true
                document.dispatchEvent loadEvent
