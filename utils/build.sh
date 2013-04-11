#!/bin/bash
coffee -c -p coffee/server.coffee > bin/watchdogs_server.js
coffee -c -p coffee/client.coffee > bin/watchdogs_client.js
coffee -c -p coffee/viewer.coffee > lib/viewer.js
