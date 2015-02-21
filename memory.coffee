{exec} = require 'child_process'
somata = require 'somata'

SERIES = process.env.SERIES
INTERVAL = parseInt process.env.INTERVAL || 1000

if !SERIES
    console.log "Requires $SERIES to be set."
    process.exit()
client = new somata.Client

getMem = (cb) ->
    exec 'free', (err, stdout, stderr) ->
        chunks = stdout.split('\n').map (line) ->
            line.split(/\s+/)
        total = parseFloat chunks[1][1]
        used = parseFloat chunks[1][2]
        per = used/total
        cb null, per

showMem = ->
    getMem (err, per) ->
        point = {value: per}
        client.remote 'influx', 'log', SERIES, point, ->

setInterval showMem, INTERVAL
