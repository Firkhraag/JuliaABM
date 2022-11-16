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
)
    # num_parameters = 26
    # num_parameters = 29
    num_parameters = 33
    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 1000)

    if duration_parameter_default > 5.4
        duration_parameter_default = 5.4
    end
    if duration_parameter_default < 2.6
        duration_parameter_default = 2.6
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
        (immune_memory_susceptibility_levels_default[1] - 0.05, immune_memory_susceptibility_levels_default[1] + 0.05),
        (immune_memory_susceptibility_levels_default[2] - 0.05, immune_memory_susceptibility_levels_default[2] + 0.05),
        (immune_memory_susceptibility_levels_default[3] - 0.05, immune_memory_susceptibility_levels_default[3] + 0.05),
        (immune_memory_susceptibility_levels_default[4] - 0.05, immune_memory_susceptibility_levels_default[4] + 0.05),
        (immune_memory_susceptibility_levels_default[5] - 0.05, immune_memory_susceptibility_levels_default[5] + 0.05),
        (immune_memory_susceptibility_levels_default[6] - 0.05, immune_memory_susceptibility_levels_default[6] + 0.05),
        (immune_memory_susceptibility_levels_default[7] - 0.05, immune_memory_susceptibility_levels_default[7] + 0.05),
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

    nMAE_min = 1.0e12

    for i = 1:num_runs
        println(i)

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]
        immune_memory_susceptibility_levels =  points[i, 16:22]
        random_infection_probabilities = points[i, 30:33]
        # random_infection_probabilities = random_infection_probabilities_default

        # duration_parameter = duration_parameter_default
        # susceptibility_parameters = susceptibility_parameters_default
        # temperature_parameters = temperature_parameters_default
        # random_infection_probabilities = random_infection_probabilities_default

        for k = 1:length(viruses)
            viruses[k].mean_immunity_duration = points[i, 22 + k]
            viruses[k].immunity_duration_sd = points[i, 22 + k] * 0.33
            # viruses[k].mean_immunity_duration = points[i, k]
            # viruses[k].immunity_duration_sd = points[i, k] * 0.33
        end

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

        # observed_num_infected_age_groups_viruses = zeros(Float64, 52, 7, 4)
        # for i = 1:num_years
        #     for j = 1:52
        #         for k = 1:7
        #             for z = 1:4
        #                 observed_num_infected_age_groups_viruses[j, k, z] += observed_num_infected_age_groups_viruses[52 * (i - 1) + j, k, z]
        #             end
        #         end
        #     end
        # end
        # for j = 1:52
        #     for k = 1:7
        #         for z = 1:4
        #             observed_num_infected_age_groups_viruses[j, k, z] /= num_years
        #         end
        #     end
        # end

        nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    
        # MAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / (size(observed_num_infected_age_groups_viruses)[1] * size(observed_num_infected_age_groups_viruses)[2] * size(observed_num_infected_age_groups_viruses)[3])
        # RMSE = sqrt(sum((observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)) / sqrt((size(observed_num_infected_age_groups_viruses)[1] * size(observed_num_infected_age_groups_viruses)[2] * size(observed_num_infected_age_groups_viruses)[3]))
        # nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        # S_square = sum((observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)

        if nMAE < nMAE_min
            nMAE_min = nMAE
        end

        println("nMAE_cur = ", nMAE)
        println("nMAE_min = ", nMAE_min)

        # incidence_arr_mean = sum(sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1], dims = 2)[:, 1]

        # infected_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
        # infected_data_mean = vec(transpose(infected_data[42:(41 + num_years), 2:53]))

        # nMAE_general = sum(abs.(incidence_arr_mean - infected_data_mean)) / sum(infected_data_mean)
        # println("General nMAE: $(nMAE_general)")

        # # ------------------
        # incidence_arr_mean = sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :]

        # infected_data_0 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
        # infected_data_3 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
        # infected_data_7 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
        # infected_data_15 = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

        # infected_data_mean = cat(
        #     vec(infected_data_0[2:53, 24:(23 + num_years)]),
        #     vec(infected_data_3[2:53, 24:(23 + num_years)]),
        #     vec(infected_data_7[2:53, 24:(23 + num_years)]),
        #     vec(infected_data_15[2:53, 24:(23 + num_years)]),
        #     dims = 2,
        # )

        # nMAE_0_2 = sum(abs.(incidence_arr_mean[:, 1] - infected_data_mean[:, 1])) / sum(infected_data_mean[:, 1])
        # println("0-2 nMAE: $(nMAE_0_2)")

        # nMAE_3_6 = sum(abs.(incidence_arr_mean[:, 2] - infected_data_mean[:, 2])) / sum(infected_data_mean[:, 2])
        # println("3-6 nMAE: $(nMAE_3_6)")

        # nMAE_7_14 = sum(abs.(incidence_arr_mean[:, 3] - infected_data_mean[:, 3])) / sum(infected_data_mean[:, 3])
        # println("7-14 nMAE: $(nMAE_7_14)")

        # nMAE_15 = sum(abs.(incidence_arr_mean[:, 4] - infected_data_mean[:, 4])) / sum(infected_data_mean[:, 4])
        # println("15+ nMAE: $(nMAE_15)")

        # # ------------------

        # incidence_arr_mean = sum(observed_num_infected_age_groups_viruses, dims = 3)[:, :, 1]

        # infected_data = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu.csv"), ',', Int, '\n')
        # infected_data = transpose(infected_data[42:(41 + num_years), 2:53])

        # etiology = get_etiology()

        # infected_data_1 = etiology[:, 1] .* infected_data
        # infected_data_2 = etiology[:, 2] .* infected_data
        # infected_data_3 = etiology[:, 3] .* infected_data
        # infected_data_4 = etiology[:, 4] .* infected_data
        # infected_data_5 = etiology[:, 5] .* infected_data
        # infected_data_6 = etiology[:, 6] .* infected_data
        # infected_data_7 = etiology[:, 7] .* infected_data
        # infected_data_viruses_mean = cat(
        #     vec(infected_data_1),
        #     vec(infected_data_2),
        #     vec(infected_data_3),
        #     vec(infected_data_4),
        #     vec(infected_data_5),
        #     vec(infected_data_6),
        #     vec(infected_data_7),
        #     dims = 2)

        # nMAE_FluA = sum(abs.(incidence_arr_mean[:, 1] - infected_data_viruses_mean[:, 1])) / sum(infected_data_viruses_mean[:, 1])
        # println("FluA nMAE: $(nMAE_FluA)")

        # nMAE_FluB = sum(abs.(incidence_arr_mean[:, 2] - infected_data_viruses_mean[:, 2])) / sum(infected_data_viruses_mean[:, 2])
        # println("FluB nMAE: $(nMAE_FluB)")

        # nMAE_RV = sum(abs.(incidence_arr_mean[:, 3] - infected_data_viruses_mean[:, 3])) / sum(infected_data_viruses_mean[:, 3])
        # println("RV nMAE: $(nMAE_RV)")

        # nMAE_RSV = sum(abs.(incidence_arr_mean[:, 4] - infected_data_viruses_mean[:, 4])) / sum(infected_data_viruses_mean[:, 4])
        # println("RSV nMAE: $(nMAE_RSV)")

        # nMAE_AdV = sum(abs.(incidence_arr_mean[:, 5] - infected_data_viruses_mean[:, 5])) / sum(infected_data_viruses_mean[:, 5])
        # println("AdV nMAE: $(nMAE_AdV)")

        # nMAE_PIV = sum(abs.(incidence_arr_mean[:, 6] - infected_data_viruses_mean[:, 6])) / sum(infected_data_viruses_mean[:, 6])
        # println("PIV nMAE: $(nMAE_PIV)")

        # nMAE_CoV = sum(abs.(incidence_arr_mean[:, 7] - infected_data_viruses_mean[:, 7])) / sum(infected_data_viruses_mean[:, 7])
        # println("CoV nMAE: $(nMAE_CoV)")

        # averaged_nMAE = nMAE_FluA + nMAE_FluB + nMAE_RV + nMAE_RSV + nMAE_AdV + nMAE_PIV + nMAE_CoV + nMAE_general + nMAE_0_2 + nMAE_3_6 + nMAE_7_14 + nMAE_15
        # averaged_nMAE /= 12
        # println("Averaged nMAE: $(averaged_nMAE)")

        # if averaged_nMAE < averaged_nMAE_min
        #     averaged_nMAE_min = averaged_nMAE
        # end

        # println("Min")
        # println("MAE_min = ", MAE_min)
        # println("RMSE_min = ", RMSE_min)
        # println("nMAE_min = ", nMAE_min)
        # println("S_square_min = ", S_square_min)
        # println("averaged_nMAE_min = ", averaged_nMAE_min)

        open("output/output.txt", "a") do io
            println(io, "nMAE = ", nMAE)
            println(io, "duration_parameter = ", duration_parameter)
            println(io, "susceptibility_parameters = ", susceptibility_parameters)
            println(io, "temperature_parameters = ", temperature_parameters)
            println(io, "random_infection_probabilities = ", random_infection_probabilities)
            println(io, "immune_memory_susceptibility_levels = ", immune_memory_susceptibility_levels)
            # println(io, "mean_immunity_durations = ", [points[i, 20], points[i, 21], points[i, 22], points[i, 23], points[i, 24], points[i, 25], points[i, 26]])
            println(io, "mean_immunity_durations = ", [points[i, 23], points[i, 24], points[i, 25], points[i, 26], points[i, 27], points[i, 28], points[i, 29]])
            # println(io, "mean_immunity_durations = ", [points[i, 1], points[i, 2], points[i, 3], points[i, 4], points[i, 5], points[i, 6], points[i, 7]])
            println(io)
        end

        # !!!!!!!!!!!!!!!!!!!!!!!!
        # Surrogate model training
        save(joinpath(@__DIR__, "..", "parameters_labels", "test", "tables", "results_$(i + 233).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "duration_parameter", duration_parameter,
            "susceptibility_parameters", susceptibility_parameters,
            "temperature_parameters", temperature_parameters,
            "random_infection_probabilities", random_infection_probabilities,
            "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
            "mean_immunity_durations", [points[i, 23], points[i, 24], points[i, 25], points[i, 26], points[i, 27], points[i, 28], points[i, 29]])
        # !!!!!!!!!!!!!!!!!!!!!!!!
    end
end

function main()
    println("Initialization...")

    num_years = 2
    # num_years = 1

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

    # Значения по умолчанию
    # MAE = 8102.385989010989
    # RMSE = 16730.329106749414
    # nMAE = 0.8479873742178521
    # nMAE_general = 0.25513686616373477
    # nMAE_0_2 = 0.6545364358790557
    # nMAE_3_6 = 0.3961378251502477
    # nMAE_7_14 = 0.32563074370904216
    # nMAE_15 = 0.3032275815743922
    # nMAE_FluA = 0.6056144791641577
    # nMAE_FluB = 0.5076132194545417
    # nMAE_RV = 0.4352634322160331
    # nMAE_RSV = 0.40660058519171355
    # nMAE_AdV = 0.4001107236423587
    # nMAE_PIV = 0.4842520506463988
    # nMAE_CoV = 0.4982699023670046
    # averaged_nMAE = 0.4393661537632234
    # S_square = 1.222620287704e12
    # duration_parameter = 3.4530208693646935
    # susceptibility_parameters = [2.961469101251183, 3.167287716319191, 3.4916943562222045, 4.6394720291814755, 3.7734951731077695, 3.884105915607123, 4.764410553127257]
    # temperature_parameters = [-0.9186440677966101, -0.8710653753026634, -0.058308068579255024, -0.18910795956800802, -0.15449393624938407, -0.13182946028950876, -0.39406884479523696]
    # random_infection_probabilities = [0.0014940628663457143, 0.0008840743021979316, 0.00038872171014607207, 9.17650342489106e-6]
    # immune_memory_susceptibility_levels = [0.9098056664884753, 0.9358503401360532, 0.970090143915809, 1.0089242476651676, 0.934450209462314, 0.9150099053488884, 1.0415254237288136]
    # mean_immunity_durations = [335.0017819146148, 302.32613230191924, 148.23370522939533, 92.42560506483024, 101.87847342326762, 140.87062950501206, 159.8814782204614]

    duration_parameter = 3.4981229101810196
    susceptibility_parameters = [2.954326244108326, 3.204022410196742, 3.4467963970385314, 4.6762067230590265, 3.7163523159649126, 3.888187548260184, 4.837879940882358]
    temperature_parameters = [-0.9659183673469387, -0.8975959875475613, -0.058308068579255024, -0.10339367385372232, -0.11163679339224122, -0.1379519092691006, -0.34713006928503287]
    random_infection_probabilities = [0.0014794579506836707, 0.0008793683095140078, 0.0003872949994728858, 9.187485035591078e-6]
    immune_memory_susceptibility_levels = [0.882254646080312, 0.915442176870747, 0.9775510204081632, 0.9530612244897959, 0.9061224489795917, 0.9530612244897959, 0.9081632653061223]
    mean_immunity_durations = [336.9405574248189, 302.93837719987846, 139.86635829061981, 87.3235642485037, 101.4703101579615, 141.27879277031818, 158.45290679188997]


#     MAE = 8697.192078754579
# RMSE = 18467.555486333236
# nMAE = 0.85421136045895
# nMAE_general = 0.2433218583566225
# nMAE_0_2 = 0.6542560729888327
# nMAE_3_6 = 0.4016351001264837
# nMAE_7_14 = 0.334754761133114
# nMAE_15 = 0.31139380473816103
# nMAE_FluA = 0.5921555771408605
# nMAE_FluB = 0.5109756542773303
# nMAE_RV = 0.44389678657484216
# nMAE_RSV = 0.33211642015883336
# nMAE_AdV = 0.4035811610362842
# nMAE_PIV = 0.4565264330126922
# nMAE_CoV = 0.5164333646277555
# averaged_nMAE = 0.433420582847651
# S_square = 1.489709045439e12
duration_parameter = 3.503224950997346
susceptibility_parameters = [2.973713999210367, 3.211165267339599, 3.4274086419364904, 4.675186314895761, 3.707168642495525, 3.903493670709164, 4.855226879657868]
temperature_parameters = [-0.9510204081632653, -0.9435143548945001, -0.020552966538438702, -0.1452304085475999, -0.14122863012693512, -0.1512172153915496, -0.3869259876523798]
random_infection_probabilities = [0.0014779482997135853, 0.0008741638848250473, 0.00038848059641004767, 9.245609940918287e-6]
immune_memory_susceptibility_levels = [0.8444995440394957, 0.9348299319727879, 0.9734693877551021, 0.9734693877551021, 0.95, 1.0, 0.8806122448979591]
mean_immunity_durations = [335.8181084452271, 306.91796903661316, 135.27452155592593, 89.05825812605472, 98.102963219186, 138.93185399480797, 163.04474352658386]



# MAE = 8663.269001831502
# RMSE = 18628.12087132402
# nMAE = 0.8524129372677983
# nMAE_general = 0.2403411364977252
# nMAE_0_2 = 0.6494755262709271
# nMAE_3_6 = 0.396511351331857
# nMAE_7_14 = 0.3273033886853395
# nMAE_15 = 0.31583202004805333
# nMAE_FluA = 0.5960861433037131
# nMAE_FluB = 0.5045083619825148
# nMAE_RV = 0.4543247425811245
# nMAE_RSV = 0.34443620960421767
# nMAE_AdV = 0.4120379241126699
# nMAE_PIV = 0.4534597210854482
# nMAE_CoV = 0.49009863399381226
# averaged_nMAE = 0.43203459662478355
# S_square = 1.515726083275e12
# duration_parameter = 3.4981229101810194
# susceptibility_parameters = [2.991060937985877, 3.2468795530538848, 3.401898437854858, 4.649676110814129, 3.7163523159649126, 3.8596161196887557, 4.856247287821134]
# temperature_parameters = [-0.9306122448979591, -0.9078000691802144, -0.01428571428571429, -0.12176102079249784, -0.16673883420856778, -0.19917639906501897, -0.33896680397891044]
# random_infection_probabilities = [0.0014812661428353913, 0.0008664926507337254, 0.0003871328065857679, 9.304102575238382e-6]
# immune_memory_susceptibility_levels = [0.8659281154680671, 0.9648299319727879, 0.9616326530612245, 0.9726530612244898, 0.9628571428571429, 0.9738775510204082, 0.8885714285714285]
# mean_immunity_durations = [336.32831252685975, 308.6526629141642, 132.1112562498035, 92.83376833013635, 100.85806526000232, 141.48287440297122, 160.4937231184206]

    # 1
    # duration_parameter = 4.9579158316633265
    # susceptibility_parameters = [2.2064128256513027, 7.9579158316633265, 1.561122244488978, 3.3286573146292584, 7.5230460921843685, 2.6693386773547094, 3.1042084168336674]
    # temperature_parameters = [-0.8472344689378757, -0.8016032064128257, -0.37505010020040075, -0.3552104208416834, -0.5297995991983968, -0.2818036072144289, -0.7718436873747495]
    # immune_memory_susceptibility_levels = [0.8176352705410821, 0.5450901803607214, 0.6723446893787575, 0.7394789579158316, 0.530060120240481, 0.9809619238476954, 0.5050100200400801]
    # mean_immunity_durations = [168.52705410821645, 127.85370741482966, 124.40681362725451, 309.8496993987976, 287.1002004008016, 305.02404809619236, 214.02605210420842]
    # random_infection_probabilities = [0.0012925851703406814, 0.0009869739478957915, 0.0004819639278557115, 6.683366733466934e-6]

    # 2
    # duration_parameter = 4.882795256542751
    # susceptibility_parameters = [2.25350537274385, 7.851251251251251, 1.4807600641267977, 3.14082402679597, 7.367881837020114, 2.6350407430567753, 3.2414820541073053]
    # temperature_parameters = [-0.8562844279878348, -0.8244669792765985, -0.3103535855038861, -0.3026442182754809, -0.5322975516963494, -0.1796878550986768, -0.831180296711359]
    # immune_memory_susceptibility_levels = [0.7768353797411912, 0.5106106106106106, 0.7206520876861557, 0.8401933086301824, 0.5467467467467468, 0.9361861861861862, 0.5548048048048049]
    # mean_immunity_durations = [165.4762760574384, 118.3810529421752, 129.94007416051505, 313.6302981793964, 285.5400038406051, 302.39733046947475, 214.97472805288436]    
    # random_infection_probabilities = [0.0013005098977000589, 0.0011099867118351437, 0.0005365039459596167, 5.8868704985090726e-6]

    # 3
    # duration_parameter = 4.838677669568021
    # susceptibility_parameters = [2.142171589981496, 7.810810810810811, 1.5359581193248528, 3.054932012332527, 7.554202851912556, 2.5761451127325734, 3.1624417893527546]
    # temperature_parameters = [-0.8517329377220588, -0.8100964863346771, -0.20031395403568328, -0.2736969036138805, -0.47544069483949264, -0.23019959132469878, -0.7509582379178716]
    # immune_memory_susceptibility_levels = [0.7807443907930594, 0.5898398398398399, 0.7357100027440707, 0.9164838849207587, 0.5615615615615617, 0.943043043043043, 0.5264570693142121]
    # mean_immunity_durations = [155.31111089227323, 126.49896677437476, 132.8611585101708, 306.5489310980293, 291.9929874364459, 307.1595416602574, 204.19813513343428]    
    # random_infection_probabilities = [0.0013105878953824344, 0.001230945333728642, 0.00045769050755017416, 4.687217753836495e-6]

    # 4
    duration_parameter = 4.844800118547613
    susceptibility_parameters = [2.0625797532468018, 7.825096525096526, 1.619631588712608, 3.140646298046813, 7.554202851912556, 2.525124704569308, 3.160400973026224]
    temperature_parameters = [-0.8945900805792018, -0.7733617924571261, -0.2186813009744588, -0.26247241381796216, -0.463195796880309, -0.20570979540633144, -0.7866725236321573]
    random_infection_probabilities = [0.0013279732450150585, 0.0012435060003993424, 0.0004404103557345043, 4.471988367180738e-6]
    immune_memory_susceptibility_levels = [0.8031933703848961, 0.5888194316765746, 0.7295875537644789, 0.9501573543085138, 0.5717656431942147, 0.9277369205940633, 0.5019672733958448]
    mean_immunity_durations = [151.02539660655896, 123.02957901927272, 133.77952585710958, 309.6101555878252, 287.7072731507316, 303.1799498235227, 199.81038003139346]

    # 5
    duration_parameter = 4.8033859771334715
    susceptibility_parameters = [2.1302565209235693, 7.908934908934909, 1.717611386692406, 3.068929126329641, 7.575414973124677, 2.433205512650116, 3.234138346763598]
    temperature_parameters = [-0.878933514922636, -0.7678062369015706, -0.20908534137849918, -0.28115928250483085, -0.4879432716277838, -0.23045727015380618, -0.7669755539351877]
    random_infection_probabilities = [0.0012870609379716652, 0.0012453901003999473, 0.0004477505283300794, 4.280009068589645e-6]
    immune_memory_susceptibility_levels = [0.8218802390717649, 0.5529608458179887, 0.778577452754378, 0.9474747474747475, 0.544997966426538, 0.9534944963516391, 0.5196440410726125]
    mean_immunity_durations = [154.61125519241753, 124.19119518088888, 135.54720262478634, 307.23641821408785, 286.74767719113566, 298.5839902275631, 197.43664265765608]

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

    # infected_data_3 = infected_data_3[2:53, 21:27]
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

    # infected_data_7 = infected_data_7[2:53, 21:27]
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

    # infected_data_15 = infected_data_15[2:53, 21:27]
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

    # infected_data_3 = infected_data_3[2:53, 21:27]
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

    # infected_data_7 = infected_data_7[2:53, 21:27]
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

    # infected_data_15 = infected_data_15[2:53, 21:27]
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

    # num_runs = 100
    # num_runs = 50
    num_runs = 77
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
    )
end

main()
