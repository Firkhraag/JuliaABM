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

        @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt = run_simulation(
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
    duration_parameter = 3.970325706039992
    susceptibility_parameters = [3.201473922902495, 3.708895073180786, 3.817058338486913, 5.601783137497422, 4.082564419707281, 4.03612244897959, 4.4968913626056475]
    temperature_parameters = [-0.7745701917130488, -0.769160997732426, -0.09444444444444446, -0.11111111111111113, -0.12291280148423, -0.11346114203257066, -0.24710368996083393]
    random_infection_probabilities = [0.00011583879612451038, 6.800197897340754e-5, 4.915064935064938e-5, 6.634034219748507e-7]
    mean_immunity_durations = [252.02886002886, 312.16244073386935, 98.2385075242218, 34.277468563182836, 83.02370645227786, 116.12162440733866, 101.6384250669965]


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
