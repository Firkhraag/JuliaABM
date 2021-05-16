using Distributed
@everywhere using Distributions
@everywhere using Random

@everywhere include("src/model/virus.jl")
@everywhere include("src/model/collective.jl")
@everywhere include("src/model/agent.jl")
@everywhere include("src/model/initialization.jl")
@everywhere include("src/model/simulation_distributed.jl")

@everywhere include("src/data/district_households.jl")
@everywhere include("src/data/district_people.jl")
@everywhere include("src/data/district_people_households.jl")
@everywhere include("src/data/district_nums.jl")
@everywhere include("src/data/temperature.jl")
@everywhere include("src/data/etiology.jl")

@everywhere function initialize_population(taskid::Int, ntasks::Int)
    # Параметры
    duration_parameter = 7.05
    temperature_parameters = Float64[-0.8, -0.8, -0.05, -0.64, -0.2, -0.05, -0.8]   
    # temperature_parameters = Float64[-0.8, -0.8, -0.1, -0.64, -0.2, -0.1, -0.8]   
    susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]
    # susceptibility_parameters = Float64[2.1, 2.1, 3.77, 4.89, 4.69, 3.89, 3.77]
    immunity_durations = Int[366, 366, 60, 60, 90, 90, 366]

    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.16),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.16),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.3),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.3),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.3),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 0.3),
        Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.3)]

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

    # Номера районов для MPI процессов
    district_nums = get_district_nums()

    agents = Agent[]
    @time create_population(
        taskid, ntasks, agents, viruses, viral_loads, collectives,
        district_households, district_people, district_people_households, district_nums)

    num_of_people_in_collectives = zeros(Int, 4)
    for agent in agents
        if agent.collective_id == 1
            num_of_people_in_collectives[1] += 1
        elseif agent.collective_id == 2
            num_of_people_in_collectives[2] += 1
        elseif agent.collective_id == 3
            num_of_people_in_collectives[3] += 1
        elseif agent.collective_id == 4
            num_of_people_in_collectives[4] += 1
        end
    end
    println(num_of_people_in_collectives)
    # println(num_of_people_in_collectives[3] / 25)

    # @time run_simulation(
    #     taskid, agents, viruses, viral_loads,
    #     collectives, temp_influences, duration_parameter,
    #     susceptibility_parameters, immunity_durations, etiology, false)
end

function main()
    r = [@spawnat p initialize_population(i, nworkers()) for (i, p) in enumerate(workers())]
    @time [fetch(r[i]) for i in 1:nworkers()]
end

main()

# using Distributed
# @everywhere using Distributions
# @everywhere using Random

# @everywhere include("../model/agent.jl")
# @everywhere include("../model/collective.jl")
# @everywhere include("../model/initialization.jl")
# @everywhere include("../data/district_households.jl")
# @everywhere include("../data/district_people.jl")
# @everywhere include("../data/district_people_households.jl")
# @everywhere include("../data/district_nums.jl")
# @everywhere include("../data/temperature.jl")
# @everywhere include("../data/etiology.jl")

# function main()
#     # Вирусы
#     viruses = Virus[
#         Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.16),
#         Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.16),
#         Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.3),
#         Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.3),
#         Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.3),
#         Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 0.3),
#         Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.3)]

#     # Вирусная нагрузка
#     viral_loads = Array{Float64,4}(undef, 7, 7, 13, 21)
#     for days_infected in -6:14
#         days_infected_index = days_infected + 7
#         for infection_period in 2:14
#             infection_period_index = infection_period - 1
#             for incubation_period in 1:7
#                 min_days_infected = 1 - incubation_period
#                 mean_viral_loads = [4.6, 4.7, 3.5, 6.0, 4.1, 4.7, 4.93]
#                 for i in 1:7
#                     if (days_infected >= min_days_infected) && (days_infected <= infection_period)
#                         viral_loads[i, incubation_period, infection_period_index, days_infected_index] = get_viral_load(
#                             days_infected, incubation_period, infection_period, mean_viral_loads[i])
#                     end
#                 end
#             end
#         end
#     end

#     # Коллективы
#     collectives = Collective[
#         Collective(1, 5.88, 2.52, [[Int[]], [Int[]], [Int[]], [Int[]], [Int[]], [Int[]]]),
#         Collective(2, 4.783, 2.67, [[Int[]], [Int[]], [Int[]], [Int[]], [Int[]], [Int[]],
#             [Int[]], [Int[]], [Int[]], [Int[]], [Int[]]]),
#         Collective(3, 2.1, 3.0, [[Int[]], [Int[]], [Int[]], [Int[]], [Int[]], [Int[]]]),
#         Collective(4, 3.0, 3.0, [[Int[]]])]

#     # Агенты
#     # agents = Agent[]

#     println("Initialization...")
#     r = [@spawnat p create_population(i, nworkers(), Agent[], viruses, viral_loads, collectives) for (i, p) in enumerate(workers())]
#     @time [fetch(r[i]) for i in 1:nworkers()]
# end

# main()

