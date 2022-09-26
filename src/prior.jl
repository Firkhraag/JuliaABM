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
    schools::Vector{School},
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
    num_years::Int,
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
        (duration_parameter_default - 0.05, duration_parameter_default + 0.05),
        (susceptibility_parameters_default[1] - 0.05, susceptibility_parameters_default[1] + 0.05),
        (susceptibility_parameters_default[2] - 0.05, susceptibility_parameters_default[2] + 0.05),
        (susceptibility_parameters_default[3] - 0.05, susceptibility_parameters_default[3] + 0.05),
        (susceptibility_parameters_default[4] - 0.05, susceptibility_parameters_default[4] + 0.05),
        (susceptibility_parameters_default[5] - 0.05, susceptibility_parameters_default[5] + 0.05),
        (susceptibility_parameters_default[6] - 0.05, susceptibility_parameters_default[6] + 0.05),
        (susceptibility_parameters_default[7] - 0.05, susceptibility_parameters_default[7] + 0.05),
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
        (mean_immunity_durations[1] - 3.0, mean_immunity_durations[1] + 3.0),
        (mean_immunity_durations[2] - 3.0, mean_immunity_durations[2] + 3.0),
        (mean_immunity_durations[3] - 3.0, mean_immunity_durations[3] + 3.0),
        (mean_immunity_durations[4] - 3.0, mean_immunity_durations[4] + 3.0),
        (mean_immunity_durations[5] - 3.0, mean_immunity_durations[5] + 3.0),
        (mean_immunity_durations[6] - 3.0, mean_immunity_durations[6] + 3.0),
        (mean_immunity_durations[7] - 3.0, mean_immunity_durations[7] + 3.0),
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

        @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, false)

        observed_num_infected_age_groups_viruses_mean = zeros(Float64, 52, 7, 4)
        for i = 1:num_years
            for j = 1:52
                for k = 1:7
                    for z = 1:4
                        observed_num_infected_age_groups_viruses_mean[j, k, z] += observed_num_infected_age_groups_viruses[52 * (i - 1) + j, k, z]
                    end
                end
            end
        end
        for j = 1:52
            for k = 1:7
                for z = 1:4
                    observed_num_infected_age_groups_viruses_mean[j, k, z] /= num_years
                end
            end
        end
    
        MAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses_mean)) / (size(observed_num_infected_age_groups_viruses_mean)[1] * size(observed_num_infected_age_groups_viruses_mean)[2] * size(observed_num_infected_age_groups_viruses_mean)[3])
        RMSE = sqrt(sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses_mean).^2)) / sqrt((size(observed_num_infected_age_groups_viruses_mean)[1] * size(observed_num_infected_age_groups_viruses_mean)[2] * size(observed_num_infected_age_groups_viruses_mean)[3]))
        nMAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses_mean)) / sum(num_infected_age_groups_viruses_mean)
        S_square = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses_mean).^2)

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

    num_years = 3

    num_threads = nthreads()

    # Вероятности случайного инфицирования
    random_infection_probabilities = [0.0015, 0.0012, 0.00045, 0.000001]
    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    # recovered_duration_mean = 6.0
    # recovered_duration_sd = 2.0
    recovered_duration_mean = 5.0
    recovered_duration_sd = 1.5
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
    num_barabasi_albert_attachments = 6
    # num_barabasi_albert_attachments = 5

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

    # duration_parameter = 3.764265099979386
    # susceptibility_parameters = [3.2580395794681514, 3.884652648938362, 3.817058338486913, 5.678550814265098, 4.145190682333544, 3.8139002267573696, 4.7655782312925155]
    # temperature_parameters = [-0.9220449391877963, -0.7772418058132341, -0.1949804164089878, -0.0393939393939394, -0.08250876108018959, -0.15083487940630802, -0.3359224902082046]
    # random_infection_probabilities = [0.00011537414965986393, 6.832319109461966e-5, 4.910216450216453e-5, 6.985549371263659e-7]
    # mean_immunity_durations = [253.96825396825392, 314.95031952174816, 97.14759843331271, 22.70171098742527, 80.84188827045969, 114.48526077097503, 85.45660688517833]

    # duration_parameter = 3.764265099979386
    # susceptibility_parameters = [3.2580395794681514, 3.884652648938362, 3.817058338486913, 5.678550814265098, 4.145190682333544, 3.8139002267573696, 4.5655782312925155]
    # temperature_parameters = [-0.9220449391877963, -0.7772418058132341, -0.1949804164089878, -0.0393939393939394, -0.08250876108018959, -0.15083487940630802, -0.159224902082046]
    # random_infection_probabilities = [0.00011537414965986393, 6.832319109461966e-5, 4.910216450216453e-5, 6.985549371263659e-7]
    # mean_immunity_durations = [253.96825396825392, 314.95031952174816, 97.14759843331271, 22.70171098742527, 80.84188827045969, 114.48526077097503, 95.45660688517833]
    
    # duration_parameter = 3.779416615130901
    # susceptibility_parameters = [3.2610698824984543, 3.8452587095444226, 3.7817048031333775, 5.663399299113583, 4.237109874252735, 3.9098598227169656, 4.5706287363430205]
    # temperature_parameters = [-0.9164893836322408, -0.811080189651618, -0.19548546691403831, -0.03636363636363636, -0.09816532673675527, -0.14426922284065144, -0.18397237682952078]
    # random_infection_probabilities = [0.00011500041228612655, 6.840904968047825e-5, 4.915367965367968e-5, 6.952216037930325e-7]
    # mean_immunity_durations = [256.9682539682539, 312.3745619459906, 99.17790146361574, 25.459286745001027, 81.05400948258091, 116.81859410430836, 98.45660688517833]

    # duration_parameter = 3.762244897959184
    # susceptibility_parameters = [3.1954133168418886, 3.886672850958564, 3.6958462172747915, 5.702793238507522, 4.155291692434554, 3.8118800247371674, 4.654467120181404]
    # temperature_parameters = [-0.9200247371675943, -0.77320140177283, -0.15962688105545242, -0.07474747474747476, -0.12695320552463404, -0.12558235415378277, -0.17235621521335917]
    # random_infection_probabilities = [0.00011488930117501543, 6.831713048855906e-5, 4.9166810966810994e-5, 6.908781694495981e-7]
    # mean_immunity_durations = [258.39249639249635, 312.8897134611421, 97.99608328179755, 23.91383219954648, 79.99340342197485, 114.78829107400533, 98.30509173366318]

    # duration_parameter = 3.762244897959184
    # susceptibility_parameters = [3.1954133168418886, 3.886672850958564, 3.6958462172747915, 5.702793238507522, 4.155291692434554, 3.8118800247371674, 4.654467120181404]
    # temperature_parameters = [-0.9200247371675943, -0.77320140177283, -0.15962688105545242, -0.07474747474747476, -0.12695320552463404, -0.12558235415378277, -0.17235621521335917]
    # random_infection_probabilities = [0.00011488930117501543, 6.831713048855906e-5, 4.9166810966810994e-5, 6.908781694495981e-7]
    # mean_immunity_durations = [258.39249639249635, 312.8897134611421, 97.99608328179755, 23.91383219954648, 79.99340342197485, 114.78829107400533, 98.30509173366318]

    # duration_parameter = 3.6763863121005977
    # susceptibility_parameters = [3.149958771387343, 3.8553597196454326, 3.660492681921256, 5.608853844568128, 4.0896351267779885, 3.883597196454339, 4.695881261595545]
    # temperature_parameters = [-0.8882065553494124, -0.7524943310657592, -0.10962688105545242, -0.12272727272727274, -0.1224077509791795, -0.07861265718408579, -0.1748814677386117]
    # random_infection_probabilities = [0.00011504081632653058, 6.830399917542775e-5, 4.918600288600291e-5, 6.903731189445476e-7]
    # mean_immunity_durations = [256.3015873015873, 314.0109255823542, 99.17790146361574, 24.91383219954648, 78.7509791795506, 115.84889713461139, 100.75963718820863]

    # duration_parameter = 3.711739847454133
    # susceptibility_parameters = [3.049958771387343, 3.797783962069675, 3.6978664192949933, 5.583601319315603, 4.070443207586069, 3.957334570191713, 4.612042877757162]
    # temperature_parameters = [-0.8786105957534528, -0.7631003916718199, -0.0868996083281797, -0.15656565656565657, -0.1027107812822098, -0.05588538445681307, -0.16932591218305615]
    # random_infection_probabilities = [0.00011551556380127805, 6.822016079158936e-5, 4.922135642135645e-5, 6.844135229849516e-7]
    # mean_immunity_durations = [255.05916305916304, 312.7078952793239, 101.87487116058544, 27.368377654091933, 77.08431251288393, 117.33374561945988, 103.15357658214802]

    # MAE = 826.1174166235645
    # RMSE = 1509.7036582462517
    # nMAE = 0.47575228156220234
    # S_square = 3.318522677611399e9
    # duration_parameter = 3.7975984333127193
    # susceptibility_parameters = [3.0772314986600704, 3.728086992372705, 3.7473613687899427, 5.517944753659037, 4.002766439909301, 4.002789115646258, 4.625174190888475]
    # temperature_parameters = [-0.849822716965574, -0.7545145330859613, -0.08538445681302818, -0.1782828282828283, -0.14058956916099768, -0.06043083900226762, -0.20215419501133897]
    # random_infection_probabilities = [0.00011528324056895483, 6.812016079158936e-5, 4.924256854256857e-5, 6.762317048031335e-7]
    # mean_immunity_durations = [255.75613275613273, 312.798804370233, 102.81426509997938, 30.18655947227375, 78.7509791795506, 114.81859410430836, 101.54751597608741]

    # MAE = 823.0007176211213
    # RMSE = 1488.7004898186701
    # nMAE = 0.4739574075751422
    # S_square = 3.2268296400505223e9
    # duration_parameter = 3.8329519686662548
    # susceptibility_parameters = [3.1731910946196664, 3.686672850958564, 3.756452277880852, 5.561379097093381, 4.082564419707281, 4.001779014636156, 4.6383055040197885]
    # temperature_parameters = [-0.8412368583797154, -0.7267367553081835, -0.036394557823129184, -0.17070707070707072, -0.10776128633271485, -0.08820861678004539, -0.2066996495567935]
    # random_infection_probabilities = [0.00011557616986188411, 6.802420119562976e-5, 4.9154689754689777e-5, 6.668377654091941e-7]
    # mean_immunity_durations = [253.18037518037517, 311.5563801278087, 100.72335600907029, 32.095650381364656, 78.84188827045969, 113.09132137703563, 101.21418264275408]

    # MAE = 794.7771319940739
    # RMSE = 1459.8275394527732
    # nMAE = 0.45770374316165785
    # S_square = 3.102876423839539e9
    # duration_parameter = 3.928911564625851
    # susceptibility_parameters = [3.109554730983303, 3.616975881261594, 3.846351267779842, 5.594712430426714, 4.168423005565867, 4.002789115646257, 4.588810554524839]
    # temperature_parameters = [-0.8185095856524427, -0.7716862502576785, -0.0696969696969697, -0.12272727272727275, -0.08907441764584616, -0.10588538445681307, -0.25669964955679353]
    # random_infection_probabilities = [0.0001158690991548134, 6.804743351886208e-5, 4.910519480519483e-5, 6.727973613687901e-7]
    # mean_immunity_durations = [254.05916305916304, 312.85941043083903, 98.14759843331271, 32.853226138940414, 80.20552463409605, 113.18223046794472, 101.06266749123893]

    # MAE = 791.2851837526694
    # RMSE = 1401.6711714189296
    # nMAE = 0.45569276710726686
    # S_square = 2.860577097977747e9
    # duration_parameter = 3.970325706039992
    # susceptibility_parameters = [3.201473922902495, 3.708895073180786, 3.817058338486913, 5.601783137497422, 4.082564419707281, 4.03612244897959, 4.4968913626056475]
    # temperature_parameters = [-0.7745701917130488, -0.769160997732426, -0.09444444444444446, -0.11111111111111113, -0.12291280148423, -0.11346114203257066, -0.24710368996083393]
    # random_infection_probabilities = [0.00011583879612451038, 6.800197897340754e-5, 4.915064935064938e-5, 6.634034219748507e-7]
    # mean_immunity_durations = [252.02886002886, 312.16244073386935, 98.2385075242218, 34.277468563182836, 83.02370645227786, 116.12162440733866, 101.6384250669965]



    # duration_parameter = 3.8784065141208
    # susceptibility_parameters = [3.145918367346939, 3.786672850958564, 3.731199752628327, 5.631076066790351, 4.075493712636574, 3.938142650999792, 4.457497423211708]
    # temperature_parameters = [-0.75588332302618, -0.7363327149041431, -0.05444444444444445, -0.07121212121212123, -0.08604411461554314, -0.0786126571840858, -0.2597299525870965]
    # random_infection_probabilities = [0.0001157680890538033, 6.800096887239743e-5, 4.911327561327564e-5, 6.729993815708104e-7]
    # mean_immunity_durations = [251.15007215007213, 313.1018346732633, 99.66274994846422, 32.97443826015253, 83.6600700886415, 114.63677592249017, 99.30509173366318]

    # duration_parameter = 3.796588332302618
    # susceptibility_parameters = [3.1630900845186565, 3.7533395176252307, 3.6675633889919634, 5.5512780869923715, 4.17145330859617, 3.955314368171509, 4.5494166151309]
    # temperature_parameters = [-0.7765903937332507, -0.7146155431869714, -0.050656565656565655, -0.050383838383838395, -0.05004411461554313, -0.05082477839620701, -0.2258915687487127]
    # random_infection_probabilities = [0.00011587920016491442, 6.79656153370439e-5, 4.9059740259740285e-5, 6.777468563182851e-7]
    # mean_immunity_durations = [249.66522366522364, 311.7381983096269, 101.51123479694907, 32.70171098742526, 86.59946402803544, 114.84889713461139, 99.6384250669965]

    # duration_parameter = 3.704669140383426
    # susceptibility_parameters = [3.0671304885590605, 3.699804164089877, 3.702916924345499, 5.511884147598432, 4.123978561121422, 3.8613749742321146, 4.552446918161203]
    # temperature_parameters = [-0.8063883735312305, -0.7292620078334361, -0.07338383838383838, -0.050014141414141411, -0.06469057926200777, -0.06749144506287369, -0.19104308390022784]
    # random_infection_probabilities = [0.00011514182642754069, 6.805349412492268e-5, 4.9076911976912e-5, 6.790599876314165e-7]
    # mean_immunity_durations = [248.36219336219332, 309.2230467944754, 103.11729540300968, 31.76231704803132, 85.6600700886415, 113.06101834673261, 97.85054627911772]

    # duration_parameter = 3.6127499484642343
    # susceptibility_parameters = [2.9731910946196662, 3.6583900226757358, 3.6796846011131756, 5.486631622345907, 4.066402803545665, 3.86642547928262, 4.583760049474334]
    # temperature_parameters = [-0.800832817975675, -0.6802721088435371, -0.05063636363636363, -0.0687010101010101, -0.050973407544836056, -0.09021871779014642, -0.2289218717790157]
    # random_infection_probabilities = [0.00011440445269016695, 6.814339311482168e-5, 4.913852813852816e-5, 6.860296846011134e-7]
    # mean_immunity_durations = [249.78643578643576, 308.16244073386935, 101.3294166151309, 30.580498866213137, 84.6600700886415, 112.48526077097503, 95.3353947639662]

    # duration_parameter = 3.522850958565244
    # susceptibility_parameters = [2.88733250876108, 3.6250566893424025, 3.6544320758606506, 5.412894248608533, 4.049231086373948, 3.9098598227169634, 4.611032776747061]
    # temperature_parameters = [-0.764974232117089, -0.6514842300556583, -0.07538383838383839, -0.09445858585858585, -0.095922902494331, -0.06547124304267168, -0.22134611420325814]
    # random_infection_probabilities = [0.00011471758400329827, 6.80716759431045e-5, 4.913549783549786e-5, 6.94615543186972e-7]
    # mean_immunity_durations = [248.90764790764788, 306.49577406720266, 98.39002267573696, 31.580498866213134, 83.23582766439908, 114.57616986188413, 94.21418264275408]

    # duration_parameter = 3.4794166151309005
    # susceptibility_parameters = [2.8176355390641104, 3.6220263863120996, 3.604937126365701, 5.401783137497422, 4.112867450010311, 3.9169305297876704, 4.67062873634302]
    # temperature_parameters = [-0.716994434137291, -0.678251906823335, -0.05568686868686869, -0.05455959595959596, -0.05093300350443201, -0.05070356627499491, -0.1885178313749753]
    # random_infection_probabilities = [0.0001149499072356215, 6.803026180169036e-5, 4.920519480519483e-5, 6.981508967223256e-7]
    # mean_immunity_durations = [251.48340548340545, 303.798804370233, 100.05668934240363, 31.853226138940407, 85.81158524015666, 115.51556380127806, 95.15357658214802]

    # duration_parameter = 3.452143887858173
    # susceptibility_parameters = [2.8166254380540092, 3.5361678004535135, 3.571603793032368, 5.3139043496186344, 4.037109874252736, 3.8512739641311047, 4.592850958565243]
    # temperature_parameters = [-0.6821459492888061, -0.6716862502576785, -0.07841414141414141, -0.08334747474747475, -0.07972088229231081, -0.05001669758812621, -0.13952793238507633]
    # random_infection_probabilities = [0.0001151620284477427, 6.795450422593278e-5, 4.91759018759019e-5, 7.06534735106164e-7]
    # mean_immunity_durations = [252.30158730158726, 303.4048649762936, 102.08699237270666, 34.48958977530404, 88.38734281591424, 115.00041228612655, 94.82024324881469]

    # MAE = 858.8455587330458
    # RMSE = 1566.9730663375478
    # nMAE = 0.4946000724047148
    # S_square = 3.575069083953344e9
    # duration_parameter = 3.4046691403834255
    # susceptibility_parameters = [2.8580395794681506, 3.5129354772211903, 3.6695835910121657, 5.270470006184291, 3.9573118944547563, 3.779556792413933, 4.494871160585445]
    # temperature_parameters = [-0.6472974644403212, -0.670171098742527, -0.05467676767676767, -0.1262767676767677, -0.05800371057513909, -0.05041063698206561, -0.12387136672851067]
    # random_infection_probabilities = [0.0001155559678416821, 6.792319109461965e-5, 4.911428571428574e-5, 7.098680684394973e-7]
    # mean_immunity_durations = [252.27128427128423, 302.28365285508147, 100.17790146361575, 36.88352916924343, 89.38734281591424, 112.18223046794473, 96.54751597608742]

    # MAE = 833.8268011550025
    # RMSE = 1517.873614606014
    # nMAE = 0.480192034563976
    # S_square = 3.3545370912393355e9
    # duration_parameter = 3.343052978767264
    # susceptibility_parameters = [2.9277365491651204, 3.4351576994434123, 3.605947227375802, 5.25935889507318, 3.859332096474958, 3.760364873222014, 4.564568130282415]
    # temperature_parameters = [-0.6528530199958767, -0.6464337250051533, -0.061242424242424244, -0.10152929292929296, -0.06355926613069465, -0.06606720263863128, -0.12538651824366218]
    # random_infection_probabilities = [0.0001149600082457225, 6.787773654916511e-5, 4.905266955266958e-5, 7.174438260152549e-7]
    # mean_immunity_durations = [250.11976911976907, 303.4048649762936, 101.17790146361575, 39.21686250257677, 86.50855493712636, 109.2428365285508, 96.57781900639046]

    # MAE = 833.5009673682822
    # RMSE = 1515.46875599419
    # nMAE = 0.48000439033287406
    # S_square = 3.343915921374505e9
    # duration_parameter = 3.3056792413935265
    # susceptibility_parameters = [2.868140589569161, 3.341218305504018, 3.6695835910121657, 5.322995258709543, 3.918928056070918, 3.67652648938363, 4.626184291898576]
    # temperature_parameters = [-0.6765903937332505, -0.5964337250051532, -0.05054545454545455, -0.07173131313131316, -0.07315522572665425, -0.08677427334570198, -0.11478045763760159]
    # random_infection_probabilities = [0.0001153539476396619, 6.793329210472066e-5, 4.9011255411255434e-5, 7.135044320758609e-7]
    # mean_immunity_durations = [251.30158730158726, 300.82910740053603, 100.60214388785818, 39.73201401772828, 86.5388579674294, 110.48526077097503, 98.123273551845]

    # MAE = 826.1034514532165
    # RMSE = 1522.900897687132
    # nMAE = 0.4757442391683225
    # S_square = 3.3767947219206524e9
    # duration_parameter = 3.3026489383632236
    # susceptibility_parameters = [2.964100185528757, 3.429097093382806, 3.626149247577822, 5.3139043496186344, 3.956301793444655, 3.768445681302822, 4.574669140383424]
    # temperature_parameters = [-0.6902267573696141, -0.6070397856112139, -0.09650505050505051, -0.057084848484848516, -0.06658956916099769, -0.12768336425479287, -0.10518449804164198]
    # random_infection_probabilities = [0.00011473778602350028, 6.79787466501752e-5, 4.9038528138528164e-5, 7.208781694495983e-7]
    # mean_immunity_durations = [249.75613275613273, 303.5866831581118, 100.45062873634302, 42.48958977530404, 88.69037311894455, 111.90950319521745, 98.94145537002682]

    # MAE = 823.8697068252536
    # RMSE = 1511.5938321993963
    # nMAE = 0.4744578492656328
    # S_square = 3.3268375701189814e9
    # duration_parameter = 3.247093382807668
    # susceptibility_parameters = [3.0277365491651205, 3.3937435580292705, 3.619078540507115, 5.234106369820655, 4.003776540919403, 3.7351123479694888, 4.521133786848071]
    # temperature_parameters = [-0.6594186765615333, -0.6095650381364663, -0.11822222222222223, -0.10708484848484852, -0.05074108431251284, -0.11909750566893429, -0.1491238919810359]
    # random_infection_probabilities = [0.0001150509173366316, 6.793329210472066e-5, 4.908802308802311e-5, 7.292620078334367e-7]
    # mean_immunity_durations = [248.69552669552667, 306.4048649762936, 100.66274994846424, 45.30777159348586, 88.2358276643991, 109.09132137703564, 100.00206143063288]

    # MAE = 814.5072600647093
    # RMSE = 1487.4132600080336
    # nMAE = 0.4690661152122116
    # S_square = 3.2212517880054893e9
    # duration_parameter = 3.244063079777365
    # susceptibility_parameters = [2.992383013811585, 3.3159657802514926, 3.5514017728303475, 5.315924551638836, 4.039130076272938, 3.6977386105957515, 4.544366110080394]
    # temperature_parameters = [-0.6972974644403213, -0.6484539270253553, -0.1348888888888889, -0.06213535353535357, -0.09973098330241183, -0.08222881880024742, -0.11124510410224803]
    # random_infection_probabilities = [0.00011467717996289422, 6.785955473098329e-5, 4.906681096681099e-5, 7.287569573283861e-7]
    # mean_immunity_durations = [250.05916305916304, 306.3745619459906, 99.11729540300969, 45.76231704803131, 90.56916099773242, 111.78829107400534, 98.69903112760258]

    # MAE = 813.5764469588414
    # RMSE = 1512.601458496748
    # nMAE = 0.46853006979068473
    # S_square = 3.331274378790888e9
    # duration_parameter = 3.2188105545248398
    # susceptibility_parameters = [2.995413316841888, 3.359400123685836, 3.560492681921257, 5.290672026386311, 3.9633725005153626, 3.7310719439290847, 4.4888105545248385]
    # temperature_parameters = [-0.6877015048443617, -0.6216862502576785, -0.1788282828282828, -0.10708484848484852, -0.10427643784786637, -0.11707730364873227, -0.061245104102248024]
    # random_infection_probabilities = [0.00011391960420531847, 6.779995877138733e-5, 4.905772005772008e-5, 7.209791795506084e-7]
    # mean_immunity_durations = [249.1197691197691, 306.5260770975057, 101.45062873634302, 44.09565038136465, 87.62976705833849, 112.30344258915686, 100.54751597608742]

    # MAE = 815.8997971296993
    # RMSE = 1460.2252869082852
    # nMAE = 0.46986806257768016
    # S_square = 3.1045674856944146e9
    # duration_parameter = 3.215275200989486
    # susceptibility_parameters = [2.9459183673469385, 3.269501133786846, 3.480694702123277, 5.263399299113583, 3.923978561121423, 3.669455782312923, 4.554467120181404]
    # temperature_parameters = [-0.7225499896928466, -0.6605751391465675, -0.1288282828282828, -0.14900404040404044, -0.10276128633271486, -0.1286934652648939, -0.04659863945578338]
    # random_infection_probabilities = [0.00011298021026592454, 6.7766625438054e-5, 4.900822510822513e-5, 7.129993815708104e-7]
    # mean_immunity_durations = [249.69552669552667, 306.67759224902085, 99.78396206967635, 42.85322613894041, 89.05400948258091, 114.21253349824777, 99.97175840032985]

    # MAE = 807.3193953177048
    # RMSE = 1474.179452247213
    # nMAE = 0.4649266999376561
    # S_square = 3.164186563615012e9
    # duration_parameter = 3.1834570191713043
    # susceptibility_parameters = [2.9752112966398676, 3.335157699443412, 3.570593692022267, 5.232086167800452, 3.977513914656776, 3.761374974232115, 4.5393156050298895]
    # temperature_parameters = [-0.7038631210059778, -0.6479488765203049, -0.08286868686868683, -0.12021616161616165, -0.12548855905998757, -0.12212780869923731, -0.0393939393939394]
    # random_infection_probabilities = [0.00011341455370026798, 6.77676355390641e-5, 4.9077922077922105e-5, 7.135044320758609e-7]
    # mean_immunity_durations = [251.1197691197691, 306.9503195217481, 97.20820449391877, 45.67140795712223, 89.50855493712636, 113.81859410430837, 102.4263038548753]

    # MAE = 806.1422513400723
    # RMSE = 1472.4120696343973
    # nMAE = 0.4642487951727684
    # S_square = 3.1566040728841515e9
    # duration_parameter = 3.21931560502989
    # susceptibility_parameters = [2.9575345289631, 3.317480931766644, 3.605442176870752, 5.211379097093382, 3.9547866419295037, 3.7750113378684786, 4.531739847454132]
    # temperature_parameters = [-0.7094186765615333, -0.6838074623788908, -0.0995353535353535, -0.13385252525252528, -0.15629663986806835, -0.15798639455782318, -0.05555555555555556]
    # random_infection_probabilities = [0.00011431354359925787, 6.782723149866006e-5, 4.91698412698413e-5, 7.190599876314165e-7]
    # mean_immunity_durations = [253.39249639249638, 305.1018346732632, 98.81426509997938, 45.459286745001016, 88.4479488765203, 116.81859410430837, 103.78994021851166]

    # MAE = 800.6057848881843
    # RMSE = 1457.3951960090426
    # nMAE = 0.4610604027078768
    # S_square = 3.092545102701943e9
    duration_parameter = 3.2066893424036276
    susceptibility_parameters = [2.9236961451247163, 3.3169758812615937, 3.6231189445475196, 5.246227581941867, 3.9977159348587965, 3.7310719439290847, 4.549416615130899]
    temperature_parameters = [-0.6755802927231495, -0.7196660482374767, -0.07276767676767674, -0.11516565656565658, -0.12952896310039158, -0.1595015460729747, -0.10050505050505051]
    random_infection_probabilities = [0.00011494990723562151, 6.77635951350237e-5, 4.918903318903322e-5, 7.137064522778812e-7]
    mean_immunity_durations = [250.6955266955267, 304.22304679447535, 98.54153782725211, 45.065347351061625, 86.3570397856112, 115.03071531642959, 106.18387961245105]



    # MAE = 979.8299150437975
    # RMSE = 2270.2073251085694
    # nMAE = 0.5642736834313689
    # S_square = 7.5039929313099375e9

    duration_parameter = 3.211234796949082
    susceptibility_parameters = [2.9716759431045143, 3.302329416615129, 3.611502782931358, 5.272995258709544, 3.986099773242635, 3.7699608328179735, 4.566083281797566]
    temperature_parameters = [-0.7215398886827454, -0.7666357452071737, -0.09650505050505048, -0.1368828282828283, -0.14619562976705824, -0.1499055864770151, -0.1282828282828283]
    random_infection_probabilities = [0.00011516202844774272, 6.780096887239744e-5, 4.911529581529584e-5, 7.194640280354569e-7]
    mean_immunity_durations = [251.0894660894661, 301.52607709750566, 100.69305297876727, 46.48958977530405, 85.29643372500514, 117.7276850133993, 108.3353947639662]

    # MAE = 984.3643736697913
    # RMSE = 1961.8607402760651
    # nMAE = 0.5668850301885684
    # S_square = 5.603994853528418e9
    duration_parameter = 3.2531539888682737
    susceptibility_parameters = [2.995413316841888, 3.2957637600494722, 3.5786745001030753, 5.241177076891363, 3.982564419707282, 3.803799216656357, 4.599921665635949]
    temperature_parameters = [-0.7604287775716344, -0.7944135229849515, -0.10812121212121209, -0.12122626262626265, -0.1830643166357451, -0.1504106369820656, -0.1378787878787879]
    random_infection_probabilities = [0.00011426303854875283, 6.788278705421562e-5, 4.9100144300144324e-5, 7.100700886415176e-7]
    mean_immunity_durations = [248.998556998557, 301.37456194599054, 99.63244691816121, 45.12595341166768, 83.14491857348999, 115.09132137703565, 108.00206143063288]

    # MAE = 953.5027138556175
    # RMSE = 1834.752357777331
    # nMAE = 0.5491121267562709
    # S_square = 4.901356408121956e9
    duration_parameter = 3.2981034838177683
    susceptibility_parameters = [3.0201607915893627, 3.2619253762110887, 3.571098742527318, 5.225520511234797, 3.9911502782931407, 3.8073345701917107, 4.609517625231908]
    temperature_parameters = [-0.7568934240362809, -0.8070397856112141, -0.08943434343434341, -0.0863777777777778, -0.20579158936301784, -0.1994005359719646, -0.10101010101010104]
    random_infection_probabilities = [0.00011485899814471242, 6.779894867037723e-5, 4.911327561327564e-5, 7.022923108637398e-7]
    mean_immunity_durations = [251.81673881673882, 300.37456194599054, 97.78396206967636, 47.33807462378889, 80.7509791795506, 117.00041228612656, 107.97175840032985]

    # MAE = 924.1888880623769
    # RMSE = 1736.3434183536715
    # nMAE = 0.5322306045636381
    # S_square = 4.389677607165924e9
    duration_parameter = 3.318810554524839
    susceptibility_parameters = [3.013595135023706, 3.291723356009068, 3.5887755102040857, 5.250267985982272, 3.97044320758607, 3.779556792413933, 4.649416615130898]
    temperature_parameters = [-0.7624489795918364, -0.840878169449598, -0.10105050505050503, -0.05657979797979801, -0.24872088229231076, -0.22515811172954037, -0.08131313131313134]
    random_infection_probabilities = [0.00011488930117501545, 6.788278705421562e-5, 4.9041558441558465e-5, 6.979488765203054e-7]
    mean_immunity_durations = [253.7864357864358, 301.4351680065966, 95.32941661513091, 44.398680684394954, 82.96310039167182, 119.87920016491444, 105.63842506699652]

    # MAE = 898.4255207748887
    # RMSE = 1692.1069406062265
    # nMAE = 0.5173937538677126
    # S_square = 4.168856908139944e9
    duration_parameter = 3.3415378272521115
    susceptibility_parameters = [3.061574933003504, 3.328592042877755, 3.538775510204086, 5.251783137497424, 4.01034219748506, 3.8022840651412055, 4.666083281797564]
    temperature_parameters = [-0.8084085755514324, -0.8201710987425272, -0.14296969696969697, -0.05304444444444447, -0.26134714491857336, -0.2711177076891363, -0.07474747474747476]
    random_infection_probabilities = [0.00011485899814471242, 6.790197897340755e-5, 4.903650793650796e-5, 7.000700886415176e-7]
    mean_immunity_durations = [253.87734487734488, 303.2230467944754, 94.8142650999794, 45.459286745001016, 85.47825190682333, 117.90950319521747, 103.48690991548136]

    # MAE = 884.0306803118527
    # RMSE = 1646.131817187075
    # nMAE = 0.5091039175136948
    # S_square = 3.945395941112985e9
    duration_parameter = 3.331941867656152
    susceptibility_parameters = [3.1065244279529987, 3.370511234796947, 3.494836116264692, 5.208853844568131, 4.006806843949707, 3.770465883323024, 4.6756792413935235]
    temperature_parameters = [-0.8422469593898163, -0.846938775510204, -0.10408080808080808, -0.06466060606060609, -0.26084209441352285, -0.22414801071943935, -0.10454545454545455]
    random_infection_probabilities = [0.00011460647289218717, 6.794339311482168e-5, 4.911630591630594e-5, 7.054236239950529e-7]
    mean_immunity_durations = [253.66522366522366, 302.5260770975057, 95.39002267573697, 47.73201401772829, 86.84188827045969, 120.42465471036898, 102.66872809729955]

    # MAE = 865.5507385088378
    # RMSE = 1618.3161271406693
    # nMAE = 0.4984615145101914
    # S_square = 3.8131869592013655e9
    duration_parameter = 3.3203257060399904
    susceptibility_parameters = [3.085817357245928, 3.3407132549989673, 3.4458462172747932, 5.188146773861061, 3.994180581323444, 3.8043042671614073, 4.724669140383423]
    temperature_parameters = [-0.8417419088847657, -0.890878169449598, -0.05913131313131313, -0.06112525252525255, -0.22700371057513902, -0.2488954854669141, -0.09191919191919193]
    random_infection_probabilities = [0.0001143337456194599, 6.788783755926613e-5, 4.914155844155847e-5, 7.150195835910125e-7]
    mean_immunity_durations = [254.66522366522366, 302.98062255205116, 94.69305297876727, 45.035044320758594, 86.7509791795506, 120.51556380127808, 104.88084930942077]

    # MAE: 864.1975220555024
    # RMSE: 1595.3663626939594
    # nMAE: 0.4976822114690413
    # S_square: 3.7058022182495556e9
    duration_parameter = 3.3536590393733237
    susceptibility_parameters = [3.1534941249226955, 3.4174809317666437, 3.491300762729338, 5.202288188002475, 3.971958359101222, 3.7790517419088823, 4.700426716140998]
    temperature_parameters = [-0.8437621109049678, -0.8777468563182849, -0.13690909090909092, -0.11163030303030305, -0.2684178519892804, -0.2680874046588333, -0.1525252525252525]
    random_infection_probabilities = [0.00011510142238713665, 6.789389816532674e-5, 4.9200144300144326e-5, 7.057266542980832e-7]
    mean_immunity_durations = [252.54401154401154, 303.0412286126572, 94.63244691816121, 46.55019583591011, 88.4479488765203, 121.42465471036898, 105.30509173366319]


    # MAE = 830.9128184430754
    # RMSE = 1513.744981746704
    # nMAE = 0.4785139027442908
    # S_square = 3.336313154375407e9
    duration_parameter = 3.387497423211707
    susceptibility_parameters = [3.166120387548958, 3.396773861059573, 3.517058338486914, 5.152288188002475, 3.9563017934446565, 3.825011337868478, 4.687800453514735]
    temperature_parameters = [-0.8573984745413314, -0.8772418058132343, -0.11620202020202021, -0.13334747474747477, -0.2669027004741289, -0.24131972789115652, -0.18535353535353533]
    random_infection_probabilities = [0.00011604081632653059, 6.794945372088229e-5, 4.926378066378069e-5, 7.001710987425276e-7]
    mean_immunity_durations = [250.63492063492063, 304.5260770975057, 97.51123479694908, 45.73201401772829, 86.96310039167182, 119.15192743764172, 108.00206143063289]

    # MAE = 808.6643872952768
    # RMSE = 1467.7307778738348
    # nMAE = 0.46570126659021266
    # S_square = 3.1365641744791994e9
    # duration_parameter = 3.4354772211915052
    # susceptibility_parameters = [3.176726448155019, 3.3922284065141186, 3.553927025355601, 5.129560915275203, 3.968928056070919, 3.84672850958565, 4.715578231292513]
    # temperature_parameters = [-0.8174994846423416, -0.8747165532879818, -0.1540808080808081, -0.10354949494949496, -0.2562966398680683, -0.2670773036487323, -0.2131313131313131]
    # random_infection_probabilities = [0.00011659637188208614, 6.791005978148835e-5, 4.926479076479079e-5, 7.077468563182852e-7]
    # mean_immunity_durations = [251.33189033189032, 302.43516800659665, 98.08699237270666, 48.36837765409193, 86.32673675530818, 116.6367759224902, 105.00206143063289]

    # MAE = 801.5605354226491
    # RMSE = 1454.3589175769957
    # nMAE = 0.4616102334413224
    # S_square = 3.079672757813623e9
    duration_parameter = 3.4430529787672626
    susceptibility_parameters = [3.1762213976499685, 3.3452587095444217, 3.505947227375803, 5.110874046588334, 4.001756338899202, 3.8815769944341345, 4.71204287775716]
    temperature_parameters = [-0.8452772624201194, -0.8822923108637394, -0.16670707070707072, -0.11516565656565658, -0.23255926613069455, -0.24131972789115652, -0.17222222222222217]
    random_infection_probabilities = [0.0001166468769325912, 6.797773654916511e-5, 4.933650793650796e-5, 7.088579674293963e-7]
    mean_immunity_durations = [254.27128427128426, 300.40486497629365, 98.54153782725211, 48.82292310863738, 88.05400948258091, 115.21253349824778, 107.09297052154199]

    # MAE = 794.8733545175048
    # RMSE = 1457.8933324109737
    # nMAE = 0.4577591566950598
    # S_square = 3.0946595224102726e9
    duration_parameter = 3.431436817151101
    susceptibility_parameters = [3.1262213976499686, 3.346773861059573, 3.5357452071737825, 5.0740053597196475, 3.9547866419295055, 3.868950731807872, 4.72264893836322]
    temperature_parameters = [-0.8053782725211294, -0.8363327149041434, -0.17125252525252527, -0.07122626262626264, -0.23306431663574506, -0.20445104102246967, -0.20505050505050498]
    random_infection_probabilities = [0.00011590950319521746, 6.793026180169036e-5, 4.925670995670998e-5, 7.101710987425276e-7]
    mean_immunity_durations = [253.57431457431454, 300.8594104308391, 99.11729540300969, 47.459286745001016, 89.78128220985364, 116.69738198309626, 107.24448567305714]

    # MAE = 791.1555497388223
    # RMSE = 1500.1680978897707
    # nMAE = 0.4556181122499611
    # S_square = 3.276734292724565e9
    duration_parameter = 3.4369923727066567
    susceptibility_parameters = [3.091372912801484, 3.374551638837351, 3.535240156668732, 5.078550814265102, 3.94923108637395, 3.8603648732220135, 4.682749948464231]
    temperature_parameters = [-0.7644691816120385, -0.8247165532879818, -0.14044444444444446, -0.06971111111111111, -0.18609461966604812, -0.23828942486085353, -0.21464646464646459]
    random_infection_probabilities = [0.00011670748299319726, 6.785652442795299e-5, 4.926378066378069e-5, 7.009791795506084e-7]
    mean_immunity_durations = [251.11976911976907, 297.9806225520512, 98.42032570603999, 47.79262007833435, 90.66007008864152, 118.30344258915687, 105.82024324881472]


#     MAE = 803.8219063198119
# RMSE = 1482.3308047313017
# nMAE = 0.4629125330202136
# S_square = 3.1992755189381876e9
# duration_parameter = 3.1849721706864558
# susceptibility_parameters = [2.9171304885590597, 3.2730364873221998, 3.5973613687899437, 5.264914450628736, 3.96084724799011, 3.7548093176664583, 4.50951762523191]
# temperature_parameters = [-0.682145949288806, -0.7252216037930322, -0.1086262626262626, -0.07627676767676769, -0.08962997320140169, -0.16202679859822725, -0.07373737373737375]
# random_infection_probabilities = [0.0001145357658214801, 6.771612038754894e-5, 4.913347763347766e-5, 7.041104926819216e-7]
# mean_immunity_durations = [253.02886002886004, 302.0715316429602, 95.78396206967636, 46.55019583591011, 87.47825190682333, 113.00041228612656, 105.06266749123893]





    # MAE = 792.904538823402
    # RMSE = 1483.8943523602538
    # nMAE = 0.4566253365629614
    # S_square = 3.2060282056954527e9
    # duration_parameter = 4.04810348381777
    # susceptibility_parameters = [3.115615337043909, 3.6715213358070486, 3.743320964749539, 5.633096268810553, 4.097715934858796, 3.9765264893836303, 4.572648938363223]
    # temperature_parameters = [-0.7680045351473922, -0.7807771593485876, -0.055555555555555566, -0.11565656565656568, -0.12947845804988656, -0.16245104102246966, -0.2324572253143693]
    # random_infection_probabilities = [0.00011528324056895483, 6.792824159967017e-5, 4.923852813852817e-5, 6.7259534116677e-7]
    # mean_immunity_durations = [249.6349206349206, 312.5563801278087, 98.20820449391877, 36.55019583591011, 83.9631003916718, 116.51556380127805, 103.24448567305711]

    # MAE = 791.7049158918541
    # RMSE = 1470.306513034289
    # nMAE = 0.45593448640629614
    # S_square = 3.1475826087466483e9
    # duration_parameter = 4.057194392908679
    # susceptibility_parameters = [3.1933931148216868, 3.613945578231291, 3.705947227375802, 5.662389198103482, 4.072463409606271, 3.957334570191711, 4.4968913626056475]
    # temperature_parameters = [-0.7210348381776952, -0.7560296846011129, -0.10555555555555557, -0.07373737373737375, -0.13806431663574514, -0.146794475365904, -0.23902288188002585]
    # random_infection_probabilities = [0.00011444485673057098, 6.799793856936713e-5, 4.918701298701302e-5, 6.664337250051538e-7]
    # mean_immunity_durations = [248.57431457431454, 311.5563801278087, 97.26881055452483, 38.277468563182836, 86.9631003916718, 117.93980622552047, 104.06266749123893]

    # MAE = 787.1627168160165
    # RMSE = 1455.6593867241222
    # nMAE = 0.45331868200591013
    # S_square = 3.0851828282301173e9
    # duration_parameter = 4.124871160585446
    # susceptibility_parameters = [3.190362811791384, 3.705864770150483, 3.650391671820246, 5.598752834467119, 3.9825644197072805, 4.000768913626054, 4.530224695938981]
    # temperature_parameters = [-0.749822716965574, -0.7413832199546482, -0.12222222222222223, -0.032828282828282845, -0.10725623582766433, -0.13820861678004542, -0.2819521748093188]
    # random_infection_probabilities = [0.0001146569779426922, 6.802925170068026e-5, 4.9165800865800896e-5, 6.699690785405074e-7]
    # mean_immunity_durations = [247.6349206349206, 308.9200164914451, 96.39002267573696, 40.428983714697985, 86.2661306947021, 115.12162440733866, 104.51721294578438]






    # duration_parameter = 5.5
    # susceptibility_parameters = [2.0580395794681514, 2.684652648938362, 2.617058338486913, 4.478550814265098, 2.945190682333544, 2.6139002267573696, 3.5655782312925155]
    # temperature_parameters = [-0.9220449391877963, -0.7772418058132341, -0.1949804164089878, -0.0393939393939394, -0.08250876108018959, -0.15083487940630802, -0.3359224902082046]
    # random_infection_probabilities = [0.00011537414965986393, 6.832319109461966e-5, 4.910216450216453e-5, 6.985549371263659e-7]
    # mean_immunity_durations = [253.96825396825392, 314.95031952174816, 97.14759843331271, 22.70171098742527, 80.84188827045969, 114.48526077097503, 85.45660688517833]

    # duration_parameter = 5.406060606060606
    # susceptibility_parameters = [2.0873325087610803, 2.7078849721706852, 2.710997732426307, 4.521985157699442, 2.996705833848696, 2.675516388373531, 3.578709544423829]
    # temperature_parameters = [-0.9265903937332508, -0.8080498866213149, -0.15104102246959386, -0.0494949494949495, -0.10018552875695727, -0.199824778396207, -0.32531642960214396]
    # random_infection_probabilities = [0.00011588930117501544, 6.826359513502371e-5, 4.904862914862917e-5, 6.885549371263659e-7]
    # mean_immunity_durations = [254.96825396825392, 314.79880437023303, 96.3294166151309, 25.095650381364663, 81.5388579674294, 113.00041228612655, 83.66872809729955]

    # duration_parameter = 5.352525252525253
    # susceptibility_parameters = [2.142888064316636, 2.6301071943929073, 2.6635229849515594, 4.617944753659038, 2.9775139146567766, 2.638142650999794, 3.593861059575344]
    # temperature_parameters = [-0.9695196866625437, -0.7610801896516179, -0.18992991135848275, -0.06767676767676768, -0.11079158936301789, -0.20841063698206558, -0.28440733869305307]
    # random_infection_probabilities = [0.00011523273551844979, 6.821612038754895e-5, 4.9077922077922105e-5, 6.949185734900023e-7]
    # mean_immunity_durations = [254.27128427128423, 313.6775922490209, 97.6324469181612, 22.338074623788906, 83.32673675530818, 112.48526077097503, 80.9111523397238]

    # duration_parameter = 5.284848484848486
    # susceptibility_parameters = [2.05702947845805, 2.6311172954030084, 2.6382704596990343, 4.693702329416613, 3.01084724799011, 2.7260214388785817, 3.600931766646051]
    # temperature_parameters = [-0.9929292929292929, -0.7646155431869714, -0.2156874871160585, -0.03787878787878789, -0.10624613481756334, -0.197804576376005, -0.2354174397031541]
    # random_infection_probabilities = [0.00011437414965986393, 6.812420119562976e-5, 4.9010245310245336e-5, 6.980498866213153e-7]
    # mean_immunity_durations = [255.08946608946604, 313.0412286126573, 97.5415378272521, 19.64110492681921, 84.14491857348999, 112.21253349824777, 79.66872809729955]

    # duration_parameter = 5.213131313131314
    # susceptibility_parameters = [2.0620799835085553, 2.5553597196454327, 2.578674500103075, 4.682591218305502, 3.0583219954648575, 2.7654153782725213, 3.698911564625849]
    # temperature_parameters = [-0.913131313131313, -0.7287569573283855, -0.22124304267161407, -0.08585858585858586, -0.11180169037311889, -0.151844980416409, -0.23289218717790156]
    # random_infection_probabilities = [0.00011357616986188413, 6.81635951350237e-5, 4.902135642135645e-5, 6.910801896516184e-7]
    # mean_immunity_durations = [254.57431457431454, 316.0412286126573, 96.66274994846422, 20.277468563182847, 86.78128220985363, 113.33374561945989, 76.97175840032985]

    # duration_parameter = 5.262626262626264
    # susceptibility_parameters = [2.0045042259327976, 2.6351576994434125, 2.5958462172747923, 4.633096268810553, 2.9765038136466755, 2.746223459080602, 3.7181034838177682]
    # temperature_parameters = [-0.8803030303030301, -0.727241805813234, -0.25104102246959387, -0.13282828282828282, -0.12644815501958354, -0.1796227581941868, -0.1960235003092147]
    # random_infection_probabilities = [0.00011328324056895485, 6.826157493300351e-5, 4.899408369408372e-5, 6.81686250257679e-7]
    # mean_immunity_durations = [252.48340548340545, 318.0109255823543, 96.99608328179755, 22.125953411667695, 88.7509791795506, 114.51556380127808, 77.78994021851166]

    # duration_parameter = 5.259595959595961
    # susceptibility_parameters = [2.031776953205525, 2.694753659039372, 2.675644197072772, 4.567439703153987, 2.9169078540507156, 2.6805668934240363, 3.62012368583797]
    # temperature_parameters = [-0.8969696969696969, -0.7095650381364663, -0.21720263863121003, -0.14646464646464646, -0.14614512471655325, -0.20437023294166157, -0.1470336013193157]
    # random_infection_probabilities = [0.0001129297052154195, 6.822824159967017e-5, 4.90678210678211e-5, 6.728983714698002e-7]
    # mean_immunity_durations = [252.69552669552667, 316.88971346114215, 94.48093176664604, 23.792620078334362, 91.4479488765203, 117.39435168006595, 76.18387961245105]

    # viruses = Virus[
    #     # FluA
    #     Virus(1.4, 0.09, 1, 7,  4.8, 1.12, 3, 21,  8.8, 3.748, 3, 21,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
    #     # FluB
    #     Virus(1.0, 0.0484, 1, 7,  3.7, 0.66, 3, 21,  7.8, 2.94, 3, 21,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
    #     # RV
    #     Virus(1.9, 0.175, 1, 7,  10.1, 4.93, 3, 21,  11.4, 6.25, 3, 21,  3.5, 2.6, 1.8,  0.19, 0.24, 0.29,  mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
    #     # RSV
    #     Virus(4.4, 0.937, 1, 7,  7.4, 2.66, 3, 21,  9.3, 4.0, 3, 21,  6.0, 4.5, 3.0,  0.24, 0.3, 0.36,  mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
    #     # AdV
    #     Virus(5.6, 1.51, 1, 7,  8.0, 3.1, 3, 21,  9.0, 3.92, 3, 21,  4.1, 3.1, 2.1,  0.15, 0.19, 0.23,  mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
    #     # PIV
    #     Virus(2.6, 0.327, 1, 7,  7.0, 2.37, 3, 21,  8.0, 3.1, 3, 21,  4.8, 3.6, 2.4,  0.16, 0.2, 0.24,  mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
    #     # CoV
    #     Virus(3.2, 0.496, 1, 7,  6.5, 2.15, 3, 21,  7.5, 2.9, 3, 21,  4.9, 3.7, 2.5,  0.21, 0.26, 0.32,  mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

    viruses = Virus[
        # FluA
        Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  4.6, 3.5, 2.3,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        # FluB
        Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 1.7, 1, 28,  4.7, 3.5, 2.4,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
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
        schools,
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
        num_years,
    )
end

main()
