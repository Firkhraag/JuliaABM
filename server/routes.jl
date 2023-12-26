using Genie
using Genie.Router
using Genie.Requests
using Genie.Renderer.Json
using Plots
using Base64
using HTTP.WebSockets
using JSON
using Base.Threads

using Genie.Assets

using JuliaABM.Model

@async WebSockets.listen("127.0.0.1", 80) do ws
    # @info "Websocket connection has been established"
    payload = JSON.parse(receive(ws))
    Model.main(
        ws,
        parse(Float64, payload["d"]),
        parse.(Float64, payload["s"]),
        -parse.(Float64, payload["t"]),
        parse.(Float64, payload["r"]),
        parse.(Float64, payload["p"]),
        parse(Int, payload["schoolClassClosurePeriod"]),
        parse(Float64, payload["schoolClassClosureThreshold"]),
        parse(Float64, payload["globalWarmingTemperature"]),
    )
    # @info "Websocket connection has ended"
end

route("/") do
    return serve_static_file("index.html")
end
