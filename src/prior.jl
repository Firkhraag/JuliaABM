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
    # num_parameters = 29
    # num_parameters = 1
    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 1000)

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

    # points = scaleLHC(latin_hypercube_plan, [
    #     # (duration_parameter_default - 0.1, duration_parameter_default + 0.1),
    #     (duration_parameter_default - 0.05, duration_parameter_default + 0.05),
    #     (susceptibility_parameters_default[1] - 0.1, susceptibility_parameters_default[1] + 0.1),
    #     (susceptibility_parameters_default[2] - 0.1, susceptibility_parameters_default[2] + 0.1),
    #     (susceptibility_parameters_default[3] - 0.1, susceptibility_parameters_default[3] + 0.1),
    #     (susceptibility_parameters_default[4] - 0.1, susceptibility_parameters_default[4] + 0.1),
    #     (susceptibility_parameters_default[5] - 0.1, susceptibility_parameters_default[5] + 0.1),
    #     (susceptibility_parameters_default[6] - 0.1, susceptibility_parameters_default[6] + 0.1),
    #     (susceptibility_parameters_default[7] - 0.1, susceptibility_parameters_default[7] + 0.1),
    #     (temperature_parameters_default[1] - 0.05, temperature_parameters_default[1] + 0.05),
    #     (temperature_parameters_default[2] - 0.05, temperature_parameters_default[2] + 0.05),
    #     (temperature_parameters_default[3] - 0.05, temperature_parameters_default[3] + 0.05),
    #     (temperature_parameters_default[4] - 0.05, temperature_parameters_default[4] + 0.05),
    #     (temperature_parameters_default[5] - 0.05, temperature_parameters_default[5] + 0.05),
    #     (temperature_parameters_default[6] - 0.05, temperature_parameters_default[6] + 0.05),
    #     (temperature_parameters_default[7] - 0.05, temperature_parameters_default[7] + 0.05),
    #     (immune_memory_susceptibility_levels_default[1] - 0.03, immune_memory_susceptibility_levels_default[1] + 0.03),
    #     (immune_memory_susceptibility_levels_default[2] - 0.03, immune_memory_susceptibility_levels_default[2] + 0.03),
    #     (immune_memory_susceptibility_levels_default[3] - 0.03, immune_memory_susceptibility_levels_default[3] + 0.03),
    #     (immune_memory_susceptibility_levels_default[4] - 0.03, immune_memory_susceptibility_levels_default[4] + 0.03),
    #     (immune_memory_susceptibility_levels_default[5] - 0.03, immune_memory_susceptibility_levels_default[5] + 0.03),
    #     (immune_memory_susceptibility_levels_default[6] - 0.03, immune_memory_susceptibility_levels_default[6] + 0.03),
    #     (immune_memory_susceptibility_levels_default[7] - 0.03, immune_memory_susceptibility_levels_default[7] + 0.03),
    #     (mean_immunity_durations[1] - 5.0, mean_immunity_durations[1] + 5.0),
    #     (mean_immunity_durations[2] - 5.0, mean_immunity_durations[2] + 5.0),
    #     (mean_immunity_durations[3] - 5.0, mean_immunity_durations[3] + 5.0),
    #     (mean_immunity_durations[4] - 5.0, mean_immunity_durations[4] + 5.0),
    #     (mean_immunity_durations[5] - 5.0, mean_immunity_durations[5] + 5.0),
    #     (mean_immunity_durations[6] - 5.0, mean_immunity_durations[6] + 5.0),
    #     (mean_immunity_durations[7] - 5.0, mean_immunity_durations[7] + 5.0),
    #     (random_infection_probabilities_default[1] - random_infection_probabilities_default[1] * 0.05, random_infection_probabilities_default[1] + random_infection_probabilities_default[1] * 0.05),
    #     (random_infection_probabilities_default[2] - random_infection_probabilities_default[2] * 0.05, random_infection_probabilities_default[2] + random_infection_probabilities_default[2] * 0.05),
    #     (random_infection_probabilities_default[3] - random_infection_probabilities_default[3] * 0.05, random_infection_probabilities_default[3] + random_infection_probabilities_default[3] * 0.05),
    #     (random_infection_probabilities_default[4] - random_infection_probabilities_default[4] * 0.05, random_infection_probabilities_default[4] + random_infection_probabilities_default[4] * 0.05),
    # ])

    points = scaleLHC(latin_hypercube_plan, [
        # (duration_parameter_default - 0.1, duration_parameter_default + 0.1),
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

    # points = scaleLHC(latin_hypercube_plan, [
    #     (susceptibility_parameters_default[2] - 5.0, susceptibility_parameters_default[2] + 0.01),
    # ])

    # points = scaleLHC(latin_hypercube_plan, [
    #     (2.5, 5.0), # duration_parameter
    #     (1.0, 8.0), # susceptibility_parameters
    #     (1.0, 8.0),
    #     (1.0, 8.0),
    #     (1.0, 8.0),
    #     (1.0, 8.0),
    #     (1.0, 8.0),
    #     (1.0, 8.0),
    #     (-1.0, -0.01), # temperature_parameters
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (0.5, 1.0), # immune_memory_susceptibility_levels
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (30, 365), # mean_immunity_durations
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (0.001, 0.002), # random_infection_probabilities
    #     (0.0005, 0.001),
    #     (0.0002, 0.0005),
    #     (0.000005, 0.000015),
    # ])

    # points = scaleLHC(latin_hypercube_plan, [
    #     (0.1, 1.0), # duration_parameter
    #     (1.0, 7.0), # susceptibility_parameters
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (-1.0, -0.01), # temperature_parameters
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (0.5, 1.0), # immune_memory_susceptibility_levels
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (0.5, 1.0),
    #     (30, 365), # mean_immunity_durations
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     # (0.001, 0.002), # random_infection_probabilities
    #     # (0.0005, 0.001),
    #     # (0.0002, 0.0005),
    #     # (0.000005, 0.000015),
    # ])

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
        save(joinpath(@__DIR__, "..", "parameters_labels", "new_model", "tables", "results_$(i + 496).jld"),
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

    # nMAE = 0.5424788116516213
    # duration_parameter = 0.22036698644738847
    # susceptibility_parameters = [2.973124820049759, 3.2385712447455766, 3.4081319440883644, 4.434215195353213, 3.707243206855803, 3.8493968094694457, 4.782291513865361]
    # temperature_parameters = [-0.9505050505050505, -0.8778837892639345, -0.07171717171717172, -0.08755118755118754, -0.09316981063954417, -0.1394757893644093, -0.36083867585078233]
    # immune_memory_susceptibility_levels = [0.9281002876402393, 0.9199999999999999, 0.9299990899990899, 0.9226317226317226, 0.9322049322049322, 0.8778178178178176, 0.9376167076167076]
    # mean_immunity_durations = [350.4465216450689, 316.5664858279871, 142.85063198917922, 98.05034854671658, 110.08865949059654, 136.91148483158165, 161.21580884050633]
    
    # 0.5349980458940209
    # duration_parameter = 0.22794274402314604
    # susceptibility_parameters = [2.998377345302284, 3.1527126588869905, 3.5000511360075564, 4.520073781211798, 3.772899772512369, 3.769598829671466, 4.78128141285526]
    # temperature_parameters = [-0.9252525252525252, -0.8925302539103992, -0.05707070707070708, -0.03957138957138957, -0.10276577023550376, -0.14705154694016687, -0.381545746557853]
    # immune_memory_susceptibility_levels = [0.913857863397815, 0.9342424242424242, 0.9084839384839384, 0.9059650559650558, 0.9022049322049321, 0.8799390299390297, 0.9548894348894349]
    # mean_immunity_durations = [354.9414711400184, 316.7180009795022, 139.56780370635093, 96.58570208207011, 107.61391201584907, 135.244818164915, 165.50873813343563]

    # nMAE = 0.5244722462925852
    # duration_parameter = 0.22541749149789353
    # susceptibility_parameters = [3.0519126988376377, 3.111298517472849, 3.575808711765132, 4.579669740807757, 3.8446169442295406, 3.7201038801765165, 4.725725857299705]
    # temperature_parameters = [-0.9116161616161615, -0.8536413650215102, -0.013131313131313133, -0.0787878787878788, -0.0568061742759078, -0.1717990216876416, -0.4123538273659338]
    # immune_memory_susceptibility_levels = [0.920827560367512, 0.9503030303030303, 0.9306051506051505, 0.9292983892983891, 0.9043261443261442, 0.8766056966056964, 0.9527272727272726]
    # mean_immunity_durations = [358.3253095238568, 316.86951613101735, 137.49709663564386, 101.28267177903982, 105.1391645411016, 139.6387575588544, 164.44813207282957]

    # 0.5189713551481547
    # duration_parameter = 0.24713466321506525
    # susceptibility_parameters = [3.087266234191173, 3.096147002321334, 3.487929923886344, 4.588760649898666, 3.875930075542672, 3.7898008498734863, 4.70047333204718]
    # temperature_parameters = [-0.9373737373737373, -0.88343934481949, -0.02323232323232323, -0.10151515151515152, -0.027008194477928002, -0.12886972875834868, -0.40679827181037825]
    # immune_memory_susceptibility_levels = [0.890827560367512, 0.9327272727272726, 0.9563627263627262, 0.9386923286923285, 0.9294776594776594, 0.8878178178178177, 0.9254545454545454]
    # mean_immunity_durations = [356.15359235213964, 321.36446562596683, 138.96174310029033, 99.21196470833274, 106.09876050069755, 141.70946462956147, 167.73096035565786]

    # 0.5128575932033336
    # duration_parameter = 0.2506700167504188
    # susceptibility_parameters = [3.070094517019456, 3.1092783154526473, 3.4303541663105865, 4.646336407474424, 3.9415866411992377, 3.825154385227022, 4.622695554269402]
    # temperature_parameters = [-0.9095959595959595, -0.8748534862336315, -0.08181818181818182, -0.13434343434343435, -0.02121212121212121, -0.12331417320279311, -0.37599019100229747]
    # immune_memory_susceptibility_levels = [0.8971911967311483, 0.9196969696969696, 0.9254545454545454, 0.9608135408135406, 0.9170534170534169, 0.891151151151151, 0.9524242424242424]
    # mean_immunity_durations = [356.9111681097154, 324.2432535047547, 134.46679360534083, 98.65640915277719, 101.19977060170766, 145.29532321542004, 165.35722298192047]

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

    # num_runs = 200
    # num_runs = 100
    num_runs = 300
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
