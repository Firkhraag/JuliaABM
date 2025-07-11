using Oxygen
using HTTP
using Base.Threads
using Random
using Dates
using DelimitedFiles
using Distributions
using DataFrames
using CSV
using JLD2
using XLSX
using JSON
using Plots
using Base64

include("../src/data/etiology.jl")
include("../src/data/incidence.jl")
include("../src/data/moscow.jl")
include("../src/global/variables.jl")

include("../src/model/agent.jl")
include("../src/model/virus.jl")
include("../src/model/household.jl")
include("../src/model/workplace.jl")
include("../src/model/school.jl")
include("../src/model/initialization.jl")
include("../src/model/simulation.jl")
include("../src/model/connections.jl")
include("../src/model/contacts.jl")

include("../src/util/haversine.jl")
include("../src/util/moving_avg.jl")
include("../src/util/stats.jl")

include("../src/model.jl")

include("./router.jl")

serve(port=8080)
