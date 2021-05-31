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

function multiple_simulations(
    agents::Vector{Agent},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
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
        (6.5, 6.8), # duration
        (2.7, 3.3), # susceptibility1
        (2.7, 3.3), # susceptibility2
        (3.2, 3.8), # susceptibility3
        (4.6, 5.4), # susceptibility4
        (4.6, 5.4), # susceptibility5
        (3.6, 4.4), # susceptibility6
        (3.6, 4.4), # susceptibility7
        (-0.95, -0.85), # temp1
        (-0.85, -0.75), # temp2
        (-0.11, -0.01), # temp3
        (-0.45, -0.3), # temp4
        (-0.11, -0.01), # temp5
        (-0.11, -0.01), # temp6
        (-0.9, -0.8)]) # temp7

    # points = scaleLHC(latin_hypercube_plan,[
    #     (6.2, 6.7), # duration
    #     (3.1, 3.6), # susceptibility1
    #     (3.5, 4.0), # susceptibility2
    #     (3.0, 4.0), # susceptibility3
    #     (4.6, 5.4), # susceptibility4
    #     (4.0, 4.5), # susceptibility5
    #     (4.0, 4.5), # susceptibility6
    #     (4.0, 4.5), # susceptibility7
    #     (-0.8, -0.9), # temp1
    #     (-0.7, -0.8), # temp2
    #     (-0.11, -0.01), # temp3
    #     (-0.5, -0.4), # temp4
    #     (-0.11, -0.01), # temp5
    #     (-0.11, -0.01), # temp6
    #     (-0.9, -0.8)]) # temp7

    RSS_min = 4.3770455548375e10
    
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
            num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
            temp_influences, duration_parameter,
            susceptibility_parameters, etiology,
            incidence_data_mean_0, incidence_data_mean_3,
            incidence_data_mean_7, incidence_data_mean_15)

        if RSS < RSS_min
            RSS_min = RSS
        end

        open("output/output.txt", "a") do io
            println(io, "RSS: ", RSS)
            println(io, "duration_parameter ", duration_parameter)
            println(io, "susceptibility_parameters ", susceptibility_parameters)
            println(io, "temperature_parameters ", temperature_parameters)
            println(io)
        end

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

            agent.FluA_immunity = false
            agent.FluB_immunity = false
            agent.CoV_immunity = false
    
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
    println("RSS_min: ", RSS_min)
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
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.16),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.16),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.3),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.3),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.3),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.8, 0.3),
        Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.3)]

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
    # Параметры (RSS: 5.081978631875e9) 7.145395508875e9
    # duration_parameter = 6.75
    # temperature_parameters = Float64[-0.9, -0.8, -0.05, -0.35, -0.05, -0.05, -0.85]
    # susceptibility_parameters = Float64[3.05, 3.1, 3.47, 4.9, 4.7, 4.02, 3.88]

    # RSS: 4.874078926875e9   7.043697269875e9
    # duration_parameter = 6.590361445783133
    # temperature_parameters = Float64[-0.86285140562249, -0.7556224899598394, -0.024457831325301202, -0.43975903614457834, -0.06060240963855421, -0.039317269076305214, -0.846987951807229]
    # susceptibility_parameters = Float64[3.3907630522088355, 3.3714859437751006, 3.7670682730923692, 5.077510040160643, 4.26425702811245, 4.347389558232932, 4.383534136546185]

    # RSS 5.422644491375e9 5.431303046875e9
    # duration_parameter = 6.533333333333333
    # susceptibility_parameters = [3.317171717171717, 3.51010101010101, 3.595959595959596, 4.858585858585858, 4.111111111111111, 4.484848484848484, 4.404040404040404]
    # temperature_parameters = [-0.8252525252525253, -0.7565656565656566, -0.08373737373737374, -0.44646464646464645, -0.03424242424242424, -0.014040404040404048, -0.88989898989899]

    # 5.599750365375e9
    duration_parameter = 6.570469798657718
    susceptibility_parameters = [3.1308724832214763, 3.2798657718120805, 3.3691275167785237, 4.906040268456376, 4.664429530201342, 4.024161073825503, 3.6214765100671142]
    temperature_parameters = [-0.8983221476510067, -0.786241610738255, -0.10932885906040268, -0.3422818791946309, -0.10261744966442952, -0.0710738255033557, -0.8053691275167786]


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
        num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
        temp_influences, duration_parameter,
        susceptibility_parameters, etiology,
        incidence_data_mean_0, incidence_data_mean_3,
        incidence_data_mean_7, incidence_data_mean_15)
    println("RSS: ", RSS)

    # Multiple runs
    # num_runs = 150
    # multiple_simulations(agents, num_threads, thread_rng, num_runs,
    #     start_agent_ids, end_agent_ids, infectivities,
    #     etiology, incidence_data_mean_0,
    #     incidence_data_mean_3, incidence_data_mean_7, incidence_data_mean_15,
    #     temperature, min_temp, max_min_temp, viruses)

end

main()
