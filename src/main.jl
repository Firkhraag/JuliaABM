using Base.Threads
using Distributions
using Random
using DelimitedFiles
using DataFrames
using CSV

include("global/variables.jl")

include("model/virus.jl")
include("model/agent.jl")
include("model/household.jl")
include("model/workplace.jl")
include("model/school.jl")
include("model/restaurant.jl")
include("model/shop.jl")
include("model/initialization.jl")
include("model/simulation.jl")
include("model/contacts.jl")
include("model/connections.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

include("util/burnin.jl")
include("util/reset.jl")
include("util/stats.jl")

function main()
    println("Initialization...")

    num_threads = nthreads()

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

    agents = Array{Agent, 1}(undef, num_agents)

    # With set seed
    thread_rng = [MersenneTwister(i) for i = 1:num_threads]

    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv")))
    # Массив для хранения домохозяйств
    households = Array{Household, 1}(undef, num_households)

    kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
    # Массив для хранения детских садов
    kindergartens = Array{School, 1}(undef, num_kindergartens)
    for i in 1:size(kindergarten_coords_df, 1)
        kindergartens[i] = School(
            1,
            kindergarten_coords_df[i, :dist],
            kindergarten_coords_df[i, :x],
            kindergarten_coords_df[i, :y],
        )
    end

    school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
    # Массив для хранения школ
    schools = Array{School, 1}(undef, num_schools)
    for i in 1:size(school_coords_df, 1)
        schools[i] = School(
            2,
            school_coords_df[i, :dist],
            school_coords_df[i, :x],
            school_coords_df[i, :y],
        )
    end

    university_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "universities.csv")))
    # Массив для хранения школ
    universities = Array{School, 1}(undef, num_universities)
    for i in 1:size(university_coords_df, 1)
        universities[i] = School(
            3,
            university_coords_df[i, :dist],
            university_coords_df[i, :x],
            university_coords_df[i, :y],
        )
    end

    # Массив для хранения фирм
    workplaces = Workplace[]

    shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
    # Массив для хранения продовольственных магазинов
    shops = Array{Shop, 1}(undef, num_shops)
    for i in 1:size(shop_coords_df, 1)
        shops[i] = Shop(
            shop_coords_df[i, :dist],
            shop_coords_df[i, :x],
            shop_coords_df[i, :y],
            ceil(Int, rand(Gamma(shop_capacity_shape, shop_capacity_scale))),
            shop_num_groups,
        )
    end

    restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))
    # Массив для хранения ресторанов/кафе/столовых
    restaurants = Array{Restaurant, 1}(undef, num_restaurants)
    for i in 1:size(restaurant_coords_df, 1)
        restaurants[i] = Restaurant(
            restaurant_coords_df[i, :dist],
            restaurant_coords_df[i, :x],
            restaurant_coords_df[i, :y],
            restaurant_coords_df[i, :seats],
            restaurant_num_groups,
        )
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, infectivities, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people,
            district_people_households, district_nums)
    end

    @time set_connections(
        agents, households, kindergartens, schools, universities,
        workplaces, shops, restaurants, thread_rng,
        num_threads, homes_coords_df)

    # get_stats(agents)

    # return

    println("Simulation...")

    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = mean(duration_parameter_array[burnin:step:size(duration_parameter_array)[1]])
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
    susceptibility_parameters = [
        mean(susceptibility_parameter_1_array[burnin:step:size(susceptibility_parameter_1_array)[1]]),
        mean(susceptibility_parameter_2_array[burnin:step:size(susceptibility_parameter_2_array)[1]]),
        mean(susceptibility_parameter_3_array[burnin:step:size(susceptibility_parameter_3_array)[1]]),
        mean(susceptibility_parameter_4_array[burnin:step:size(susceptibility_parameter_4_array)[1]]),
        mean(susceptibility_parameter_5_array[burnin:step:size(susceptibility_parameter_5_array)[1]]),
        mean(susceptibility_parameter_6_array[burnin:step:size(susceptibility_parameter_6_array)[1]]),
        mean(susceptibility_parameter_7_array[burnin:step:size(susceptibility_parameter_7_array)[1]])
    ]

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
    temperature_parameters = -[
        mean(temperature_parameter_1_array[burnin:step:size(temperature_parameter_1_array)[1]]),
        mean(temperature_parameter_2_array[burnin:step:size(temperature_parameter_2_array)[1]]),
        mean(temperature_parameter_3_array[burnin:step:size(temperature_parameter_3_array)[1]]),
        mean(temperature_parameter_4_array[burnin:step:size(temperature_parameter_4_array)[1]]),
        mean(temperature_parameter_5_array[burnin:step:size(temperature_parameter_5_array)[1]]),
        mean(temperature_parameter_6_array[burnin:step:size(temperature_parameter_6_array)[1]]),
        mean(temperature_parameter_7_array[burnin:step:size(temperature_parameter_7_array)[1]])
    ]

    duration_parameter = 3.634747474747475
    susceptibility_parameters = [5.988080808080809, 5.876666666666667, 6.234747474747475, 7.8397979797979795, 7.859999999999999, 7.101111111111111, 7.005353535353535]
    temperature_parameters = [-0.9176767676767678, -0.6322222222222222, -0.07373737373737374, -0.3527272727272727, -0.03535353535353536, -0.0696969696969697, -0.6197979797979798]

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

    activity_nums = Int[0, 0, 0, 0]
    for agent in agents
        if agent.activity_type == 1
            activity_nums[1] += 1
        elseif agent.activity_type == 2
            activity_nums[2] += 1
        elseif agent.activity_type == 3
            activity_nums[3] += 1
        elseif agent.activity_type == 4
            activity_nums[4] += 1
        end
    end

    writedlm(
        joinpath(@__DIR__, "..", "output", "tables", "activity_sizes.csv"), activity_nums, ',')

    # ----------------------
    # Single run
    # ----------------------
    @time num_infected_age_groups_viruses = run_simulation(
        num_threads, thread_rng, agents, households,
        shops, restaurants, infectivities, temp_influences, duration_parameter,
        susceptibility_parameters, etiology, true)

    writedlm(
        joinpath(@__DIR__, "..", "output", "tables", "age_groups_viruses_data.csv"),
        num_infected_age_groups_viruses ./ 10072, ',')
    writedlm(
        joinpath(@__DIR__, "..", "output", "tables", "infected_data.csv"),
        sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 10072, ',')
    writedlm(
        joinpath(@__DIR__, "..", "output", "tables", "etiology_data.csv"),
        sum(num_infected_age_groups_viruses, dims = 3)[:, :, 1] ./ 10072, ',')
    writedlm(
        joinpath(@__DIR__, "..", "output", "tables", "age_groups_data.csv"),
        sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :] ./ 10072, ',')

    S_abs = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean))
    S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

    println("S: ", S_abs)
    println("S: ", S_square)

    # ----------------------
    # Sensitivity analyses
    # ----------------------
    # multipliers = [0.8, 0.9, 1.1, 1.2]
    # k = -2

    # for m in multipliers
    #     duration_parameter_new = duration_parameter * m
    #     @time num_infected_age_groups_viruses = run_simulation(
    #         num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
    #         temp_influences, duration_parameter_new,
    #         susceptibility_parameters, etiology, false)
    #     writedlm(
    #         joinpath(@__DIR__, "..", "sensitivity", "tables", "infected_data_d_$k.csv"),
    #         sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 10072, ',')
    #     reset_population(
    #         agents,
    #         num_threads,
    #         thread_rng,
    #         start_agent_ids,
    #         end_agent_ids,
    #         infectivities,
    #         viruses)
    #     if k == -1
    #         k = 1
    #     else
    #         k += 1
    #     end
    # end

    # for i in 1:7
    #     k = -2
    #     for m in multipliers
    #         susceptibility_parameters_new = copy(susceptibility_parameters)
    #         susceptibility_parameters_new[i] *= m
    #         @time num_infected_age_groups_viruses = run_simulation(
    #             num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
    #             temp_influences, duration_parameter,
    #             susceptibility_parameters_new, etiology, false)
    #         writedlm(
    #             joinpath(@__DIR__, "..", "sensitivity", "tables", "infected_data_s$(i)_$k.csv"),
    #             sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 10072, ',')
    #         reset_population(
    #             agents,
    #             num_threads,
    #             thread_rng,
    #             start_agent_ids,
    #             end_agent_ids,
    #             infectivities,
    #             viruses)
    #         if k == -1
    #             k = 1
    #         else
    #             k += 1
    #         end
    #     end
    # end

    # values = -[0.25, 0.5, 0.75, 1.0]
    # for i in 1:7
    #     k = -2
    #     for v in values
    #         temperature_parameters_new = copy(temperature_parameters)
    #         temperature_parameters_new[i] = v
    #         temp_influences = Array{Float64,2}(undef, 7, 365)
    #         year_day = 213
    #         for i in 1:365
    #             current_temp = (temperature[year_day] - min_temp) / max_min_temp
    #             for v in 1:7
    #                 temp_influences[v, i] = temperature_parameters_new[v] * current_temp + 1.0
    #             end
    #             if year_day == 365
    #                 year_day = 1
    #             else
    #                 year_day += 1
    #             end
    #         end
            
    #         @time num_infected_age_groups_viruses = run_simulation(
    #             num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, infectivities,
    #             temp_influences, duration_parameter,
    #             susceptibility_parameters, etiology, false)
    #         writedlm(
    #             joinpath(@__DIR__, "..", "sensitivity", "tables", "infected_data_t$(i)_$k.csv"),
    #             sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 10072, ',')
    #         reset_population(
    #             agents,
    #             num_threads,
    #             thread_rng,
    #             start_agent_ids,
    #             end_agent_ids,
    #             infectivities,
    #             viruses)
    #         if k == -1
    #             k = 1
    #         else
    #             k += 1
    #         end
    #     end
    # end
end

main()
