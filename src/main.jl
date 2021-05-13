using DelimitedFiles
using Distributions
using Random
using MPI

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

function main()
    MPI.Init()

    comm = MPI.COMM_WORLD
    comm_size = MPI.Comm_size(comm)
    comm_rank = MPI.Comm_rank(comm)

    if comm_rank == 0
        println("Initialization...")
    end

    # Параметры
    duration_parameter = 7.05
    temperature_parameters = Float64[-0.8, -0.8, -0.05, -0.64, -0.2, -0.05, -0.8]   
    # temperature_parameters = Float64[-0.8, -0.8, -0.1, -0.64, -0.2, -0.1, -0.8]   
    susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]
    # susceptibility_parameters = Float64[2.1, 2.1, 3.77, 4.89, 4.69, 3.89, 3.77]
    immunity_durations = Int[366, 366, 60, 60, 90, 90, 366]
    
    # Вирусы
    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.16),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.16),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.3),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.3),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.3),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 0.3),
        Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.3)]
    # viruses = Virus[
    #     Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.01),
    #     Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.01),
    #     Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.9),
    #     Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.9),
    #     Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.9),
    #     Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 0.9),
    #     Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.9)]

    viral_loads = Array{Float64,4}(undef, 7, 7, 13, 21)

    for days_infected in -6:14
        days_infected_index = days_infected + 7
        for infection_period in 2:14
            infection_period_index = infection_period - 1
            for incubation_period in 1:7
                min_days_infected = 1 - incubation_period
                mean_viral_loads = [4.6, 4.7, 3.5, 6.0, 4.1, 4.7, 4.93]
                for i in 1:7
                    if (days_infected >= min_days_infected) && (days_infected <= infection_period)
                        viral_loads[i, incubation_period, infection_period_index, days_infected_index] = get_viral_load(
                            days_infected, incubation_period, infection_period, mean_viral_loads[i])
                    end
                end
            end
        end
    end

    # Коллективы
    collectives = Collective[
        Collective(1, 5.88, 2.52, [Group[], Group[], Group[], Group[], Group[], Group[]]),
        Collective(2, 4.783, 2.67, [Group[], Group[], Group[], Group[], Group[], Group[],
            Group[], Group[], Group[], Group[], Group[]]),
        Collective(3, 2.1, 3.0, [Group[], Group[], Group[], Group[], Group[], Group[]]),
        Collective(4, 3.0, 3.0, [Group[]])]
    # collectives = Collective[
    #     # http://ecs.force.com/mbdata/MBQuest2RTanw?rep=KK3Q1806#:~:text=6%20hours%20per%20day%20for%20kindergarten%20and%20elementary%20students.&text=437.5%20hours%20per%20year%20for%20half%2Dday%20kindergarten.
    #     Collective(1, 5.5, 1.0, [Group[], Group[], Group[], Group[], Group[], Group[]]),
    #     # https://nces.ed.gov/surveys/sass/tables/sass0708_035_s1s.asp
    #     # Mixing patterns between age groups in social networks
    #     Collective(2, 6.64, 1.0, [Group[], Group[], Group[], Group[], Group[], Group[],
    #         Group[], Group[], Group[], Group[], Group[]]),
    #     # 
    #     Collective(3, 2.0, 0.5, [Group[], Group[], Group[], Group[], Group[], Group[]]),
    #     # American Time Use Survey Summary. Bls.gov. 2017-06-27. Retrieved 2018-06-06
    #     Collective(4, 7.9, 1.0, [Group[]])]

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

    # Число домохозяйств каждого типа по районам
    district_households = get_district_households()
    # Число людей в каждой группе по районам
    district_people = get_district_people()
    # Число людей в домохозяйствах по районам
    district_people_households = get_district_people_households()

    # Вероятность случайного инфицирования
    etiology = get_random_infection_probabilities()
    
    # Компиляция
    test_collectives = Collective[
        Collective(1, 5.88, 2.52, [Group[], Group[], Group[], Group[], Group[], Group[]]),
        Collective(2, 4.783, 2.67, [Group[], Group[], Group[], Group[], Group[], Group[],
            Group[], Group[], Group[], Group[], Group[]]),
        Collective(3, 2.1, 3.0, [Group[], Group[], Group[], Group[], Group[], Group[]]),
        Collective(4, 3.0, 3.0, [Group[]])]
    test_agents = Agent[]
    create_population(
        comm_rank, comm_size, test_agents, viruses, viral_loads, test_collectives,
        district_households, district_people, district_people_households, collect(1:comm_size))
    MPI.Barrier(comm)
    run_simulation(
        comm_rank, comm, test_agents, viruses, viral_loads,
        test_collectives, temp_influences, duration_parameter,
        susceptibility_parameters, immunity_durations, etiology, true)
    MPI.Barrier(comm)

    # Набор агентов
    all_agents = Agent[]
    # Номера районов для MPI процессов
    district_nums = get_district_nums()
    # district_nums = collect(1:80)

    @time create_population(
        comm_rank, comm_size, all_agents, viruses, viral_loads, collectives,
        district_households, district_people, district_people_households, district_nums)
    MPI.Barrier(comm)

    # println("Stats...")
    # age_groups_nums = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    # collective_nums = Int[0, 0, 0, 0]
    # household_nums = Int[0, 0, 0, 0, 0, 0]
    # mean_ig_level = 0.0
    # num_of_infected = 0
    # mean_num_of_work_conn = 0.0
    # size_work_conn = 0
    # mean_size_work_groups = size(collectives[4].groups[1], 1)
    # mean_size_work_group = 0
    # for agent in all_agents
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
    #     elseif agent.collective_id == 2
    #         collective_nums[2] += 1
    #     elseif agent.collective_id == 3
    #         collective_nums[3] += 1
    #     elseif agent.collective_id == 4
    #         collective_nums[4] += 1
    #     end

    #     household_nums[size(agent.household.agent_ids, 1)] += 1

    #     mean_ig_level += agent.ig_level
    #     if size(agent.work_conn_ids, 1) != 0
    #         mean_num_of_work_conn += size(agent.work_conn_ids, 1)
    #         size_work_conn += 1
    #     end

    #     if agent.virus_id != 0
    #         num_of_infected += 1
    #     end
    # end
    # for group in collectives[4].groups[1]
    #     mean_size_work_group += size(group.agent_ids, 1)
    # end
    # for i = 1:6
    #     household_nums[i] /= i
    # end

    # age_groups_all = MPI.Reduce(age_groups_nums, MPI.SUM, 0, comm)

    # collective_nums_all = MPI.Reduce(collective_nums, MPI.SUM, 0, comm)

    # household_nums_all = MPI.Reduce(household_nums, MPI.SUM, 0, comm)

    # mean_ig_level_all = MPI.Reduce(mean_ig_level, MPI.SUM, 0, comm)
    # size_all = MPI.Reduce(size(all_agents, 1), MPI.SUM, 0, comm)

    # num_of_infected_all = MPI.Reduce(num_of_infected, MPI.SUM, 0, comm)

    # mean_num_of_work_conn_all = MPI.Reduce(mean_num_of_work_conn, MPI.SUM, 0, comm)
    # size_work_con_all = MPI.Reduce(size_work_conn, MPI.SUM, 0, comm)

    # mean_size_work_groups_all = MPI.Reduce(mean_size_work_groups, MPI.SUM, 0, comm)
    # mean_size_work_group_all = MPI.Reduce(mean_size_work_group, MPI.SUM, 0, comm)

    # println("Age groups: $(age_groups_all)")
    # println("Collectives: $(collective_nums_all)")
    # println("Households: $(household_nums_all)")
    # println("Ig level: $(mean_ig_level_all / size_all)")
    # println("Infected: $(num_of_infected_all)")
    # println("Work conn: $(mean_num_of_work_conn_all / size_work_con_all)")
    # println("Work groups: $(mean_size_work_groups_all)")
    # println("Work group agents: $(mean_size_work_group_all / mean_size_work_groups_all)")
    # MPI.Barrier(comm)

    if comm_rank == 0
        println("Simulation...")
    end
    @time run_simulation(
        comm_rank, comm, all_agents, viruses, viral_loads,
        collectives, temp_influences, duration_parameter,
        susceptibility_parameters, immunity_durations, etiology, false)
    MPI.Barrier(comm)
end

main()
