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

**Client: ** Is the app you run on the machines you want to get info from.  
**Server: ** Is where your clients connect to. The central hub.  
**Viewer: ** Is a javascript interface that connect to the server and retrieves info from the machines.

## Usage

TODO

## TODO

TODO
