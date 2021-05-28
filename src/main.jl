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

function sample_from_zipf_distribution(
    parameter::Float64, max_size::Int
)::Int
    cumulative = 0.0
    rand_num = rand(Float64)
    multiplier = 1 / sum((1:max_size).^(-parameter))
    for i = 1:max_size
        cumulative += i^(-parameter) * multiplier
        if rand_num < cumulative
            return i
        end
    end
    return max_size
end

# Создание графа Барабаши-Альберта
# На вход подаются группа с набором агентов (group) и число минимальных связей, которые должен иметь агент (m)
function generate_barabasi_albert_network(agents::Vector{Agent}, group_ids::Vector{Int}, m::Int)
    if size(group_ids, 1) < m
        m = size(group_ids, 1)
    end
    # Связный граф с m вершинами
    for i = 1:m
        for j = (i + 1):m
            push!(agents[group_ids[i]].collective_conn_ids, group_ids[j])
            push!(agents[group_ids[j]].collective_conn_ids, group_ids[i])
        end
    end
    # Сумма связей всех вершин
    degree_sum = m * (m - 1)
    # Добавление новых вершин
    for i = (m + 1):size(group_ids, 1)
        agent = agents[group_ids[i]]
        degree_sum_temp = degree_sum
        for _ = 1:m
            cumulative = 0.0
            rand_num = rand(Float64)
            for j = 1:(i-1)
                if group_ids[j] in agent.collective_conn_ids
                    continue
                end
                agent2 = agents[group_ids[j]]
                cumulative += size(agent2.collective_conn_ids, 1) / degree_sum_temp
                if rand_num < cumulative
                    degree_sum_temp -= size(agent2.collective_conn_ids, 1)
                    push!(agent.collective_conn_ids, agent2.id)
                    push!(agent2.collective_conn_ids, agent.id)
                    break
                end
            end
        end
        degree_sum += 2m
    end
end

function set_connections(
    agents::Vector{Agent},
    num_threads::Int,
    num_of_people_in_school_threads::Matrix{Int},
    num_of_people_in_university_threads::Matrix{Int},
    num_of_people_in_workplace_threads::Vector{Int}
)
    num_of_people_in_school = sum(num_of_people_in_school_threads, dims=2)
    num_of_people_in_university = sum(num_of_people_in_university_threads, dims=2)
    num_of_people_in_workplace = sum(num_of_people_in_workplace_threads)

    school_group_nums = ceil.(Int, num_of_people_in_school ./ 25)

    university_group_nums = Array{Int, 1}(undef, 6)
    university_group_nums[1] = ceil(Int, num_of_people_in_university[1] / 15)
    university_group_nums[2:3] = ceil.(Int, num_of_people_in_university[2:3] ./ 14)
    university_group_nums[4] = ceil.(Int, num_of_people_in_university[4] ./ 13)
    university_group_nums[5] = ceil.(Int, num_of_people_in_university[5] ./ 11)
    university_group_nums[6] = ceil.(Int, num_of_people_in_university[6] ./ 10)

    workplaces_num_people = Int[]
    workplace_num_people = num_of_people_in_workplace

    while num_of_people_in_workplace > 0
        num_people = sample_from_zipf_distribution(1.056, 1995) + 5
        if num_of_people_in_workplace - num_people > 0
            append!(workplaces_num_people, num_people)
        else
            append!(workplaces_num_people, num_of_people_in_workplace)
        end
        num_of_people_in_workplace -= num_people
    end

    workplace_weights = workplaces_num_people ./ workplace_num_people

    school_groups = [[Int[] for _ in 1:school_group_nums[j]] for j = 1:11]
    university_groups = [[Int[] for _ in 1:university_group_nums[j]] for j = 1:6]
    workplace_groups = [Int[] for _ in 1:size(workplaces_num_people, 1)]

    school_group_ids = [collect(1:school_group_nums[i]) for i = 1:11]
    university_group_ids = [collect(1:university_group_nums[i]) for i = 1:6]

    @time for agent in agents
        if agent.collective_id == 2
            random_num = rand(1:size(school_group_ids[agent.group_num], 1))
            group_id = school_group_ids[agent.group_num][random_num]
            deleteat!(school_group_ids[agent.group_num], random_num)
            if size(school_group_ids[agent.group_num], 1) == 0
                school_group_ids[agent.group_num] = collect(1:school_group_nums[agent.group_num])
            end
            push!(school_groups[agent.group_num][group_id], agent.id)
            agent.collective_conn_ids = school_groups[agent.group_num][group_id]
        elseif agent.collective_id == 3
            random_num = rand(1:size(university_group_ids[agent.group_num], 1))
            group_id = university_group_ids[agent.group_num][random_num]
            deleteat!(university_group_ids[agent.group_num], random_num)
            if size(university_group_ids[agent.group_num], 1) == 0
                university_group_ids[agent.group_num] = collect(1:university_group_nums[agent.group_num])
            end
            push!(university_groups[agent.group_num][group_id], agent.id)
            agent.collective_conn_ids = university_groups[agent.group_num][group_id]
        elseif agent.collective_id == 4
            random_num = rand(Float64)
            cumulative = 0.0
            for i in 1:size(workplaces_num_people, 1)
                cumulative += workplace_weights[i]
                if random_num < cumulative
                    push!(workplace_groups[i], agent.id)
                    break
                end
            end
        end
    end

    @time @threads for i = 1:6
        for j = 1:4:size(university_groups[i], 1)
            if size(university_groups[i], 1) - j >= 4
                group1 = university_groups[i][j]
                group2 = university_groups[i][j + 1]
                group3 = university_groups[i][j + 2]
                group4 = university_groups[i][j + 3]
                connections_for_group1 = vcat(group2, group3, group4)
                connections_for_group2 = vcat(group1, group3, group4)
                connections_for_group3 = vcat(group2, group1, group4)
                connections_for_group4 = vcat(group2, group3, group1)
                for agent_id in group1
                    agent = agents[agent_id]
                    agent.collective_cross_conn_ids = connections_for_group1
                end
                for agent_id in group2
                    agent = agents[agent_id]
                    agent.collective_cross_conn_ids = connections_for_group2
                end
                for agent_id in group3
                    agent = agents[agent_id]
                    agent.collective_cross_conn_ids = connections_for_group3
                end
                for agent_id in group4
                    agent = agents[agent_id]
                    agent.collective_cross_conn_ids = connections_for_group4
                end
            end
        end
    end

    num_groups = size(workplace_groups, 1)
    # 6 процессов
    ranges = [
        1:num_groups ÷ 6,
        num_groups ÷ 6 + 1:num_groups ÷ 3,
        num_groups ÷ 3 + 1:num_groups ÷ 2,
        num_groups ÷ 2 + 1:2num_groups ÷ 3,
        2num_groups ÷ 3 + 1:5num_groups ÷ 6,
        5num_groups ÷ 6 + 1:num_groups]
    
    @time @threads for thread_id in 1:num_threads
        for group_id in ranges[thread_id]
            generate_barabasi_albert_network(agents, workplace_groups[group_id], 6)
        end
    end
end

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

function multiple_simulations(
    agents::Vector{Agent},
    num_threads::Int,
    num_runs::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    infectivities::Array{Float64, 4},
    etiology::Matrix{Float64},
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
    points = scaleLHC(latin_hypercube_plan,[
        (6.5, 7.0), # duration
        (2.5, 3.5), # susceptibility1
        (2.5, 3.5), # susceptibility2
        (3.0, 4.0), # susceptibility3
        (4.5, 5.5), # susceptibility4
        (4.5, 5.5), # susceptibility5
        (3.5, 4.5), # susceptibility6
        (3.5, 4.5), # susceptibility7
        (-0.95, -0.85), # temp1
        (-0.85, -0.75), # temp2
        (-0.11, -0.01), # temp3
        (-0.45, -0.3), # temp4
        (-0.11, -0.01), # temp5
        (-0.11, -0.01), # temp6
        (-0.9, -0.8)]) # temp7
    for i = 1:num_runs
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

        @time RSS = run_simulation(
            num_threads, start_agent_ids, end_agent_ids, agents, infectivities,
            temp_influences, duration_parameter,
            susceptibility_parameters, etiology,
            incidence_data_mean_0, incidence_data_mean_3,
            incidence_data_mean_7, incidence_data_mean_15)
        println("RSS: ", RSS)
        println("duration_parameter ", duration_parameter)
        println("susceptibility_parameters ", susceptibility_parameters)
        println("temperature_parameters ", temperature_parameters)

        for agent in agents
            agent.on_parent_leave = false
            is_infected = false
            if agent.age < 3
                if rand(Float64) < 0.016
                    is_infected = true
                end
            elseif agent.age < 7
                if rand(Float64) < 0.01
                    is_infected = true
                end
            elseif agent.age < 15
                if rand(Float64) < 0.007
                    is_infected = true
                end
            else
                if rand(Float64) < 0.003
                    is_infected = true
                end
            end
    
            # Набор дней после приобретения типоспецифического иммунитета кроме гриппа
            agent.RV_days_immune = 0
            agent.RSV_days_immune = 0
            agent.AdV_days_immune = 0
            agent.PIV_days_immune = 0
    
            if !is_infected
                if agent.age < 3
                    if rand(Float64) < 0.63
                        rand_num = rand(Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(1:60)
                        else
                            agent.PIV_days_immune = rand(1:60)
                        end
                    end
                elseif agent.age < 7
                    if rand(Float64) < 0.44
                        rand_num = rand(Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(1:60)
                        else
                            agent.PIV_days_immune = rand(1:60)
                        end
                    end
                elseif agent.age < 15
                    if rand(Float64) < 0.37
                        rand_num = rand(Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(1:60)
                        else
                            agent.PIV_days_immune = rand(1:60)
                        end
                    end
                else
                    if rand(Float64) < 0.2
                        rand_num = rand(Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(1:60)
                        else
                            agent.PIV_days_immune = rand(1:60)
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
                rand_num = rand(Float64)
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
                    viruses[agent.virus_id].max_incubation_period)
                # Период болезни
                if agent.age < 16
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_child,
                        viruses[agent.virus_id].infection_period_variance_child,
                        viruses[agent.virus_id].min_infection_period_child,
                        viruses[agent.virus_id].max_infection_period_child)
                else
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_adult,
                        viruses[agent.virus_id].infection_period_variance_adult,
                        viruses[agent.virus_id].min_infection_period_adult,
                        viruses[agent.virus_id].max_infection_period_adult)
                end
    
                # Дней с момента инфицирования
                agent.days_infected = rand((1 - agent.incubation_period):agent.infection_period)
                # days_infected = rand(1:(infection_period + incubation_period))
    
                if rand(Float64) < viruses[agent.virus_id].asymptomatic_probab
                    # Асимптомный
                    agent.is_asymptomatic = true
                else
                    # Самоизоляция
                    if agent.days_infected >= 1
                        rand_num = rand(Float64)
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
                        rand_num = rand(Float64)
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
                        rand_num = rand(Float64)
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

function main()
    println("Initialization...")

    num_threads = nthreads()

    num_people = 9897284
    # 6 threads
    start_agent_ids = Int[1, 1669514, 3297338, 4919969, 6552869, 8229576]
    end_agent_ids = Int[1669513, 3297337, 4919968, 6552868, 8229575, 9897284]

    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.16),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.16),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.3),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.3),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.3),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 0.3),
        Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.3)]

    infectivities = Array{Float64,4}(undef, 7, 7, 13, 21)
    for days_infected in -6:14
        days_infected_index = days_infected + 7
        for infection_period in 2:14
            infection_period_index = infection_period - 1
            for incubation_period in 1:7
                min_days_infected = 1 - incubation_period
                mean_infectivities = [4.6, 4.7, 3.5, 6.0, 4.1, 4.7, 4.93]
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
    num_of_people_in_school_threads = zeros(Int, 11, num_threads)
    num_of_people_in_university_threads = zeros(Int, 6, num_threads)
    num_of_people_in_workplace_threads = zeros(Int, num_threads)

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, start_agent_ids[thread_id],
            agents, viruses, infectivities, district_households, district_people,
            district_people_households, district_nums, num_of_people_in_school_threads,
            num_of_people_in_university_threads, num_of_people_in_workplace_threads)
    end

    # set_connections(
    #     agents,
    #     num_threads,
    #     num_of_people_in_school_threads,
    #     num_of_people_in_university_threads,
    #     num_of_people_in_workplace_threads)

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

    # # Single run
    # # Параметры (RSS: 5.081978631875e9)
    # duration_parameter = 6.75
    # temperature_parameters = Float64[-0.9, -0.8, -0.05, -0.35, -0.05, -0.05, -0.85]
    # susceptibility_parameters = Float64[3.05, 3.1, 3.47, 4.9, 4.7, 4.02, 3.88]

    # temp_influences = Array{Float64,2}(undef, 7, 365)
    # year_day = 213
    # for i in 1:365
    #     current_temp = (temperature[year_day] - min_temp) / max_min_temp
    #     for v in 1:7
    #         temp_influences[v, i] = temperature_parameters[v] * current_temp + 1.0
    #     end
    #     if year_day == 365
    #         year_day = 1
    #     else
    #         year_day += 1
    #     end
    # end

    # @time RSS = run_simulation(
    #     num_threads, start_agent_ids, end_agent_ids, agents, infectivities,
    #     temp_influences, duration_parameter,
    #     susceptibility_parameters, etiology,
    #     incidence_data_mean_0, incidence_data_mean_3,
    #     incidence_data_mean_7, incidence_data_mean_15)
    # println("RSS: ", RSS)

    # Multiple runs
    num_runs = 2
    multiple_simulations(agents, num_threads, num_runs,
        start_agent_ids, end_agent_ids, infectivities,
        etiology, incidence_data_mean_0,
        incidence_data_mean_3, incidence_data_mean_7, incidence_data_mean_15,
        temperature, min_temp, max_min_temp, viruses)

end

main()
