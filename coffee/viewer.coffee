
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
            if name of this.servers
                this.servers[name].updateInfo(info)
            else
                this.servers[name] = new Server(info)
            this.onupdate name

    # Handlers
    onupdate: (name) ->


class Server
    constructor: (info) ->
        this.updateInfo info

    updateInfo: (info) ->
        this.info = info

    # Lazy methods
    getStatus: ->
        this.get 'status'

    getHostname: ->
        this.get 'hostname'

    getType: ->
        this.get 'type'

    getPlatform: ->
        this.get 'platform'

    getArch: ->
        this.get 'arch'

    getUptime: ->
        this.parseTime this.get('uptime')

    getLoad: ->
        result = null
        load = this.get 'load'
        if load
            one = load[0].toFixed(2)
            five = load[1].toFixed(2)
            fifteen = load[2].toFixed(2)
            result = "#{one}, #{five}, #{fifteen}"
        return result


    getTotalMemory: ->
        this.parseBytes this.get('total_memory')

    getFreeMemory: ->
        this.parseBytes this.get('free_memory')

    getMemory: ->
        "#{this.getFreeMemory()}/#{this.getTotalMemory()}"

    # Raw methods
    get: (key) ->
        result = null
        if key of this.info
            result = this.info[key]
        return result

    # Parsers
    # http://bateru.com/news/2011/08/code-of-the-day-javascript-convert-bytes-to-kb-mb-gb-etc/
    parseBytes: (bytes, decimals=2) ->
        if isNaN bytes
            return
        units = ['bytes', 'KB', 'MB', 'GB', 'TB', 'PB']
        exponents = Math.floor Math.log(+bytes)/Math.log(2)

        if exponents < 1
            exponents = 0

        i = Math.floor exponents / 10
        bytes = +bytes / Math.pow(2, 10*i)

        # Round to three decimals
        if bytes.toString().length > bytes.toFixed(decimals).toString().length
            bytes = bytes.toFixed(decimals)

        return "#{bytes} #{units[i]}"

    parseTime: (time) ->
        hours = Math.floor(time / 3600)
        time %= 3600
        minutes = Math.floor(time / 60)
        seconds = Math.floor(time % 60)
        result = ''
        if hours > 0
            result = "#{result}#{hours}h"
        if minutes > 0
            result = "#{result} #{minutes}m"
        result = "#{result} #{seconds}s"


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
