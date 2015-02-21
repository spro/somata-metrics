os = require 'os'
somata = require 'somata'

SERIES = process.env.SERIES
INTERVAL = parseInt process.env.INTERVAL || 1000

if !SERIES
    console.log "Requires $SERIES to be set."
    process.exit()
client = new somata.Client

# user, nice, sys
last = [{}, {}, {}, {}]

showSince = ->
    [0, 1, 2, 3].map (cpui) ->
        cpu = os.cpus()[cpui]
        console.log cpu.times
        diffs = {}
        for k, v of cpu.times
            diffs[k] = v - last[cpui][k]
        change = sum(v for k, v of diffs)
        console.log change
        per = (change-diffs.idle)/change
        console.log '\t', per
        last[cpui] = cpu.times

        if per > 0
            point = {value: per}
            client.remote 'influx', 'log', SERIES, point, ->

sum = (l) -> l.reduce (a, b) -> a + b

setInterval showSince, INTERVAL
