using Base.Threads
using Distributions
using Random
using DelimitedFiles
using LatinHypercubeSampling

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

include("util/burnin.jl")
include("util/reset.jl")
include("util/stats.jl")

function find_R0(
    agents::Vector{Agent},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    num_runs::Int,
    infectivities::Array{Float64, 4},
    viruses::Vector{Virus},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temp_influences::Array{Float64,2},
    months_threads::Vector{Vector{Int}}
)
    R0 = zeros(Float64, 7, 12)
    @time @threads for thread_id in 1:num_threads
        r = months_threads[thread_id]
        for month_num in r
            for virus_num = 1:7
                for _ = 1:num_runs
                    infected_agent_id = rand(start_agent_ids[thread_id]:end_agent_ids[thread_id])
                    agent = agents[infected_agent_id]

                    agent.virus_id = virus_num
                    # Инкубационный период
                    agent.incubation_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_incubation_period,
                        viruses[agent.virus_id].incubation_period_variance,
                        viruses[agent.virus_id].min_incubation_period,
                        viruses[agent.virus_id].max_incubation_period,
                        thread_rng[thread_id])
                    # Период болезни
                    if agent.age < 16
                        agent.infection_period = get_period_from_erlang(
                            viruses[agent.virus_id].mean_infection_period_child,
                            viruses[agent.virus_id].infection_period_variance_child,
                            viruses[agent.virus_id].min_infection_period_child,
                            viruses[agent.virus_id].max_infection_period_child,
                            thread_rng[thread_id])
                    else
                        agent.infection_period = get_period_from_erlang(
                            viruses[agent.virus_id].mean_infection_period_adult,
                            viruses[agent.virus_id].infection_period_variance_adult,
                            viruses[agent.virus_id].min_infection_period_adult,
                            viruses[agent.virus_id].max_infection_period_adult,
                            thread_rng[thread_id])
                    end

                    # Дней с момента инфицирования
                    agent.days_infected =  1 - agent.incubation_period

                    asymp_prob = 0.0
                    if agent.age < 16
                        asymp_prob = viruses[agent.virus_id].asymptomatic_probab_child
                    else
                        asymp_prob = viruses[agent.virus_id].asymptomatic_probab_adult
                    end

                    if rand(thread_rng[thread_id], Float64) < asymp_prob
                        agent.is_asymptomatic = true
                    end

                    # Вирусная нагрузкаx
                    agent.infectivity = find_agent_infectivity(
                        agent.age, infectivities[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                        agent.is_asymptomatic && agent.days_infected > 0)

                    R0[virus_num, month_num] += run_simulation_r0(
                        month_num, infected_agent_id, agents, infectivities,
                        temp_influences, duration_parameter,
                        susceptibility_parameters, thread_rng[thread_id])
                end
                R0[virus_num, month_num] /= num_runs
            end
        end
    end
    writedlm(joinpath(@__DIR__, "..", "output", "tables", "r0.csv"), R0, ',')
end

function multiple_simulations(
    agents::Vector{Agent},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    num_runs::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    infectivities::Array{Float64, 4},
    etiology::Matrix{Float64},
    temperature::Vector{Float64},
    min_temp::Float64,
    max_min_temp::Float64,
    viruses::Vector{Virus},
    duration_parameter_default::Float64,
    susceptibility_parameters_default::Vector{Float64},
    temperature_parameters_default::Vector{Float64},
    num_infected_age_groups_viruses_mean::Array{Float64, 3}
)
    latin_hypercube_plan, _ = LHCoptim(num_runs, 15, 1000)

    for i = 1:7
        if temperature_parameters_default[i] < -0.95
            temperature_parameters_default[i] = -0.95
        elseif temperature_parameters_default[i] > -0.05
            temperature_parameters_default[i] = -0.05
        end
    end

    points = scaleLHC(latin_hypercube_plan, [
        (duration_parameter_default - 0.1, duration_parameter_default + 0.1),
        (susceptibility_parameters_default[1] - 0.1, susceptibility_parameters_default[1] + 0.1),
        (susceptibility_parameters_default[2] - 0.1, susceptibility_parameters_default[2] + 0.1),
        (susceptibility_parameters_default[3] - 0.1, susceptibility_parameters_default[3] + 0.1),
        (susceptibility_parameters_default[4] - 0.1, susceptibility_parameters_default[4] + 0.1),
        (susceptibility_parameters_default[5] - 0.1, susceptibility_parameters_default[5] + 0.1),
        (susceptibility_parameters_default[6] - 0.1, susceptibility_parameters_default[6] + 0.1),
        (susceptibility_parameters_default[7] - 0.1, susceptibility_parameters_default[7] + 0.1),
        (temperature_parameters_default[1] - 0.05, temperature_parameters_default[1] + 0.05),
        (temperature_parameters_default[2] - 0.05, temperature_parameters_default[2] + 0.05),
        (temperature_parameters_default[3] - 0.05, temperature_parameters_default[3] + 0.05),
        (temperature_parameters_default[4] - 0.05, temperature_parameters_default[4] + 0.05),
        (temperature_parameters_default[5] - 0.05, temperature_parameters_default[5] + 0.05),
        (temperature_parameters_default[6] - 0.05, temperature_parameters_default[6] + 0.05),
        (temperature_parameters_default[7] - 0.05, temperature_parameters_default[7] + 0.05)])

    S_min = 3.2385170711911373e9

    for i = 1:num_runs
        println(i)

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]

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
            susceptibility_parameters, etiology, false)

        S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

        if S_square < S_min
            S_min = S_square
        end

        println("S = ", S_square)
        println("S_min = ", S_min)

        open("output/output.txt", "a") do io
            println(io, "S: ", S_square)
            println(io, "duration_parameter = ", duration_parameter)
            println(io, "susceptibility_parameters = ", susceptibility_parameters)
            println(io, "temperature_parameters = ", temperature_parameters)
            println(io)
        end

        reset_population(
            agents,
            num_threads,
            thread_rng,
            start_agent_ids,
            end_agent_ids,
            infectivities,
            viruses)
    end
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
        Virus(7, 3.2, 0.496, 1, 7, 6.5, 2.37, 3, 12, 7.5, 3.1, 4, 14, 4.93, 0.5, 0.3, 365)]

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

    # With set seed
    thread_rng = [MersenneTwister(i) for i = 1:num_threads]
    # With random seed
    # thread_rng = [MersenneTwister(rand(1:1000000)) for i = 1:num_threads]

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, viruses, infectivities, district_households, district_people,
            district_people_households, district_nums)
    end

    # get_stats(agents)

    println("Simulation...")

    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = mean(duration_parameter_array[burnin:step:size(duration_parameter_array)[1]])
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
    susceptibility_parameters = [
        mean(susceptibility_parameter_1_array[burnin:step:size(susceptibility_parameter_1_array)[1]]),
        mean(susceptibility_parameter_2_array[burnin:step:size(susceptibility_parameter_2_array)[1]]),
        mean(susceptibility_parameter_3_array[burnin:step:size(susceptibility_parameter_3_array)[1]]),
        mean(susceptibility_parameter_4_array[burnin:step:size(susceptibility_parameter_4_array)[1]]),
        mean(susceptibility_parameter_5_array[burnin:step:size(susceptibility_parameter_5_array)[1]]),
        mean(susceptibility_parameter_6_array[burnin:step:size(susceptibility_parameter_6_array)[1]]),
        mean(susceptibility_parameter_7_array[burnin:step:size(susceptibility_parameter_7_array)[1]])
    ]

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
    temperature_parameters = -[
        mean(temperature_parameter_1_array[burnin:step:size(temperature_parameter_1_array)[1]]),
        mean(temperature_parameter_2_array[burnin:step:size(temperature_parameter_2_array)[1]]),
        mean(temperature_parameter_3_array[burnin:step:size(temperature_parameter_3_array)[1]]),
        mean(temperature_parameter_4_array[burnin:step:size(temperature_parameter_4_array)[1]]),
        mean(temperature_parameter_5_array[burnin:step:size(temperature_parameter_5_array)[1]]),
        mean(temperature_parameter_6_array[burnin:step:size(temperature_parameter_6_array)[1]]),
        mean(temperature_parameter_7_array[burnin:step:size(temperature_parameter_7_array)[1]])
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

    # Runs
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

    writedlm(
        joinpath(@__DIR__, "..", "output", "tables", "collective_sizes.csv"), collective_nums, ',')

    # ----------------------
    # Single run
    # ----------------------
    # @time num_infected_age_groups_viruses = run_simulation(
    #     num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
    #     temp_influences, duration_parameter,
    #     susceptibility_parameters, etiology, true)

    # writedlm(
    #     joinpath(@__DIR__, "..", "output", "tables", "age_groups_viruses_data.csv"),
    #     num_infected_age_groups_viruses ./ 9897, ',')
    # writedlm(
    #     joinpath(@__DIR__, "..", "output", "tables", "infected_data.csv"),
    #     sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 9897, ',')
    # writedlm(
    #     joinpath(@__DIR__, "..", "output", "tables", "etiology_data.csv"),
    #     sum(num_infected_age_groups_viruses, dims = 3)[:, :, 1] ./ 9897, ',')
    # writedlm(
    #     joinpath(@__DIR__, "..", "output", "tables", "age_groups_data.csv"),
    #     sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :] ./ 9897, ',')

    # S_abs = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean))
    # S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

    # println("S: ", S_abs)
    # println("S: ", S_square)

    # ----------------------
    # Prior search
    # ----------------------
    # num_runs = 100
    # multiple_simulations(
    #     agents,
    #     num_threads,
    #     thread_rng,
    #     num_runs,
    #     start_agent_ids,
    #     end_agent_ids,
    #     infectivities,
    #     etiology,
    #     temperature,
    #     min_temp,
    #     max_min_temp,
    #     viruses,
    #     4.708649537853532,
    #     [4.791077491179754, 4.801204516560952, 5.277449916720067, 7.005768331227963, 6.87462448433526, 6.161149335090182, 6.232429844021741],
    #     [-0.9813131313131312, -0.6699003080680871, -0.03232323232323232, -0.37724434921845895, -0.12687954242389426, -0.13323867452062765, -0.6061108567674399],
    #     num_infected_age_groups_viruses_mean
    # )

    # ----------------------
    # Sensitivity analyses
    # ----------------------
    multipliers = [0.8, 0.9, 1.1, 1.2]
    k = -2

    for m in multipliers
        duration_parameter_new = duration_parameter * m
        @time num_infected_age_groups_viruses = run_simulation(
            num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
            temp_influences, duration_parameter_new,
            susceptibility_parameters, etiology, false)
        writedlm(
            joinpath(@__DIR__, "..", "analysis", "tables", "infected_data_d_$k.csv"),
            sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 9897, ',')
        reset_population(
            agents,
            num_threads,
            thread_rng,
            start_agent_ids,
            end_agent_ids,
            infectivities,
            viruses)
        if k == -1
            k = 1
        else
            k += 1
        end
    end

    for i in 1:7
        k = -2
        for m in multipliers
            susceptibility_parameters_new = copy(susceptibility_parameters)
            susceptibility_parameters_new[i] *= m
            @time num_infected_age_groups_viruses = run_simulation(
                num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
                temp_influences, duration_parameter,
                susceptibility_parameters_new, etiology, false)
            writedlm(
                joinpath(@__DIR__, "..", "analysis", "tables", "infected_data_s$(i)_$k.csv"),
                sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 9897, ',')
            reset_population(
                agents,
                num_threads,
                thread_rng,
                start_agent_ids,
                end_agent_ids,
                infectivities,
                viruses)
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end

    values = -[0.25, 0.5, 0.75, 1.0]
    for i in 1:7
        k = -2
        for v in values
            temperature_parameters_new = copy(temperature_parameters)
            temperature_parameters_new[i] = v
            temp_influences = Array{Float64,2}(undef, 7, 365)
            year_day = 213
            for i in 1:365
                current_temp = (temperature[year_day] - min_temp) / max_min_temp
                for v in 1:7
                    temp_influences[v, i] = temperature_parameters_new[v] * current_temp + 1.0
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
                susceptibility_parameters, etiology, false)
            writedlm(
                joinpath(@__DIR__, "..", "analysis", "tables", "infected_data_t$(i)_$k.csv"),
                sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 9897, ',')
            reset_population(
                agents,
                num_threads,
                thread_rng,
                start_agent_ids,
                end_agent_ids,
                infectivities,
                viruses)
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end

    # ----------------------
    # R0
    # ----------------------
    # num_runs = 200000
    # months_threads = [[1, 5, 9], [2, 6, 10], [3, 7, 11], [4, 8, 12]]

    # find_R0(agents, num_threads, thread_rng, start_agent_ids, end_agent_ids, num_runs, infectivities,
    #     viruses, duration_parameter, susceptibility_parameters,
    #     temp_influences, months_threads)

    # ----------------------
    # Contacts evaluation
    # ----------------------
    # run_simulation_evaluation(
    #     num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
    #     temp_influences, duration_parameter,
    #     susceptibility_parameters, etiology)
end

main()
