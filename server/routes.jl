using Genie.Router
using Genie.Requests
using Plots
using Statistics

# function moving_average(X::Vector, numofele::Int)
#     BackDelta = div(numofele,2) 
#     ForwardDelta = isodd(numofele) ? div(numofele,2) : div(numofele,2) - 1
#     len = length(X)
#     Y = similar(X)
#     for n = 1:len
#         lo = max(1,n - BackDelta)
#         hi = min(len,n + ForwardDelta)
#         Y[n] = mean(X[lo:hi])
#     end
#     return Y
# end

mutable struct Agent
    state::Int
    personality::Char

    function Agent(
        state::Int,
        personality::Char
    )
        return new(state, personality)
    end
end

function initialize_population(
    N::Int,
    stubborn_prob::Float64 = 0.5,
)::Vector{Agent}
    states = [0, 1]
    personalities = ['F', 'S']

    population = Vector{Agent}()
    for i = 1:N
        agent = Agent(rand(states), rand(Float64) < stubborn_prob ? 'S' : 'F')
        push!(population, agent)
    end
    return population
end

function count_ones(
    population::Vector{Agent}
)::Float64
    t = 0.0
    for agent in population
        if agent.state == 1
            t += 1
        end
    end
    return t / length(population)
end

function choose_pair(
    population::Vector{Agent}
)::Tuple{Agent, Agent}
    i = rand(1:length(population))
    j = rand(1:length(population))
    while i == j
        j = rand(1:length(population))
    end
    return population[i], population[j]
end

function interact(
    listener::Agent,
    producer::Agent
)
    if (listener.state != producer.state) && (listener.personality != 'S')
        listener.state = producer.state
    end
end

function run_abm(population_size::Int, num_steps::Int, stubborn_ratio::Float64)
    # population_size = 100
    # num_steps = 2000
    population = initialize_population(population_size, stubborn_ratio)
    proportions_ones = []

    # for i = 1:num_steps
    #     listener, producer = choose_pair(population)
    #     interact(listener, producer)
    #     push!(proportions_ones, count_ones(population))
    # end

    # xlabel_name = "Число шагов"
    # ylabel_name = "Доля [1]"

    # ones_plot = plot(
    #     1:num_steps,
    #     proportions_ones,
    #     lw = 1.5,
    #     grid = true,
    #     legend = false,
    #     color = :black,
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    #     xlabel = xlabel_name,
    #     ylabel = ylabel_name,
    # )
end

route("/") do
  serve_static_file("index.html")
end

route("/api/results", method = POST) do
    message = jsonpayload()
    run_abm(message["numAgents"], message["numSteps"], message["stubbornRatio"])
end
