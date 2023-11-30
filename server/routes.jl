using Genie.Router
using Genie.Requests

route("/") do
  serve_static_file("index.html")
end

# route("/api/results", method = POST) do
#     message = jsonpayload()
#     run_abm(message["numAgents"], message["numSteps"], message["stubbornRatio"])
# end
