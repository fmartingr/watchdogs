WatchDogs
=========

A simple server monitoring tool written in node and websockets.

## The client-server-viewer on diagram

```
      WATCHDOGS
       CLIENTS                                       +----------------+
  +---------------+                                  |     Viewer     |
  |   Server 1    |+-----+                           +----------------+
  +---------------+      |                                   ^
                         |                                   |
  +---------------+      |                                   | Connect using
  |   Server 2    |+-----|  +----------------+               |      key
  +---------------+      |  |                |               |
                         +->|    Watchdogs   |<--------------+
  +---------------+      |  |     Server     |
  |   Server 3    |+-----|  |                |
  +---------------+      |  +----------------+
                         |
  +---------------+      |
  |   Server 4    |+-----+
  +---------------+
```

**Client:** Is the app you run on the machines you want to get info from.  
**Server:** Is where your clients connect to. The central hub.  
**Viewer:** Is a javascript interface that connect to the server and retrieves info from the machines via websockets.

## Quickstart

Just to see it in action, install from `npm` and get [the example config files](https://github.com/fmartingr/watchdogs/tree/master/config) for client and server.  
Start the server, start the client and open [the example viewer](https://github.com/fmartingr/watchdogs/blob/master/example/viewer.html) html on your browser.

```
$ npm install watchdogs -g
...
$ watchdogs_server /path/to/config.toml
# or
$ watchdogs_client /path/to/config.toml
```

You should see something like this:

![Example viewer in action](http://cdn.fmartingr.com/github/watchdogs.png)

## Usage

Install watchdogs via `npm` on your client and server.

### Server

Configure the server:

```
key = "randomkeyhere"
port = 1337
hostname = "watchdogs.myawesomeserver.lol:1337"
update_interval = 5
cache_updates = true
```
Save it as `watchdogs.toml`, or with another filename if you want (but if you use the first you don't need to specify the config location to the server), and start the server:

```
$ watchdogs_server /path/to/config.toml
   info  - socket.io started
-------------------------------------------------------------
| WatchDogs Server [ONLINE]
| Scripts to include in your application:
| http://watchdogs.myawesomeserver.lol:1337/socket.io/socket.io.js
| http://watchdogs.myawesomeserver.lol:1337/viewer?key=randomkeyhere
-------------------------------------------------------------
```

### Clients

Configure the clients:

```
server = "watchdogs.myawesomeserver.lol:1337"
name = "srv1" # MUST BE UNIQUE!
expose = [
    "hostname",
    "type",
    "platform",
    "arch",
    "uptime",
    "load",
    "memory"
]
```

The `server` variable is the same `hostname` we specified in the server. The `name` must be unique for each client, and the services we want to show. Save it as `watchdogs.toml` or wathever you want, and start the client:

```
$ watchdogs_client /path/to/config.toml
Registered on server.
```

The server must show something like: `[register] server: srv1` and a lot of websockets transactions after that (depeding on the update interval you configured).

Repeat for every client and you just need to conect to your server from your HTML files via websockets and start parsing the data:

```
["srv1", {
        "status": "online",
        "hostname": "workstation.local",
        "type": "Darwin",
        "platform": "darwin",
        "arch": "x64",
        "uptime": 785295,
        "load": [3.08154296875, 2.9853515625, 2.78271484375],
        "total_memory": 8589934592,
        "free_memory": 248696832
    }
]
```

## TODO

[TODO file](https://github.com/fmartingr/watchdogs/blob/master/TODO)

## License

See LICENSE file.