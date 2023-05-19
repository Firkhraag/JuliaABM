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

include("util/moving_avg.jl")
include("util/reset.jl")

function log_g(x, mu, sigma)
    return -log(sqrt(2 * pi) * sigma) - 0.5 * ((x - mu) / sigma)^2
end

# Not used
function main()
    println("Initialization...")

    num_threads = nthreads()

    num_years = 1

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
    # num_barabasi_albert_attachments = 4
    num_barabasi_albert_attachments = 5

    # duration_parameter = 0.23703365311405514
    # susceptibility_parameters = [3.0731248200497587, 3.0315005376748694, 3.4960107319671523, 4.558457619595636, 3.9627987624113588, 3.751417011489648, 4.552998584572433]
    # temperature_parameters = [-0.8747474747474746, -0.9177827791629244, -0.051010101010101006, -0.16313131313131315, -0.003030303030303022, -0.08442528431390421, -0.35326291827502476]
    # immune_memory_susceptibility_level = [0.8944639240038756, 0.9430303030303029, 0.9336363636363636, 0.9363636363636363, 0.8876594776594775, 0.8817572117572116, 0.946060606060606]
    # mean_immunity_duration = [357.979797979798, 326.2129504744517, 133.30517744372466, 99.91903541540344, 105.99775039968745, 148.27512119521802, 162.6804553051528]
    # random_infection_probability = [0.00138, 0.00077, 0.0004, 9.2e-6]


    # 0.844341073010478
    # 0.6891394882784254
    # 0.6124775009090876
    # 0.5964802510558316
    # 0.5819206614642499
    # 0.5675548810778043


    # Dur: 0.2650438619552923
    # Suscept: [3.6433511521367454, 3.3168576850125047, 3.5355742617472266, 4.270434008400693, 3.808848922096886, 4.903505020407575, 4.8087924732680145]
    # Imm mem susc lvl: [0.9929571333458245, 0.7371440466628617, 0.7520424358334441, 0.8667517754579, 0.810720272322192, 0.8198455891572074, 0.5600762318047444]
    # Temp: [0.8776924376093859, 0.8648615346364421, 0.1665298811896958, 0.48520557758548144, 0.29165347167441513, 0.9974125624128285, 0.03178074473191338]
    # Immunity dur: [72.52719329203795, 96.50602649410996, 98.87109533467387, 246.75602978371035, 83.39124480922891, 266.88006846520943, 288.18976818775616]
    # Rand inf prob: [0.0011950656645745936, 0.0008553075112566531, 0.0002907664798315337, 5.4980642918194155e-6]

    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = duration_parameter_array[end]
    
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
    susceptibility_parameters = [
        susceptibility_parameter_1_array[end],
        susceptibility_parameter_2_array[end],
        susceptibility_parameter_3_array[end],
        susceptibility_parameter_4_array[end],
        susceptibility_parameter_5_array[end],
        susceptibility_parameter_6_array[end],
        susceptibility_parameter_7_array[end]
    ]

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
    temperature_parameters = -[
        temperature_parameter_1_array[end],
        temperature_parameter_2_array[end],
        temperature_parameter_3_array[end],
        temperature_parameter_4_array[end],
        temperature_parameter_5_array[end],
        temperature_parameter_6_array[end],
        temperature_parameter_7_array[end]
    ]

    immune_memory_susceptibility_level_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_1_array.csv"), ',', Float64, '\n'))
    immune_memory_susceptibility_level_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_2_array.csv"), ',', Float64, '\n'))
    immune_memory_susceptibility_level_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_3_array.csv"), ',', Float64, '\n'))
    immune_memory_susceptibility_level_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_4_array.csv"), ',', Float64, '\n'))
    immune_memory_susceptibility_level_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_5_array.csv"), ',', Float64, '\n'))
    immune_memory_susceptibility_level_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_6_array.csv"), ',', Float64, '\n'))
    immune_memory_susceptibility_level_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_7_array.csv"), ',', Float64, '\n'))
    immune_memory_susceptibility_level = [
        immune_memory_susceptibility_level_1_array[end],
        immune_memory_susceptibility_level_2_array[end],
        immune_memory_susceptibility_level_3_array[end],
        immune_memory_susceptibility_level_4_array[end],
        immune_memory_susceptibility_level_5_array[end],
        immune_memory_susceptibility_level_6_array[end],
        immune_memory_susceptibility_level_7_array[end]
    ]

    mean_immunity_duration_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "mean_immunity_duration_1_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "mean_immunity_duration_2_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "mean_immunity_duration_3_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "mean_immunity_duration_4_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "mean_immunity_duration_5_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "mean_immunity_duration_6_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "mean_immunity_duration_7_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration = [
        mean_immunity_duration_1_array[end],
        mean_immunity_duration_2_array[end],
        mean_immunity_duration_3_array[end],
        mean_immunity_duration_4_array[end],
        mean_immunity_duration_5_array[end],
        mean_immunity_duration_6_array[end],
        mean_immunity_duration_7_array[end]
    ]

    random_infection_probability_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "random_infection_probability_1_array.csv"), ',', Float64, '\n'))
    random_infection_probability_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "random_infection_probability_2_array.csv"), ',', Float64, '\n'))
    random_infection_probability_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "random_infection_probability_3_array.csv"), ',', Float64, '\n'))
    random_infection_probability_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", "tables", "random_infection_probability_4_array.csv"), ',', Float64, '\n'))
    random_infection_probability = [
        random_infection_probability_1_array[end],
        random_infection_probability_2_array[end],
        random_infection_probability_3_array[end],
        random_infection_probability_4_array[end],
    ]

    viruses = Virus[
        # FluA
        Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_duration[1], mean_immunity_duration[1] * 0.33),
        # FluB
        Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_duration[2], mean_immunity_duration[2] * 0.33),
        # RV
        Virus(1.9, 1.11, 1, 7,  10.1, 7.0, 1, 28,  11.4, 7.7, 1, 28,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_duration[3], mean_immunity_duration[3] * 0.33),
        # RSV
        Virus(4.4, 1.0, 1, 7,  6.5, 2.7, 1, 28,  6.7, 2.8, 1, 28,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_duration[4], mean_immunity_duration[4] * 0.33),
        # AdV
        Virus(5.6, 1.3, 1, 7,  8.0, 5.6, 1, 28,  9.0, 6.3, 1, 28,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_duration[5], mean_immunity_duration[5] * 0.33),
        # PIV
        Virus(2.6, 0.85, 1, 7,  7.0, 2.9, 1, 28,  8.0, 3.4, 1, 28,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_duration[6], mean_immunity_duration[6] * 0.33),
        # CoV
        Virus(3.2, 0.44, 1, 7,  6.5, 4.5, 1, 28,  7.5, 5.2, 1, 28,  4.9, 3.7, 2.5,  0.21, 0.26, 0.32,  mean_immunity_duration[7], mean_immunity_duration[7] * 0.33)]

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

    # With seed
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

    # infected_data_0_sd = infected_data_0_all[2:53, 18:27]
    # infected_data_0_sd_1 = std(etiology[:, 1] .* infected_data_0_sd, dims = 2)[:, 1]
    # # infected_data_0_sd_1 = etiology[:, 1] .* infected_data_0_sd
    # # println()
    # # println(infected_data_0_sd_1[1, 1])
    # # return
    # infected_data_0_sd_2 = std(etiology[:, 2] .* infected_data_0_sd, dims = 2)[:, 1]
    # infected_data_0_sd_3 = std(etiology[:, 3] .* infected_data_0_sd, dims = 2)[:, 1]
    # infected_data_0_sd_4 = std(etiology[:, 4] .* infected_data_0_sd, dims = 2)[:, 1]
    # infected_data_0_sd_5 = std(etiology[:, 5] .* infected_data_0_sd, dims = 2)[:, 1]
    # infected_data_0_sd_6 = std(etiology[:, 6] .* infected_data_0_sd, dims = 2)[:, 1]
    # infected_data_0_sd_7 = std(etiology[:, 7] .* infected_data_0_sd, dims = 2)[:, 1]
    # infected_data_sd_0 = cat(
    #     vec(infected_data_0_sd_1),
    #     vec(infected_data_0_sd_2),
    #     vec(infected_data_0_sd_3),
    #     vec(infected_data_0_sd_4),
    #     vec(infected_data_0_sd_5),
    #     vec(infected_data_0_sd_6),
    #     vec(infected_data_0_sd_7),
    #     dims = 2)

    # infected_data_3_sd = infected_data_3_all[2:53, 18:27]
    # infected_data_3_sd_1 = std(etiology[:, 1] .* infected_data_3_sd, dims = 2)[:, 1]
    # infected_data_3_sd_2 = std(etiology[:, 2] .* infected_data_3_sd, dims = 2)[:, 1]
    # infected_data_3_sd_3 = std(etiology[:, 3] .* infected_data_3_sd, dims = 2)[:, 1]
    # infected_data_3_sd_4 = std(etiology[:, 4] .* infected_data_3_sd, dims = 2)[:, 1]
    # infected_data_3_sd_5 = std(etiology[:, 5] .* infected_data_3_sd, dims = 2)[:, 1]
    # infected_data_3_sd_6 = std(etiology[:, 6] .* infected_data_3_sd, dims = 2)[:, 1]
    # infected_data_3_sd_7 = std(etiology[:, 7] .* infected_data_3_sd, dims = 2)[:, 1]
    # infected_data_sd_3 = cat(
    #     vec(infected_data_3_sd_1),
    #     vec(infected_data_3_sd_2),
    #     vec(infected_data_3_sd_3),
    #     vec(infected_data_3_sd_4),
    #     vec(infected_data_3_sd_5),
    #     vec(infected_data_3_sd_6),
    #     vec(infected_data_3_sd_7),
    #     dims = 2)

    # infected_data_7_sd = infected_data_7_all[2:53, 18:27]
    # infected_data_7_sd_1 = std(etiology[:, 1] .* infected_data_7_sd, dims = 2)[:, 1]
    # infected_data_7_sd_2 = std(etiology[:, 2] .* infected_data_7_sd, dims = 2)[:, 1]
    # infected_data_7_sd_3 = std(etiology[:, 3] .* infected_data_7_sd, dims = 2)[:, 1]
    # infected_data_7_sd_4 = std(etiology[:, 4] .* infected_data_7_sd, dims = 2)[:, 1]
    # infected_data_7_sd_5 = std(etiology[:, 5] .* infected_data_7_sd, dims = 2)[:, 1]
    # infected_data_7_sd_6 = std(etiology[:, 6] .* infected_data_7_sd, dims = 2)[:, 1]
    # infected_data_7_sd_7 = std(etiology[:, 7] .* infected_data_7_sd, dims = 2)[:, 1]
    # infected_data_sd_7 = cat(
    #     vec(infected_data_7_sd_1),
    #     vec(infected_data_7_sd_2),
    #     vec(infected_data_7_sd_3),
    #     vec(infected_data_7_sd_4),
    #     vec(infected_data_7_sd_5),
    #     vec(infected_data_7_sd_6),
    #     vec(infected_data_7_sd_7),
    #     dims = 2)

    # infected_data_15_sd = infected_data_15_all[2:53, 18:27]
    # infected_data_15_sd_1 = std(etiology[:, 1] .* infected_data_15_sd, dims = 2)[:, 1]
    # infected_data_15_sd_2 = std(etiology[:, 2] .* infected_data_15_sd, dims = 2)[:, 1]
    # infected_data_15_sd_3 = std(etiology[:, 3] .* infected_data_15_sd, dims = 2)[:, 1]
    # infected_data_15_sd_4 = std(etiology[:, 4] .* infected_data_15_sd, dims = 2)[:, 1]
    # infected_data_15_sd_5 = std(etiology[:, 5] .* infected_data_15_sd, dims = 2)[:, 1]
    # infected_data_15_sd_6 = std(etiology[:, 6] .* infected_data_15_sd, dims = 2)[:, 1]
    # infected_data_15_sd_7 = std(etiology[:, 7] .* infected_data_15_sd, dims = 2)[:, 1]
    # infected_data_sd_15 = cat(
    #     vec(infected_data_15_sd_1),
    #     vec(infected_data_15_sd_2),
    #     vec(infected_data_15_sd_3),
    #     vec(infected_data_15_sd_4),
    #     vec(infected_data_15_sd_5),
    #     vec(infected_data_15_sd_6),
    #     vec(infected_data_15_sd_7),
    #     dims = 2)

    # num_infected_age_groups_viruses_sd = cat(
    #     infected_data_sd_0,
    #     infected_data_sd_3,
    #     infected_data_sd_7,
    #     infected_data_sd_15,
    #     dims = 3,
    # )

    # println(num_infected_age_groups_viruses_sd[3, 3, 3])
    # println(num_infected_age_groups_viruses_sd[4, 4, 4])
    # return

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

    num_infected_age_groups_viruses_prev = cat(
        infected_data_0_viruses_prev,
        infected_data_3_viruses_prev,
        infected_data_7_viruses_prev,
        infected_data_15_viruses_prev,
        dims = 3,
    )

    for virus_id = 1:length(viruses)
        num_infected_age_groups_viruses_prev[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_infected_age_groups_viruses_prev[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_infected_age_groups_viruses_prev[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_infected_age_groups_viruses_prev[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, num_infected_age_groups_viruses_prev, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households, district_nums,
            immune_memory_susceptibility_level[1], immune_memory_susceptibility_level[2],
            immune_memory_susceptibility_level[3], immune_memory_susceptibility_level[4],
            immune_memory_susceptibility_level[5], immune_memory_susceptibility_level[6],
            immune_memory_susceptibility_level[7])
    end

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, num_barabasi_albert_attachments)

    # get_stats(agents, workplaces)
    # return

    println("Simulation...")

    @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses_model, activities_infections, rt, num_schools_closed, num_infected_districts = run_simulation(
        num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        mean_household_contact_durations, household_contact_duration_sds,
        other_contact_duration_shapes, other_contact_duration_scales,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, random_infection_probability,
        recovered_duration_mean, recovered_duration_sd, num_years, false,
        immune_memory_susceptibility_level[1], immune_memory_susceptibility_level[2],
        immune_memory_susceptibility_level[3], immune_memory_susceptibility_level[4],
        immune_memory_susceptibility_level[5], immune_memory_susceptibility_level[6],
        immune_memory_susceptibility_level[7])


    accept_num = 0
    local_rejected_num = 0

    # duration_parameter_delta = 0.1
    # susceptibility_parameter_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    # temperature_parameter_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    # immune_memory_susceptibility_level_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    # mean_immunity_duration_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    # random_infection_probability_deltas = [0.1, 0.1, 0.1, 0.1]

    duration_parameter_delta = 0.03
    susceptibility_parameter_deltas = [0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03]
    temperature_parameter_deltas = [0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03]
    immune_memory_susceptibility_level_deltas = [0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03]
    mean_immunity_duration_deltas = [0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03]
    random_infection_probability_deltas = [0.03, 0.03, 0.03, 0.03]

    # prob_prev_age_groups = zeros(Float64, 7, 4, 52 * num_years)
    # prob_prev = 0.0
    # for i in 1:(52 * num_years)
    #     for j in 1:4
    #         for k in 1:7
    #             prob_prev += log_g(num_infected_age_groups_viruses[i, k, j], observed_num_infected_age_groups_viruses[i, k, j], sqrt(observed_num_infected_age_groups_viruses[i, k, j]) + 0.001)
    #         end
    #     end
    # end

    nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    nMAE_prev = nMAE

    # open("parameters/output.txt", "a") do io
    #     println(io, "n = ", 0)
    #     println(io, "nMAE = ", nMAE)
    #     println(io)
    # end

    # n = 1
    # n = 51
    n = 541
    N = 1000
    while n <= N
        # Duration parameter
        # duration_parameter_candidate = exp(rand(Normal(log(duration_parameter_array[end]), duration_parameter_delta)))


        # duration_parameter_candidate = exp(rand(Normal(log(duration_parameter_array[end]), duration_parameter_delta)))

        # susceptibility_parameter_1_candidate = exp(rand(Normal(log(susceptibility_parameter_1_array[end]), susceptibility_parameter_deltas[1])))
        # susceptibility_parameter_2_candidate = exp(rand(Normal(log(susceptibility_parameter_2_array[end]), susceptibility_parameter_deltas[2])))
        # susceptibility_parameter_3_candidate = exp(rand(Normal(log(susceptibility_parameter_3_array[end]), susceptibility_parameter_deltas[3])))
        # susceptibility_parameter_4_candidate = exp(rand(Normal(log(susceptibility_parameter_4_array[end]), susceptibility_parameter_deltas[4])))
        # susceptibility_parameter_5_candidate = exp(rand(Normal(log(susceptibility_parameter_5_array[end]), susceptibility_parameter_deltas[5])))
        # susceptibility_parameter_6_candidate = exp(rand(Normal(log(susceptibility_parameter_6_array[end]), susceptibility_parameter_deltas[6])))
        # susceptibility_parameter_7_candidate = exp(rand(Normal(log(susceptibility_parameter_7_array[end]), susceptibility_parameter_deltas[7])))

        # temperature_parameter_1_candidate = -exp(rand(Normal(log(temperature_parameter_1_array[end]),temperature_parameter_deltas[1])))
        # temperature_parameter_2_candidate = -exp(rand(Normal(log(temperature_parameter_2_array[end]),temperature_parameter_deltas[2])))
        # temperature_parameter_3_candidate = -exp(rand(Normal(log(temperature_parameter_3_array[end]),temperature_parameter_deltas[3])))
        # temperature_parameter_4_candidate = -exp(rand(Normal(log(temperature_parameter_4_array[end]),temperature_parameter_deltas[4])))
        # temperature_parameter_5_candidate = -exp(rand(Normal(log(temperature_parameter_5_array[end]),temperature_parameter_deltas[5])))
        # temperature_parameter_6_candidate = -exp(rand(Normal(log(temperature_parameter_6_array[end]),temperature_parameter_deltas[6])))
        # temperature_parameter_7_candidate = -exp(rand(Normal(log(temperature_parameter_7_array[end]),temperature_parameter_deltas[7])))

        # immune_memory_susceptibility_level_parameter_1_candidate = exp(rand(Normal(log(immune_memory_susceptibility_level_parameter_1_array[end]), immune_memory_susceptibility_level_parameter_deltas[1])))
        # immune_memory_susceptibility_level_parameter_2_candidate = exp(rand(Normal(log(immune_memory_susceptibility_level_parameter_2_array[end]), immune_memory_susceptibility_level_parameter_deltas[2])))
        # immune_memory_susceptibility_level_parameter_3_candidate = exp(rand(Normal(log(immune_memory_susceptibility_level_parameter_3_array[end]), immune_memory_susceptibility_level_parameter_deltas[3])))
        # immune_memory_susceptibility_level_parameter_4_candidate = exp(rand(Normal(log(immune_memory_susceptibility_level_parameter_4_array[end]), immune_memory_susceptibility_level_parameter_deltas[4])))
        # immune_memory_susceptibility_level_parameter_5_candidate = exp(rand(Normal(log(immune_memory_susceptibility_level_parameter_5_array[end]), immune_memory_susceptibility_level_parameter_deltas[5])))
        # immune_memory_susceptibility_level_parameter_6_candidate = exp(rand(Normal(log(immune_memory_susceptibility_level_parameter_6_array[end]), immune_memory_susceptibility_level_parameter_deltas[6])))
        # immune_memory_susceptibility_level_parameter_7_candidate = exp(rand(Normal(log(immune_memory_susceptibility_level_parameter_7_array[end]), immune_memory_susceptibility_level_parameter_deltas[7])))

        # mean_immunity_duration_parameter_1_candidate = exp(rand(Normal(log(mean_immunity_duration_parameter_1_array[end]), mean_immunity_duration_parameter_deltas[1])))
        # mean_immunity_duration_parameter_2_candidate = exp(rand(Normal(log(mean_immunity_duration_parameter_2_array[end]), mean_immunity_duration_parameter_deltas[2])))
        # mean_immunity_duration_parameter_3_candidate = exp(rand(Normal(log(mean_immunity_duration_parameter_3_array[end]), mean_immunity_duration_parameter_deltas[3])))
        # mean_immunity_duration_parameter_4_candidate = exp(rand(Normal(log(mean_immunity_duration_parameter_4_array[end]), mean_immunity_duration_parameter_deltas[4])))
        # mean_immunity_duration_parameter_5_candidate = exp(rand(Normal(log(mean_immunity_duration_parameter_5_array[end]), mean_immunity_duration_parameter_deltas[5])))
        # mean_immunity_duration_parameter_6_candidate = exp(rand(Normal(log(mean_immunity_duration_parameter_6_array[end]), mean_immunity_duration_parameter_deltas[6])))
        # mean_immunity_duration_parameter_7_candidate = exp(rand(Normal(log(mean_immunity_duration_parameter_7_array[end]), mean_immunity_duration_parameter_deltas[7])))

        # random_infection_probability_1_candidate = exp(rand(Normal(log(random_infection_probability_1_array[end]), random_infection_probability_deltas[1])))
        # random_infection_probability_2_candidate = exp(rand(Normal(log(random_infection_probability_2_array[end]), random_infection_probability_deltas[2])))
        # random_infection_probability_3_candidate = exp(rand(Normal(log(random_infection_probability_3_array[end]), random_infection_probability_deltas[3])))
        # random_infection_probability_4_candidate = exp(rand(Normal(log(random_infection_probability_4_array[end]), random_infection_probability_deltas[4])))



        # Duration parameter
        x = duration_parameter_array[end]
        y = rand(Normal(log((x - 0.1) / (1 - x)), duration_parameter_delta))
        duration_parameter_candidate = (exp(y) + 0.1) / (1 + exp(y))


        # Susceptibility parameter
        x = susceptibility_parameter_1_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[1]))
        susceptibility_parameter_1_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_2_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[2]))
        susceptibility_parameter_2_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_3_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[3]))
        susceptibility_parameter_3_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_4_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[4]))
        susceptibility_parameter_4_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_4_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[4]))
        susceptibility_parameter_4_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_5_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[5]))
        susceptibility_parameter_5_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_6_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[6]))
        susceptibility_parameter_6_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_7_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[7]))
        susceptibility_parameter_7_candidate = (7 * exp(y) + 1) / (1 + exp(y))


        # Temperature_parameter
        x = temperature_parameter_1_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[1]))
        temperature_parameter_1_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_2_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[2]))
        temperature_parameter_2_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_3_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[3]))
        temperature_parameter_3_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_4_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[4]))
        temperature_parameter_4_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_5_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[5]))
        temperature_parameter_5_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_6_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[6]))
        temperature_parameter_6_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_7_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[7]))
        temperature_parameter_7_candidate = (exp(y) + 0.01) / (1 + exp(y))


        # Immune memory susceptibility
        x = immune_memory_susceptibility_level_1_array[end]
        y = rand(Normal(log((x - 0.5) / (1 - x)), immune_memory_susceptibility_level_deltas[1]))
        immune_memory_susceptibility_level_1_candidate = (exp(y) + 0.5) / (1 + exp(y))

        x = immune_memory_susceptibility_level_2_array[end]
        y = rand(Normal(log((x - 0.5) / (1 - x)), immune_memory_susceptibility_level_deltas[2]))
        immune_memory_susceptibility_level_2_candidate = (exp(y) + 0.5) / (1 + exp(y))

        x = immune_memory_susceptibility_level_3_array[end]
        y = rand(Normal(log((x - 0.5) / (1 - x)), immune_memory_susceptibility_level_deltas[3]))
        immune_memory_susceptibility_level_3_candidate = (exp(y) + 0.5) / (1 + exp(y))

        x = immune_memory_susceptibility_level_4_array[end]
        y = rand(Normal(log((x - 0.5) / (1 - x)), immune_memory_susceptibility_level_deltas[4]))
        immune_memory_susceptibility_level_4_candidate = (exp(y) + 0.5) / (1 + exp(y))

        x = immune_memory_susceptibility_level_5_array[end]
        y = rand(Normal(log((x - 0.5) / (1 - x)), immune_memory_susceptibility_level_deltas[5]))
        immune_memory_susceptibility_level_5_candidate = (exp(y) + 0.5) / (1 + exp(y))

        x = immune_memory_susceptibility_level_6_array[end]
        y = rand(Normal(log((x - 0.5) / (1 - x)), immune_memory_susceptibility_level_deltas[6]))
        immune_memory_susceptibility_level_6_candidate = (exp(y) + 0.5) / (1 + exp(y))

        x = immune_memory_susceptibility_level_7_array[end]
        y = rand(Normal(log((x - 0.5) / (1 - x)), immune_memory_susceptibility_level_deltas[7]))
        immune_memory_susceptibility_level_7_candidate = (exp(y) + 0.5) / (1 + exp(y))


        # Mean immunity duration
        x = mean_immunity_duration_1_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[1]))
        mean_immunity_duration_1_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_2_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[2]))
        mean_immunity_duration_2_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_3_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[3]))
        mean_immunity_duration_3_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_4_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[4]))
        mean_immunity_duration_4_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_5_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[5]))
        mean_immunity_duration_5_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_6_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[6]))
        mean_immunity_duration_6_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_7_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[7]))
        mean_immunity_duration_7_candidate = (365 * exp(y) + 30) / (1 + exp(y))
        

        # Random infection probability
        x = random_infection_probability_1_array[end]
        y = rand(Normal(log((x - 0.001) / (0.002 - x)), random_infection_probability_deltas[1]))
        random_infection_probability_1_candidate = (0.002 * exp(y) + 0.001) / (1 + exp(y))

        x = random_infection_probability_2_array[end]
        y = rand(Normal(log((x - 0.0005) / (0.001 - x)), random_infection_probability_deltas[2]))
        random_infection_probability_2_candidate = (0.001 * exp(y) + 0.0005) / (1 + exp(y))

        x = random_infection_probability_3_array[end]
        y = rand(Normal(log((x - 0.0002) / (0.0005 - x)), random_infection_probability_deltas[3]))
        random_infection_probability_3_candidate = (0.0005 * exp(y) + 0.0002) / (1 + exp(y))

        x = random_infection_probability_4_array[end]
        y = rand(Normal(log((x - 0.000005) / (0.00001 - x)), random_infection_probability_deltas[4]))
        random_infection_probability_4_candidate = (0.00001 * exp(y) + 0.000005) / (1 + exp(y))


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
        immune_memory_susceptibility_level = [
            immune_memory_susceptibility_level_1_candidate,
            immune_memory_susceptibility_level_2_candidate,
            immune_memory_susceptibility_level_3_candidate,
            immune_memory_susceptibility_level_4_candidate,
            immune_memory_susceptibility_level_5_candidate,
            immune_memory_susceptibility_level_6_candidate,
            immune_memory_susceptibility_level_7_candidate,
        ]
        mean_immunity_duration = [
            mean_immunity_duration_1_candidate,
            mean_immunity_duration_2_candidate,
            mean_immunity_duration_3_candidate,
            mean_immunity_duration_4_candidate,
            mean_immunity_duration_5_candidate,
            mean_immunity_duration_6_candidate,
            mean_immunity_duration_7_candidate,
        ]
        random_infection_probability = [
            random_infection_probability_1_candidate,
            random_infection_probability_2_candidate,
            random_infection_probability_3_candidate,
            random_infection_probability_4_candidate,
        ]

        for k = 1:length(viruses)
            viruses[k].mean_immunity_duration = mean_immunity_duration[k]
            viruses[k].immunity_duration_sd = mean_immunity_duration[k] * 0.33
        end

        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_infected_age_groups_viruses_prev,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
                immune_memory_susceptibility_level[1],
                immune_memory_susceptibility_level[2],
                immune_memory_susceptibility_level[3],
                immune_memory_susceptibility_level[4],
                immune_memory_susceptibility_level[5],
                immune_memory_susceptibility_level[6],
                immune_memory_susceptibility_level[7],
            )
        end

        @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses_model, activities_infections, rt, num_schools_closed, num_infected_districts = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probability,
            recovered_duration_mean, recovered_duration_sd, num_years, false,
            immune_memory_susceptibility_level[1], immune_memory_susceptibility_level[2],
            immune_memory_susceptibility_level[3], immune_memory_susceptibility_level[4],
            immune_memory_susceptibility_level[5], immune_memory_susceptibility_level[6],
            immune_memory_susceptibility_level[7])

        nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)

        # prob = 0.0
        # for i in 1:(52 * num_years)
        #     for j in 1:4
        #         for k in 1:7
        #             prob += log_g(num_infected_age_groups_viruses[i, k, j], observed_num_infected_age_groups_viruses[i, k, j], sqrt(observed_num_infected_age_groups_viruses[i, k, j]) + 0.001)
        #         end
        #     end
        # end

        # accept_prob = exp(prob - prob_prev)
        accept_prob = nMAE < nMAE_prev ? 1 : 0

        open("parameters/output.txt", "a") do io
            println(io, "n = ", n)
            # println(io, "Exp pow: ", prob - prob_prev)
            # println(io, "Exp pow curr: ", prob)
            # println(io, "Accept prob: ", accept_prob)
            println(io, "nMAE = ", nMAE)
            println(io, "Dur: ", duration_parameter_candidate)
            println(io, "Suscept: ", [
                susceptibility_parameter_1_candidate,
                susceptibility_parameter_2_candidate,
                susceptibility_parameter_3_candidate,
                susceptibility_parameter_4_candidate,
                susceptibility_parameter_5_candidate,
                susceptibility_parameter_6_candidate,
                susceptibility_parameter_7_candidate])
            println(io, "Imm mem susc lvl: ", [
                immune_memory_susceptibility_level_1_candidate,
                immune_memory_susceptibility_level_2_candidate,
                immune_memory_susceptibility_level_3_candidate,
                immune_memory_susceptibility_level_4_candidate,
                immune_memory_susceptibility_level_5_candidate,
                immune_memory_susceptibility_level_6_candidate,
                immune_memory_susceptibility_level_7_candidate])
            println(io, "Temp: ", [
                temperature_parameter_1_candidate,
                temperature_parameter_2_candidate,
                temperature_parameter_3_candidate,
                temperature_parameter_4_candidate,
                temperature_parameter_5_candidate,
                temperature_parameter_6_candidate,
                temperature_parameter_7_candidate])
            println(io, "Immunity dur: ", [
                mean_immunity_duration_1_candidate,
                mean_immunity_duration_2_candidate,
                mean_immunity_duration_3_candidate,
                mean_immunity_duration_4_candidate,
                mean_immunity_duration_5_candidate,
                mean_immunity_duration_6_candidate,
                mean_immunity_duration_7_candidate,
            ])
            println(io, "Rand inf prob: ", [
                random_infection_probability_1_candidate,
                random_infection_probability_2_candidate,
                random_infection_probability_3_candidate,
                random_infection_probability_4_candidate,
            ])
            println(io)
        end

        if accept_prob == 1 || local_rejected_num >= 10
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

            push!(immune_memory_susceptibility_level_1_array, immune_memory_susceptibility_level_1_candidate)
            push!(immune_memory_susceptibility_level_2_array, immune_memory_susceptibility_level_2_candidate)
            push!(immune_memory_susceptibility_level_3_array, immune_memory_susceptibility_level_3_candidate)
            push!(immune_memory_susceptibility_level_4_array, immune_memory_susceptibility_level_4_candidate)
            push!(immune_memory_susceptibility_level_5_array, immune_memory_susceptibility_level_5_candidate)
            push!(immune_memory_susceptibility_level_6_array, immune_memory_susceptibility_level_6_candidate)
            push!(immune_memory_susceptibility_level_7_array, immune_memory_susceptibility_level_7_candidate)

            push!(mean_immunity_duration_1_array, mean_immunity_duration_1_candidate)
            push!(mean_immunity_duration_2_array, mean_immunity_duration_2_candidate)
            push!(mean_immunity_duration_3_array, mean_immunity_duration_3_candidate)
            push!(mean_immunity_duration_4_array, mean_immunity_duration_4_candidate)
            push!(mean_immunity_duration_5_array, mean_immunity_duration_5_candidate)
            push!(mean_immunity_duration_6_array, mean_immunity_duration_6_candidate)
            push!(mean_immunity_duration_7_array, mean_immunity_duration_7_candidate)

            push!(random_infection_probability_1_array, random_infection_probability_1_candidate)
            push!(random_infection_probability_2_array, random_infection_probability_2_candidate)
            push!(random_infection_probability_3_array, random_infection_probability_3_candidate)
            push!(random_infection_probability_4_array, random_infection_probability_4_candidate)

            # prob_prev = prob
            nMAE_prev = nMAE

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

            push!(immune_memory_susceptibility_level_1_array, immune_memory_susceptibility_level_1_array[end])
            push!(immune_memory_susceptibility_level_2_array, immune_memory_susceptibility_level_2_array[end])
            push!(immune_memory_susceptibility_level_3_array, immune_memory_susceptibility_level_3_array[end])
            push!(immune_memory_susceptibility_level_4_array, immune_memory_susceptibility_level_4_array[end])
            push!(immune_memory_susceptibility_level_5_array, immune_memory_susceptibility_level_5_array[end])
            push!(immune_memory_susceptibility_level_6_array, immune_memory_susceptibility_level_6_array[end])
            push!(immune_memory_susceptibility_level_7_array, immune_memory_susceptibility_level_7_array[end])

            push!(mean_immunity_duration_1_array, mean_immunity_duration_1_array[end])
            push!(mean_immunity_duration_2_array, mean_immunity_duration_2_array[end])
            push!(mean_immunity_duration_3_array, mean_immunity_duration_3_array[end])
            push!(mean_immunity_duration_4_array, mean_immunity_duration_4_array[end])
            push!(mean_immunity_duration_5_array, mean_immunity_duration_5_array[end])
            push!(mean_immunity_duration_6_array, mean_immunity_duration_6_array[end])
            push!(mean_immunity_duration_7_array, mean_immunity_duration_7_array[end])

            push!(random_infection_probability_1_array, random_infection_probability_1_array[end])
            push!(random_infection_probability_2_array, random_infection_probability_2_array[end])
            push!(random_infection_probability_3_array, random_infection_probability_3_array[end])
            push!(random_infection_probability_4_array, random_infection_probability_4_array[end])
            
            local_rejected_num += 1
        end

        if n % 5 == 0
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

            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_1_array.csv"), immune_memory_susceptibility_level_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_2_array.csv"), immune_memory_susceptibility_level_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_3_array.csv"), immune_memory_susceptibility_level_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_4_array.csv"), immune_memory_susceptibility_level_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_5_array.csv"), immune_memory_susceptibility_level_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_6_array.csv"), immune_memory_susceptibility_level_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "immune_memory_susceptibility_level_7_array.csv"), immune_memory_susceptibility_level_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_1_array.csv"), mean_immunity_duration_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_2_array.csv"), mean_immunity_duration_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_3_array.csv"), mean_immunity_duration_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_4_array.csv"), mean_immunity_duration_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_5_array.csv"), mean_immunity_duration_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_6_array.csv"), mean_immunity_duration_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "mean_immunity_duration_7_array.csv"), mean_immunity_duration_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "random_infection_probability_1_array.csv"), random_infection_probability_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "random_infection_probability_2_array.csv"), random_infection_probability_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "random_infection_probability_3_array.csv"), random_infection_probability_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", "tables", "random_infection_probability_4_array.csv"), random_infection_probability_4_array, ',')
        end
        
        println("Accept rate: ", accept_num / n)
        n += 1
    end
end

main()
