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
include("util/burnin.jl")

function f(x, mu, sigma)
    dist = Normal(mu, sigma)
    return cdf(dist, x + 0.5) - cdf(dist, x - 0.5)
end

function log_g(x, mu, sigma)
    -log(sqrt(2 * pi) * sigma) - 0.5 * ((x - mu) / sigma)^2
end

function main()
    println("Initialization...")

    num_threads = nthreads()

    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 2.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.32, 0.16, 365),
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

    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0_mean = mean(infected_data_0[2:53, 21:27], dims = 2)[:, 1]
    infected_data_3_mean = mean(infected_data_3[2:53, 21:27], dims = 2)[:, 1]
    infected_data_7_mean = mean(infected_data_7[2:53, 21:27], dims = 2)[:, 1]
    infected_data_15_mean = mean(infected_data_15[2:53, 21:27], dims = 2)[:, 1]

    num_infected_age_groups_mean = cat(
        infected_data_0_mean,
        infected_data_3_mean,
        infected_data_7_mean,
        infected_data_15_mean,
        dims = 2,
    )

    infected_data_0_sd = std(infected_data_0[2:53, 21:27], dims = 2)[:, 1]
    infected_data_3_sd = std(infected_data_3[2:53, 21:27], dims = 2)[:, 1]
    infected_data_7_sd = std(infected_data_7[2:53, 21:27], dims = 2)[:, 1]
    infected_data_15_sd = std(infected_data_15[2:53, 21:27], dims = 2)[:, 1]

    num_infected_age_groups_sd = cat(
        infected_data_0_sd,
        infected_data_3_sd,
        infected_data_7_sd,
        infected_data_15_sd,
        dims = 2,
    )

    agents = Array{Agent, 1}(undef, num_people)
    thread_rng = [MersenneTwister(i) for i = 1:num_threads]

    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "homes.csv")))
    # Массив для хранения домохозяйств
    households = Array{Household, 1}(undef, num_households)

    kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "kindergartens.csv")))
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

    school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "schools.csv")))
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

    university_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "universities.csv")))
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

    shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "shops.csv")))
    # Массив для хранения магазинов
    shops = Array{Shop, 1}(undef, num_shops)
    for i in 1:size(shop_coords_df, 1)
        shops[i] = Shop(
            shop_coords_df[i, :dist],
            shop_coords_df[i, :x],
            shop_coords_df[i, :y],
            ceil(Int, rand(Gamma(shop_capacity_shape, shop_capacity_scale)))
        )
    end

    restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "restaurants.csv")))
    # Массив для хранения ресторанов/кафе/столовых
    restaurants = Array{Restaurant, 1}(undef, num_restaurants)
    for i in 1:size(restaurant_coords_df, 1)
        restaurants[i] = Restaurant(
            restaurant_coords_df[i, :dist],
            restaurant_coords_df[i, :x],
            restaurant_coords_df[i, :y],
            restaurant_coords_df[i, :seats]
        )
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, kindergartens, schools, viruses, infectivities, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people,
            district_people_households, district_nums)
    end

    @time set_connections(
        agents, households, kindergartens, schools, universities,
        workplaces, thread_rng, num_threads, homes_coords_df)

    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "mcmc", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))

    duration_parameter = duration_parameter_array[size(duration_parameter_array)[1]]
    susceptibility_parameters = [
        susceptibility_parameter_1_array[size(susceptibility_parameter_1_array)[1]],
        susceptibility_parameter_2_array[size(susceptibility_parameter_2_array)[1]],
        susceptibility_parameter_3_array[size(susceptibility_parameter_3_array)[1]],
        susceptibility_parameter_4_array[size(susceptibility_parameter_4_array)[1]],
        susceptibility_parameter_5_array[size(susceptibility_parameter_5_array)[1]],
        susceptibility_parameter_6_array[size(susceptibility_parameter_6_array)[1]],
        susceptibility_parameter_7_array[size(susceptibility_parameter_7_array)[1]],
    ]
    temperature_parameters = -[
        temperature_parameter_1_array[size(temperature_parameter_1_array)[1]],
        temperature_parameter_2_array[size(temperature_parameter_2_array)[1]],
        temperature_parameter_3_array[size(temperature_parameter_3_array)[1]],
        temperature_parameter_4_array[size(temperature_parameter_4_array)[1]],
        temperature_parameter_5_array[size(temperature_parameter_5_array)[1]],
        temperature_parameter_6_array[size(temperature_parameter_6_array)[1]],
        temperature_parameter_7_array[size(temperature_parameter_7_array)[1]],
    ]

    duration_parameter_prior_mean = 4.708649537853532
    susceptibility_parameters_prior_means = [4.791077491179754, 4.801204516560952, 5.277449916720067, 7.005768331227963, 6.87462448433526, 6.161149335090182, 6.232429844021741]
    temperature_parameters_prior_means = [-0.9813131313131312, -0.6699003080680871, -0.03232323232323232, -0.37724434921845895, -0.12687954242389426, -0.13323867452062765, -0.6061108567674399]

    duration_parameter_prior_sd = 0.2
    susceptibility_parameters_prior_sds = [
        0.1,
        0.1,
        0.1,
        0.1,
        0.1,
        0.1,
        0.1]
    temperature_parameters_prior_sds = [
        0.03,
        0.03,
        0.03,
        0.03,
        0.03,
        0.03,
        0.03]

    accept_num = 0
    local_rejected_num = 0

    deltas = [0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]

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
        num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, households,
        shops, restaurants, infectivities, temp_influences, duration_parameter,
        susceptibility_parameters, etiology, false)

    num_infected_age_groups = sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :]
    S_abs = sum(abs.(num_infected_age_groups - num_infected_age_groups_mean))
    S_square = sum((num_infected_age_groups - num_infected_age_groups_mean).^2)
    
    num_infected_age_groups = sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :]
    prob_prev_prior = log_g(duration_parameter, duration_parameter_prior_mean, duration_parameter_prior_sd)
    for i = 1:7
        prob_prev_prior += log_g(susceptibility_parameters[i], susceptibility_parameters_prior_means[i], susceptibility_parameters_prior_sds[i])
        prob_prev_prior += log_g(temperature_parameters[i], temperature_parameters_prior_means[i], temperature_parameters_prior_sds[i])
    end

    prob_prev_age_groups = zeros(Float64, 4, 52)
    for i in 1:52
        for j in 1:4
            prob_prev_age_groups[j, i] = log_g(num_infected_age_groups[i, j], num_infected_age_groups_mean[i, j], num_infected_age_groups_sd[i, j])
        end
    end

    open("mcmc/output.txt", "a") do io
        println(io, "n = ", 0)
        println(io, "S_abs: ", S_abs)
        println(io, "S_square: ", S_square)
        println(io)
    end

    n = 1
    N = 1000
    while n <= N
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

        @time num_infected_age_groups_viruses = run_simulation(
            num_threads, thread_rng, start_agent_ids, end_agent_ids, agents, households,
            shops, restaurants, infectivities, temp_influences, duration_parameter,
            susceptibility_parameters, etiology, false)

        num_infected_age_groups = sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :]
        S_abs = sum(abs.(num_infected_age_groups - num_infected_age_groups_mean))
        S_square = sum((num_infected_age_groups - num_infected_age_groups_mean).^2)

        prob_prior = log_g(duration_parameter, duration_parameter_prior_mean, duration_parameter_prior_sd)
        for i = 1:7
            prob_prior += log_g(susceptibility_parameters[i], susceptibility_parameters_prior_means[i], susceptibility_parameters_prior_sds[i])
            prob_prior += log_g(temperature_parameters[i], temperature_parameters_prior_means[i], temperature_parameters_prior_sds[i])
        end

        prob_age_groups = zeros(Float64, 4, 52)
        for i in 1:52
            for j in 1:4
                prob_age_groups[j, i] = log_g(num_infected_age_groups[i, j], num_infected_age_groups_mean[i, j], num_infected_age_groups_sd[i, j])
            end
        end

        accept_prob = 0.0
        for i in 1:52
            for j in 1:4
                accept_prob += prob_age_groups[j, i] - prob_prev_age_groups[j, i]
            end
        end
        accept_prob += prob_prior - prob_prev_prior
        accept_prob_final = min(1.0, exp(accept_prob))

        open("mcmc/output.txt", "a") do io
            println(io, "n = ", n)
            println(io, "Accept prob exp: ", accept_prob)
            println(io, "Accept prob: ", accept_prob_final)
            println(io, "S_abs: ", S_abs)
            println(io, "S_square: ", S_square)
            println(io, "Dur: ", duration_parameter_candidate)
            println(io, "Suscept: ", [
                susceptibility_parameter_1_candidate,
                susceptibility_parameter_2_candidate,
                susceptibility_parameter_3_candidate,
                susceptibility_parameter_4_candidate,
                susceptibility_parameter_5_candidate,
                susceptibility_parameter_6_candidate,
                susceptibility_parameter_7_candidate])
            println(io, "Temp: ", [
                temperature_parameter_1_candidate,
                temperature_parameter_2_candidate,
                temperature_parameter_3_candidate,
                temperature_parameter_4_candidate,
                temperature_parameter_5_candidate,
                temperature_parameter_6_candidate,
                temperature_parameter_7_candidate])
            println(io)
        end

        if rand(Float64) < accept_prob_final || local_rejected_num > 10
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
            prob_prev_prior = prob_prior

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

        if n % 2 == 0
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
        end

        reset_population(
            agents,
            num_threads,
            thread_rng,
            start_agent_ids,
            end_agent_ids,
            infectivities,
            viruses)
        
        println("Accept rate: ", accept_num / n)
        n += 1
    end
end

main()
