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
using HTTP

include("./data/etiology.jl")
include("./data/incidence.jl")
include("./global/variables.jl")

include("./model/agent.jl")
include("./model/virus.jl")
include("./model/household.jl")
include("./model/workplace.jl")
include("./model/school.jl")
include("./model/initialization.jl")
include("./model/simulation.jl")
include("./model/connections.jl")
include("./model/contacts.jl")

include("./util/haversine.jl")
include("./util/moving_avg.jl")
include("./util/stats.jl")

include("./model.jl")

run_model()
