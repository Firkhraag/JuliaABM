using Base.Threads
using Distributions
using Random
using DelimitedFiles
using DataFrames
using LatinHypercubeSampling
using CSV
using JLD

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
include("model/contacts.jl")
include("model/connections.jl")

include("data/district_households.jl")
include("data/district_people.jl")
include("data/district_people_households.jl")
include("data/district_nums.jl")
include("data/temperature.jl")
include("data/etiology.jl")

include("util/moving_avg.jl")
include("util/reset.jl")

function multiple_simulations(
    agents::Vector{Agent},
    households::Vector{Household},
    schools::Vector{School},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    num_runs::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    etiology::Matrix{Float64},
    temperature::Vector{Float64},
    viruses::Vector{Virus},
    num_infected_age_groups_viruses_prev_data::Array{Float64, 3},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    duration_parameter_default::Float64,
    susceptibility_parameters_default::Vector{Float64},
    temperature_parameters_default::Vector{Float64},
    num_infected_age_groups_viruses::Array{Float64, 3},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    random_infection_probabilities_default::Vector{Float64},
    mean_immunity_durations::Vector{Float64},
    num_years::Int,
    immune_memory_susceptibility_levels_default::Vector{Float64},
    surrogate_training::Bool,
)
    num_files = 0
    if surrogate_training
        for i in readdir(joinpath(@__DIR__, "..", "surrogate", "tables", "initial"))
            if isfile(i)
                num_files +=1
            end
        end
    end

    num_parameters = 33
    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 500)

    if duration_parameter_default > 0.95
        duration_parameter_default = 0.95
    end
    if duration_parameter_default < 0.15
        duration_parameter_default = 0.15
    end

    for i = 1:7
        if susceptibility_parameters_default[i] < 1.1
            susceptibility_parameters_default[i] = 1.1
        elseif susceptibility_parameters_default[i] > 7.9
            susceptibility_parameters_default[i] = 7.9
        end

        if temperature_parameters_default[i] < -0.95
            temperature_parameters_default[i] = -0.95
        elseif temperature_parameters_default[i] > -0.05
            temperature_parameters_default[i] = -0.05
        end

        if immune_memory_susceptibility_levels_default[i] > 0.95
            immune_memory_susceptibility_levels_default[i] = 0.95
        elseif immune_memory_susceptibility_levels_default[i] < 0.05
            immune_memory_susceptibility_levels_default[i] = 0.05
        end

        if mean_immunity_durations[i] > 355.0
            mean_immunity_durations[i] = 355.0
        elseif mean_immunity_durations[i] < 35.0
            mean_immunity_durations[i] = 35.0
        end
    end

    points = scaleLHC(latin_hypercube_plan, [
        (duration_parameter_default - 0.05, duration_parameter_default + 0.05),
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
        (temperature_parameters_default[7] - 0.05, temperature_parameters_default[7] + 0.05),
        (immune_memory_susceptibility_levels_default[1] - 0.03, immune_memory_susceptibility_levels_default[1] + 0.03),
        (immune_memory_susceptibility_levels_default[2] - 0.03, immune_memory_susceptibility_levels_default[2] + 0.03),
        (immune_memory_susceptibility_levels_default[3] - 0.03, immune_memory_susceptibility_levels_default[3] + 0.03),
        (immune_memory_susceptibility_levels_default[4] - 0.03, immune_memory_susceptibility_levels_default[4] + 0.03),
        (immune_memory_susceptibility_levels_default[5] - 0.03, immune_memory_susceptibility_levels_default[5] + 0.03),
        (immune_memory_susceptibility_levels_default[6] - 0.03, immune_memory_susceptibility_levels_default[6] + 0.03),
        (immune_memory_susceptibility_levels_default[7] - 0.03, immune_memory_susceptibility_levels_default[7] + 0.03),
        (mean_immunity_durations[1] - 5.0, mean_immunity_durations[1] + 5.0),
        (mean_immunity_durations[2] - 5.0, mean_immunity_durations[2] + 5.0),
        (mean_immunity_durations[3] - 5.0, mean_immunity_durations[3] + 5.0),
        (mean_immunity_durations[4] - 5.0, mean_immunity_durations[4] + 5.0),
        (mean_immunity_durations[5] - 5.0, mean_immunity_durations[5] + 5.0),
        (mean_immunity_durations[6] - 5.0, mean_immunity_durations[6] + 5.0),
        (mean_immunity_durations[7] - 5.0, mean_immunity_durations[7] + 5.0),
        (random_infection_probabilities_default[1] - random_infection_probabilities_default[1] * 0.05, random_infection_probabilities_default[1] + random_infection_probabilities_default[1] * 0.05),
        (random_infection_probabilities_default[2] - random_infection_probabilities_default[2] * 0.05, random_infection_probabilities_default[2] + random_infection_probabilities_default[2] * 0.05),
        (random_infection_probabilities_default[3] - random_infection_probabilities_default[3] * 0.05, random_infection_probabilities_default[3] + random_infection_probabilities_default[3] * 0.05),
        (random_infection_probabilities_default[4] - random_infection_probabilities_default[4] * 0.05, random_infection_probabilities_default[4] + random_infection_probabilities_default[4] * 0.05),
    ])

    if surrogate_training
        points = scaleLHC(latin_hypercube_plan, [
            (0.1, 1.0), # duration_parameter
            (1.0, 7.0), # susceptibility_parameters
            (1.0, 7.0),
            (1.0, 7.0),
            (1.0, 7.0),
            (1.0, 7.0),
            (1.0, 7.0),
            (1.0, 7.0),
            (-1.0, -0.01), # temperature_parameters
            (-1.0, -0.01),
            (-1.0, -0.01),
            (-1.0, -0.01),
            (-1.0, -0.01),
            (-1.0, -0.01),
            (-1.0, -0.01),
            (0.5, 1.0), # immune_memory_susceptibility_levels
            (0.5, 1.0),
            (0.5, 1.0),
            (0.5, 1.0),
            (0.5, 1.0),
            (0.5, 1.0),
            (0.5, 1.0),
            (30, 365), # mean_immunity_durations
            (30, 365),
            (30, 365),
            (30, 365),
            (30, 365),
            (30, 365),
            (30, 365),
            (0.001, 0.002), # random_infection_probabilities
            (0.0005, 0.001),
            (0.0002, 0.0005),
            (0.000005, 0.00001),
        ])

        writedlm(joinpath(@__DIR__, "..", "surrogate", "tables", "parameters.csv"), points, ',')
    end

    nMAE_min = 1.0e12

    for i = 1:num_runs
        println(i)

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]
        immune_memory_susceptibility_levels =  points[i, 16:22]
        for k = 1:length(viruses)
            viruses[k].mean_immunity_duration = points[i, 22 + k]
            viruses[k].immunity_duration_sd = points[i, 22 + k] * 0.33
        end
        random_infection_probabilities = points[i, 30:33]

        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_infected_age_groups_viruses_prev_data,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
                immune_memory_susceptibility_levels[1],
                immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3],
                immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5],
                immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7],
            )
        end

        @time observed_num_infected_age_groups_viruses, _, __, ___, ____ = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, false,
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])

        nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    
        if nMAE < nMAE_min
            nMAE_min = nMAE
        end

        println("nMAE_cur = ", nMAE)
        println("nMAE_min = ", nMAE_min)

        open("output/output.txt", "a") do io
            println(io, "nMAE = ", nMAE)
            println(io, "duration_parameter = ", duration_parameter)
            println(io, "susceptibility_parameters = ", susceptibility_parameters)
            println(io, "temperature_parameters = ", temperature_parameters)
            println(io, "immune_memory_susceptibility_levels = ", immune_memory_susceptibility_levels)
            println(io, "mean_immunity_durations = ", [points[i, 23], points[i, 24], points[i, 25], points[i, 26], points[i, 27], points[i, 28], points[i, 29]])
            println(io, "random_infection_probabilities = ", random_infection_probabilities)
            println(io)
        end

        if surrogate_training
            save(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i + num_files).jld"),
                "observed_cases", observed_num_infected_age_groups_viruses,
                "duration_parameter", duration_parameter,
                "susceptibility_parameters", susceptibility_parameters,
                "temperature_parameters", temperature_parameters,
                "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
                "mean_immunity_durations", [points[i, 23], points[i, 24], points[i, 25], points[i, 26], points[i, 27], points[i, 28], points[i, 29]],
                "random_infection_probabilities", random_infection_probabilities)
        end
    end
end

function main()
    println("Initialization...")

    num_years = 2
    # num_years = 1

    surrogate_training = true

    num_threads = nthreads()

    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    recovered_duration_mean = 6.0
    recovered_duration_sd = 2.0
    # Продолжительности контактов в домохозяйствах
    # Укороченные для различных коллективов и полная: Kinder, School, College, Work, Full
    mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
    # Продолжительности контактов в прочих коллективах
    other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
    # Параметры, отвечающие за связи на рабочих местах
    firm_min_size = 1
    firm_max_size = 1000
    num_barabasi_albert_attachments = 5

    # nMAE = 0.5127395196087101
    duration_parameter = 0.23703365311405514
    susceptibility_parameters = [3.0731248200497587, 3.0315005376748694, 3.4960107319671523, 4.558457619595636, 3.9627987624113588, 3.751417011489648, 4.552998584572433]
    temperature_parameters = [-0.8747474747474746, -0.9177827791629244, -0.051010101010101006, -0.16313131313131315, -0.003030303030303022, -0.08442528431390421, -0.35326291827502476]
    immune_memory_susceptibility_levels = [0.8944639240038756, 0.9430303030303029, 0.9336363636363636, 0.9363636363636363, 0.8876594776594775, 0.8817572117572116, 0.946060606060606]
    mean_immunity_durations = [357.979797979798, 326.2129504744517, 133.30517744372466, 99.91903541540344, 105.99775039968745, 148.27512119521802, 162.6804553051528]
    random_infection_probabilities = [0.00138, 0.00077, 0.0004, 9.2e-6]

    viruses = Virus[
        # FluA
        Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        # FluB
        Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
        # RV
        Virus(1.9, 1.11, 1, 7,  10.1, 7.0, 1, 28,  11.4, 7.7, 1, 28,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
        # RSV
        Virus(4.4, 1.0, 1, 7,  6.5, 2.7, 1, 28,  6.7, 2.8, 1, 28,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
        # AdV
        Virus(5.6, 1.3, 1, 7,  8.0, 5.6, 1, 28,  9.0, 6.3, 1, 28,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
        # PIV
        Virus(2.6, 0.85, 1, 7,  7.0, 2.9, 1, 28,  8.0, 3.4, 1, 28,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
        # CoV
        Virus(3.2, 0.44, 1, 7,  6.5, 4.5, 1, 28,  7.5, 5.2, 1, 28,  4.9, 3.7, 2.5,  0.21, 0.26, 0.32,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

    # Число домохозяйств каждого типа по районам
    district_households = get_district_households()
    # Число людей в каждой группе по районам
    district_people = get_district_people()
    # Число людей в домохозяйствах по районам
    district_people_households = get_district_people_households()
    # Распределение вирусов в течение года
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
    
    infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0 = infected_data_0_all[2:53, 24:(23 + num_years)]
    infected_data_0_1 = etiology[:, 1] .* infected_data_0
    infected_data_0_2 = etiology[:, 2] .* infected_data_0
    infected_data_0_3 = etiology[:, 3] .* infected_data_0
    infected_data_0_4 = etiology[:, 4] .* infected_data_0
    infected_data_0_5 = etiology[:, 5] .* infected_data_0
    infected_data_0_6 = etiology[:, 6] .* infected_data_0
    infected_data_0_7 = etiology[:, 7] .* infected_data_0
    infected_data_0_viruses = cat(
        vec(infected_data_0_1),
        vec(infected_data_0_2),
        vec(infected_data_0_3),
        vec(infected_data_0_4),
        vec(infected_data_0_5),
        vec(infected_data_0_6),
        vec(infected_data_0_7),
        dims = 2)

    infected_data_3 = infected_data_3_all[2:53, 24:(23 + num_years)]
    infected_data_3_1 = etiology[:, 1] .* infected_data_3
    infected_data_3_2 = etiology[:, 2] .* infected_data_3
    infected_data_3_3 = etiology[:, 3] .* infected_data_3
    infected_data_3_4 = etiology[:, 4] .* infected_data_3
    infected_data_3_5 = etiology[:, 5] .* infected_data_3
    infected_data_3_6 = etiology[:, 6] .* infected_data_3
    infected_data_3_7 = etiology[:, 7] .* infected_data_3
    infected_data_3_viruses = cat(
        vec(infected_data_3_1),
        vec(infected_data_3_2),
        vec(infected_data_3_3),
        vec(infected_data_3_4),
        vec(infected_data_3_5),
        vec(infected_data_3_6),
        vec(infected_data_3_7),
        dims = 2)

    infected_data_7 = infected_data_7_all[2:53, 24:(23 + num_years)]
    infected_data_7_1 = etiology[:, 1] .* infected_data_7
    infected_data_7_2 = etiology[:, 2] .* infected_data_7
    infected_data_7_3 = etiology[:, 3] .* infected_data_7
    infected_data_7_4 = etiology[:, 4] .* infected_data_7
    infected_data_7_5 = etiology[:, 5] .* infected_data_7
    infected_data_7_6 = etiology[:, 6] .* infected_data_7
    infected_data_7_7 = etiology[:, 7] .* infected_data_7
    infected_data_7_viruses = cat(
        vec(infected_data_7_1),
        vec(infected_data_7_2),
        vec(infected_data_7_3),
        vec(infected_data_7_4),
        vec(infected_data_7_5),
        vec(infected_data_7_6),
        vec(infected_data_7_7),
        dims = 2)

    infected_data_15 = infected_data_15_all[2:53, 24:(23 + num_years)]
    infected_data_15_1 = etiology[:, 1] .* infected_data_15
    infected_data_15_2 = etiology[:, 2] .* infected_data_15
    infected_data_15_3 = etiology[:, 3] .* infected_data_15
    infected_data_15_4 = etiology[:, 4] .* infected_data_15
    infected_data_15_5 = etiology[:, 5] .* infected_data_15
    infected_data_15_6 = etiology[:, 6] .* infected_data_15
    infected_data_15_7 = etiology[:, 7] .* infected_data_15
    infected_data_15_viruses = cat(
        vec(infected_data_15_1),
        vec(infected_data_15_2),
        vec(infected_data_15_3),
        vec(infected_data_15_4),
        vec(infected_data_15_5),
        vec(infected_data_15_6),
        vec(infected_data_15_7),
        dims = 2)

    num_infected_age_groups_viruses = cat(
        infected_data_0_viruses,
        infected_data_3_viruses,
        infected_data_7_viruses,
        infected_data_15_viruses,
        dims = 3,
    )


    infected_data_0_prev = infected_data_0_all[2:53, 23]
    infected_data_0_1_prev = etiology[:, 1] .* infected_data_0_prev
    infected_data_0_2_prev = etiology[:, 2] .* infected_data_0_prev
    infected_data_0_3_prev = etiology[:, 3] .* infected_data_0_prev
    infected_data_0_4_prev = etiology[:, 4] .* infected_data_0_prev
    infected_data_0_5_prev = etiology[:, 5] .* infected_data_0_prev
    infected_data_0_6_prev = etiology[:, 6] .* infected_data_0_prev
    infected_data_0_7_prev = etiology[:, 7] .* infected_data_0_prev
    infected_data_0_viruses_prev = cat(
        vec(infected_data_0_1_prev),
        vec(infected_data_0_2_prev),
        vec(infected_data_0_3_prev),
        vec(infected_data_0_4_prev),
        vec(infected_data_0_5_prev),
        vec(infected_data_0_6_prev),
        vec(infected_data_0_7_prev),
        dims = 2)

    infected_data_3_prev = infected_data_3_all[2:53, 23]
    infected_data_3_1_prev = etiology[:, 1] .* infected_data_3_prev
    infected_data_3_2_prev = etiology[:, 2] .* infected_data_3_prev
    infected_data_3_3_prev = etiology[:, 3] .* infected_data_3_prev
    infected_data_3_4_prev = etiology[:, 4] .* infected_data_3_prev
    infected_data_3_5_prev = etiology[:, 5] .* infected_data_3_prev
    infected_data_3_6_prev = etiology[:, 6] .* infected_data_3_prev
    infected_data_3_7_prev = etiology[:, 7] .* infected_data_3_prev
    infected_data_3_viruses_prev = cat(
        vec(infected_data_3_1_prev),
        vec(infected_data_3_2_prev),
        vec(infected_data_3_3_prev),
        vec(infected_data_3_4_prev),
        vec(infected_data_3_5_prev),
        vec(infected_data_3_6_prev),
        vec(infected_data_3_7_prev),
        dims = 2)

    infected_data_7_prev = infected_data_7_all[2:53, 23]
    infected_data_7_1_prev = etiology[:, 1] .* infected_data_7_prev
    infected_data_7_2_prev = etiology[:, 2] .* infected_data_7_prev
    infected_data_7_3_prev = etiology[:, 3] .* infected_data_7_prev
    infected_data_7_4_prev = etiology[:, 4] .* infected_data_7_prev
    infected_data_7_5_prev = etiology[:, 5] .* infected_data_7_prev
    infected_data_7_6_prev = etiology[:, 6] .* infected_data_7_prev
    infected_data_7_7_prev = etiology[:, 7] .* infected_data_7_prev
    infected_data_7_viruses_prev = cat(
        vec(infected_data_7_1_prev),
        vec(infected_data_7_2_prev),
        vec(infected_data_7_3_prev),
        vec(infected_data_7_4_prev),
        vec(infected_data_7_5_prev),
        vec(infected_data_7_6_prev),
        vec(infected_data_7_7_prev),
        dims = 2)

    infected_data_15_prev = infected_data_15_all[2:53, 23]
    infected_data_15_1_prev = etiology[:, 1] .* infected_data_15_prev
    infected_data_15_2_prev = etiology[:, 2] .* infected_data_15_prev
    infected_data_15_3_prev = etiology[:, 3] .* infected_data_15_prev
    infected_data_15_4_prev = etiology[:, 4] .* infected_data_15_prev
    infected_data_15_5_prev = etiology[:, 5] .* infected_data_15_prev
    infected_data_15_6_prev = etiology[:, 6] .* infected_data_15_prev
    infected_data_15_7_prev = etiology[:, 7] .* infected_data_15_prev
    infected_data_15_viruses_prev = cat(
        vec(infected_data_15_1_prev),
        vec(infected_data_15_2_prev),
        vec(infected_data_15_3_prev),
        vec(infected_data_15_4_prev),
        vec(infected_data_15_5_prev),
        vec(infected_data_15_6_prev),
        vec(infected_data_15_7_prev),
        dims = 2)

    num_infected_age_groups_viruses_prev_data = cat(
        infected_data_0_viruses_prev,
        infected_data_3_viruses_prev,
        infected_data_7_viruses_prev,
        infected_data_15_viruses_prev,
        dims = 3,
    )

    for virus_id = 1:length(viruses)
        num_infected_age_groups_viruses_prev_data[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_infected_age_groups_viruses_prev_data[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_infected_age_groups_viruses_prev_data[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_infected_age_groups_viruses_prev_data[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, num_infected_age_groups_viruses_prev_data, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households, district_nums,
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])
    end

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, num_barabasi_albert_attachments)

    println("Simulation...")

    num_runs = 1000
    multiple_simulations(
        agents,
        households,
        schools,
        num_threads,
        thread_rng,
        num_runs,
        start_agent_ids,
        end_agent_ids,
        etiology,
        temperature,
        viruses,
        num_infected_age_groups_viruses_prev_data,
        mean_household_contact_durations,
        household_contact_duration_sds,
        other_contact_duration_shapes,
        other_contact_duration_scales,
        isolation_probabilities_day_1,
        isolation_probabilities_day_2,
        isolation_probabilities_day_3,
        duration_parameter,
        susceptibility_parameters,
        temperature_parameters,
        num_infected_age_groups_viruses,
        recovered_duration_mean,
        recovered_duration_sd,
        random_infection_probabilities,
        mean_immunity_durations,
        num_years,
        immune_memory_susceptibility_levels,
        surrogate_training,
    )
end

main()
