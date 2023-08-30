using Base.Threads
using Random
using DelimitedFiles
using Distributions
using DataFrames
using CSV
using JLD

include("global/variables.jl")

include("model/virus.jl")
include("model/agent.jl")
include("model/group.jl")
include("model/household.jl")
include("model/workplace.jl")
include("model/school.jl")
include("model/initialization.jl")
include("model/simulation.jl")
include("model/connections.jl")
include("model/contacts.jl")

include("data/etiology.jl")

include("util/moving_avg.jl")
include("util/stats.jl")
include("util/reset.jl")

function simulate_contacts(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    kindergartens::Vector{School},
    schools::Vector{School},
    colleges::Vector{School},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
)
    println("Holiday")
    @time run_simulation_evaluation(
        num_threads, thread_rng, agents, kindergartens,
        schools, colleges, mean_household_contact_durations,
        household_contact_duration_sds, other_contact_duration_shapes,
        other_contact_duration_scales, true)
    println("Weekday")
    @time run_simulation_evaluation(
        num_threads, thread_rng, agents, kindergartens,
        schools, colleges, mean_household_contact_durations,
        household_contact_duration_sds, other_contact_duration_shapes,
        other_contact_duration_scales, false)
end

function global_sensitivity(
    n::Int,
    disturbance::Float64,
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    viruses::Vector{Virus},
    households::Vector{Household},
    schools::Vector{School},
    duration_parameter_default::Float64,
    susceptibility_parameters_default::Vector{Float64},
    temperature_parameters_default::Vector{Float64},
    temperature::Vector{Float64},
    mean_household_contact_durations_default::Vector{Float64},
    household_contact_duration_sds_default::Vector{Float64},
    other_contact_duration_shapes_default::Vector{Float64},
    other_contact_duration_scales_default::Vector{Float64},
    isolation_probabilities_day_1_default::Vector{Float64},
    isolation_probabilities_day_2_default::Vector{Float64},
    isolation_probabilities_day_3_default::Vector{Float64},
    random_infection_probabilities_default::Vector{Float64},
    recovered_duration_mean_default::Float64,
    recovered_duration_sd_default::Float64,
    num_years::Int,
    immune_memory_susceptibility_levels_default::Vector{Float64},
    mean_immunity_durations_default::Vector{Float64},
    incubation_period_durations_default::Vector{Float64},
    incubation_period_duration_variances_default::Vector{Float64},
    infection_period_durations_child_default::Vector{Float64},
    infection_period_duration_variances_child_default::Vector{Float64},
    infection_period_durations_adult_default::Vector{Float64},
    infection_period_duration_variances_adult_default::Vector{Float64},
    symptomatic_probabilities_child_default::Vector{Float64},
    symptomatic_probabilities_teenager_default::Vector{Float64},
    symptomatic_probabilities_adult_default::Vector{Float64},
    mean_viral_loads_infant_default::Vector{Float64},
    mean_viral_loads_child_default::Vector{Float64},
    mean_viral_loads_adult_default::Vector{Float64},
)
    isolation_probabilities_day_1 = copy(isolation_probabilities_day_1_default)
    isolation_probabilities_day_2 = copy(isolation_probabilities_day_2_default)
    isolation_probabilities_day_3 = copy(isolation_probabilities_day_3_default)
    recovered_duration_mean = recovered_duration_mean_default
    recovered_duration_sd = recovered_duration_sd_default
    mean_household_contact_durations = copy(mean_household_contact_durations_default)
    household_contact_duration_sds = copy(household_contact_duration_sds_default)
    other_contact_duration_shapes = copy(other_contact_duration_shapes_default)
    other_contact_duration_scales = copy(other_contact_duration_scales_default)

    duration_parameter = duration_parameter_default
    susceptibility_parameters = copy(susceptibility_parameters_default)
    temperature_parameters = copy(temperature_parameters_default)
    random_infection_probabilities = copy(random_infection_probabilities_default)
    immune_memory_susceptibility_levels = copy(immune_memory_susceptibility_levels_default)
    mean_immunity_durations = copy(mean_immunity_durations_default)

    incubation_period_durations = copy(incubation_period_durations_default)
    incubation_period_duration_variances = copy(incubation_period_duration_variances_default)
    infection_period_durations_child = copy(infection_period_durations_child_default)
    infection_period_duration_variances_child = copy(infection_period_duration_variances_child_default)
    infection_period_durations_adult = copy(infection_period_durations_adult_default)
    infection_period_duration_variances_adult = copy(infection_period_duration_variances_adult_default)
    symptomatic_probabilities_child = copy(symptomatic_probabilities_child_default)
    symptomatic_probabilities_teenager = copy(symptomatic_probabilities_teenager_default)
    symptomatic_probabilities_adult = copy(symptomatic_probabilities_adult_default)
    mean_viral_loads_infant = copy(mean_viral_loads_infant_default)
    mean_viral_loads_child = copy(mean_viral_loads_child_default)
    mean_viral_loads_adult = copy(mean_viral_loads_adult_default)
    
    for run_num = 1:n
        for k = eachindex(isolation_probabilities_day_1_default)
            isolation_probabilities_day_1[k] = isolation_probabilities_day_1_default[k]
            isolation_probabilities_day_2[k] = isolation_probabilities_day_2_default[k]
            isolation_probabilities_day_3[k] = isolation_probabilities_day_3_default[k]
        end
        recovered_duration_mean = recovered_duration_mean_default
        recovered_duration_sd = recovered_duration_sd_default
        for k = eachindex(mean_household_contact_durations_default)
            mean_household_contact_durations[k] = mean_household_contact_durations_default[k]
            household_contact_duration_sds[k] = household_contact_duration_sds_default[k]
        end
        for k = eachindex(other_contact_duration_scales_default)
            other_contact_duration_shapes[k] = other_contact_duration_shapes_default[k]
            other_contact_duration_scales[k] = other_contact_duration_scales_default[k]
        end

        duration_parameter = duration_parameter_default
        for k = eachindex(susceptibility_parameters_default)
            susceptibility_parameters[k] = susceptibility_parameters_default[k]
            temperature_parameters[k] = temperature_parameters_default[k]
        end

        for k = eachindex(random_infection_probabilities_default)
            random_infection_probabilities[k] = random_infection_probabilities_default[k]
        end

        for k = eachindex(incubation_period_durations_default)
            incubation_period_durations[k] = incubation_period_durations_default[k]
            incubation_period_duration_variances[k] = incubation_period_duration_variances_default[k]
            infection_period_durations_child[k] = infection_period_durations_child_default[k]
            infection_period_duration_variances_child[k] = infection_period_duration_variances_child_default[k]
            infection_period_durations_adult[k] = infection_period_durations_adult_default[k]
            infection_period_duration_variances_adult[k] = infection_period_duration_variances_adult_default[k]
            symptomatic_probabilities_child[k] = symptomatic_probabilities_child_default[k]
            symptomatic_probabilities_teenager[k] = symptomatic_probabilities_teenager_default[k]
            symptomatic_probabilities_adult[k] = symptomatic_probabilities_adult_default[k]
            mean_viral_loads_infant[k] = mean_viral_loads_infant_default[k]
            mean_viral_loads_child[k] = mean_viral_loads_child_default[k]
            mean_viral_loads_adult[k] = mean_viral_loads_adult_default[k]
            # immune_memory_susceptibility_levels[k] = immune_memory_susceptibility_levels_default[k]
            mean_immunity_durations[k] = mean_immunity_durations_default[k]
        end

        # Disturbance
        for k = eachindex(isolation_probabilities_day_1)
            isolation_probabilities_day_1[k] += rand(Normal(0.0, disturbance * isolation_probabilities_day_1[k]))
            isolation_probabilities_day_2[k] += rand(Normal(0.0, disturbance * isolation_probabilities_day_2[k]))
            isolation_probabilities_day_3[k] += rand(Normal(0.0, disturbance * isolation_probabilities_day_3[k]))
        end
        recovered_duration_mean += rand(Normal(0.0, disturbance * recovered_duration_mean))
        recovered_duration_sd += rand(Normal(0.0, disturbance * recovered_duration_sd))

        for k = eachindex(mean_household_contact_durations)
            mean_household_contact_durations[k] += rand(Normal(0.0, disturbance * mean_household_contact_durations[k]))
            household_contact_duration_sds[k] += rand(Normal(0.0, disturbance * household_contact_duration_sds[k]))
        end
        for k = eachindex(other_contact_duration_scales)
            other_contact_duration_shapes[k] += rand(Normal(0.0, disturbance * other_contact_duration_shapes[k]))
            other_contact_duration_scales[k] += rand(Normal(0.0, disturbance * other_contact_duration_scales[k]))
        end

        duration_parameter += rand(Normal(0.0, disturbance * duration_parameter))
        for k = eachindex(susceptibility_parameters)
            susceptibility_parameters[k] += rand(Normal(0.0, disturbance * susceptibility_parameters[k]))
            temperature_parameters[k] += rand(Normal(0.0, -disturbance * temperature_parameters[k]))
        end

        for k = eachindex(random_infection_probabilities)
            random_infection_probabilities[k] += rand(Normal(0.0, disturbance * random_infection_probabilities[k]))
        end

        for k = eachindex(incubation_period_durations)
            incubation_period_durations[k] += rand(Normal(0.0, disturbance * incubation_period_durations[k]))
            infection_period_durations_child[k] += rand(Normal(0.0, disturbance * infection_period_durations_child[k]))
            infection_period_duration_variances_child[k] += rand(Normal(0.0, disturbance * infection_period_duration_variances_child[k]))
            infection_period_durations_adult[k] += rand(Normal(0.0, disturbance * infection_period_durations_adult[k]))
            infection_period_duration_variances_adult[k] += rand(Normal(0.0, disturbance * infection_period_duration_variances_adult[k]))
            symptomatic_probabilities_child[k] += rand(Normal(0.0, disturbance * symptomatic_probabilities_child[k]))
            symptomatic_probabilities_teenager[k] += rand(Normal(0.0, disturbance * symptomatic_probabilities_teenager[k]))
            symptomatic_probabilities_adult[k] += rand(Normal(0.0, disturbance * symptomatic_probabilities_adult[k]))
            mean_viral_loads_infant[k] += rand(Normal(0.0, disturbance * mean_viral_loads_infant[k]))
            mean_viral_loads_child[k] += rand(Normal(0.0, disturbance * mean_viral_loads_child[k]))
            mean_viral_loads_adult[k] += rand(Normal(0.0, disturbance * mean_viral_loads_adult[k]))
            # immune_memory_susceptibility_levels[k] += rand(Normal(0.0, disturbance * immune_memory_susceptibility_levels[k]))
            mean_immunity_durations[k] += rand(Normal(0.0, disturbance * mean_immunity_durations[k]))
        end

        for k = eachindex(viruses)
            viruses[k].mean_incubation_period = incubation_period_durations[k]
            viruses[k].incubation_period_variance = incubation_period_duration_variances[k]
            viruses[k].mean_infection_period_child = infection_period_durations_child[k]
            viruses[k].infection_period_variance_child = infection_period_duration_variances_child[k]
            viruses[k].mean_infection_period_adult = infection_period_durations_adult[k]
            viruses[k].infection_period_variance_adult = infection_period_duration_variances_adult[k]
            viruses[k].symptomatic_probability_child = symptomatic_probabilities_child[k]
            viruses[k].symptomatic_probability_teenager = symptomatic_probabilities_teenager[k]
            viruses[k].symptomatic_probability_adult = symptomatic_probabilities_adult[k]
            viruses[k].mean_viral_load_toddler = mean_viral_loads_infant[k]
            viruses[k].mean_viral_load_child = mean_viral_loads_child[k]
            viruses[k].mean_viral_load_adult = mean_viral_loads_adult[k]
        end

        return

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
                immune_memory_susceptibility_levels[1],
                immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3],
                immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5],
                immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7],
            )
        end

        @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, true,
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])

        save(joinpath(@__DIR__, "..", "sensitivity", "tables", "results_$(run_num + starting_bias).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt,
            "isolation_probabilities_day_1", isolation_probabilities_day_1,
            "isolation_probabilities_day_2", isolation_probabilities_day_2,
            "isolation_probabilities_day_3", isolation_probabilities_day_3,
            "recovered_duration_mean", recovered_duration_mean,
            "recovered_duration_sd", recovered_duration_sd,
            "mean_household_contact_durations", mean_household_contact_durations,
            "household_contact_duration_sds", household_contact_duration_sds,
            "other_contact_duration_shapes", other_contact_duration_shapes,
            "other_contact_duration_scales", other_contact_duration_scales,
            "duration_parameter", duration_parameter,
            "susceptibility_parameters", susceptibility_parameters,
            "temperature_parameters", temperature_parameters,
            "random_infection_probabilities", random_infection_probabilities,
            "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
            "mean_immunity_durations", mean_immunity_durations,
            "incubation_period_durations", incubation_period_durations,
            "incubation_period_duration_variances", incubation_period_duration_variances,
            "infection_period_durations_child", infection_period_durations_child,
            "infection_period_duration_variances_child", infection_period_duration_variances_child,
            "infection_period_durations_adult", infection_period_durations_adult,
            "infection_period_duration_variances_adult", infection_period_duration_variances_adult,
            "symptomatic_probabilities_child", symptomatic_probabilities_child,
            "symptomatic_probabilities_teenager", symptomatic_probabilities_teenager,
            "symptomatic_probabilities_adult", symptomatic_probabilities_adult,
            "mean_viral_loads_infant", mean_viral_loads_infant,
            "mean_viral_loads_child", mean_viral_loads_child,
            "mean_viral_loads_adult", mean_viral_loads_adult)
    end
end

function parameter_sensitivity(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    viruses::Vector{Virus},
    households::Vector{Household},
    schools::Vector{School},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temperature_parameters::Vector{Float64},
    temperature::Vector{Float64},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    random_infection_probabilities::Vector{Float64},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    num_years::Int,
    immune_memory_susceptibility_levels::Vector{Float64},
    mean_immunity_durations::Vector{Float64},
)
    multipliers = [0.8, 0.9, 1.1, 1.2]
    k = -2
    for m in multipliers
        duration_parameter_new = duration_parameter * m
        @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter_new,
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
        writedlm(
            joinpath(@__DIR__, "..", "sensitivity", "tables", "2nd", "infected_data_d_$k.csv"),
            sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
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
                immune_memory_susceptibility_levels[1],
                immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3],
                immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5],
                immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7],
            )
        end
        if k == -1
            k = 1
        else
            k += 1
        end
    end

    for i in 1:7
        k = -2
        for m in multipliers
            susceptibility_parameters_new = copy(susceptibility_parameters)
            susceptibility_parameters_new[i] *= m
            @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
                susceptibility_parameters_new, temperature_parameters, temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities,
                recovered_duration_mean, recovered_duration_sd, num_years, false,
                immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7])
            writedlm(
                joinpath(@__DIR__, "..", "sensitivity", "tables", "2nd", "infected_data_s$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
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
                    immune_memory_susceptibility_levels[1],
                    immune_memory_susceptibility_levels[2],
                    immune_memory_susceptibility_levels[3],
                    immune_memory_susceptibility_levels[4],
                    immune_memory_susceptibility_levels[5],
                    immune_memory_susceptibility_levels[6],
                    immune_memory_susceptibility_levels[7],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end

    values = -[0.25, 0.5, 0.75, 1.0]
    for i in 1:7
        k = -2
        for v in values
            temperature_parameters_new = copy(temperature_parameters)
            temperature_parameters_new[i] = v
            @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
                susceptibility_parameters, temperature_parameters_new, temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities,
                recovered_duration_mean, recovered_duration_sd, num_years, false,
                immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7])
            writedlm(
                joinpath(@__DIR__, "..", "sensitivity", "tables", "2nd", "infected_data_t$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
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
                    immune_memory_susceptibility_levels[1],
                    immune_memory_susceptibility_levels[2],
                    immune_memory_susceptibility_levels[3],
                    immune_memory_susceptibility_levels[4],
                    immune_memory_susceptibility_levels[5],
                    immune_memory_susceptibility_levels[6],
                    immune_memory_susceptibility_levels[7],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end

    prob_multipliers = [0.1, 0.5, 2.0, 10.0]
    for i in 1:4
        k = -2
        for m in prob_multipliers
            random_infection_probabilities_new = copy(random_infection_probabilities)
            random_infection_probabilities_new[i] *= m
            @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
                susceptibility_parameters, temperature_parameters, temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities_new,
                recovered_duration_mean, recovered_duration_sd, num_years, false,
                immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7])
            writedlm(
                joinpath(@__DIR__, "..", "sensitivity", "tables", "2nd", "infected_data_p$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
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
                    immune_memory_susceptibility_levels[1],
                    immune_memory_susceptibility_levels[2],
                    immune_memory_susceptibility_levels[3],
                    immune_memory_susceptibility_levels[4],
                    immune_memory_susceptibility_levels[5],
                    immune_memory_susceptibility_levels[6],
                    immune_memory_susceptibility_levels[7],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end

    for i in 1:7
        k = -2
        for m in multipliers
            mean_immunity_durations_new = copy(mean_immunity_durations)
            mean_immunity_durations_new[i] *= m
            for k = 1:length(viruses)
                viruses[k].mean_immunity_duration = mean_immunity_durations_new[k]
            end
            @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
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
            writedlm(
                joinpath(@__DIR__, "..", "sensitivity", "tables", "2nd", "infected_data_r$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
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
                    immune_memory_susceptibility_levels[1],
                    immune_memory_susceptibility_levels[2],
                    immune_memory_susceptibility_levels[3],
                    immune_memory_susceptibility_levels[4],
                    immune_memory_susceptibility_levels[5],
                    immune_memory_susceptibility_levels[6],
                    immune_memory_susceptibility_levels[7],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end

            for k = 1:length(viruses)
                viruses[k].mean_immunity_duration = mean_immunity_durations[k]
            end
        end
    end

    values = [1.0, 0.8, 0.6, 0.4]
    for i in 1:7
        k = -2
        for v in values
            immune_memory_susceptibility_levels_new = copy(immune_memory_susceptibility_levels)
            immune_memory_susceptibility_levels_new[i] = v
            @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
                susceptibility_parameters, temperature_parameters, temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities,
                recovered_duration_mean, recovered_duration_sd, num_years, false,
                immune_memory_susceptibility_levels_new[1], immune_memory_susceptibility_levels_new[2],
                immune_memory_susceptibility_levels_new[3], immune_memory_susceptibility_levels_new[4],
                immune_memory_susceptibility_levels_new[5], immune_memory_susceptibility_levels_new[6],
                immune_memory_susceptibility_levels_new[7])
            writedlm(
                joinpath(@__DIR__, "..", "sensitivity", "tables", "2nd", "infected_data_alpha$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
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
                    immune_memory_susceptibility_levels[1],
                    immune_memory_susceptibility_levels[2],
                    immune_memory_susceptibility_levels[3],
                    immune_memory_susceptibility_levels[4],
                    immune_memory_susceptibility_levels[5],
                    immune_memory_susceptibility_levels[6],
                    immune_memory_susceptibility_levels[7],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end
end

function lhs_simulations(
    num_runs::Int,
    surrogate_training::Bool,
    lhs_step::Int,
    agents::Vector{Agent},
    households::Vector{Household},
    schools::Vector{School},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    temperature::Vector{Float64},
    viruses::Vector{Virus},
    num_infected_age_groups_viruses_prev::Array{Float64, 3},
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
    num_files = 0
    if surrogate_training
        for _ in readdir(joinpath(@__DIR__, "..", "surrogate", "tables", "initial"))
            num_files +=1
        end
    else
        for _ in readdir(joinpath(@__DIR__, "..", "lhs", "tables", "step$(lhs_step)"))
            num_files +=1
        end
    end

    # num_parameters = 33
    num_parameters = 26

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

        # if immune_memory_susceptibility_levels_default[i] > 0.95
        #     immune_memory_susceptibility_levels_default[i] = 0.95
        # elseif immune_memory_susceptibility_levels_default[i] < 0.05
        #     immune_memory_susceptibility_levels_default[i] = 0.05
        # end

        if mean_immunity_durations[i] > 355.0
            mean_immunity_durations[i] = 355.0
        elseif mean_immunity_durations[i] < 35.0
            mean_immunity_durations[i] = 35.0
        end
    end

    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 500)

    # points = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "lhs", "tables", "parameters$(lhs_step).csv"), header = false)))

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
        # (immune_memory_susceptibility_levels_default[1] - 0.03, immune_memory_susceptibility_levels_default[1] + 0.03),
        # (immune_memory_susceptibility_levels_default[2] - 0.03, immune_memory_susceptibility_levels_default[2] + 0.03),
        # (immune_memory_susceptibility_levels_default[3] - 0.03, immune_memory_susceptibility_levels_default[3] + 0.03),
        # (immune_memory_susceptibility_levels_default[4] - 0.03, immune_memory_susceptibility_levels_default[4] + 0.03),
        # (immune_memory_susceptibility_levels_default[5] - 0.03, immune_memory_susceptibility_levels_default[5] + 0.03),
        # (immune_memory_susceptibility_levels_default[6] - 0.03, immune_memory_susceptibility_levels_default[6] + 0.03),
        # (immune_memory_susceptibility_levels_default[7] - 0.03, immune_memory_susceptibility_levels_default[7] + 0.03),
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
            # (0.5, 1.0), # immune_memory_susceptibility_levels
            # (0.5, 1.0), # immune_memory_susceptibility_levels
            # (0.5, 1.0), # immune_memory_susceptibility_levels
            # (0.5, 1.0), # immune_memory_susceptibility_levels
            # (0.5, 1.0), # immune_memory_susceptibility_levels
            # (0.5, 1.0), # immune_memory_susceptibility_levels
            # (0.5, 1.0), # immune_memory_susceptibility_levels
        ])

        writedlm(joinpath(@__DIR__, "..", "surrogate", "tables", "parameters.csv"), points, ',')

        # points = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "surrogate", "tables", "parameters.csv"), header = false)))
    else
        writedlm(joinpath(@__DIR__, "..", "lhs", "tables", "parameters$(lhs_step).csv"), points, ',')
    end

    nMAE_min = 1.0e12

    for i = (num_files + 1):num_runs
        println(i)

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]
        immune_memory_susceptibility_levels = immune_memory_susceptibility_levels_default
        for k = 1:length(viruses)
            viruses[k].mean_immunity_duration = points[i, 15 + k]
            viruses[k].immunity_duration_sd = points[i, 15 + k] * 0.33
        end
        random_infection_probabilities = points[i, 23:26]
        # immune_memory_susceptibility_levels =  points[i, 27:33]

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
            println("nMAE_min = ", nMAE_min)
            println("duration_parameter = ", duration_parameter)
            println("susceptibility_parameters = ", susceptibility_parameters)
            println("temperature_parameters = ", temperature_parameters)
            # println("immune_memory_susceptibility_levels = ", immune_memory_susceptibility_levels)
            println("mean_immunity_durations = ", [points[i, 16], points[i, 17], points[i, 18], points[i, 19], points[i, 20], points[i, 21], points[i, 22]])
            println("random_infection_probabilities = ", random_infection_probabilities)
        end

        if surrogate_training
            save(joinpath(@__DIR__, "..", "surrogate", "tables", "initial", "results_$(i).jld"),
                "observed_cases", observed_num_infected_age_groups_viruses,
                "duration_parameter", duration_parameter,
                "susceptibility_parameters", susceptibility_parameters,
                "temperature_parameters", temperature_parameters,
                # "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
                "mean_immunity_durations", [points[i, 16], points[i, 17], points[i, 18], points[i, 19], points[i, 20], points[i, 21], points[i, 22]],
                "random_infection_probabilities", random_infection_probabilities)
        else
            save(joinpath(@__DIR__, "..", "lhs", "tables", "step$(lhs_step)", "results_$(i).jld"),
                "observed_cases", observed_num_infected_age_groups_viruses,
                "duration_parameter", duration_parameter,
                "susceptibility_parameters", susceptibility_parameters,
                "temperature_parameters", temperature_parameters,
                # "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
                "mean_immunity_durations", [points[i, 16], points[i, 17], points[i, 18], points[i, 19], points[i, 20], points[i, 21], points[i, 22]],
                "random_infection_probabilities", random_infection_probabilities)
        end
    end
end

function mcmc_simulations(
    agents::Vector{Agent},
    households::Vector{Household},
    schools::Vector{School},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    temperature::Vector{Float64},
    viruses::Vector{Virus},
    num_infected_age_groups_viruses_prev::Array{Float64, 3},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    num_infected_age_groups_viruses::Array{Float64, 3},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    random_infection_probabilities::Vector{Float64},
    num_years::Int,
)
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
    immune_memory_susceptibility_levels = [
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

    @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses_model, activities_infections, rt, num_schools_closed, num_infected_districts = run_simulation(
        num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        mean_household_contact_durations, household_contact_duration_sds,
        other_contact_duration_shapes, other_contact_duration_scales,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, random_infection_probabilities,
        recovered_duration_mean, recovered_duration_sd, num_years, is_rt_run,
        immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
        immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
        immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
        immune_memory_susceptibility_levels[7], school_class_closure_period, 
        school_class_closure_threshold, with_global_warming)

    accept_num = 0
    local_rejected_num = 0

    duration_parameter_delta = 0.03
    susceptibility_parameter_deltas = [0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03]
    temperature_parameter_deltas = [0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03]
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

    
    # for i = 1:7
    #     for k = 1:4
    #         for l = 1:52
    #             for j = 1:num_years
    #                 observed_num_infected_age_groups_viruses[l, i, k] += observed_num_infected_age_groups_viruses[52 * (j - 1) + l, i, k]
    #             end
    #             observed_num_infected_age_groups_viruses[l, i, k] /= num_years
    #         end
    #     end
    # end

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_years)
    incidence_arr_mean = zeros(Float64, 52, 7, 4)

    for i = 1:num_years
        incidence_arr[i] = observed_num_infected_age_groups_viruses[(52 * (i - 1) + 1):(52 * (i - 1) + 52), :, :]
    end

    for i = 1:52
        for k = 1:7
            for m = 1:4
                for j = 1:num_years
                    incidence_arr_mean[i, k, m] += incidence_arr[j][i, k, m]
                end
                incidence_arr_mean[i, k, m] /= num_years
            end
        end
    end

    nMAE = sum(abs.(incidence_arr_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    nMAE_prev = nMAE

    n = 1
    N = 1000
    while n <= N
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

        for k = eachindex(viruses)
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
                immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
                immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
                immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
                immune_memory_susceptibility_levels[7]
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
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])

        # for i = 1:7
        #     for k = 1:4
        #         for l = 1:52
        #             for j = 1:num_years
        #                 observed_num_infected_age_groups_viruses[l, i, k] += observed_num_infected_age_groups_viruses[52 * (j - 1) + l, i, k]
        #             end
        #             observed_num_infected_age_groups_viruses[l, i, k] /= num_years
        #         end
        #     end
        # end

        # nMAE = sum(abs.(observed_num_infected_age_groups_viruses[1:52, :, :] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)


        incidence_arr_mean = zeros(Float64, 52, 7, 4)

        for i = 1:num_years
            incidence_arr[i] = observed_num_infected_age_groups_viruses[(52 * (i - 1) + 1):(52 * (i - 1) + 52), :, :]
        end

        for i = 1:52
            for k = 1:7
                for m = 1:4
                    for j = 1:num_years
                        incidence_arr_mean[i, k, m] += incidence_arr[j][i, k, m]
                    end
                    incidence_arr_mean[i, k, m] /= num_years
                end
            end
        end

        nMAE = sum(abs.(incidence_arr_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)


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
            println(io, nMAE)
        end

        if accept_prob == 1 || local_rejected_num >= 10
            println("nMAE = $(nMAE)")
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
        
        # println("Accept rate: ", accept_num / n)
        n += 1
    end
end

function main(
    # nMAE = 0.4981281258117053
    duration_parameter::Float64 = 0.22637404671777045,
    susceptibility_parameters::Vector{Float64} = [3.095038052808992, 3.0554159364150997, 3.621467164928697, 4.612459518531132, 3.9086201477859595, 3.9490870441188344, 4.61599824854622],
    temperature_parameters::Vector{Float64} = -[0.8846019152491571, 0.9313057237697472, 0.04837343942226003, 0.13610826071131651, 0.048281056835923, 0.07401637656561208, 0.36034078438752476],
    mean_immunity_durations::Vector{Float64} = [358.53571508348136, 326.40686999692815, 128.36635586863198, 86.9285869152992, 110.11396877548141, 166.57369789857893, 153.80184097804894],
    random_infection_probabilities::Vector{Float64} = [0.0013742087365687383, 0.0007810400878682918, 0.00039431021797935243, 9.16649170205853e-6],
    immune_memory_susceptibility_levels::Vector{Float64} = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
    surrogate_index = 0,
)
    println("Initialization...")

    # Random seed number
    run_num = 0
    is_rt_run = true
    try
        run_num = parse(Int64, ARGS[1])
    catch
        run_num = 0
    end

    # num_years = 3
    num_years = 2
    # num_years = 1

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    school_class_closure_period = 0
    # school_class_closure_period = 7
    school_class_closure_threshold = 0.3
    # [0.2  0.1  0.3  0.2_14  0.1_14]

    with_global_warming = false
    # with_global_warming = true
    # ["+4 °С" "+3 °С" "+2 °С" "+1 °С"]

    is_herd_immunity_test = false
    # is_herd_immunity_test = true
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
    # num_barabasi_albert_attachments = 4
    num_barabasi_albert_attachments = 5
    # num_barabasi_albert_attachments = 6

    viruses = Virus[
        # FluA
        Virus(1.4, 0.67, 1, 7,  4.8, 2.04, 1, 28,  8.0, 3.4, 1, 28,  3.45, 2.63, 1.73,  0.38, 0.47, 0.57,  mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        # FluB
        Virus(0.6, 0.19, 1, 7,  3.7, 3.0, 1, 28,  6.1, 4.8, 1, 28,  3.53, 2.63, 1.8,  0.38, 0.47, 0.57,  mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
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
    district_households = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_households.csv"))))
    # Число людей в каждой группе по районам
    district_people = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_people.csv"))))
    # Число людей в домохозяйствах по районам
    district_people_households = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_people_households.csv"))))
    # Распределение вирусов в течение года
    etiology = get_etiology()
    # Температура воздуха, начиная с 1 января
    temperature = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "temperature.csv"))))[1, :]

    agents = Array{Agent, 1}(undef, num_agents)

    # With seed
    thread_rng = [MersenneTwister(i + run_num * num_threads) for i = 1:num_threads]

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

    infected_data_0_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu0-2.csv"), ';', Int, '\n')
    infected_data_3_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu3-6.csv"), ';', Int, '\n')
    infected_data_7_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu7-14.csv"), ';', Int, '\n')
    infected_data_15_all = readdlm(joinpath(@__DIR__, "..", "input", "tables", "flu15+.csv"), ';', Int, '\n')

    infected_data_0 = infected_data_0_all[
        2:53, flu_starting_index:((flu_starting_index - flu_starting_index_immmunity_bias) + num_years)]
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

    infected_data_3 = infected_data_3_all[
        2:53, flu_starting_index:((flu_starting_index - flu_starting_index_immmunity_bias) + num_years)]
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

    infected_data_7 = infected_data_7_all[
        2:53, flu_starting_index:((flu_starting_index - flu_starting_index_immmunity_bias) + num_years)]
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

    infected_data_15 = infected_data_15_all[
        2:53, flu_starting_index:((flu_starting_index - flu_starting_index_immmunity_bias) + num_years)]
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

    infected_data_0_prev = infected_data_0_all[2:53, 1:flu_starting_index_immmunity_bias]
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

    infected_data_3_prev = infected_data_3_all[2:53, 1:flu_starting_index_immmunity_bias]
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

    infected_data_7_prev = infected_data_7_all[2:53, 1:flu_starting_index_immmunity_bias]
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

    infected_data_15_prev = infected_data_15_all[2:53, 1:flu_starting_index_immmunity_bias]
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

    for virus_id in eachindex(viruses)
        num_infected_age_groups_viruses_prev[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_infected_age_groups_viruses_prev[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_infected_age_groups_viruses_prev[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_infected_age_groups_viruses_prev[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id],
            agents, households, viruses, num_infected_age_groups_viruses_prev, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households,
            immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
            immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
            immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
            immune_memory_susceptibility_levels[7])
    end

    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, num_barabasi_albert_attachments)

    # get_stats(agents, schools, workplaces)
    # return

    println("Simulation...")

    # --------------------------
    # simulate_contacts(
    #     num_threads,
    #     thread_rng,
    #     agents,
    #     kindergartens,
    #     schools,
    #     colleges,
    #     mean_household_contact_durations,
    #     household_contact_duration_sds,
    #     other_contact_duration_shapes,
    #     other_contact_duration_scales,
    # )
    # return
    # --------------------------

    # --------------------------
    # global_sensitivity(
    #     300,
    #     0.05,
    #     num_threads,
    #     thread_rng,
    #     agents,
    #     viruses,
    #     households,
    #     schools,
    #     duration_parameter,
    #     susceptibility_parameters,
    #     temperature_parameters,
    #     temperature,
    #     mean_household_contact_durations,
    #     household_contact_duration_sds,
    #     other_contact_duration_shapes,
    #     other_contact_duration_scales,
    #     isolation_probabilities_day_1,
    #     isolation_probabilities_day_2,
    #     isolation_probabilities_day_3,
    #     random_infection_probabilities,
    #     recovered_duration_mean,
    #     recovered_duration_sd,
    #     num_years,
    #     immune_memory_susceptibility_levels,
    #     mean_immunity_durations,
    #     [1.4, 1.0, 1.9, 4.4, 5.6, 2.6, 3.2],
    #     [0.09, 0.0484, 0.175, 0.937, 1.51, 0.327, 0.496],
    #     [4.8, 3.7, 10.1, 7.4, 8.0, 7.0, 6.5],
    #     [1.12, 0.66, 4.93, 2.66, 3.1, 2.37, 2.15],
    #     [8.8, 7.8, 11.4, 9.3, 9.0, 8.0, 7.5],
    #     [3.748, 2.94, 6.25, 4.0, 3.92, 3.1, 2.9],
    #     [0.38, 0.38, 0.19, 0.24, 0.15, 0.16, 0.21],
    #     [0.47, 0.47, 0.24, 0.3, 0.19, 0.2, 0.26],
    #     [0.57, 0.57, 0.29, 0.36, 0.23, 0.24, 0.32],
    #     [4.6, 4.7, 3.5, 6.0, 4.1, 4.8, 4.9],
    #     [3.5, 3.5, 2.6, 4.5, 3.1, 3.6, 3.7],
    #     [2.3, 2.4, 1.8, 3.0, 2.1, 2.4, 2.5],
    # )
    # return
    # --------------------------

    # --------------------------
    # parameter_sensitivity(
    #     num_threads,
    #     thread_rng,
    #     agents,
    #     viruses,
    #     households,
    #     schools,
    #     duration_parameter,
    #     susceptibility_parameters,
    #     temperature_parameters,
    #     temperature,
    #     mean_household_contact_durations,
    #     household_contact_duration_sds,
    #     other_contact_duration_shapes,
    #     other_contact_duration_scales,
    #     isolation_probabilities_day_1,
    #     isolation_probabilities_day_2,
    #     isolation_probabilities_day_3,
    #     random_infection_probabilities,
    #     recovered_duration_mean,
    #     recovered_duration_sd,
    #     num_years,
    #     immune_memory_susceptibility_levels,
    #     mean_immunity_durations,
    # )
    # return
    # --------------------------

    # lhs_simulations(
    #     100,
    #     false,
    #     1,
    #     agents,
    #     households,
    #     schools,
    #     num_threads,
    #     thread_rng,
    #     start_agent_ids,
    #     end_agent_ids,
    #     temperature,
    #     viruses,
    #     num_infected_age_groups_viruses_prev,
    #     mean_household_contact_durations,
    #     household_contact_duration_sds,
    #     other_contact_duration_shapes,
    #     other_contact_duration_scales,
    #     isolation_probabilities_day_1,
    #     isolation_probabilities_day_2,
    #     isolation_probabilities_day_3,
    #     duration_parameter,
    #     susceptibility_parameters,
    #     temperature_parameters,
    #     num_infected_age_groups_viruses,
    #     recovered_duration_mean,
    #     recovered_duration_sd,
    #     random_infection_probabilities,
    #     mean_immunity_durations,
    #     num_years,
    #     immune_memory_susceptibility_levels,
    # )
    # return
    # --------------------------

    # --------------------------
    mcmc_simulations(
        agents,
        households,
        schools,
        num_threads,
        thread_rng,
        start_agent_ids,
        end_agent_ids,
        temperature,
        viruses,
        num_infected_age_groups_viruses_prev::Array{Float64, 3},
        mean_household_contact_durations,
        household_contact_duration_sds,
        other_contact_duration_shapes,
        other_contact_duration_scales,
        isolation_probabilities_day_1,
        isolation_probabilities_day_2,
        isolation_probabilities_day_3,
        num_infected_age_groups_viruses::Array{Float64, 3},
        recovered_duration_mean,
        recovered_duration_sd,
        random_infection_probabilities,
        num_years
    )
    return
    # --------------------------
    
    @time observed_num_infected_age_groups_viruses, num_infected_age_groups_viruses_model, activities_infections, rt, num_schools_closed, num_infected_districts = run_simulation(
        num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        mean_household_contact_durations, household_contact_duration_sds,
        other_contact_duration_shapes, other_contact_duration_scales,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, random_infection_probabilities,
        recovered_duration_mean, recovered_duration_sd, num_years, is_rt_run,
        immune_memory_susceptibility_levels[1], immune_memory_susceptibility_levels[2],
        immune_memory_susceptibility_levels[3], immune_memory_susceptibility_levels[4],
        immune_memory_susceptibility_levels[5], immune_memory_susceptibility_levels[6],
        immune_memory_susceptibility_levels[7], school_class_closure_period, 
        school_class_closure_threshold, with_global_warming)

    if with_global_warming
        save(joinpath(@__DIR__, "..", "output", "tables", "results_warming_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "num_infected_districts", num_infected_districts,
            "rt", rt)
    elseif is_herd_immunity_test
        save(joinpath(@__DIR__, "..", "output", "tables", "results_herd_immunity_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "num_infected_districts", num_infected_districts,
            "rt", rt)
    elseif school_class_closure_period == 0
        save(joinpath(@__DIR__, "..", "output", "tables", "results_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "num_infected_districts", num_infected_districts,
            "rt", rt)
    elseif school_class_closure_threshold > 0.99
        save(joinpath(@__DIR__, "..", "output", "tables", "results_class_quarantine_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "num_infected_districts", num_infected_districts,
            "rt", rt,
            "num_schools_closed", num_schools_closed)
    else
        save(joinpath(@__DIR__, "..", "output", "tables", "results_quarantine_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "all_cases", num_infected_age_groups_viruses_model,
            "activities_cases", activities_infections,
            "num_infected_districts", num_infected_districts,
            "rt", rt,
            "num_schools_closed", num_schools_closed)
    end

    nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    println(nMAE)

    if surrogate_index > 0
        save(joinpath(@__DIR__, "..", "surrogate", "tables", "procedure", "results_$(surrogate_index).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "duration_parameter", duration_parameter,
            "susceptibility_parameters", susceptibility_parameters,
            "temperature_parameters", temperature_parameters,
            "mean_immunity_durations", mean_immunity_durations,
            "random_infection_probabilities", random_infection_probabilities)
    end

end

main()
