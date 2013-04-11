#!/bin/bash

# Server
echo "#!/usr/bin/env node" > bin/watchdogs_server
coffee -c -p coffee/server.coffee >> bin/watchdogs_server

# Client
echo "#!/usr/bin/env node" > bin/watchdogs_client
coffee -c -p coffee/client.coffee >> bin/watchdogs_client

# Viewer
coffee -c -p coffee/viewer.coffee > lib/viewer.js
