using Base.Threads
using Distributions
using Random
using DelimitedFiles

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

function f(x, mu, sigma)
    1 / sqrt(2 * pi) / sigma * exp(-0.5 * ((x - mu) / sigma)^2)
end

function main()

    println("Initialization...")

    num_threads = nthreads()

    num_people = 9897284
    # 6 threads
    # start_agent_ids = Int[1, 1669514, 3297338, 4919969, 6552869, 8229576]
    # end_agent_ids = Int[1669513, 3297337, 4919968, 6552868, 8229575, 9897284]
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

    agents = Array{Agent, 1}(undef, num_people)

    thread_rng = [MersenneTwister(i) for i = 1:num_threads]
    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, viruses, infectivities, district_households, district_people,
            district_people_households, district_nums)
    end

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

    # Runs
    etiology_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "etiology_ratio.csv"), ',', Float64, '\n')

    incidence_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    incidence_data_mean = mean(incidence_data[42:45, 2:53], dims = 1)[1, :]
    incidence_data_mean_0 = mean(incidence_data_0[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_3 = mean(incidence_data_3[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_7 = mean(incidence_data_7[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_15 = mean(incidence_data_15[2:53, 24:27], dims = 2)[:, 1]

    incidence_data_0_sd = sqrt.(incidence_data_mean_0)
    incidence_data_3_sd = sqrt.(incidence_data_mean_3)
    incidence_data_7_sd = sqrt.(incidence_data_mean_7)
    incidence_data_15_sd = sqrt.(incidence_data_mean_15)

    etiology_incidence_data_mean_1 = incidence_data_mean .* etiology_data[1, :]
    etiology_incidence_data_mean_0 = mean(incidence_data_0[2:53, 24:27], dims = 2)[:, 1]
    etiology_incidence_data_mean_3 = mean(incidence_data_3[2:53, 24:27], dims = 2)[:, 1]
    etiology_incidence_data_mean_7 = mean(incidence_data_7[2:53, 24:27], dims = 2)[:, 1]
    etiology_incidence_data_mean_15 = mean(incidence_data_15[2:53, 24:27], dims = 2)[:, 1]

    # for i = 1:7
    #     etiology_model[i, :] = etiology_model[i, :] ./ etiology_sum
    #     S += 1 / 14 * sum((etiology_data[i, :] .* incidence .- etiology_model[i, :] .* incidence).^ 2)

    collective_nums = Int[0, 0, 0, 0]
    for agent in agents
        if agent.collective_id == 1
            collective_nums[1] += 1
        elseif agent.collective_id == 2
            collective_nums[2] += 1
        elseif agent.collective_id == 3
            collective_nums[3] += 1
        elseif agent.collective_id == 4
            collective_nums[4] += 1
        end
    end

    N = 1e4

    duration_parameter_array = [6.749360438556418]

    susceptibility_parameter_1_array = [2.9125475864169337]
    susceptibility_parameter_2_array = [2.7244500279173645]
    susceptibility_parameter_3_array = [3.4927161057814327]
    susceptibility_parameter_4_array = [5.0994233795238815]
    susceptibility_parameter_5_array = [4.39737526013908]
    susceptibility_parameter_6_array = [4.079802548094005]
    susceptibility_parameter_7_array = [4.179229480737016]

    temperature_parameters_1_array = [0.987586416933151]
    temperature_parameters_2_array = [0.679688848281813]
    temperature_parameters_3_array = [0.06255012435916961]
    temperature_parameters_4_array = [0.3581041571493833]
    temperature_parameters_5_array = [0.18531597380843606]
    temperature_parameters_6_array = [0.06743261763362265]
    temperature_parameters_7_array = [0.6817735140348207]

    num_infected_weekly_prev = rand(11111:15555, 52)
    prob_prev = 0.5
    accept_num = 0
    rejected_num = 0

    intervals_min = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001]
    intervals_max = [10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

    deltas = [2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]

    @time age_group_incidence, etiology_incidence = run_simulation_mcmc(
        num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
        temp_influences, duration_parameter,
        susceptibility_parameters, etiology, incidence_data_mean,
        incidence_data_mean_0, incidence_data_mean_3,
        incidence_data_mean_7, incidence_data_mean_15, true)

    prob_prev = 1
    for i in 1:52
        for j in 1:4
            prob_prev *= f(age_group_incidence[i, j], mean_values[i], sd_values[i])
        end
    end

    for _ in 1:N
        duration_parameter_candidate = exp(rand(Normal(log(duration_parameter_array[size(duration_parameter_array)[1]]), deltas[1])))

        susceptibility_parameter_1_candidate = exp(rand(Normal(log(susceptibility_parameter_1_array[size(susceptibility_parameter_1_array)[1]]), deltas[2])))
        susceptibility_parameter_2_candidate = exp(rand(Normal(log(susceptibility_parameter_2_array[size(susceptibility_parameter_1_array)[1]]), deltas[3])))
        susceptibility_parameter_3_candidate = exp(rand(Normal(log(susceptibility_parameter_3_array[size(susceptibility_parameter_1_array)[1]]), deltas[4])))
        susceptibility_parameter_4_candidate = exp(rand(Normal(log(susceptibility_parameter_4_array[size(susceptibility_parameter_1_array)[1]]), deltas[5])))
        susceptibility_parameter_5_candidate = exp(rand(Normal(log(susceptibility_parameter_5_array[size(susceptibility_parameter_1_array)[1]]), deltas[6])))
        susceptibility_parameter_6_candidate = exp(rand(Normal(log(susceptibility_parameter_6_array[size(susceptibility_parameter_1_array)[1]]), deltas[7])))
        susceptibility_parameter_7_candidate = exp(rand(Normal(log(susceptibility_parameter_7_array[size(susceptibility_parameter_1_array)[1]]), deltas[8])))

        temperature_parameter_1_candidate = exp(rand(Normal(log(temperature_parameter_1_array[size(temperature_parameter_1_array)[1]]), deltas[9])))
        temperature_parameter_2_candidate = exp(rand(Normal(log(temperature_parameter_2_array[size(temperature_parameter_1_array)[1]]), deltas[10])))
        temperature_parameter_3_candidate = exp(rand(Normal(log(temperature_parameter_3_array[size(temperature_parameter_1_array)[1]]), deltas[11])))
        temperature_parameter_4_candidate = exp(rand(Normal(log(temperature_parameter_4_array[size(temperature_parameter_1_array)[1]]), deltas[12])))
        temperature_parameter_5_candidate = exp(rand(Normal(log(temperature_parameter_5_array[size(temperature_parameter_1_array)[1]]), deltas[13])))
        temperature_parameter_6_candidate = exp(rand(Normal(log(temperature_parameter_6_array[size(temperature_parameter_1_array)[1]]), deltas[14])))
        temperature_parameter_7_candidate = exp(rand(Normal(log(temperature_parameter_7_array[size(temperature_parameter_1_array)[1]]), deltas[15])))

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
        temperature_parameters = [
            temperature_parameter_1_candidate,
            temperature_parameter_2_candidate,
            temperature_parameter_3_candidate,
            temperature_parameter_4_candidate,
            temperature_parameter_5_candidate,
            temperature_parameter_6_candidate,
            temperature_parameter_7_candidate,
        ]

        @time age_group_incidence, etiology_incidence = run_simulation_mcmc(
            num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
            temp_influences, duration_parameter,
            susceptibility_parameters, etiology, incidence_data_mean,
            incidence_data_mean_0, incidence_data_mean_3,
            incidence_data_mean_7, incidence_data_mean_15, true)

        prob = 1
        for i in 1:52
            prob *= f(num_infected_weekly_new[i], mean_values[i], sd_values[i])
        end

        accept_prob = min(1, prob / prob_prev)
        if rand(Float64) < accept_prob || rejected_num > 10

            push!(samples, candidate)


            push!(duration_parameter_array)
            push!(susceptibility_parameter_1_array)
            push!(susceptibility_parameter_2_array)
            push!(susceptibility_parameter_3_array)
            push!(susceptibility_parameter_4_array)
            push!(susceptibility_parameter_5_array)
            push!(susceptibility_parameter_6_array)
            push!(susceptibility_parameter_7_array)

            push!(temperature_parameters_1_array)
            push!(temperature_parameters_2_array)
            push!(temperature_parameters_3_array)
            push!(temperature_parameters_4_array)
            push!(temperature_parameters_5_array)
            push!(temperature_parameters_6_array)
            push!(temperature_parameters_7_array)


            num_infected_weekly_prev = num_infected_weekly_new
            prob_prev = prob
            accept_num += 1
            rejected_num = 0
        else
            push!(samples, samples[size(samples)[1]])
            rejected_num += 1
        end
    end

    burnin = 1000
    retained_duration_parameter_array = duration_parameter_array[burnin + 1:size(duration_parameter_array)[1]]
    retained_duration_parameter_array = retained_duration_parameter_array[1:5:size(duration_parameter_array)[1]]
    println(mean(samples))
end

main()
