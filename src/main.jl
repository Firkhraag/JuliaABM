using Base.Threads
using Distributions
using LatinHypercubeSampling
using Random
using DelimitedFiles

include("model/virus.jl")
include("model/collective.jl")
include("model/agent.jl")
include("model/initialization.jl")
include("model/simulation.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

function get_stats(agents::Vector{Agent})
    println("Stats...")
    age_groups_nums = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    collective_nums = Int[0, 0, 0, 0]
    household_nums = Int[0, 0, 0, 0, 0, 0]
    mean_ig_level = 0.0
    num_of_infected = 0
    mean_num_of_kinder_conn = 0
    mean_num_of_school_conn = 0
    mean_num_of_univer_conn = 0
    mean_num_of_univer_cross_conn = 0
    mean_num_of_work_conn = 0
    size_kinder_conn = 0
    size_school_conn = 0
    size_univer_conn = 0
    size_work_conn = 0
    for agent in agents
        if agent.age < 3
            age_groups_nums[1] += 1
        elseif agent.age < 7
            age_groups_nums[2] += 1
        elseif agent.age < 16
            age_groups_nums[3] += 1
        elseif agent.age < 18
            age_groups_nums[4] += 1
        elseif agent.age < 25
            age_groups_nums[5] += 1
        elseif agent.age < 35
            age_groups_nums[6] += 1
        elseif agent.age < 45
            age_groups_nums[7] += 1
        elseif agent.age < 55
            age_groups_nums[8] += 1
        elseif agent.age < 65
            age_groups_nums[9] += 1
        elseif agent.age < 75
            age_groups_nums[10] += 1
        else
            age_groups_nums[11] += 1
        end

        if agent.collective_id == 1
            collective_nums[1] += 1
            mean_num_of_kinder_conn += size(agent.collective_conn_ids, 1)
            size_kinder_conn += 1
        elseif agent.collective_id == 2
            collective_nums[2] += 1
            mean_num_of_school_conn += size(agent.collective_conn_ids, 1)
            size_school_conn += 1
        elseif agent.collective_id == 3
            collective_nums[3] += 1
            mean_num_of_univer_conn += size(agent.collective_conn_ids, 1)
            mean_num_of_univer_cross_conn += size(agent.collective_cross_conn_ids, 1)
            size_univer_conn += 1
        elseif agent.collective_id == 4
            collective_nums[4] += 1
            mean_num_of_work_conn += size(agent.collective_conn_ids, 1)
            size_work_conn += 1
        end

        household_nums[size(agent.household_conn_ids, 1)] += 1

        mean_ig_level += agent.ig_level

        if agent.virus_id != 0
            num_of_infected += 1
        end
    end
    for i = 1:6
        household_nums[i] /= i
    end

    println("Age groups: $(age_groups_nums)")
    println("Collectives: $(collective_nums)")
    println("Households: $(household_nums)")
    println("Ig level: $(mean_ig_level / size(agents, 1))")
    println("Infected: $(num_of_infected)")
    println("Kinder conn: $(mean_num_of_kinder_conn / size_kinder_conn)")
    println("School conn: $(mean_num_of_school_conn / size_school_conn)")
    println("Univer conn: $(mean_num_of_univer_conn / size_univer_conn)")
    println("Univer cross conn: $(mean_num_of_univer_cross_conn / size_univer_conn)")
    println("Work conn: $(mean_num_of_work_conn / size_work_conn)")
end

function reset_population(
    agents::Vector{Agent},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    infectivities::Array{Float64, 4},
    viruses::Vector{Virus}
)
    @threads for thread_id in 1:num_threads
        for agent_id in start_agent_ids[thread_id]:end_agent_ids[thread_id]
            agent = agents[agent_id]
            agent.on_parent_leave = false
            is_infected = false
            if agent.age < 3
                if rand(thread_rng[thread_id], Float64) < 0.016
                    is_infected = true
                end
            elseif agent.age < 7
                if rand(thread_rng[thread_id], Float64) < 0.01
                    is_infected = true
                end
            elseif agent.age < 15
                if rand(thread_rng[thread_id], Float64) < 0.007
                    is_infected = true
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.003
                    is_infected = true
                end
            end

            # Набор дней после приобретения типоспецифического иммунитета кроме гриппа
            agent.RV_days_immune = 0
            agent.RSV_days_immune = 0
            agent.AdV_days_immune = 0
            agent.PIV_days_immune = 0

            agent.FluA_immunity = false
            agent.FluB_immunity = false
            agent.CoV_immunity = false

            if !is_infected
                if agent.age < 3
                    if rand(thread_rng[thread_id], Float64) < 0.63
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(thread_rng[thread_id], 1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                        else
                            agent.PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                        end
                    end
                elseif agent.age < 7
                    if rand(thread_rng[thread_id], Float64) < 0.44
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(thread_rng[thread_id], 1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                        else
                            agent.PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                        end
                    end
                elseif agent.age < 15
                    if rand(thread_rng[thread_id], Float64) < 0.37
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(thread_rng[thread_id], 1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                        else
                            agent.PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                        end
                    end
                else
                    if rand(thread_rng[thread_id], Float64) < 0.2
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(thread_rng[thread_id], 1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                        else
                            agent.PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                        end
                    end
                end
            end

            # Информация при болезни
            agent.virus_id = 0
            agent.incubation_period = 0
            agent.infection_period = 0
            agent.days_infected = 0
            agent.is_asymptomatic = false
            agent.is_isolated = false
            agent.infectivity = 0.0
            if is_infected
                # Тип инфекции
                rand_num = rand(thread_rng[thread_id], Float64)
                if rand_num < 0.6
                    agent.virus_id = viruses[3].id
                elseif rand_num < 0.8
                    agent.virus_id = viruses[5].id
                else
                    agent.virus_id = viruses[6].id
                end

                # Инкубационный период
                agent.incubation_period = get_period_from_erlang(
                    viruses[agent.virus_id].mean_incubation_period,
                    viruses[agent.virus_id].incubation_period_variance,
                    viruses[agent.virus_id].min_incubation_period,
                    viruses[agent.virus_id].max_incubation_period,
                    thread_rng[1])
                # Период болезни
                if agent.age < 16
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_child,
                        viruses[agent.virus_id].infection_period_variance_child,
                        viruses[agent.virus_id].min_infection_period_child,
                        viruses[agent.virus_id].max_infection_period_child,
                        thread_rng[1])
                else
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_adult,
                        viruses[agent.virus_id].infection_period_variance_adult,
                        viruses[agent.virus_id].min_infection_period_adult,
                        viruses[agent.virus_id].max_infection_period_adult,
                        thread_rng[1])
                end

                # Дней с момента инфицирования
                agent.days_infected = rand(thread_rng[thread_id], (1 - agent.incubation_period):agent.infection_period)

                asymp_prob = 0.0
                if agent.age < 16
                    asymp_prob = viruses[agent.virus_id].asymptomatic_probab_child
                else
                    asymp_prob = viruses[agent.virus_id].asymptomatic_probab_adult
                end

                if rand(thread_rng[thread_id], Float64) < asymp_prob
                    # Асимптомный
                    agent.is_asymptomatic = true
                else
                    # Самоизоляция
                    if agent.days_infected >= 1
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if agent.age < 8
                            if rand_num < 0.305
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < 0.204
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < 0.101
                                agent.is_isolated = true
                            end
                        end
                    end
                    if agent.days_infected >= 2 && !agent.is_isolated
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if agent.age < 8
                            if rand_num < 0.576
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < 0.499
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < 0.334
                                agent.is_isolated = true
                            end
                        end
                    end
                    if agent.days_infected >= 3 && !agent.is_isolated
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if agent.age < 8
                            if rand_num < 0.325
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < 0.376
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < 0.168
                                agent.is_isolated = true
                            end
                        end
                    end
                end

                # Вирусная нагрузкаx
                agent.infectivity = find_agent_infectivity(
                    agent.age, infectivities[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                    agent.is_asymptomatic && agent.days_infected > 0)
            end
        end
    end
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
    etiology_data::Matrix{Float64},
    incidence_data_mean_0::Vector{Float64},
    incidence_data_mean_3::Vector{Float64},
    incidence_data_mean_7::Vector{Float64},
    incidence_data_mean_15::Vector{Float64},
    temperature::Vector{Float64},
    min_temp::Float64,
    max_min_temp::Float64,
    viruses::Vector{Virus}
)
    latin_hypercube_plan, _ = LHCoptim(num_runs, 15, 1000)


    duration_parameter_default = 6.517852686250043
    susceptibility_parameters_default = [2.9308724832214765, 2.7252568210178407, 3.3545715152945936, 4.808825334727328, 4.279140332535159, 4.388023675424101, 4.130626285791372]
    temperature_parameters_default = [-0.7952035344507775, -0.620578058075613, -0.068115072004316885, -0.3307345452092678, -0.09427270581093386, -0.068735961687632798, -0.5586091531482917]

    points = scaleLHC(latin_hypercube_plan,[
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

    S_min = 100.0

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

        @time S, etiology_model = run_simulation(
            num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
            temp_influences, duration_parameter,
            susceptibility_parameters, etiology,
            incidence_data_mean_0, incidence_data_mean_3,
            incidence_data_mean_7, incidence_data_mean_15, false)

        etiology_sum = sum(etiology_model, dims = 1)
        for i = 1:7
            etiology_model[i, :] = etiology_model[i, :] ./ etiology_sum[1, :]
        end
        S += sum(abs.(etiology_data .- etiology_model)) / maximum(etiology_model)

        if S < S_min
            S_min = S
        end

        println("S = ", S)

        open("output/output.txt", "a") do io
            println(io, "S: ", S)
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
            viruses
        )
    end
    println("S_min: ", S_min)
end

# function R0_simulations(
#     agents::Vector{Agent},
#     num_threads::Int,
#     thread_rng::Vector{MersenneTwister},
#     num_runs::Int,
#     start_agent_ids::Vector{Int},
#     end_agent_ids::Vector{Int},
#     infectivities::Array{Float64, 4},
#     etiology::Matrix{Float64},
#     incidence_data_mean_0::Vector{Float64},
#     incidence_data_mean_3::Vector{Float64},
#     incidence_data_mean_7::Vector{Float64},
#     incidence_data_mean_15::Vector{Float64},
#     temperature::Vector{Float64},
#     min_temp::Float64,
#     max_min_temp::Float64,
#     viruses::Vector{Virus},
#     duration_parameter::Float64,
#     susceptibility_parameters::Vector{Float64},
#     temperature_parameters::Vector{Float64},
#     temp_influences::Array{Float64,2}
# )
#     for i = 1:12
#         for j = 1:7
#             for k = 1:num_runs
#                 run_simulation_R0(
#                     num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
#                     temp_influences, duration_parameter,
#                     susceptibility_parameters, etiology,
#                     incidence_data_mean_0, incidence_data_mean_3,
#                     incidence_data_mean_7, incidence_data_mean_15, false)

#                 reset_population(
#                     agents,
#                     num_threads,
#                     thread_rng,
#                     start_agent_ids,
#                     end_agent_ids,
#                     infectivities,
#                     viruses
#                 )
#             end
#         end
#     end
# end

function main()
    println("Initialization...")

    etiology_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "etiology_ratio.csv"), ',', Float64, '\n')

    num_threads = nthreads()

    num_people = 9897284
    # 6 threads
    # start_agent_ids = Int[1, 1669514, 3297338, 4919969, 6552869, 8229576]
    # end_agent_ids = Int[1669513, 3297337, 4919968, 6552868, 8229575, 9897284]
    # 4 threads
    start_agent_ids = Int[1, 2442913, 4892801, 7392381]
    end_agent_ids = Int[2442912, 4892800, 7392380, 9897284]

    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.27, 0.16, 365),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.27, 0.16, 365),
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

    # get_stats(agents)

    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    incidence_data_mean_0 = mean(incidence_data_0[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_3 = mean(incidence_data_3[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_7 = mean(incidence_data_7[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_15 = mean(incidence_data_15[2:53, 24:27], dims = 2)[:, 1]

    println("Simulation...")

    # Single run
    # S = 62.85 63.07
    duration_parameter = 6.436644632558768
    susceptibility_parameters = [2.8348993288590605, 2.8198876935010624, 3.333766146167077, 4.8296307038548445, 4.259677245286837, 4.305473339853632, 4.187673265657144]
    temperature_parameters = [-0.7841297089474218, -0.6437324204917203, -0.0973097028768001, -0.3377815250750396, -0.12682304138140368, -0.08048092813058583, -0.5676695558328555]


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

    @time S, etiology_model = run_simulation(
        num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
        temp_influences, duration_parameter,
        susceptibility_parameters, etiology,
        incidence_data_mean_0, incidence_data_mean_3,
        incidence_data_mean_7, incidence_data_mean_15, true)

    etiology_sum = sum(etiology_model, dims = 1)[1, :]
    for i = 1:7
        etiology_model[i, :] = etiology_model[i, :] ./ etiology_sum
    end
    S += sum(abs.(etiology_data .- etiology_model)) / maximum(etiology_model)

    println("S: ", S)

    # Multiple runs
    # num_runs = 150
    # multiple_simulations(agents, num_threads, thread_rng, num_runs,
    #     start_agent_ids, end_agent_ids, infectivities,
    #     etiology, etiology_data, incidence_data_mean_0,
    #     incidence_data_mean_3, incidence_data_mean_7, incidence_data_mean_15,
    #     temperature, min_temp, max_min_temp, viruses)

end

main()
