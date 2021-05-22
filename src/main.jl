using Base.Threads
using Distributions
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
        for j = 1:m
            if i != j
                push!(agents[group_ids[i]].collective_conn_ids, agents[group_ids[j]].id)
            end
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

function main()
    println("Initialization...")

    num_threads = nthreads()

    num_people = 9897284
    # 6 threads
    start_agent_ids = Int[1, 1669514, 3297338, 4919969, 6552869, 8229576]
    end_agent_ids = Int[1669513, 3297337, 4919968, 6552868, 8229575, 9897284]
    # # 4 threads
    # start_agent_ids = Int[1, 2536385, 5090846, 7523313]
    # end_agent_ids = Int[2536384, 5090845, 7523312, 9897284]
    # # 7 threads
    # start_agent_ids = Int[1, 1404541, 2813967, 4198700, 5582666, 6980559, 8427071]
    # end_agent_ids = Int[1404540, 2813966, 4198699, 5582665, 6980558, 8427070, 9897284]
    # # 8 threads
    # start_agent_ids = Int[1, 1214204, 2437939, 3664273, 4875259, 6090590, 7316432, 8589989]
    # end_agent_ids = Int[1214203, 2437938, 3664272, 4875258, 6090589, 7316431, 8589988, 9897284]

    # Параметры
    # Default
    # duration_parameter = 7.05
    # temperature_parameters = Float64[-0.8, -0.8, -0.1, -0.64, -0.2, -0.1, -0.8]
    # susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]

    # 9.498273408375e9
    # duration_parameter = 7.05
    # temperature_parameters = Float64[-0.85, -0.85, -0.05, -0.4, -0.2, -0.05, -0.7]
    # susceptibility_parameters = Float64[3.1, 3.1, 3.37, 4.29, 4.69, 3.89, 3.77]

    # 9.130457694375e9
    # duration_parameter = 7.04
    # temperature_parameters = Float64[-0.89, -0.87, -0.09, -0.33, -0.24, -0.04, -0.71]
    # susceptibility_parameters = Float64[3.09, 3.08, 3.4, 4.27, 4.66, 3.88, 3.7]

    # 8.915680668375e9
    # duration_parameter = 7.06
    # temperature_parameters = Float64[-0.88, -0.92, -0.08, -0.35, -0.25, -0.06, -0.68]
    # susceptibility_parameters = Float64[3.13, 3.12, 3.33, 4.22, 4.65, 3.87, 3.71]

    # 8.748040327375e9
    # duration_parameter = 7.01
    # temperature_parameters = Float64[-0.91, -0.93, -0.13, -0.33, -0.25, -0.07, -0.67]
    # susceptibility_parameters = Float64[3.17, 3.1, 3.36, 4.21, 4.7, 3.92, 3.76]

    # duration_parameter = 6.94
    # temperature_parameters = Float64[-0.91, -0.93, -0.13, -0.33, -0.25, -0.07, -0.67]
    # susceptibility_parameters = Float64[3.18, 3.11, 3.37, 4.22, 4.71, 3.93, 3.77]

    # RSS: 9.300468706875e9 9.442429776875e9
    # duration_parameter = 7.01
    # temperature_parameters = Float64[-0.91, -0.93, -0.13, -0.33, -0.25, -0.07, -0.67]
    # susceptibility_parameters = Float64[3.27, 3.2, 3.36, 4.21, 4.7, 3.92, 3.76]

    # # RSS: 9.421687267875e9
    # duration_parameter = 6.8
    # temperature_parameters = Float64[-0.91, -0.93, -0.13, -0.33, -0.25, -0.07, -0.67]
    # susceptibility_parameters = Float64[3.67, 3.6, 3.76, 4.61, 5.1, 4.32, 4.16]

    # RSS: 9.421687267875e9
    # duration_parameter = 6.7
    # temperature_parameters = Float64[-0.91, -0.93, -0.13, -0.33, -0.25, -0.07, -0.67]
    # susceptibility_parameters = Float64[3.87, 3.8, 3.96, 4.81, 5.3, 4.52, 4.36]

    duration_parameter = 7.05
    temperature_parameters = Float64[-0.8, -0.8, -0.1, -0.64, -0.2, -0.1, -0.8]
    susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]

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
    while num_of_people_in_workplace > 0
        num_people = sample_from_zipf_distribution(1.056, 1995) + 5
        if num_of_people_in_workplace - num_people > 0
            append!(workplaces_num_people, num_people)
        else
            append!(workplaces_num_people, num_of_people_in_workplace)
        end
        num_of_people_in_workplace -= num_people
    end

    school_groups = [[Int[] for _ in 1:school_group_nums[j]] for j = 1:11]
    university_groups = [[Int[] for _ in 1:university_group_nums[j]] for j = 1:6]
    workplace_groups = [Int[] for _ in 1:size(workplaces_num_people, 1)]

    school_group_ids = [collect(1:school_group_nums[i]) for i = 1:11]
    university_group_ids = [collect(1:university_group_nums[i]) for i = 1:6]
    workplace_group_ids = collect(1:size(workplaces_num_people, 1))

    @time for agent in agents
        if agent.collective_id == 2
            random_num = rand(1:size(school_group_ids[agent.group_num], 1))
            agent.group_id = school_group_ids[agent.group_num][random_num]
            deleteat!(school_group_ids[agent.group_num], random_num)
            if size(school_group_ids[agent.group_num], 1) == 0
                school_group_ids[agent.group_num] = collect(1:school_group_nums[agent.group_num])
            end
            push!(school_groups[agent.group_num][agent.group_id], agent.id)
            agent.collective_conn_ids = school_groups[agent.group_num][agent.group_id]
        elseif agent.collective_id == 3
            random_num = rand(1:size(university_group_ids[agent.group_num], 1))
            agent.group_id = university_group_ids[agent.group_num][random_num]
            deleteat!(university_group_ids[agent.group_num], random_num)
            if size(university_group_ids[agent.group_num], 1) == 0
                university_group_ids[agent.group_num] = collect(1:university_group_nums[agent.group_num])
            end
            push!(university_groups[agent.group_num][agent.group_id], agent.id)
            agent.collective_conn_ids = university_groups[agent.group_num][agent.group_id]
        elseif agent.collective_id == 4
            random_num = rand(1:size(workplace_group_ids, 1))
            agent.group_id = workplace_group_ids[random_num]
            deleteat!(workplace_group_ids, random_num)
            if size(workplace_group_ids, 1) == 0
                workplace_group_ids = collect(1:size(workplaces_num_people, 1))
            end
            push!(workplace_groups[agent.group_id], agent.id)
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

    # # 7 процессов
    # ranges = [
    #     1:num_groups ÷ 7,
    #     num_groups ÷ 7 + 1:2num_groups ÷ 7,
    #     2num_groups ÷ 7 + 1:3num_groups ÷ 7,
    #     3num_groups ÷ 7 + 1:4num_groups ÷ 7,
    #     4num_groups ÷ 7 + 1:5num_groups ÷ 7,
    #     5num_groups ÷ 7 + 1:6num_groups ÷ 7,
    #     6num_groups ÷ 7 + 1:num_groups]

    # # 8 процессов
    # ranges = [
    #     1:num_groups ÷ 8,
    #     num_groups ÷ 8 + 1:2num_groups ÷ 8,
    #     2num_groups ÷ 8 + 1:3num_groups ÷ 8,
    #     3num_groups ÷ 8 + 1:4num_groups ÷ 8,
    #     4num_groups ÷ 8 + 1:5num_groups ÷ 8,
    #     5num_groups ÷ 8 + 1:6num_groups ÷ 8,
    #     6num_groups ÷ 8 + 1:7num_groups ÷ 8,
    #     7num_groups ÷ 8 + 1:num_groups]
    
    @time @threads for thread_id in 1:num_threads
        for group_id in ranges[thread_id]
            generate_barabasi_albert_network(agents, workplace_groups[group_id], 6)
        end
    end

    incidence_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_mean = mean(incidence_data[42:45, 2:53], dims = 1)[1, :]
    
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
    @time RSS = run_simulation(
        num_threads, start_agent_ids, end_agent_ids, agents, infectivities,
        temp_influences, duration_parameter,
        susceptibility_parameters, etiology, incidence_data_mean,
        incidence_data_mean_0, incidence_data_mean_3,
        incidence_data_mean_7, incidence_data_mean_15)
    println("RSS: ", RSS)

    # println("Stats...")
    # age_groups_nums = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    # collective_nums = Int[0, 0, 0, 0]
    # household_nums = Int[0, 0, 0, 0, 0, 0]
    # mean_ig_level = 0.0
    # num_of_infected = 0
    # mean_num_of_kinder_conn = 0.0
    # mean_num_of_school_conn = 0.0
    # mean_num_of_univer_conn = 0.0
    # mean_num_of_work_conn = 0.0
    # size_kinder_conn = 0
    # size_school_conn = 0
    # size_univer_conn = 0
    # size_work_conn = 0
    # for agent in agents
    #     if agent.age < 3
    #         age_groups_nums[1] += 1
    #     elseif agent.age < 7
    #         age_groups_nums[2] += 1
    #     elseif agent.age < 16
    #         age_groups_nums[3] += 1
    #     elseif agent.age < 18
    #         age_groups_nums[4] += 1
    #     elseif agent.age < 25
    #         age_groups_nums[5] += 1
    #     elseif agent.age < 35
    #         age_groups_nums[6] += 1
    #     elseif agent.age < 45
    #         age_groups_nums[7] += 1
    #     elseif agent.age < 55
    #         age_groups_nums[8] += 1
    #     elseif agent.age < 65
    #         age_groups_nums[9] += 1
    #     elseif agent.age < 75
    #         age_groups_nums[10] += 1
    #     else
    #         age_groups_nums[11] += 1
    #     end

    #     if agent.collective_id == 1
    #         collective_nums[1] += 1
    #         mean_num_of_kinder_conn += size(agent.collective_conn_ids, 1)
    #         size_kinder_conn += 1
    #     elseif agent.collective_id == 2
    #         collective_nums[2] += 1
    #         mean_num_of_school_conn += size(agent.collective_conn_ids, 1)
    #         size_school_conn += 1
    #     elseif agent.collective_id == 3
    #         collective_nums[3] += 1
    #         mean_num_of_univer_conn += size(agent.collective_conn_ids, 1)
    #         size_univer_conn += 1
    #     elseif agent.collective_id == 4
    #         collective_nums[4] += 1
    #         mean_num_of_work_conn += size(agent.collective_conn_ids, 1)
    #         size_work_conn += 1
    #     end

    #     household_nums[size(agent.household_conn_ids, 1)] += 1

    #     mean_ig_level += agent.ig_level

    #     if agent.virus_id != 0
    #         num_of_infected += 1
    #     end
    # end
    # for i = 1:6
    #     household_nums[i] /= i
    # end

    # println("Age groups: $(age_groups_nums)")
    # println("Collectives: $(collective_nums)")
    # println("Households: $(household_nums)")
    # println("Ig level: $(mean_ig_level / size(agents, 1))")
    # println("Infected: $(num_of_infected)")
    # println("Kinder conn: $(mean_num_of_kinder_conn / size_kinder_conn)")
    # println("School conn: $(mean_num_of_school_conn / size_school_conn)")
    # println("Univer conn: $(mean_num_of_univer_conn / size_univer_conn)")
    # println("Work conn: $(mean_num_of_work_conn / size_work_conn)")
end

function main2()
    println("Initialization...")

    num_threads = nthreads()

    num_people = 9897284
    # 6 threads
    start_agent_ids = Int[1, 1669514, 3297338, 4919969, 6552869, 8229576]
    end_agent_ids = Int[1669513, 3297337, 4919968, 6552868, 8229575, 9897284]
    # # 4 threads
    # start_agent_ids = Int[1, 2536385, 5090846, 7523313]
    # end_agent_ids = Int[2536384, 5090845, 7523312, 9897284]
    # # 7 threads
    # start_agent_ids = Int[1, 1404541, 2813967, 4198700, 5582666, 6980559, 8427071]
    # end_agent_ids = Int[1404540, 2813966, 4198699, 5582665, 6980558, 8427070, 9897284]
    # # 8 threads
    # start_agent_ids = Int[1, 1214204, 2437939, 3664273, 4875259, 6090590, 7316432, 8589989]
    # end_agent_ids = Int[1214203, 2437938, 3664272, 4875258, 6090589, 7316431, 8589988, 9897284]

    # Параметры
    # Default
    # duration_parameter = 7.05
    # temperature_parameters = Float64[-0.8, -0.8, -0.1, -0.64, -0.2, -0.1, -0.8]
    # susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]

    # 9.498273408375e9
    # duration_parameter = 7.05
    # temperature_parameters = Float64[-0.85, -0.85, -0.05, -0.4, -0.2, -0.05, -0.7]
    # susceptibility_parameters = Float64[3.1, 3.1, 3.37, 4.29, 4.69, 3.89, 3.77]

    # 9.130457694375e9
    # duration_parameter = 7.04
    # temperature_parameters = Float64[-0.89, -0.87, -0.09, -0.33, -0.24, -0.04, -0.71]
    # susceptibility_parameters = Float64[3.09, 3.08, 3.4, 4.27, 4.66, 3.88, 3.7]

    # 8.915680668375e9
    # duration_parameter = 7.06
    # temperature_parameters = Float64[-0.88, -0.92, -0.08, -0.35, -0.25, -0.06, -0.68]
    # susceptibility_parameters = Float64[3.13, 3.12, 3.33, 4.22, 4.65, 3.87, 3.71]

    # 8.748040327375e9
    # duration_parameter = 7.01
    # temperature_parameters = Float64[-0.91, -0.93, -0.13, -0.33, -0.25, -0.07, -0.67]
    # susceptibility_parameters = Float64[3.17, 3.1, 3.36, 4.21, 4.7, 3.92, 3.76]

    # duration_parameter = 6.94
    # temperature_parameters = Float64[-0.91, -0.93, -0.13, -0.33, -0.25, -0.07, -0.67]
    # susceptibility_parameters = Float64[3.18, 3.11, 3.37, 4.22, 4.71, 3.93, 3.77]

    # RSS: 9.300468706875e9
    duration_parameter = 7.01
    temperature_parameters = Float64[-0.91, -0.93, -0.13, -0.33, -0.25, -0.07, -0.67]
    susceptibility_parameters = Float64[3.27, 3.2, 3.36, 4.21, 4.7, 3.92, 3.76]

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

    duration_parameter_new = 0.0
    temperature_parameters_new = Array{Float64, 1}(undef, 7)
    susceptibility_parameters_new = Array{Float64, 1}(undef, 7)

    incidence_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_mean = mean(incidence_data[42:45, 2:53], dims = 1)[1, :]
    
    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    incidence_data_mean_0 = mean(incidence_data_0[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_3 = mean(incidence_data_3[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_7 = mean(incidence_data_7[2:53, 24:27], dims = 2)[:, 1]
    incidence_data_mean_15 = mean(incidence_data_15[2:53, 24:27], dims = 2)[:, 1]

    for i = 1:2
        RSS_min = 9.300468706875e9

        duration_parameter_new = duration_parameter + rand(-0.05:0.01:0.05)

        temperature_parameters_new[1] = temperature_parameters[1] + rand(-0.05:0.01:0.05)
        if temperature_parameters_new[1] < -1
            temperature_parameters_new[1] = -1.0
        elseif temperature_parameters_new[1] > 0
            temperature_parameters_new[1] = 0.01
        end
        temperature_parameters_new[2] = temperature_parameters[2] + rand(-0.05:0.01:0.05)
        if temperature_parameters_new[2] < -1
            temperature_parameters_new[2] = -1.0
        elseif temperature_parameters_new[2] > 0
            temperature_parameters_new[2] = 0.01
        end
        temperature_parameters_new[3] = temperature_parameters[3] + rand(-0.05:0.01:0.05)
        if temperature_parameters_new[3] < -1
            temperature_parameters_new[3] = -1.0
        elseif temperature_parameters_new[3] > 0
            temperature_parameters_new[3] = 0.01
        end
        temperature_parameters_new[4] = temperature_parameters[4] + rand(-0.05:0.01:0.05)
        if temperature_parameters_new[4] < -1
            temperature_parameters_new[4] = -1.0
        elseif temperature_parameters_new[4] > 0
            temperature_parameters_new[4] = 0.01
        end
        temperature_parameters_new[5] = temperature_parameters[5] + rand(-0.05:0.01:0.05)
        if temperature_parameters_new[5] < -1
            temperature_parameters_new[5] = -1.0
        elseif temperature_parameters_new[5] > 0
            temperature_parameters_new[5] = 0.01
        end
        temperature_parameters_new[6] = temperature_parameters[6] + rand(-0.05:0.01:0.05)
        if temperature_parameters_new[6] < -1
            temperature_parameters_new[6] = -1.0
        elseif temperature_parameters_new[6] > 0
            temperature_parameters_new[6] = 0.01
        end
        temperature_parameters_new[7] = temperature_parameters[7] + rand(-0.05:0.01:0.05)
        if temperature_parameters_new[7] < -1
            temperature_parameters_new[7] = -1.0
        elseif temperature_parameters_new[7] > 0
            temperature_parameters_new[7] = 0.01
        end

        susceptibility_parameters_new[1] = susceptibility_parameters[1] + rand(-0.05:0.01:0.05)
        susceptibility_parameters_new[2] = susceptibility_parameters[2] + rand(-0.05:0.01:0.05)
        susceptibility_parameters_new[3] = susceptibility_parameters[3] + rand(-0.05:0.01:0.05)
        susceptibility_parameters_new[4] = susceptibility_parameters[4] + rand(-0.05:0.01:0.05)
        susceptibility_parameters_new[5] = susceptibility_parameters[5] + rand(-0.05:0.01:0.05)
        susceptibility_parameters_new[6] = susceptibility_parameters[6] + rand(-0.05:0.01:0.05)
        susceptibility_parameters_new[7] = susceptibility_parameters[7] + rand(-0.05:0.01:0.05)

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
        while num_of_people_in_workplace > 0
            num_people = sample_from_zipf_distribution(1.056, 1995) + 5
            if num_of_people_in_workplace - num_people > 0
                append!(workplaces_num_people, num_people)
            else
                append!(workplaces_num_people, num_of_people_in_workplace)
            end
            num_of_people_in_workplace -= num_people
        end

        school_groups = [[Int[] for _ in 1:school_group_nums[j]] for j = 1:11]
        university_groups = [[Int[] for _ in 1:university_group_nums[j]] for j = 1:6]
        workplace_groups = [Int[] for _ in 1:size(workplaces_num_people, 1)]

        school_group_ids = [collect(1:school_group_nums[i]) for i = 1:11]
        university_group_ids = [collect(1:university_group_nums[i]) for i = 1:6]
        workplace_group_ids = collect(1:size(workplaces_num_people, 1))

        @time for agent in agents
            if agent.collective_id == 2
                random_num = rand(1:size(school_group_ids[agent.group_num], 1))
                agent.group_id = school_group_ids[agent.group_num][random_num]
                deleteat!(school_group_ids[agent.group_num], random_num)
                if size(school_group_ids[agent.group_num], 1) == 0
                    school_group_ids[agent.group_num] = collect(1:school_group_nums[agent.group_num])
                end
                push!(school_groups[agent.group_num][agent.group_id], agent.id)
                agent.collective_conn_ids = school_groups[agent.group_num][agent.group_id]
            elseif agent.collective_id == 3
                random_num = rand(1:size(university_group_ids[agent.group_num], 1))
                agent.group_id = university_group_ids[agent.group_num][random_num]
                deleteat!(university_group_ids[agent.group_num], random_num)
                if size(university_group_ids[agent.group_num], 1) == 0
                    university_group_ids[agent.group_num] = collect(1:university_group_nums[agent.group_num])
                end
                push!(university_groups[agent.group_num][agent.group_id], agent.id)
                agent.collective_conn_ids = university_groups[agent.group_num][agent.group_id]
            elseif agent.collective_id == 4
                random_num = rand(1:size(workplace_group_ids, 1))
                agent.group_id = workplace_group_ids[random_num]
                deleteat!(workplace_group_ids, random_num)
                if size(workplace_group_ids, 1) == 0
                    workplace_group_ids = collect(1:size(workplaces_num_people, 1))
                end
                push!(workplace_groups[agent.group_id], agent.id)
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

        println("Simulation...")
        @time RSS = run_simulation(
            num_threads, start_agent_ids, end_agent_ids, agents, infectivities,
            temp_influences, duration_parameter_new,
            susceptibility_parameters_new, etiology, incidence_data_mean,
            incidence_data_mean_0, incidence_data_mean_3,
            incidence_data_mean_7, incidence_data_mean_15)
        if RSS < RSS_min
            RSS_min = RSS
            duration_parameter = duration_parameter_new
            temperature_parameters = copy(temperature_parameters_new)
            susceptibility_parameters = copy(susceptibility_parameters_new)
            println("RSS: ", RSS)
            println("Duration parameter: ", duration_parameter)
            println("Temperature parameters: ", temperature_parameters)
            println("Susceptibility parameters: ", susceptibility_parameters)
        end
    end
end

main()
# main2()
