using Base.Threads
using Distributions
using Random
using DelimitedFiles
using DataFrames
using CSV

include("global/variables.jl")

include("model/virus.jl")
include("model/agent.jl")
include("model/group.jl")
include("model/household.jl")
include("model/workplace.jl")
include("model/school.jl")
include("model/public_space.jl")
include("model/initialization.jl")
include("model/simulation.jl")
include("model/connections.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

include("util/reset.jl")

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
        # FluA
        Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 12,  8.8, 3.748, 4, 14,  4.6, 3.5, 2.3,  0.41, 0.52, 0.61,  270.0, 90.0),
        # FluB
        Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 12,  7.8, 2.94, 4, 14,  4.7, 3.5, 2.4,  0.41, 0.52, 0.61,  270.0, 90.0),
        # RV
        Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 12,  11.4, 6.25, 4, 14,  3.5, 2.6, 1.8,  0.19, 0.24, 0.28,  60.0, 20.0),
        # RSV
        Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 12,  9.3, 4.0, 4, 14,  6.0, 4.5, 3.0,  0.26, 0.33, 0.39,  60.0, 20.0),
        # AdV
        Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 12,  9.0, 3.92, 4, 14,  4.1, 3.1, 2.1,  0.15, 0.19, 0.22,  90.0, 30.0),
        # PIV
        Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 12,  8.0, 3.1, 4, 14,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  90.0, 30.0),
        # CoV
        Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 12,  7.5, 2.9, 4, 14,  4.9, 3.7, 2.5,  0.22, 0.28, 0.33,  120.0, 40.0)]

    # Начальные доли инфицированных
    initially_infected = [4896 / 272834, 3615 / 319868, 2906 / 559565, 14928 / 8920401]
    # Вероятности случайного инфицирования
    random_infection_probabilities = [0.0015, 0.0012, 0.00045, 0.000001]
    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    recovered_duration_mean = 12.0
    recovered_duration_sd = 4.0
    # Продолжительности контактов в домохозяйствах
    # Укороченные для различных коллективов и полная: Kinder, School, College, Work, Full
    mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
    # Продолжительности контактов в прочих коллективах
    other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
    # Параметры, отвечающие за связи на рабочих местах
    zipf_max_size = 994
    num_barabasi_albert_attachments = 6

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

    college_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "colleges.csv")))
    # Массив для хранения школ
    colleges = Array{School, 1}(undef, num_colleges)
    for i in 1:size(college_coords_df, 1)
        colleges[i] = School(
            3,
            college_coords_df[i, :dist],
            college_coords_df[i, :x],
            college_coords_df[i, :y],
        )
    end

    # Массив для хранения фирм
    workplaces = Workplace[]

    shop_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "shops.csv")))
    # Массив для хранения магазинов
    shops = Array{PublicSpace, 1}(undef, num_shops)
    for i in 1:size(shop_coords_df, 1)
        shops[i] = PublicSpace(
            shop_coords_df[i, :dist],
            shop_coords_df[i, :x],
            shop_coords_df[i, :y],
            ceil(Int, rand(Gamma(shop_capacity_shape, shop_capacity_scale))),
            shop_num_groups,
        )
    end

    restaurant_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "restaurants.csv")))
    # Массив для хранения ресторанов/кафе/столовых
    restaurants = Array{PublicSpace, 1}(undef, num_restaurants)
    for i in 1:size(restaurant_coords_df, 1)
        restaurants[i] = PublicSpace(
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
            agents, households, viruses, initially_infected, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households, district_nums)
    end

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df)

    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))

    duration_parameter = duration_parameter_array[end]
    susceptibility_parameters = [
        susceptibility_parameter_1_array[end],
        susceptibility_parameter_2_array[end],
        susceptibility_parameter_3_array[end],
        susceptibility_parameter_4_array[end],
        susceptibility_parameter_5_array[end],
        susceptibility_parameter_6_array[end],
        susceptibility_parameter_7_array[end],
    ]
    temperature_parameters = -[
        temperature_parameter_1_array[end],
        temperature_parameter_2_array[end],
        temperature_parameter_3_array[end],
        temperature_parameter_4_array[end],
        temperature_parameter_5_array[end],
        temperature_parameter_6_array[end],
        temperature_parameter_7_array[end],
    ]

    duration_parameter_prior_mean = 3.5214965986394575
    susceptibility_parameters_prior_means = [5.562201607915895, 5.760239125953412, 5.892160379303236, 7.768025149453722, 7.772195423623994, 6.932838589981448, 7.372510822510822]
    temperature_parameters_prior_means = [-0.9462413729128016, -0.7259224902082045, -0.11562564419707275, -0.2841331684188827, -0.06545454545454546, -0.059562358276643974, -0.7648299319727891]

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

    @time num_infected_age_groups_viruses = run_simulation(
        num_threads, thread_rng, agents, viruses, households, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        symptomatic_probabilities_children, symptomatic_probabilities_teenagers,
        symptomatic_probabilities_adults, random_infection_probabilities,
        immunity_duration_sds, etiology, false)

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

    open("parameters/output.txt", "a") do io
        println(io, "n = ", 0)
        println(io, "S_abs: ", S_abs)
        println(io, "S_square: ", S_square)
        println(io)
    end

    n = 1
    N = 1000
    while n <= N
        duration_parameter_candidate = exp(rand(Normal(log(duration_parameter_array[end]), deltas[1])))

        susceptibility_parameter_1_candidate = exp(rand(Normal(log(susceptibility_parameter_1_array[end]), deltas[2])))
        susceptibility_parameter_2_candidate = exp(rand(Normal(log(susceptibility_parameter_2_array[end]), deltas[3])))
        susceptibility_parameter_3_candidate = exp(rand(Normal(log(susceptibility_parameter_3_array[end]), deltas[4])))
        susceptibility_parameter_4_candidate = exp(rand(Normal(log(susceptibility_parameter_4_array[end]), deltas[5])))
        susceptibility_parameter_5_candidate = exp(rand(Normal(log(susceptibility_parameter_5_array[end]), deltas[6])))
        susceptibility_parameter_6_candidate = exp(rand(Normal(log(susceptibility_parameter_6_array[end]), deltas[7])))
        susceptibility_parameter_7_candidate = exp(rand(Normal(log(susceptibility_parameter_7_array[end]), deltas[8])))

        x = temperature_parameter_1_array[end]
        y = rand(Normal(log(x / (1 - x)), deltas[9]))
        temperature_parameter_1_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_2_array[end]
        y = rand(Normal(log(x / (1 - x)), deltas[10]))
        temperature_parameter_2_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_3_array[end]
        y = rand(Normal(log(x / (1 - x)), deltas[11]))
        temperature_parameter_3_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_4_array[end]
        y = rand(Normal(log(x / (1 - x)), deltas[12]))
        temperature_parameter_4_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_5_array[end]
        y = rand(Normal(log(x / (1 - x)), deltas[13]))
        temperature_parameter_5_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_6_array[end]
        y = rand(Normal(log(x / (1 - x)), deltas[14]))
        temperature_parameter_6_candidate = exp(y) / (1 + exp(y))

        x = temperature_parameter_7_array[end]
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

        @time num_infected_age_groups_viruses = run_simulation(
            num_threads, thread_rng, agents, viruses, households, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities, etiology, false)

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

        open("parameters/output.txt", "a") do io
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
            push!(duration_parameter_array, duration_parameter_array[end])

            push!(susceptibility_parameter_1_array, susceptibility_parameter_1_array[end])
            push!(susceptibility_parameter_2_array, susceptibility_parameter_2_array[end])
            push!(susceptibility_parameter_3_array, susceptibility_parameter_3_array[end])
            push!(susceptibility_parameter_4_array, susceptibility_parameter_4_array[end])
            push!(susceptibility_parameter_5_array, susceptibility_parameter_5_array[end])
            push!(susceptibility_parameter_6_array, susceptibility_parameter_6_array[end])
            push!(susceptibility_parameter_7_array, susceptibility_parameter_7_array[end])

            push!(temperature_parameter_1_array, temperature_parameter_1_array[end])
            push!(temperature_parameter_2_array, temperature_parameter_2_array[end])
            push!(temperature_parameter_3_array, temperature_parameter_3_array[end])
            push!(temperature_parameter_4_array, temperature_parameter_4_array[end])
            push!(temperature_parameter_5_array, temperature_parameter_5_array[end])
            push!(temperature_parameter_6_array, temperature_parameter_6_array[end])
            push!(temperature_parameter_7_array, temperature_parameter_7_array[end])
            
            local_rejected_num += 1
        end

        if n % 2 == 0
            writedlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), duration_parameter_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), susceptibility_parameter_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), susceptibility_parameter_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), susceptibility_parameter_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), susceptibility_parameter_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), susceptibility_parameter_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), susceptibility_parameter_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), susceptibility_parameter_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), temperature_parameter_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), temperature_parameter_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), temperature_parameter_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), temperature_parameter_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), temperature_parameter_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), temperature_parameter_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), temperature_parameter_7_array, ',')
        end

        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                initially_infected,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
            )
        end
        
        println("Accept rate: ", accept_num / n)
        n += 1
    end
end

main()
