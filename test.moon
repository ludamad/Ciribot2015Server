http = require "socket.http"
ltn12 = require "ltn12"
json = require "json"
require "misc"

request = (body) ->
    url = "http://localhost:8080/#{body.url}"
    body.url = nil
    respbody = {} 
    reqbody = json.encode(body)
    ok = http.request {
        method: "POST",
        :url,
        source: ltn12.source.string(reqbody),
        headers: {
            "Accept": "*/*",
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json",
            "content-length": string.len(reqbody)
        }
        sink: ltn12.sink.table(respbody)
    }
    if not ok
        error("#{url} was not ok!")
    return table.concat(respbody, "\n")


pretty request {url: "/levels/stats"}



