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

    infected_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_mean = mean(infected_data[42:45, 2:53], dims = 1)[1, :]
    infected_data_mean_0 = mean(infected_data_0[2:53, 24:27], dims = 2)[:, 1]
    infected_data_mean_3 = mean(infected_data_3[2:53, 24:27], dims = 2)[:, 1]
    infected_data_mean_7 = mean(infected_data_7[2:53, 24:27], dims = 2)[:, 1]
    infected_data_mean_15 = mean(infected_data_15[2:53, 24:27], dims = 2)[:, 1]

    num_infected_age_groups_mean = cat(
        reshape(infected_data_mean_0, (1, length(infected_data_mean_0))),
        reshape(infected_data_mean_3, (1, length(infected_data_mean_3))),
        reshape(infected_data_mean_7, (1, length(infected_data_mean_7))),
        reshape(infected_data_mean_15, (1, length(infected_data_mean_15))),
        dims = 1)

    num_infected_age_groups_sd = sqrt.(num_infected_age_groups_mean)

    etiology_infected_data_mean_1 = infected_data_mean .* etiology_data[1, :]
    etiology_infected_data_mean_2 = infected_data_mean .* etiology_data[2, :]
    etiology_infected_data_mean_3 = infected_data_mean .* etiology_data[3, :]
    etiology_infected_data_mean_4 = infected_data_mean .* etiology_data[4, :]
    etiology_infected_data_mean_5 = infected_data_mean .* etiology_data[5, :]
    etiology_infected_data_mean_6 = infected_data_mean .* etiology_data[6, :]
    etiology_infected_data_mean_7 = infected_data_mean .* etiology_data[7, :]

    num_infected_etiology_mean = cat(
        reshape(etiology_infected_data_mean_1, (1, length(etiology_infected_data_mean_1))),
        reshape(etiology_infected_data_mean_2, (1, length(etiology_infected_data_mean_2))),
        reshape(etiology_infected_data_mean_3, (1, length(etiology_infected_data_mean_3))),
        reshape(etiology_infected_data_mean_4, (1, length(etiology_infected_data_mean_4))),
        reshape(etiology_infected_data_mean_5, (1, length(etiology_infected_data_mean_5))),
        reshape(etiology_infected_data_mean_6, (1, length(etiology_infected_data_mean_6))),
        reshape(etiology_infected_data_mean_7, (1, length(etiology_infected_data_mean_7))),
        dims = 1)
    num_infected_etiology_sd = sqrt.(num_infected_etiology_mean)

    agents = Array{Agent, 1}(undef, num_people)
    thread_rng = [MersenneTwister(i) for i = 1:num_threads]
    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, viruses, infectivities, district_households, district_people,
            district_people_households, district_nums)
    end

    duration_parameter_array = [6.749360438556418]

    susceptibility_parameter_1_array = [2.9125475864169337]
    susceptibility_parameter_2_array = [2.7244500279173645]
    susceptibility_parameter_3_array = [3.4927161057814327]
    susceptibility_parameter_4_array = [5.0994233795238815]
    susceptibility_parameter_5_array = [4.39737526013908]
    susceptibility_parameter_6_array = [4.079802548094005]
    susceptibility_parameter_7_array = [4.179229480737016]

    temperature_parameter_1_array = [0.987586416933151]
    temperature_parameter_2_array = [0.679688848281813]
    temperature_parameter_3_array = [0.06255012435916961]
    temperature_parameter_4_array = [0.3581041571493833]
    temperature_parameter_5_array = [0.18531597380843606]
    temperature_parameter_6_array = [0.06743261763362265]
    temperature_parameter_7_array = [0.6817735140348207]

    duration_parameter = duration_parameter_array[1]
    susceptibility_parameters = [
        susceptibility_parameter_1_array[1],
        susceptibility_parameter_2_array[1],
        susceptibility_parameter_3_array[1],
        susceptibility_parameter_4_array[1],
        susceptibility_parameter_5_array[1],
        susceptibility_parameter_6_array[1],
        susceptibility_parameter_7_array[1],
    ]
    temperature_parameters = -[
        temperature_parameter_1_array[1],
        temperature_parameter_2_array[1],
        temperature_parameter_3_array[1],
        temperature_parameter_4_array[1],
        temperature_parameter_5_array[1],
        temperature_parameter_6_array[1],
        temperature_parameter_7_array[1],
    ]

    accept_num = 0
    local_rejected_num = 0

    intervals_min = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001]
    intervals_max = [10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

    deltas = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]

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

    @time S, age_group_incidence, etiology_incidence, incidence = run_simulation(
        num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
        temp_influences, duration_parameter,
        susceptibility_parameters, etiology, infected_data_mean,
        infected_data_mean_0, infected_data_mean_3,
        infected_data_mean_7, infected_data_mean_15, true)

    for i = 1:7
        S += 1 / 14 * sum((etiology_data[i, :] .* incidence .- etiology_incidence[i, :]).^ 2)
    end

    prob_prev_age_groups = ones(Float64, 4, 52)
    prob_prev_etiology = ones(Float64, 7, 52)
    for i in 1:52
        for j in 1:4
            prob_prev_age_groups[j, i] *= f(age_group_incidence[j, i], num_infected_age_groups_mean[j, i], num_infected_age_groups_sd[j, i])
        end
        for j in 1:7
            prob_prev_etiology[j, i] *= f(etiology_incidence[j, i], num_infected_etiology_mean[j, i], num_infected_etiology_sd[j, i])
        end
    end

    open("mcmc/output.txt", "a") do io
        println(io, "n = 0")
        println(io, "Prob age 1: ", prob_prev_age_groups[1, :])
        println(io, "Prob age 2: ", prob_prev_age_groups[2, :])
        println(io, "Prob age 3: ", prob_prev_age_groups[3, :])
        println(io, "Prob age 4: ", prob_prev_age_groups[4, :])
        println(io, "Prob etiology 1: ", prob_prev_etiology[1, :])
        println(io, "Prob etiology 2: ", prob_prev_etiology[2, :])
        println(io, "Prob etiology 3: ", prob_prev_etiology[3, :])
        println(io, "Prob etiology 4: ", prob_prev_etiology[4, :])
        println(io, "Prob etiology 5: ", prob_prev_etiology[5, :])
        println(io, "Prob etiology 6: ", prob_prev_etiology[6, :])
        println(io, "Prob etiology 7: ", prob_prev_etiology[7, :])
        println(io, "S: ", S)
        println(io)
    end

    # N = 1e5
    N = 2
    for n in 1:N
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

        @time S, age_group_incidence, etiology_incidence, incidence = run_simulation(
            num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
            temp_influences, duration_parameter,
            susceptibility_parameters, etiology, infected_data_mean,
            infected_data_mean_0, infected_data_mean_3,
            infected_data_mean_7, infected_data_mean_15, true)

        for i = 1:7
            S += 1 / 14 * sum((etiology_data[i, :] .* incidence .- etiology_incidence[i, :]).^ 2)
        end

        prob_age_groups = ones(Float64, 4, 52)
        prob_etiology = ones(Float64, 7, 52)
        for i in 1:52
            for j in 1:4
                prob_age_groups[j, i] *= f(age_group_incidence[j, i], num_infected_age_groups_mean[j, i], num_infected_age_groups_sd[j, i])
            end
            for j in 1:7
                prob_etiology[j, i] *= f(etiology_incidence[j, i], num_infected_etiology_mean[j, i], num_infected_etiology_sd[j, i])
            end
        end

        accept_prob = 1.0
        for i in 1:52
            for j in 1:4
                accept_prob *= prob_age_groups[j, i] / prob_prev_age_groups[j, i]
            end
            for j in 1:7
                accept_prob *= prob_etiology[j, i] / prob_prev_etiology[j, i]
            end
        end
        accept_prob = min(1.0, accept_prob)

        open("mcmc/output.txt", "a") do io
            println(io, "n = ", n)
            println(io, "Prob age 1: ", prob_prev_age_groups[1, :])
            println(io, "Prob age 2: ", prob_prev_age_groups[2, :])
            println(io, "Prob age 3: ", prob_prev_age_groups[3, :])
            println(io, "Prob age 4: ", prob_prev_age_groups[4, :])
            println(io, "Prob etiology 1: ", prob_prev_etiology[1, :])
            println(io, "Prob etiology 2: ", prob_prev_etiology[2, :])
            println(io, "Prob etiology 3: ", prob_prev_etiology[3, :])
            println(io, "Prob etiology 4: ", prob_prev_etiology[4, :])
            println(io, "Prob etiology 5: ", prob_prev_etiology[5, :])
            println(io, "Prob etiology 6: ", prob_prev_etiology[6, :])
            println(io, "Prob etiology 7: ", prob_prev_etiology[7, :])
            println(io, "Accept prob: ", accept_prob)
            println(io, "S: ", S)
            println(io, "Dur: ", duration_parameter_candidate)
            println(io, "Suscept: ", susceptibility_parameter_1_candidate)
            println(io, "Suscept: ", susceptibility_parameter_2_candidate)
            println(io, "Suscept: ", susceptibility_parameter_3_candidate)
            println(io, "Suscept: ", susceptibility_parameter_4_candidate)
            println(io, "Suscept: ", susceptibility_parameter_5_candidate)
            println(io, "Suscept: ", susceptibility_parameter_6_candidate)
            println(io, "Suscept: ", susceptibility_parameter_7_candidate)
            println(io, "Temp: ", temperature_parameter_1_candidate)
            println(io, "Temp: ", temperature_parameter_2_candidate)
            println(io, "Temp: ", temperature_parameter_3_candidate)
            println(io, "Temp: ", temperature_parameter_4_candidate)
            println(io, "Temp: ", temperature_parameter_5_candidate)
            println(io, "Temp: ", temperature_parameter_6_candidate)
            println(io, "Temp: ", temperature_parameter_7_candidate)
            println(io)
        end

        if rand(Float64) < accept_prob || local_rejected_num > 10
            push!(samples, candidate)

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

            prob_prev_age_groups = copy(prob_age_groups)
            prob_prev_etiology = copy(prob_etiology)

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

        reset_population(
            agents,
            num_threads,
            thread_rng,
            start_agent_ids,
            end_agent_ids,
            infectivities,
            viruses)
    end

    burnin = 1000
    # retained_duration_parameter_array = duration_parameter_array[burnin + 1:size(duration_parameter_array)[1]]
    # retained_duration_parameter_array = retained_duration_parameter_array[1:5:size(duration_parameter_array)[1]]
    println("Accept rate:", accept_num / N)

    println("Duration")
    println("Mean: ", mean(duration_parameter_array))
    println("SD: ", std(duration_parameter_array))

    println("Susceptibility")
    println("Mean: ", mean(susceptibility_parameter_1_array))
    println("SD: ", std(susceptibility_parameter_1_array))
    println("Mean: ", mean(susceptibility_parameter_2_array))
    println("SD: ", std(susceptibility_parameter_2_array))
    println("Mean: ", mean(susceptibility_parameter_3_array))
    println("SD: ", std(susceptibility_parameter_3_array))
    println("Mean: ", mean(susceptibility_parameter_4_array))
    println("SD: ", std(susceptibility_parameter_4_array))
    println("Mean: ", mean(susceptibility_parameter_5_array))
    println("SD: ", std(susceptibility_parameter_5_array))
    println("Mean: ", mean(susceptibility_parameter_6_array))
    println("SD: ", std(susceptibility_parameter_6_array))
    println("Mean: ", mean(susceptibility_parameter_7_array))
    println("SD: ", std(susceptibility_parameter_7_array))

    println("Temperature")
    println("Mean: ", mean(temperature_parameter_1_array))
    println("SD: ", std(temperature_parameter_1_array))
    println("Mean: ", mean(temperature_parameter_2_array))
    println("SD: ", std(temperature_parameter_2_array))
    println("Mean: ", mean(temperature_parameter_3_array))
    println("SD: ", std(temperature_parameter_3_array))
    println("Mean: ", mean(temperature_parameter_4_array))
    println("SD: ", std(temperature_parameter_4_array))
    println("Mean: ", mean(temperature_parameter_5_array))
    println("SD: ", std(temperature_parameter_5_array))
    println("Mean: ", mean(temperature_parameter_6_array))
    println("SD: ", std(temperature_parameter_6_array))
    println("Mean: ", mean(temperature_parameter_7_array))
    println("SD: ", std(temperature_parameter_7_array))
end

main()
