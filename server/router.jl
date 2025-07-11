staticfiles("public", "/")

@async WebSockets.listen("127.0.0.1", 80) do ws
    # @info "Websocket connection has been established"
    payload = JSON.parse(WebSockets.receive(ws))
    run_model(
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

