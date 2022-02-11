using Base.Threads
using Distributions
using Random
using DelimitedFiles
using DataFrames
using LatinHypercubeSampling
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
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    num_runs::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    etiology::Matrix{Float64},
    temperature::Vector{Float64},
    viruses::Vector{Virus},
    num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
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
    num_infected_age_groups_viruses_mean::Array{Float64, 3},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    random_infection_probabilities_default::Vector{Float64},
    mean_immunity_durations::Vector{Float64},
)
    num_parameters = 26
    # num_parameters = 7
    # num_parameters = 15
    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 1000)

    for i = 1:7
        if temperature_parameters_default[i] < -0.95
            temperature_parameters_default[i] = -0.95
        elseif temperature_parameters_default[i] > -0.05
            temperature_parameters_default[i] = -0.05
        end
    end

    points = scaleLHC(latin_hypercube_plan, [
        (duration_parameter_default - 0.1, duration_parameter_default + 0.1),
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
        (random_infection_probabilities_default[1] - 0.000001, random_infection_probabilities_default[1] + 0.000001),
        (random_infection_probabilities_default[2] - 0.0000001, random_infection_probabilities_default[2] + 0.0000001),
        (random_infection_probabilities_default[3] - 0.0000001, random_infection_probabilities_default[3] + 0.0000001),
        (random_infection_probabilities_default[4] - 0.00000001, random_infection_probabilities_default[4] + 0.00000001),
        (mean_immunity_durations[1] - 5.0, mean_immunity_durations[1] + 5.0),
        (mean_immunity_durations[2] - 5.0, mean_immunity_durations[2] + 5.0),
        (mean_immunity_durations[3] - 5.0, mean_immunity_durations[3] + 5.0),
        (mean_immunity_durations[4] - 5.0, mean_immunity_durations[4] + 5.0),
        (mean_immunity_durations[5] - 5.0, mean_immunity_durations[5] + 5.0),
        (mean_immunity_durations[6] - 5.0, mean_immunity_durations[6] + 5.0),
        (mean_immunity_durations[7] - 5.0, mean_immunity_durations[7] + 5.0),
    ])

    # points = scaleLHC(latin_hypercube_plan, [
    #     (mean_immunity_durations[1] - 30.0, mean_immunity_durations[1] + 30.0),
    #     (mean_immunity_durations[2] - 30.0, mean_immunity_durations[2] + 30.0),
    #     (mean_immunity_durations[3] - 30.0, mean_immunity_durations[3] + 30.0),
    #     (mean_immunity_durations[4] - 10.0, mean_immunity_durations[4] + 30.0),
    #     (mean_immunity_durations[5] - 30.0, mean_immunity_durations[5] + 30.0),
    #     (mean_immunity_durations[6] - 30.0, mean_immunity_durations[6] + 30.0),
    #     (mean_immunity_durations[7] - 30.0, mean_immunity_durations[7] + 30.0),
    # ])

    # points = scaleLHC(latin_hypercube_plan, [
    #     (duration_parameter_default - 0.05, duration_parameter_default + 0.2),
    #     (susceptibility_parameters_default[1] - 0.2, susceptibility_parameters_default[1] + 0.2),
    #     (susceptibility_parameters_default[2] - 0.2, susceptibility_parameters_default[2] + 0.2),
    #     (susceptibility_parameters_default[3] - 0.2, susceptibility_parameters_default[3] + 0.2),
    #     (susceptibility_parameters_default[4] - 0.2, susceptibility_parameters_default[4] + 0.2),
    #     (susceptibility_parameters_default[5] - 0.2, susceptibility_parameters_default[5] + 0.2),
    #     (susceptibility_parameters_default[6] - 0.2, susceptibility_parameters_default[6] + 0.2),
    #     (susceptibility_parameters_default[7] - 0.2, susceptibility_parameters_default[7] + 0.2),
    #     (temperature_parameters_default[1] - 0.05, temperature_parameters_default[1] + 0.05),
    #     (temperature_parameters_default[2] - 0.05, temperature_parameters_default[2] + 0.05),
    #     (temperature_parameters_default[3] - 0.05, temperature_parameters_default[3] + 0.05),
    #     (temperature_parameters_default[4] - 0.05, temperature_parameters_default[4] + 0.05),
    #     (temperature_parameters_default[5] - 0.05, temperature_parameters_default[5] + 0.05),
    #     (temperature_parameters_default[6] - 0.05, temperature_parameters_default[6] + 0.05),
    #     (temperature_parameters_default[7] - 0.05, temperature_parameters_default[7] + 0.05),
    # ])

    MAE_min = 1.0e10
    RMSE_min = 1.0e10
    nMAE_min = 1.0e10
    S_square_min = 1.0e10

    for i = 1:num_runs
        println(i)

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]
        random_infection_probabilities = points[i, 16:19]

        # duration_parameter = duration_parameter_default
        # susceptibility_parameters = susceptibility_parameters_default
        # temperature_parameters = temperature_parameters_default
        # random_infection_probabilities = random_infection_probabilities_default

        for k = 1:length(viruses)
            viruses[k].mean_immunity_duration = points[i, 19 + k]
            viruses[k].immunity_duration_sd = points[i, 19 + k] * 0.33
            # viruses[k].mean_immunity_duration = points[i, k]
            # viruses[k].immunity_duration_sd = points[i, k] * 0.33
        end

        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
            )
        end

        @time num_infected_age_groups_viruses, rt = run_simulation(
            num_threads, thread_rng, agents, viruses, households, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, false)

        MAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / (size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3])
        RMSE = sqrt(sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)) / sqrt((size(num_infected_age_groups_viruses)[1] * size(num_infected_age_groups_viruses)[2] * size(num_infected_age_groups_viruses)[3]))
        nMAE = sum(abs.(num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean)) / sum(num_infected_age_groups_viruses_mean)
        S_square = sum((num_infected_age_groups_viruses - num_infected_age_groups_viruses_mean).^2)

        if MAE < MAE_min
            MAE_min = MAE
        end
        if RMSE < RMSE_min
            RMSE_min = RMSE
        end
        if nMAE < nMAE_min
            nMAE_min = nMAE
        end
        if S_square < S_square_min
            S_square_min = S_square
        end

        println("Cur")
        println("MAE = ", MAE)
        println("RMSE = ", RMSE)
        println("nMAE = ", nMAE)
        println("S_square = ", S_square)
        println("Min")
        println("MAE_min = ", MAE_min)
        println("RMSE_min = ", RMSE_min)
        println("nMAE_min = ", nMAE_min)
        println("S_square_min = ", S_square_min)

        open("output/output.txt", "a") do io
            println(io, "MAE = ", MAE)
            println(io, "RMSE = ", RMSE)
            println(io, "nMAE = ", nMAE)
            println(io, "S_square = ", S_square)
            println(io, "duration_parameter = ", duration_parameter)
            println(io, "susceptibility_parameters = ", susceptibility_parameters)
            println(io, "temperature_parameters = ", temperature_parameters)
            println(io, "random_infection_probabilities = ", random_infection_probabilities)
            println(io, "mean_immunity_durations = ", [points[i, 20], points[i, 21], points[i, 22], points[i, 23], points[i, 24], points[i, 25], points[i, 26]])
            # println(io, "mean_immunity_durations = ", [points[i, 1], points[i, 2], points[i, 3], points[i, 4], points[i, 5], points[i, 6], points[i, 7]])
            println(io)
        end
    end
end

function main()
    println("Initialization...")

    num_threads = nthreads()

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
    firm_min_size = 0
    firm_max_size = 1000
    num_barabasi_albert_attachments = 5

    # Значения по умолчанию
    # duration_parameter = 3.663254998969285
    # susceptibility_parameters = [3.589352710781283, 3.868491032776746, 3.871603793032368, 5.654308390022673, 4.15125128839415, 3.9633951762523196, 4.8221438878581715]
    # temperature_parameters = [-0.8513378684807256, -0.6863327149041432, -0.16568748711605852, -0.09929911358482786, -0.11180169037311889, -0.19426922284065146, -0.29753865182436623]
    # random_infection_probabilities = [0.00011501051329622756, 6.836359513502371e-5, 4.8910245310245334e-5, 7.143125128839416e-7]
    # mean_immunity_durations = [259.8268398268398, 315.3543599257886, 91.49103277674705, 25.529993815708096, 84.68027210884352, 113.98021026592453, 85.65862708719852]

    # MAE = 844.6623557506414
    # RMSE = 1534.0986503400934
    # nMAE = 0.4864321158370912
    # S_square = 3.4266358220280313e9
    # duration_parameter = 3.7279014636157495
    # susceptibility_parameters = [3.403494124922697, 3.876571840857554, 3.8473613687899437, 5.73107606679035, 4.21185734900021, 3.826021438878582, 4.6665883323026165]
    # temperature_parameters = [-0.8260853432282003, -0.6903731189445472, -0.17982890125747267, -0.034652648938363215, -0.10473098330241182, -0.1548752834467121, -0.3167305710162854]
    # random_infection_probabilities = [0.00011470748299319726, 6.828884766027623e-5, 4.896681096681099e-5, 7.092620078334365e-7]
    # mean_immunity_durations = [254.1702741702741, 316.06143063285924, 89.77386105957534, 22.095650381364663, 80.74087816944959, 117.41455370026796, 92.7293341579056]

    # MAE = 796.7886736674575
    # RMSE = 1403.5143161739395
    # nMAE = 0.45886216873326857
    # S_square = 2.868105146386773e9
    # duration_parameter = 3.7470933828076687
    # susceptibility_parameters = [3.3358173572459293, 3.8492991135848267, 3.872613894042469, 5.768449804164087, 4.176503813646675, 3.7926881055452486, 4.67971964543393]
    # temperature_parameters = [-0.8720449391877962, -0.7353226138940422, -0.1833642547928262, -0.030303030303030304, -0.06988249845392697, -0.198814677386106, -0.30309420737992177]
    # random_infection_probabilities = [0.00011522263450834878, 6.826763553906411e-5, 4.902236652236655e-5, 6.992620078334365e-7]
    # mean_immunity_durations = [249.4733044733044, 315.5058750773037, 94.16780045351473, 24.065347351061632, 82.91259534116676, 116.65697794269221, 88.84044526901671]

    duration_parameter = 3.764265099979386
    susceptibility_parameters = [3.2580395794681514, 3.884652648938362, 3.817058338486913, 5.678550814265098, 4.145190682333544, 3.8139002267573696, 4.7655782312925155]
    temperature_parameters = [-0.9220449391877963, -0.7772418058132341, -0.1949804164089878, -0.0393939393939394, -0.08250876108018959, -0.15083487940630802, -0.3359224902082046]
    random_infection_probabilities = [0.00011537414965986393, 6.832319109461966e-5, 4.910216450216453e-5, 6.985549371263659e-7]
    mean_immunity_durations = [253.96825396825392, 314.95031952174816, 97.14759843331271, 22.70171098742527, 80.84188827045969, 114.48526077097503, 85.45660688517833]

    viruses = Virus[
        # FluA
        Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 21,  8.8, 3.748, 3, 21,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        # FluB
        Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 21,  7.8, 2.94, 3, 21,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
        # RV
        Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 21,  11.4, 6.25, 3, 21,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
        # RSV
        Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 21,  9.3, 4.0, 3, 21,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
        # AdV
        Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 21,  9.0, 3.92, 3, 21,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
        # PIV
        Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 21,  8.0, 3.1, 3, 21,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
        # CoV
        Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 21,  7.5, 2.9, 3, 21,  4.9, 3.7, 2.5,  0.21, 0.26, 0.32,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

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
    
    infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    infected_data_0 = infected_data_0[2:53, 21:27]
    infected_data_0_1 = etiology[:, 1] .* infected_data_0
    infected_data_0_2 = etiology[:, 2] .* infected_data_0
    infected_data_0_3 = etiology[:, 3] .* infected_data_0
    infected_data_0_4 = etiology[:, 4] .* infected_data_0
    infected_data_0_5 = etiology[:, 5] .* infected_data_0
    infected_data_0_6 = etiology[:, 6] .* infected_data_0
    infected_data_0_7 = etiology[:, 7] .* infected_data_0
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
    infected_data_3_1 = etiology[:, 1] .* infected_data_3
    infected_data_3_2 = etiology[:, 2] .* infected_data_3
    infected_data_3_3 = etiology[:, 3] .* infected_data_3
    infected_data_3_4 = etiology[:, 4] .* infected_data_3
    infected_data_3_5 = etiology[:, 5] .* infected_data_3
    infected_data_3_6 = etiology[:, 6] .* infected_data_3
    infected_data_3_7 = etiology[:, 7] .* infected_data_3
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
    infected_data_7_1 = etiology[:, 1] .* infected_data_7
    infected_data_7_2 = etiology[:, 2] .* infected_data_7
    infected_data_7_3 = etiology[:, 3] .* infected_data_7
    infected_data_7_4 = etiology[:, 4] .* infected_data_7
    infected_data_7_5 = etiology[:, 5] .* infected_data_7
    infected_data_7_6 = etiology[:, 6] .* infected_data_7
    infected_data_7_7 = etiology[:, 7] .* infected_data_7
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
    infected_data_15_1 = etiology[:, 1] .* infected_data_15
    infected_data_15_2 = etiology[:, 2] .* infected_data_15
    infected_data_15_3 = etiology[:, 3] .* infected_data_15
    infected_data_15_4 = etiology[:, 4] .* infected_data_15
    infected_data_15_5 = etiology[:, 5] .* infected_data_15
    infected_data_15_6 = etiology[:, 6] .* infected_data_15
    infected_data_15_7 = etiology[:, 7] .* infected_data_15
    infected_data_15_viruses = cat(
        infected_data_15_1,
        infected_data_15_2,
        infected_data_15_3,
        infected_data_15_4,
        infected_data_15_5,
        infected_data_15_6,
        infected_data_15_7,
        dims = 3)

    infected_data_0_viruses_mean = mean(infected_data_0_viruses, dims = 2)[:, 1, :]
    infected_data_3_viruses_mean = mean(infected_data_3_viruses, dims = 2)[:, 1, :]
    infected_data_7_viruses_mean = mean(infected_data_7_viruses, dims = 2)[:, 1, :]
    infected_data_15_viruses_mean = mean(infected_data_15_viruses, dims = 2)[:, 1, :]

    num_infected_age_groups_viruses_mean = cat(
        infected_data_0_viruses_mean,
        infected_data_3_viruses_mean,
        infected_data_7_viruses_mean,
        infected_data_15_viruses_mean,
        dims = 3,
    )

    num_all_infected_age_groups_viruses_mean = copy(num_infected_age_groups_viruses_mean)
    for virus_id = 1:length(viruses)
        num_all_infected_age_groups_viruses_mean[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_all_infected_age_groups_viruses_mean[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_all_infected_age_groups_viruses_mean[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_all_infected_age_groups_viruses_mean[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id], end_agent_ids[thread_id],
            agents, households, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households, district_nums)
    end

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, num_barabasi_albert_attachments)

    println("Simulation...")

    num_runs = 100
    multiple_simulations(
        agents,
        households,
        num_threads,
        thread_rng,
        num_runs,
        start_agent_ids,
        end_agent_ids,
        etiology,
        temperature,
        viruses,
        num_all_infected_age_groups_viruses_mean,
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
        num_infected_age_groups_viruses_mean,
        recovered_duration_mean,
        recovered_duration_sd,
        random_infection_probabilities,
        mean_immunity_durations,
    )
end

main()
