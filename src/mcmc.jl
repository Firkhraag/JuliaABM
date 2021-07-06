using Base.Threads
using Distributions
using Random
using DelimitedFiles
using Statistics

include("model/virus.jl")
include("model/collective.jl")
include("model/agent.jl")
include("model/initialization.jl")
include("model/simulation.jl")
include("model/r0.jl")
include("model/contacts.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

include("util/reset.jl")

function f(x, mu, sigma)
    dist = Normal(mu, sigma)
    return cdf(dist, x + 0.5) - cdf(dist, x - 0.5)
end

function log_g(x, mu, sigma)
    -log(sqrt(2 * pi) * sigma) - 0.5 * ((x - mu) / sigma)^2
end

function main()

    println("Initialization...")

    num_threads = nthreads()

    num_people = 9897284
    # 4 threads
    start_agent_ids = Int[1, 2442913, 4892801, 7392381]
    end_agent_ids = Int[2442912, 4892800, 7392380, 9897284]

    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.32, 0.16, 365),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.32, 0.16, 365),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.5, 0.3, 60),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.5, 0.3, 60),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.5, 0.3, 90),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.8, 0.5, 0.3, 90),
        Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.5, 0.3, 365)]

    infectivities = Array{Float64,4}(undef, 7, 7, 13, 21)
    for days_infected in -6:14
        days_infected_index = days_infected + 7
        for infection_period in 2:14
            infection_period_index = infection_period - 1
            for incubation_period in 1:7
                min_days_infected = 1 - incubation_period
                mean_infectivities = [4.6, 4.7, 3.5, 6.0, 4.1, 4.8, 4.93]
                for i in 1:7
                    if (days_infected >= min_days_infected) && (days_infected <= infection_period)
                        infectivities[i, incubation_period, infection_period_index, days_infected_index] = get_infectivity(
                            days_infected, incubation_period, infection_period, mean_infectivities[i])
                    end
                end
            end
        end
    end

    # Число домохозяйств каждого типа по районам
    district_households = get_district_households()
    # Число людей в каждой группе по районам
    district_people = get_district_people()
    # Число людей в домохозяйствах по районам
    district_people_households = get_district_people_households()

    # Вероятность случайного инфицирования
    etiology = get_random_infection_probabilities()

    # Номера районов для MPI процессов
    district_nums = get_district_nums()

    # Температура воздуха, начиная с 1 января
    temperature = get_air_temperature()

    # Минимальная температура воздуха
    min_temp = -7.2
    # Max - Min температура
    max_min_temp = 26.6

    etiology_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "etiology_ratio.csv"), ',', Float64, '\n')

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0 = infected_data_0[2:53, 21:27]
    infected_data_0_1 = etiology_data[1, :]' .* infected_data_0'
    infected_data_0_2 = etiology_data[2, :]' .* infected_data_0'
    infected_data_0_3 = etiology_data[3, :]' .* infected_data_0'
    infected_data_0_4 = etiology_data[4, :]' .* infected_data_0'
    infected_data_0_5 = etiology_data[5, :]' .* infected_data_0'
    infected_data_0_6 = etiology_data[6, :]' .* infected_data_0'
    infected_data_0_7 = etiology_data[7, :]' .* infected_data_0'
    infected_data_0_viruses = cat(
        infected_data_0_1,
        infected_data_0_2,
        infected_data_0_3,
        infected_data_0_4,
        infected_data_0_5,
        infected_data_0_6,
        infected_data_0_7,
        dims = 3)

    infected_data_3 = infected_data_3[2:53, 21:27]
    infected_data_3_1 = etiology_data[1, :]' .* infected_data_3'
    infected_data_3_2 = etiology_data[2, :]' .* infected_data_3'
    infected_data_3_3 = etiology_data[3, :]' .* infected_data_3'
    infected_data_3_4 = etiology_data[4, :]' .* infected_data_3'
    infected_data_3_5 = etiology_data[5, :]' .* infected_data_3'
    infected_data_3_6 = etiology_data[6, :]' .* infected_data_3'
    infected_data_3_7 = etiology_data[7, :]' .* infected_data_3'
    infected_data_3_viruses = cat(
        infected_data_3_1,
        infected_data_3_2,
        infected_data_3_3,
        infected_data_3_4,
        infected_data_3_5,
        infected_data_3_6,
        infected_data_3_7,
        dims = 3)

    infected_data_7 = infected_data_7[2:53, 21:27]
    infected_data_7_1 = etiology_data[1, :]' .* infected_data_7'
    infected_data_7_2 = etiology_data[2, :]' .* infected_data_7'
    infected_data_7_3 = etiology_data[3, :]' .* infected_data_7'
    infected_data_7_4 = etiology_data[4, :]' .* infected_data_7'
    infected_data_7_5 = etiology_data[5, :]' .* infected_data_7'
    infected_data_7_6 = etiology_data[6, :]' .* infected_data_7'
    infected_data_7_7 = etiology_data[7, :]' .* infected_data_7'
    infected_data_7_viruses = cat(
        infected_data_7_1,
        infected_data_7_2,
        infected_data_7_3,
        infected_data_7_4,
        infected_data_7_5,
        infected_data_7_6,
        infected_data_7_7,
        dims = 3)

    infected_data_15 = infected_data_15[2:53, 21:27]
    infected_data_15_1 = etiology_data[1, :]' .* infected_data_15'
    infected_data_15_2 = etiology_data[2, :]' .* infected_data_15'
    infected_data_15_3 = etiology_data[3, :]' .* infected_data_15'
    infected_data_15_4 = etiology_data[4, :]' .* infected_data_15'
    infected_data_15_5 = etiology_data[5, :]' .* infected_data_15'
    infected_data_15_6 = etiology_data[6, :]' .* infected_data_15'
    infected_data_15_7 = etiology_data[7, :]' .* infected_data_15'
    infected_data_15_viruses = cat(
        infected_data_15_1,
        infected_data_15_2,
        infected_data_15_3,
        infected_data_15_4,
        infected_data_15_5,
        infected_data_15_6,
        infected_data_15_7,
        dims = 3)

    infected_data_0_viruses_mean = mean(infected_data_0_viruses, dims = 1)[1, :, :]
    infected_data_3_viruses_mean = mean(infected_data_3_viruses, dims = 1)[1, :, :]
    infected_data_7_viruses_mean = mean(infected_data_7_viruses, dims = 1)[1, :, :]
    infected_data_15_viruses_mean = mean(infected_data_15_viruses, dims = 1)[1, :, :]

    num_infected_age_groups_viruses_mean = cat(
        infected_data_0_viruses_mean,
        infected_data_3_viruses_mean,
        infected_data_7_viruses_mean,
        infected_data_15_viruses_mean,
        dims = 3,
    )

    infected_data_0_viruses_sd = std(infected_data_0_viruses, dims = 1)[1, :, :]
    infected_data_3_viruses_sd = std(infected_data_3_viruses, dims = 1)[1, :, :]
    infected_data_7_viruses_sd = std(infected_data_7_viruses, dims = 1)[1, :, :]
    infected_data_15_viruses_sd = std(infected_data_15_viruses, dims = 1)[1, :, :]

    num_infected_age_groups_viruses_sd = cat(
        infected_data_0_viruses_sd,
        infected_data_3_viruses_sd,
        infected_data_7_viruses_sd,
        infected_data_15_viruses_sd,
        dims = 3,
    )

    agents = Array{Agent, 1}(undef, num_people)
    thread_rng = [MersenneTwister(i) for i = 1:num_threads]
    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, viruses, infectivities, district_households, district_people,
            district_people_households, district_nums)
    end

    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))

    duration_parameter = duration_parameter_array[size(duration_parameter_array)[1]]
    susceptibility_parameters = [
        susceptibility_parameter_1_array[size(susceptibility_parameter_1_array)[1]],
        susceptibility_parameter_2_array[size(susceptibility_parameter_2_array)[1]],
        susceptibility_parameter_3_array[size(susceptibility_parameter_3_array)[1]],
        susceptibility_parameter_4_array[size(susceptibility_parameter_4_array)[1]],
        susceptibility_parameter_5_array[size(susceptibility_parameter_5_array)[1]],
        susceptibility_parameter_6_array[size(susceptibility_parameter_6_array)[1]],
        susceptibility_parameter_7_array[size(susceptibility_parameter_7_array)[1]],
    ]
    temperature_parameters = -[
        temperature_parameter_1_array[size(temperature_parameter_1_array)[1]],
        temperature_parameter_2_array[size(temperature_parameter_2_array)[1]],
        temperature_parameter_3_array[size(temperature_parameter_3_array)[1]],
        temperature_parameter_4_array[size(temperature_parameter_4_array)[1]],
        temperature_parameter_5_array[size(temperature_parameter_5_array)[1]],
        temperature_parameter_6_array[size(temperature_parameter_6_array)[1]],
        temperature_parameter_7_array[size(temperature_parameter_7_array)[1]],
    ]

    accept_num = 0
    local_rejected_num = 0

    deltas = [0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]

    temp_influences = Array{Float64,2}(undef, 7, 365)
    year_day = 213
    for i in 1:365
        current_temp = (temperature[year_day] - min_temp) / max_min_temp
        for v in 1:7
            temp_influences[v, i] = temperature_parameters[v] * current_temp + 1.0
        end
        if year_day == 365
            year_day = 1
        else
            year_day += 1
        end
    end

    @time num_infected_age_groups_viruses = run_simulation(
        num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
        temp_influences, duration_parameter,
        susceptibility_parameters, etiology, num_infected_age_groups_viruses_mean, false)

    S_abs = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean))
    S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

    prob_prev_age_groups_viruses = zeros(Float64, 7, 4, 52)
    for i in 1:52
        for j in 1:4
            for k in 1:7
                prob_prev_age_groups_viruses[k, j, i] = log_g(num_infected_age_groups_viruses[i, k, j], num_infected_age_groups_viruses_mean[i, k, j], num_infected_age_groups_viruses_sd[i, k, j])
            end
        end
    end

    prev_nums = copy(num_infected_age_groups_viruses)

    n = size(duration_parameter_array)[1]

    open("mcmc/output.txt", "a") do io
        println(io, "n = ", n - 1)
        println(io, "S_abs: ", S_abs)
        println(io, "S_square: ", S_square)
        println(io)
    end

    N = 1000
    while n <= N
        duration_parameter_candidate = exp(rand(Normal(log(duration_parameter_array[size(duration_parameter_array)[1]]), deltas[1])))

        susceptibility_parameter_1_candidate = exp(rand(Normal(log(susceptibility_parameter_1_array[size(susceptibility_parameter_1_array)[1]]), deltas[2])))
        susceptibility_parameter_2_candidate = exp(rand(Normal(log(susceptibility_parameter_2_array[size(susceptibility_parameter_1_array)[1]]), deltas[3])))
        susceptibility_parameter_3_candidate = exp(rand(Normal(log(susceptibility_parameter_3_array[size(susceptibility_parameter_1_array)[1]]), deltas[4])))
        susceptibility_parameter_4_candidate = exp(rand(Normal(log(susceptibility_parameter_4_array[size(susceptibility_parameter_1_array)[1]]), deltas[5])))
        susceptibility_parameter_5_candidate = exp(rand(Normal(log(susceptibility_parameter_5_array[size(susceptibility_parameter_1_array)[1]]), deltas[6])))
        susceptibility_parameter_6_candidate = exp(rand(Normal(log(susceptibility_parameter_6_array[size(susceptibility_parameter_1_array)[1]]), deltas[7])))
        susceptibility_parameter_7_candidate = exp(rand(Normal(log(susceptibility_parameter_7_array[size(susceptibility_parameter_1_array)[1]]), deltas[8])))

        x = temperature_parameter_1_array[size(temperature_parameter_1_array)[1]]
        y = rand(Normal(log(x / (1 - x)), deltas[9]))
        temperature_parameter_1_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_2_array[size(temperature_parameter_2_array)[1]]
        y = rand(Normal(log(x / (1 - x)), deltas[10]))
        temperature_parameter_2_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_3_array[size(temperature_parameter_3_array)[1]]
        y = rand(Normal(log(x / (1 - x)), deltas[11]))
        temperature_parameter_3_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_4_array[size(temperature_parameter_4_array)[1]]
        y = rand(Normal(log(x / (1 - x)), deltas[12]))
        temperature_parameter_4_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_5_array[size(temperature_parameter_5_array)[1]]
        y = rand(Normal(log(x / (1 - x)), deltas[13]))
        temperature_parameter_5_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_6_array[size(temperature_parameter_6_array)[1]]
        y = rand(Normal(log(x / (1 - x)), deltas[14]))
        temperature_parameter_6_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_7_array[size(temperature_parameter_7_array)[1]]
        y = rand(Normal(log(x / (1 - x)), deltas[15]))
        temperature_parameter_7_candidate = exp(y) / (1 + exp(y))
        
        duration_parameter = duration_parameter_candidate
        susceptibility_parameters = [
            susceptibility_parameter_1_candidate,
            susceptibility_parameter_2_candidate,
            susceptibility_parameter_3_candidate,
            susceptibility_parameter_4_candidate,
            susceptibility_parameter_5_candidate,
            susceptibility_parameter_6_candidate,
            susceptibility_parameter_7_candidate,
        ]
        temperature_parameters = -[
            temperature_parameter_1_candidate,
            temperature_parameter_2_candidate,
            temperature_parameter_3_candidate,
            temperature_parameter_4_candidate,
            temperature_parameter_5_candidate,
            temperature_parameter_6_candidate,
            temperature_parameter_7_candidate,
        ]

        temp_influences = Array{Float64,2}(undef, 7, 365)
        year_day = 213
        for i in 1:365
            current_temp = (temperature[year_day] - min_temp) / max_min_temp
            for v in 1:7
                temp_influences[v, i] = temperature_parameters[v] * current_temp + 1.0
            end
            if year_day == 365
                year_day = 1
            else
                year_day += 1
            end
        end

        @time num_infected_age_groups_viruses = run_simulation(
            num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
            temp_influences, duration_parameter,
            susceptibility_parameters, etiology, num_infected_age_groups_viruses_mean, false)

        S_abs = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean))
        S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

        prob_age_groups_viruses = zeros(Float64, 7, 4, 52)
        for i in 1:52
            for j in 1:4
                for k in 1:7
                    prob_age_groups_viruses[k, j, i] = log_g(num_infected_age_groups_viruses[i, k, j], num_infected_age_groups_viruses_mean[i, k, j], num_infected_age_groups_viruses_sd[i, k, j])
                end
            end
        end

        accept_prob = 0.0
        for i in 1:52
            for j in 1:4
                for k in 1:7
                    accept_prob += prob_age_groups_viruses[k, j, i] - prob_prev_age_groups_viruses[k, j, i]
                end
            end
        end
        accept_prob_final = min(1.0, exp(accept_prob))

        open("mcmc/output.txt", "a") do io
            println(io, "n = ", n)
            println(io, "Accept prob exp: ", accept_prob)
            println(io, "Accept prob: ", accept_prob_final)
            println(io, "S_abs: ", S_abs)
            println(io, "S_square: ", S_square)
            println(io, "Dur: ", duration_parameter_candidate)
            println(io, "Suscept: ", [
                susceptibility_parameter_1_candidate,
                susceptibility_parameter_2_candidate,
                susceptibility_parameter_3_candidate,
                susceptibility_parameter_4_candidate,
                susceptibility_parameter_5_candidate,
                susceptibility_parameter_6_candidate,
                susceptibility_parameter_7_candidate])
            println(io, "Temp: ", [
                temperature_parameter_1_candidate,
                temperature_parameter_2_candidate,
                temperature_parameter_3_candidate,
                temperature_parameter_4_candidate,
                temperature_parameter_5_candidate,
                temperature_parameter_6_candidate,
                temperature_parameter_7_candidate])
            println(io)
        end

        if rand(Float64) < accept_prob_final || local_rejected_num > 10
            push!(duration_parameter_array, duration_parameter_candidate)

            push!(susceptibility_parameter_1_array, susceptibility_parameter_1_candidate)
            push!(susceptibility_parameter_2_array, susceptibility_parameter_2_candidate)
            push!(susceptibility_parameter_3_array, susceptibility_parameter_3_candidate)
            push!(susceptibility_parameter_4_array, susceptibility_parameter_4_candidate)
            push!(susceptibility_parameter_5_array, susceptibility_parameter_5_candidate)
            push!(susceptibility_parameter_6_array, susceptibility_parameter_6_candidate)
            push!(susceptibility_parameter_7_array, susceptibility_parameter_7_candidate)

            push!(temperature_parameter_1_array, temperature_parameter_1_candidate)
            push!(temperature_parameter_2_array, temperature_parameter_2_candidate)
            push!(temperature_parameter_3_array, temperature_parameter_3_candidate)
            push!(temperature_parameter_4_array, temperature_parameter_4_candidate)
            push!(temperature_parameter_5_array, temperature_parameter_5_candidate)
            push!(temperature_parameter_6_array, temperature_parameter_6_candidate)
            push!(temperature_parameter_7_array, temperature_parameter_7_candidate)

            prob_age_groups_viruses = copy(prob_prev_age_groups_viruses)

            accept_num += 1
            local_rejected_num = 0
        else
            push!(duration_parameter_array, duration_parameter_array[size(duration_parameter_array)[1]])

            push!(susceptibility_parameter_1_array, susceptibility_parameter_1_array[size(susceptibility_parameter_1_array)[1]])
            push!(susceptibility_parameter_2_array, susceptibility_parameter_2_array[size(susceptibility_parameter_2_array)[1]])
            push!(susceptibility_parameter_3_array, susceptibility_parameter_3_array[size(susceptibility_parameter_3_array)[1]])
            push!(susceptibility_parameter_4_array, susceptibility_parameter_4_array[size(susceptibility_parameter_4_array)[1]])
            push!(susceptibility_parameter_5_array, susceptibility_parameter_5_array[size(susceptibility_parameter_5_array)[1]])
            push!(susceptibility_parameter_6_array, susceptibility_parameter_6_array[size(susceptibility_parameter_6_array)[1]])
            push!(susceptibility_parameter_7_array, susceptibility_parameter_7_array[size(susceptibility_parameter_7_array)[1]])

            push!(temperature_parameter_1_array, temperature_parameter_1_array[size(temperature_parameter_1_array)[1]])
            push!(temperature_parameter_2_array, temperature_parameter_2_array[size(temperature_parameter_2_array)[1]])
            push!(temperature_parameter_3_array, temperature_parameter_3_array[size(temperature_parameter_3_array)[1]])
            push!(temperature_parameter_4_array, temperature_parameter_4_array[size(temperature_parameter_4_array)[1]])
            push!(temperature_parameter_5_array, temperature_parameter_5_array[size(temperature_parameter_5_array)[1]])
            push!(temperature_parameter_6_array, temperature_parameter_6_array[size(temperature_parameter_6_array)[1]])
            push!(temperature_parameter_7_array, temperature_parameter_7_array[size(temperature_parameter_7_array)[1]])
            
            local_rejected_num += 1
        end

        if n % 10 == 0
            writedlm(joinpath(@__DIR__, "..", "mcmc", "tables", "duration_parameter_array.csv"), duration_parameter_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_1_array.csv"), susceptibility_parameter_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_2_array.csv"), susceptibility_parameter_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_3_array.csv"), susceptibility_parameter_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_4_array.csv"), susceptibility_parameter_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_5_array.csv"), susceptibility_parameter_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_6_array.csv"), susceptibility_parameter_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_7_array.csv"), susceptibility_parameter_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "temperature_parameter_1_array.csv"), temperature_parameter_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "temperature_parameter_2_array.csv"), temperature_parameter_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "temperature_parameter_3_array.csv"), temperature_parameter_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "temperature_parameter_4_array.csv"), temperature_parameter_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "temperature_parameter_5_array.csv"), temperature_parameter_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "temperature_parameter_6_array.csv"), temperature_parameter_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "mcmc", "tables", "temperature_parameter_7_array.csv"), temperature_parameter_7_array, ',')
        end

        reset_population(
            agents,
            num_threads,
            thread_rng,
            start_agent_ids,
            end_agent_ids,
            infectivities,
            viruses)
        
        n += 1
        println("Accept rate:", accept_num / n)
    end
end

main()
