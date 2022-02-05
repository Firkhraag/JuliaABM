using Base.Threads
using Random
using DelimitedFiles
using Distributions
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
include("util/stats.jl")

function main()
    println("Initialization...")

    num_threads = nthreads()

    n = 10
    disturbance = 0.05
    for i = 1:n
        # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
        isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
        isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
        isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
        for k = 1:length(isolation_probabilities_day_1)
            isolation_probabilities_day_1[k] = isolation_probabilities_day_1[k] + rand(Normal(0.0, disturbance * isolation_probabilities_day_1[k]))
            isolation_probabilities_day_2[k] = isolation_probabilities_day_2[k] + rand(Normal(0.0, disturbance * isolation_probabilities_day_2[k]))
            isolation_probabilities_day_3[k] = isolation_probabilities_day_3[k] + rand(Normal(0.0, disturbance * isolation_probabilities_day_3[k]))
        end
        # Продолжительность резистентного состояния
        recovered_duration_mean = 12.0
        recovered_duration_sd = 4.0
        recovered_duration_mean = recovered_duration_mean + rand(Normal(0.0, disturbance * recovered_duration_mean))
        recovered_duration_sd = 0.33 * recovered_duration_mean

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

        duration_parameter = 3.9010101010101
        duration_parameter = duration_parameter + rand(Normal(0.0, disturbance * duration_parameter))

        susceptibility_parameters = [3.8606060606060617, 3.8828282828282816, 4.398989898989902, 5.903030303030302, 4.550808080808084, 4.357777777777779, 4.8609090909090895]
        for k = 1:length(susceptibility_parameters)
            susceptibility_parameters[k] = susceptibility_parameters[k] + rand(Normal(0.0, disturbance * susceptibility_parameters[k]))
        end

        temperature_parameters = [-0.8181818181818181, -0.8611111111111109, -0.15050505050505047, -0.03434343434343433, -0.058585858585858575, -0.23080808080808082, -0.6464646464646465]
        for k = 1:length(temperature_parameters)
            temperature_parameters[k] = temperature_parameters[k] + rand(Normal(0.0, disturbance * temperature_parameters[k]))
        end

        random_infection_probabilities = [0.000115, 6.82e-5, 4.88e-5, 7.13e-7]
        for k = 1:length(random_infection_probabilities)
            random_infection_probabilities[k] = random_infection_probabilities[k] + rand(Normal(0.0, disturbance * random_infection_probabilities[k]))
        end

        initially_infected = [0.0177, 0.011, 0.0039, 0.0011]
        for k = 1:length(initially_infected)
            initially_infected[k] = initially_infected[k] + rand(Normal(0.0, disturbance * initially_infected[k]))
        end

        mean_immunity_durations = [270.42424242424244, 269.03030303030306, 55.57575757575758, 61.27272727272727, 81.75757575757576, 110.78787878787877, 117.93939393939394]
        for k = 1:length(mean_immunity_durations)
            mean_immunity_durations[k] = mean_immunity_durations[k] + rand(Normal(0.0, disturbance * mean_immunity_durations[k]))
        end

        incubation_period_durations = [1.4, 1.0, 1.9, 4.4, 5.6, 2.6, 3.2]
        for k = 1:length(incubation_period_durations)
            incubation_period_durations[k] = incubation_period_durations[k] + rand(Normal(0.0, disturbance * incubation_period_durations[k]))
        end

        infection_period_durations_child = [4.8, 3.7, 10.1, 7.4, 8.0, 7.0, 6.5]
        for k = 1:length(infection_period_durations_child)
            infection_period_durations_child[k] = infection_period_durations_child[k] + rand(Normal(0.0, disturbance * infection_period_durations_child[k]))
        end

        viruses = Virus[
            # FluA
            Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 12,  8.8, 3.748, 4, 14,  4.6, 3.5, 2.3,  0.3, 0.45, 0.6,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
            # FluB
            Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 12,  7.8, 2.94, 4, 14,  4.7, 3.5, 2.4,  0.3, 0.45, 0.6,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
            # RV
            Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 12,  11.4, 6.25, 4, 14,  3.5, 2.6, 1.8,  0.19, 0.24, 0.28,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
            # RSV
            Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 12,  9.3, 4.0, 4, 14,  6.0, 4.5, 3.0,  0.26, 0.33, 0.39,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
            # AdV
            Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 12,  9.0, 3.92, 4, 14,  4.1, 3.1, 2.1,  0.15, 0.19, 0.22,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
            # PIV
            Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 12,  8.0, 3.1, 4, 14,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
            # CoV
            Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 12,  7.5, 2.9, 4, 14,  4.9, 3.7, 2.5,  0.22, 0.28, 0.33,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

        # viruses = Virus[
        #     # FluA
        #     Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 12,  8.8, 3.748, 4, 14,  4.6, 3.5, 2.3,  0.3, 0.45, 0.6,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        #     # FluB
        #     Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 12,  7.8, 2.94, 4, 14,  4.7, 3.5, 2.4,  0.3, 0.45, 0.6,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
        #     # RV
        #     Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 12,  11.4, 6.25, 4, 14,  3.5, 2.6, 1.8,  0.19, 0.24, 0.28,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
        #     # RSV
        #     Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 12,  9.3, 4.0, 4, 14,  6.0, 4.5, 3.0,  0.26, 0.33, 0.39,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
        #     # AdV
        #     Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 12,  9.0, 3.92, 4, 14,  4.1, 3.1, 2.1,  0.15, 0.19, 0.22,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
        #     # PIV
        #     Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 12,  8.0, 3.1, 4, 14,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
        #     # CoV
        #     Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 12,  7.5, 2.9, 4, 14,  4.9, 3.7, 2.5,  0.22, 0.28, 0.33,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

        # Число домохозяйств каждого типа по районам
        district_households = get_district_households()
        # Число людей в каждой группе по районам
        district_people = get_district_people()
        # Число людей в домохозяйствах по районам
        district_people_households = get_district_people_households()
        # Вероятность случайного инфицирования
        etiology = get_etiology()
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
        # Массив для хранения институтов
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

        @time @threads for thread_id in 1:num_threads
            create_population(
                thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
                agents, households, viruses, initially_infected, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
                homes_coords_df, district_households, district_people, district_people_households, district_nums)
        end

        @time set_connections(
            agents, households, kindergartens, schools, colleges,
            workplaces, thread_rng, num_threads, homes_coords_df,
            zipf_max_size, num_barabasi_albert_attachments)

        println("Simulation...")

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

        @time num_infected_age_groups_viruses = run_simulation(
            num_threads, thread_rng, agents, viruses, households, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities, etiology,
            recovered_duration_mean, recovered_duration_sd, n == 1)

        writedlm(
            joinpath(@__DIR__, "..", "output", "tables", n > 1 ? "age_groups_viruses_data_$(i).csv" : "age_groups_viruses_data.csv"),
            num_infected_age_groups_viruses ./ 10072, ',')
        writedlm(
            joinpath(@__DIR__, "..", "output", "tables", n > 1 ? "infected_data_$(i).csv" : "infected_data.csv"),
            sum(sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1] ./ 10072, ',')
        writedlm(
            joinpath(@__DIR__, "..", "output", "tables", n > 1 ? "etiology_data_$(i).csv" : "etiology_data.csv"),
            sum(num_infected_age_groups_viruses, dims = 3)[:, :, 1] ./ 10072, ',')
        writedlm(
            joinpath(@__DIR__, "..", "output", "tables", n > 1 ? "age_groups_data_$(i).csv" : "age_groups_data.csv"),
            sum(num_infected_age_groups_viruses, dims = 2)[:, 1, :] ./ 10072, ',')

        MAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / (size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3])
        MAPE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean) ./ num_infected_age_groups_viruses_mean) / (size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3])
        RMSE = sqrt(sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)) / sqrt((size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3]))
        nMAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / sum(num_infected_age_groups_viruses_mean)
        S_abs = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean))
        S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

        println("MAE: ", MAE)
        println("MAPE: ", MAPE)
        println("RMSE: ", RMSE)
        println("nMAE: ", nMAE)
        println("S_abs: ", S_abs)
        println("S_square: ", S_square)
    end
end

main()
