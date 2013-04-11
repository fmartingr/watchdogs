#!/bin/bash
coffee -c -p coffee/server.coffee > bin/watchdog_server.js
coffee -c -p coffee/client.coffee > bin/watchdog_client.js
coffee -c -p coffee/viewer.coffee > lib/viewer.js
