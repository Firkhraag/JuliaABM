function get_contact_duration_normal(mean::Float64, sd::Float64, rng::MersenneTwister)
    return rand(rng, truncated(Normal(mean, sd), 0.0, 24.0))
end

function get_contact_duration_gamma(shape::Float64, scale::Float64, rng::MersenneTwister)
    return rand(rng, Gamma(shape, scale))
end

function make_contact(
    viruses::Vector{Virus},
    infected_agent::Agent,
    susceptible_agent::Agent,
    contact_duration::Float64,
    current_step::Int,
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temperature_parameters::Vector{Float64},
    current_temp::Float64,
    rng::MersenneTwister,
)
    # Влияние продолжительности контакта на вероятность инфицирования
    duration_influence = 1 - exp(-duration_parameter * contact_duration)
            
    # Влияние температуры воздуха на вероятность инфицирования
    temperature_influence = temperature_parameters[infected_agent.virus_id] * current_temp + 1.0

    # Влияние восприимчивости агента на вероятность инфицирования
    susceptibility_influence = 2 / (1 + exp(susceptibility_parameters[infected_agent.virus_id] * susceptible_agent.ig_level))

    immunity_influence = 1.0
    if infected_agent.virus_id == 1
        immunity_influence = susceptible_agent.FluA_immunity_susceptibility_level
    elseif infected_agent.virus_id == 2
        immunity_influence = susceptible_agent.FluB_immunity_susceptibility_level
    elseif infected_agent.virus_id == 3
        immunity_influence = susceptible_agent.RV_immunity_susceptibility_level
    elseif infected_agent.virus_id == 4
        immunity_influence = susceptible_agent.RSV_immunity_susceptibility_level
    elseif infected_agent.virus_id == 5
        immunity_influence = susceptible_agent.AdV_immunity_susceptibility_level
    elseif infected_agent.virus_id == 6
        immunity_influence = susceptible_agent.PIV_immunity_susceptibility_level
    else
        immunity_influence = susceptible_agent.CoV_immunity_susceptibility_level
    end

    # Влияние силы инфекции на вероятность инфицирования
    infectivity_influence = 0.0
    if infected_agent.age < 3
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_toddler,
            infected_agent.is_asymptomatic)
    elseif infected_agent.age < 16
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_child,
            infected_agent.is_asymptomatic)
    else
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_adult,
            infected_agent.is_asymptomatic)
    end

    # Вероятность инфицирования
    infection_probability = infectivity_influence * susceptibility_influence *
        temperature_influence * duration_influence * immunity_influence

    if rand(rng, Float64) < infection_probability
        susceptible_agent.virus_id = infected_agent.virus_id
        susceptible_agent.is_newly_infected = true
        infected_agent.num_infected_agents += 1
    end
end

function infect_randomly(
    agent::Agent,
    current_step::Int,
    rng::MersenneTwister,
)
    rand_num = rand(rng, 1:7)
    if (rand_num == 1 && rand(rng, Float64) < agent.FluA_immunity_susceptibility_level) ||
        (rand_num == 2 && rand(rng, Float64) < agent.FluB_immunity_susceptibility_level) ||
        (rand_num == 3 && rand(rng, Float64) < agent.RV_immunity_susceptibility_level) ||
        (rand_num == 4 && rand(rng, Float64) < agent.RSV_immunity_susceptibility_level) ||
        (rand_num == 5 && rand(rng, Float64) < agent.AdV_immunity_susceptibility_level) ||
        (rand_num == 6 && rand(rng, Float64) < agent.PIV_immunity_susceptibility_level) ||
        (rand_num == 7 && rand(rng, Float64) < agent.CoV_immunity_susceptibility_level)

        agent.virus_id = rand_num
        agent.is_newly_infected = true
    end
end

function simulate_contacts(
    thread_id::Int,
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    households::Vector{Household},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temperature_parameters::Vector{Float64},
    random_infection_probabilities::Vector{Float64},
    viruses::Vector{Virus},
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_college_holiday::Bool,
    is_work_holiday::Bool,
    current_step::Int,
    current_temp::Float64,
    activities_infections_threads::Array{Int, 3},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        # Агент инфицирован
        if agent.virus_id != 0 && !agent.is_newly_infected
            # Контакты в домохозяйстве
            for agent2_id in agent.household_conn_ids
                agent2 = agents[agent2_id]
                # Проверка восприимчивости агента к вирусу
                if agent2.virus_id == 0 && agent2.days_immune == 0
                    dur = 0.0
                    if (agent.is_isolated || agent.quarantine_period > 0 || agent.on_parent_leave || agent.activity_type == 0 ||
                        (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_college_holiday) ||
                        (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                        (agent2.is_isolated || agent2.quarantine_period > 0 || agent2.on_parent_leave || agent2.activity_type == 0 ||
                        (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_college_holiday) ||
                        (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday))

                        dur = get_contact_duration_normal(mean_household_contact_durations[5], household_contact_duration_sds[5], rng)
                    elseif ((agent.activity_type == 4 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 4 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_work_holiday

                        dur = get_contact_duration_normal(mean_household_contact_durations[4], household_contact_duration_sds[4], rng)
                    elseif ((agent.activity_type == 2 && !(agent.is_isolated || agent.on_parent_leave || agent.quarantine_period > 0)) ||
                        (agent2.activity_type == 2 && !(agent2.is_isolated || agent2.on_parent_leave || agent2.quarantine_period > 0))) && !is_school_holiday

                        dur = get_contact_duration_normal(mean_household_contact_durations[2], household_contact_duration_sds[2], rng)
                    elseif ((agent.activity_type == 1 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 1 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_kindergarten_holiday
                        
                        dur = get_contact_duration_normal(mean_household_contact_durations[1], household_contact_duration_sds[1], rng)
                    else
                        dur = get_contact_duration_normal(mean_household_contact_durations[3], household_contact_duration_sds[3], rng)
                    end

                    if dur > 0.01
                        make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
                            susceptibility_parameters, temperature_parameters, current_temp, rng)
                        if agent2.is_newly_infected
                            activities_infections_threads[current_step, 5, thread_id] += 1
                        end
                    end
                end
            end
            # Контакты в остальных коллективах
            if !agent.is_isolated && !agent.on_parent_leave && agent.attendance &&
                ((agent.activity_type == 1 && !is_kindergarten_holiday) ||
                (agent.activity_type == 2 && !is_school_holiday) ||
                (agent.activity_type == 3 && !is_college_holiday) ||
                (agent.activity_type == 4 && !is_work_holiday)) && agent.quarantine_period == 0
                
                for agent2_id in agent.activity_conn_ids
                    agent2 = agents[agent2_id]
                    if agent2.virus_id == 0 && agent2.days_immune == 0 && agent2.attendance &&
                        !agent2.is_isolated && !agent2.on_parent_leave
                        dur = 0.0
                        if agent.activity_type == 1
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[1], other_contact_duration_scales[1], rng)
                        elseif agent.activity_type == 2
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[2], other_contact_duration_scales[2], rng)
                        elseif agent.activity_type == 3
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[3], other_contact_duration_scales[3], rng)
                        else
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[4], other_contact_duration_scales[4], rng)
                        end

                        if dur > 0.01
                            make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
                                susceptibility_parameters, temperature_parameters, current_temp, rng)
                            if agent2.is_newly_infected
                                activities_infections_threads[current_step, agent.activity_type, thread_id] += 1
                            end
                        end
                    end
                end

                # Контакты между университетскими группами
                if agent.activity_type == 3
                    for agent2_id in agent.activity_cross_conn_ids
                        agent2 = agents[agent2_id]
                        if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                            agent2.attendance && !agent2.is_isolated &&
                            !agent2.on_parent_leave && !agent2.is_teacher &&
                            rand(rng, Float64) < 0.25
                                
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[5], other_contact_duration_scales[5], rng)
                            if dur > 0.01
                                make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temperature_parameters, current_temp, rng)
    
                                if agent2.is_newly_infected
                                    activities_infections_threads[current_step, 3, thread_id] += 1
                                end
                            end
                        end
                    end
                end
            end
        # Агент восприимчив
        elseif agent.virus_id == 0 && agent.days_immune == 0
            # Случайное инфицирование
            if agent.age < 3
                if rand(rng, Float64) < random_infection_probabilities[1]
                    infect_randomly(agent, current_step, rng)
                end
            elseif agent.age < 7
                if rand(rng, Float64) < random_infection_probabilities[2]
                    infect_randomly(agent, current_step, rng)
                end
            elseif agent.age < 15
                if rand(rng, Float64) < random_infection_probabilities[3]
                    infect_randomly(agent, current_step, rng)
                end
            else
                if rand(rng, Float64) < random_infection_probabilities[4]
                    infect_randomly(agent, current_step, rng)
                end
            end
        end
    end
end

function update_agent_states(
    thread_id::Int,
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    households::Vector{Household},
    viruses::Vector{Virus},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    current_step::Int,
    observed_daily_new_cases_age_groups_viruses_threads::Array{Int, 4},
    daily_new_cases_age_groups_viruses_threads::Array{Int, 4},
    rt_threads::Matrix{Float64},
    rt_count_threads::Matrix{Float64},
    num_infected_districts_threads::Array{Int, 3},
    FluA_immune_memory_susceptibility_level::Float64 = 1.0,
    FluB_immune_memory_susceptibility_level::Float64 = 1.0,
    RV_immune_memory_susceptibility_level::Float64 = 1.0,
    RSV_immune_memory_susceptibility_level::Float64 = 1.0,
    AdV_immune_memory_susceptibility_level::Float64 = 1.0,
    PIV_immune_memory_susceptibility_level::Float64 = 1.0,
    CoV_immune_memory_susceptibility_level::Float64 = 1.0,
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]

        if agent.quarantine_period > 0
            agent.quarantine_period -= 1
        end

        if agent.days_immune != 0
            if agent.days_immune == agent.days_immune_end
                # Переход из резистентного состояния в восприимчивое
                agent.days_immune = 0
            else
                agent.days_immune += 1
            end
        end

        # Продолжительности типоспецифического иммунитета
        if agent.FluA_days_immune != 0
            if agent.FluA_days_immune == agent.FluA_immunity_end
                agent.FluA_days_immune = 0
                agent.FluA_immunity_susceptibility_level = FluA_immune_memory_susceptibility_level
            else
                agent.FluA_days_immune += 1
                agent.FluA_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.FluA_days_immune, agent.FluA_immunity_end, FluA_immune_memory_susceptibility_level)
            end
        end
        if agent.FluB_days_immune != 0
            if agent.FluB_days_immune == agent.FluB_immunity_end
                agent.FluB_days_immune = 0
                agent.FluB_immunity_susceptibility_level = FluB_immune_memory_susceptibility_level
            else
                agent.FluB_days_immune += 1
                agent.FluB_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.FluB_days_immune, agent.FluB_immunity_end, FluB_immune_memory_susceptibility_level)
            end
        end
        if agent.RV_days_immune != 0
            if agent.RV_days_immune == agent.RV_immunity_end
                agent.RV_days_immune = 0
                agent.RV_immunity_susceptibility_level = RV_immune_memory_susceptibility_level
            else
                agent.RV_days_immune += 1
                agent.RV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.RV_days_immune, agent.RV_immunity_end, RV_immune_memory_susceptibility_level)
            end
        end
        if agent.RSV_days_immune != 0
            if agent.RSV_days_immune == agent.RSV_immunity_end
                agent.RSV_days_immune = 0
                agent.RSV_immunity_susceptibility_level = RSV_immune_memory_susceptibility_level
            else
                agent.RSV_days_immune += 1
                agent.RSV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.RSV_days_immune, agent.RSV_immunity_end, RSV_immune_memory_susceptibility_level)
            end
        end
        if agent.AdV_days_immune != 0
            if agent.AdV_days_immune == agent.AdV_immunity_end
                agent.AdV_days_immune = 0
                agent.AdV_immunity_susceptibility_level = AdV_immune_memory_susceptibility_level
            else
                agent.AdV_days_immune += 1
                agent.AdV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.AdV_days_immune, agent.AdV_immunity_end, AdV_immune_memory_susceptibility_level)
            end
        end
        if agent.PIV_days_immune != 0
            if agent.PIV_days_immune == agent.PIV_immunity_end
                agent.PIV_days_immune = 0
                agent.PIV_immunity_susceptibility_level = PIV_immune_memory_susceptibility_level
            else
                agent.PIV_days_immune += 1
                agent.PIV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.PIV_days_immune, agent.PIV_immunity_end, PIV_immune_memory_susceptibility_level)
            end
        end
        if agent.CoV_days_immune != 0
            if agent.CoV_days_immune == agent.CoV_immunity_end
                agent.CoV_days_immune = 0
                agent.CoV_immunity_susceptibility_level = CoV_immune_memory_susceptibility_level
            else
                agent.CoV_days_immune += 1
                agent.CoV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.CoV_days_immune, agent.CoV_immunity_end, CoV_immune_memory_susceptibility_level)
            end
        end

        if agent.virus_id != 0 && !agent.is_newly_infected
            if agent.days_infected == agent.infection_period
                infection_time = current_step - agent.infection_period - agent.incubation_period - 1
                if infection_time > 0
                    rt_threads[infection_time, thread_id] += agent.num_infected_agents
                    rt_count_threads[infection_time, thread_id] += 1
                end
                agent.num_infected_agents = 0

                if agent.virus_id == 1
                    agent.FluA_days_immune = 1
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                elseif agent.virus_id == 2
                    agent.FluB_days_immune = 1
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                elseif agent.virus_id == 3
                    agent.RV_days_immune = 1
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                elseif agent.virus_id == 4
                    agent.RSV_days_immune = 1
                    agent.RSV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                elseif agent.virus_id == 5
                    agent.AdV_days_immune = 1
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                elseif agent.virus_id == 6
                    agent.PIV_days_immune = 1
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                else
                    agent.CoV_days_immune = 1
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                end
                agent.days_immune = 1
                agent.days_immune_end = trunc(Int, rand(rng, truncated(Normal(recovered_duration_mean, recovered_duration_sd), 1.0, 12.0)))
                agent.virus_id = 0
                agent.is_isolated = false

                if agent.needs_supporter_care
                    is_support_still_needed = false
                    for dependant_id in agents[agent.supporter_id].dependant_ids
                        dependant = agents[dependant_id]
                        if dependant.needs_supporter_care &&
                            dependant.virus_id != 0 &&
                            !dependant.is_asymptomatic &&
                            dependant.days_infected > 0 &&
                            (dependant.activity_type == 0 || dependant.is_isolated)

                            is_support_still_needed = true
                        end
                    end
                    if !is_support_still_needed
                        agents[agent.supporter_id].on_parent_leave = false
                    end
                end
            else
                agent.days_infected += 1

                if !agent.is_asymptomatic && !agent.is_isolated
                    if agent.days_infected == 1
                        rand_num = rand(rng, Float64)
                        if agent.age < 3
                            if rand_num < isolation_probabilities_day_1[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < isolation_probabilities_day_1[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < isolation_probabilities_day_1[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < isolation_probabilities_day_1[4]
                                agent.is_isolated = true
                            end
                        end
                    elseif agent.days_infected == 2
                        rand_num = rand(rng, Float64)
                        if agent.age < 3
                            if rand_num < isolation_probabilities_day_2[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < isolation_probabilities_day_2[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < isolation_probabilities_day_2[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < isolation_probabilities_day_2[4]
                                agent.is_isolated = true
                            end
                        end
                    elseif agent.days_infected == 3
                        rand_num = rand(rng, Float64)
                        if agent.age < 3
                            if rand_num < isolation_probabilities_day_3[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < isolation_probabilities_day_3[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < isolation_probabilities_day_3[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < isolation_probabilities_day_3[4]
                                agent.is_isolated = true
                            end
                        end
                    end
                    if agent.is_isolated
                        if agent.age < 3
                            observed_daily_new_cases_age_groups_viruses_threads[current_step, 1, agent.virus_id, thread_id] += 1
                        elseif agent.age < 7
                            observed_daily_new_cases_age_groups_viruses_threads[current_step, 2, agent.virus_id, thread_id] += 1
                        elseif agent.age < 15
                            observed_daily_new_cases_age_groups_viruses_threads[current_step, 3, agent.virus_id, thread_id] += 1
                        else
                            observed_daily_new_cases_age_groups_viruses_threads[current_step, 4, agent.virus_id, thread_id] += 1
                        end
                        num_infected_districts_threads[households[agent.household_id].district_id, current_step, thread_id] += 1
                    end
                end

                if agent.supporter_id != 0 &&
                    agent.needs_supporter_care &&
                    !agent.is_asymptomatic &&
                    agent.days_infected > 0 &&
                    (agent.is_isolated || agent.activity_type == 0)

                    agents[agent.supporter_id].on_parent_leave = true
                end
            end
        elseif agent.is_newly_infected
            if agent.age < 3
                daily_new_cases_age_groups_viruses_threads[current_step, 1, agent.virus_id, thread_id] += 1
            elseif agent.age < 7
                daily_new_cases_age_groups_viruses_threads[current_step, 2, agent.virus_id, thread_id] += 1
            elseif agent.age < 15
                daily_new_cases_age_groups_viruses_threads[current_step, 3, agent.virus_id, thread_id] += 1
            else
                daily_new_cases_age_groups_viruses_threads[current_step, 4, agent.virus_id, thread_id] += 1
            end

            # Инкубационный период
            incubation_period = get_period_from_erlang(
                viruses[agent.virus_id].mean_incubation_period,
                viruses[agent.virus_id].incubation_period_variance,
                viruses[agent.virus_id].min_incubation_period,
                viruses[agent.virus_id].max_incubation_period,
                rng)
            # Период болезни
            if agent.age < 16
                agent.infection_period = get_period_from_erlang(
                    viruses[agent.virus_id].mean_infection_period_child,
                    viruses[agent.virus_id].infection_period_variance_child,
                    viruses[agent.virus_id].min_infection_period_child,
                    viruses[agent.virus_id].max_infection_period_child,
                    rng)
            else
                agent.infection_period = get_period_from_erlang(
                    viruses[agent.virus_id].mean_infection_period_adult,
                    viruses[agent.virus_id].infection_period_variance_adult,
                    viruses[agent.virus_id].min_infection_period_adult,
                    viruses[agent.virus_id].max_infection_period_adult,
                    rng)
            end

            agent.days_infected = 1 - agent.incubation_period

            rand_num = rand(rng, Float64)
            if agent.age < 10
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_child
            elseif agent.age < 18
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_teenager
            else
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_adult
            end
            
            agent.is_newly_infected = false
        end

        agent.attendance = true
        if agent.activity_type == 3 && !agent.is_teacher && rand(rng, Float64) < skip_college_probability
            agent.attendance = false
        end
    end
end

function run_simulation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    viruses::Vector{Virus},
    households::Vector{Household},
    schools::Vector{School},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temperature_parameters::Vector{Float64},
    temperature_base::Vector{Float64},
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
    is_rt_run::Bool,
    FluA_immune_memory_susceptibility_level::Float64 = 1.0,
    FluB_immune_memory_susceptibility_level::Float64 = 1.0,
    RV_immune_memory_susceptibility_level::Float64 = 1.0,
    RSV_immune_memory_susceptibility_level::Float64 = 1.0,
    AdV_immune_memory_susceptibility_level::Float64 = 1.0,
    PIV_immune_memory_susceptibility_level::Float64 = 1.0,
    CoV_immune_memory_susceptibility_level::Float64 = 1.0,
    school_class_closure_period::Int = 0,
    school_class_closure_threshold::Float64 = 0.0,
    with_global_warming = false,
)::Tuple{Array{Float64, 3}, Array{Float64, 3}, Array{Float64, 2}, Vector{Float64}, Vector{Int}, Array{Float64, 2}}
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    temperature = copy(temperature_base)
    if with_global_warming
        for i = 1:length(temperature)
            temperature[i] += rand(Normal(1.0, 0.25))
            # temperature[i] += rand(Normal(2.0, 0.5))
            # temperature[i] += rand(Normal(3.0, 0.75))
            # temperature[i] += rand(Normal(4.0, 1.0))
        end
    end
    temperature_record = copy(temperature)
    # # Минимальная температура воздуха
    min_temp = -7.2
    # # Max - Min температура
    max_min_temp = 26.6

    num_viruses = 7

    year_day = 213

    max_step = num_years * 365
    if is_rt_run
        max_step += 21
    end
    num_weeks = 52 * num_years

    observed_num_infected_age_groups_viruses = zeros(Int, max_step, 7, 4)
    observed_daily_new_cases_age_groups_viruses_threads = zeros(Int, max_step, 4, 7, num_threads)
    num_infected_age_groups_viruses = zeros(Int, max_step, 7, 4)
    daily_new_cases_age_groups_viruses_threads = zeros(Int, max_step, 4, 7, num_threads)
    activities_infections_threads = zeros(Int, max_step, 5, num_threads)
    rt_threads = zeros(Float64, max_step, num_threads)
    rt_count_threads = zeros(Float64, max_step, num_threads)

    num_schools_closed_threads = zeros(Float64, max_step, num_threads)

    num_infected_districts_threads = zeros(Int, 107, max_step, num_threads)

    for current_step = 1:max_step
        # Выходные, праздники
        is_holiday = false
        if week_day == 7
            is_holiday = true
        elseif month == 1 && (day == 1 || day == 2 || day == 3 || day == 7)
            is_holiday = true
        elseif month == 5 && (day == 1 || day == 9)
            is_holiday = true
        elseif month == 2 && day == 23
            is_holiday = true
        elseif month == 3 && day == 8
            is_holiday = true
        elseif month == 6 && day == 12
            is_holiday = true
        end

        is_work_holiday = is_holiday
        if week_day == 6
            is_work_holiday = true
        end

        is_kindergarten_holiday = is_work_holiday
        if month == 7 || month == 8
            is_kindergarten_holiday = true
        end

        # Каникулы
        # Летние - 01.06.yyyy - 31.08.yyyy
        # Осенние - 05.11.yyyy - 11.11.yyyy
        # Зимние - 28.12.yyyy - 09.01.yyyy
        # Весенние - 22.03.yyyy - 31.03.yyyy
        is_school_holiday = is_holiday
        if month == 6 || month == 7 || month == 8
            is_school_holiday = true
        elseif month == 11 && day >= 5 && day <= 11
            is_school_holiday = true
        elseif month == 12 && day >= 28 && day <= 31
            is_school_holiday = true
        elseif month == 1 && day >= 1 && day <= 9
            is_school_holiday = true
        elseif month == 3 && day >= 22 && day <= 31
            is_school_holiday = true
        end

        is_college_holiday = is_holiday
        if month == 7 || month == 8
            is_college_holiday = true
        elseif month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_college_holiday = true
        elseif month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_college_holiday = true
        elseif month == 2 && (day >= 1 && day <= 10)
            is_college_holiday = true
        elseif month == 12 && (day >= 22 && day <= 31)
            is_college_holiday = true
        end

        @threads for thread_id in 1:num_threads
            simulate_contacts(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                households,
                mean_household_contact_durations,
                household_contact_duration_sds,
                other_contact_duration_shapes,
                other_contact_duration_scales,
                duration_parameter,
                susceptibility_parameters,
                temperature_parameters,
                random_infection_probabilities,
                viruses,
                is_kindergarten_holiday,
                is_school_holiday,
                is_college_holiday,
                is_work_holiday,
                current_step,
                (temperature[year_day] - min_temp) / max_min_temp,
                activities_infections_threads)
        end

        # Если сценарий карантина
        if school_class_closure_period > 0
            @threads for thread_id in 1:num_threads
                for school_id in start_school_ids[thread_id]:end_school_ids[thread_id]
                    school = schools[school_id]
                    # Если школа не на карантине
                    if school.quarantine_period == 0
                        school_num_isolated = 0
                        school_num_people = 0
                        # num_closed_classrooms = 0
                        for groups_id in 1:length(school.groups)
                            # Параллели классов
                            groups = school.groups[groups_id]
                            # Если параллель не на карантине
                            if school.quarantine_period_groups[groups_id] == 0
                                groups_num_isolated = 0
                                groups_num_people = 0
                                for group in groups
                                    num_isolated = 0
                                    for agent_id in group
                                        agent = agents[agent_id]
                                        if !agent.is_teacher
                                            if agent.quarantine_period > 1
                                                # Класс на карантине
                                                # num_closed_classrooms += 1
                                                school_num_isolated += length(group) - 1
                                                school_num_people += length(group) - 1
                                                groups_num_people += length(group) - 1
                                                break
                                            end
                                            if agent.is_isolated
                                                num_isolated += 1
                                                school_num_isolated += 1
                                                groups_num_isolated += 1
                                            end
                                            school_num_people += 1
                                            groups_num_people += 1
                                        end
                                    end
                                    if length(group) > 1 && num_isolated / (length(group) - 1) > school_class_closure_threshold
                                        for agent_id in group
                                            agent = agents[agent_id]
                                            agent.quarantine_period = school_class_closure_period + 1
                                            if !agent.is_isolated
                                                school_num_isolated += 1
                                                groups_num_isolated += 1
                                            end
                                        end
                                    end
                                end

                                if groups_num_isolated / groups_num_people > school_class_closure_threshold
                                    for group in groups
                                        for agent_id in group
                                            agent = agents[agent_id]
                                            agent.quarantine_period = school_class_closure_period + 1
                                        end
                                    end
                                    school.quarantine_period_groups[groups_id] = school_class_closure_period
                                end
                            else
                                # Учитываем учеников на карантине
                                school.quarantine_period_groups[groups_id] -= 1
                                if school.quarantine_period_groups[groups_id] > 0
                                    for group in groups
                                        school_num_isolated += length(group) - 1
                                        school_num_people += length(group) - 1
                                    end
                                end
                            end
                        end
                        # println(school_num_isolated / school_num_people)

                        # if num_closed_classrooms >= school_closure_threshold_classes
                        #     for groups in school.groups
                        #         for group in groups
                        #             for agent_id in group
                        #                 agent = agents[agent_id]
                        #                 agent.quarantine_period = school_class_closure_period + 1
                        #             end
                        #         end
                        #     end
                        #     school.quarantine_period = school_class_closure_period
                        #     num_schools_closed_threads[current_step] += 1
                        # end
                        
                        if school_num_isolated / school_num_people > school_class_closure_threshold
                            for groups in school.groups
                                for group in groups
                                    for agent_id in group
                                        agent = agents[agent_id]
                                        agent.quarantine_period = school_class_closure_period + 1
                                    end
                                end
                            end
                            school.quarantine_period = school_class_closure_period
                            num_schools_closed_threads[current_step, thread_id] += 1
                        end
                    else
                        school.quarantine_period -= 1
                        for groups_id in 1:length(school.groups)
                            # Параллели классов
                            groups = school.groups[groups_id]
                            # Если параллель на карантине
                            if school.quarantine_period_groups[groups_id] > 0
                                school.quarantine_period_groups[groups_id] -= 1
                            end
                        end
                    end
                end
            end
        end

        @threads for thread_id in 1:num_threads
            update_agent_states(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                households,
                viruses,
                recovered_duration_mean,
                recovered_duration_sd,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                current_step,
                observed_daily_new_cases_age_groups_viruses_threads,
                daily_new_cases_age_groups_viruses_threads,
                rt_threads,
                rt_count_threads,
                num_infected_districts_threads,
                FluA_immune_memory_susceptibility_level,
                FluB_immune_memory_susceptibility_level,
                RV_immune_memory_susceptibility_level,
                RSV_immune_memory_susceptibility_level,
                AdV_immune_memory_susceptibility_level,
                PIV_immune_memory_susceptibility_level,
                CoV_immune_memory_susceptibility_level,
            )
        end

        # Обновление даты
        for i = 1:4
            for j = 1:7
                observed_num_infected_age_groups_viruses[current_step, j, i] = sum(
                    observed_daily_new_cases_age_groups_viruses_threads[current_step, i, j, :])
                num_infected_age_groups_viruses[current_step, j, i] = sum(
                    daily_new_cases_age_groups_viruses_threads[current_step, i, j, :])
            end
        end

        if week_day == 7
            week_day = 1
        else
            week_day += 1
        end

        if ((month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10) && day == 31) ||
            ((month == 4 || month == 6 || month == 9 || month == 11) && day == 30) ||
            (month == 2 && day == 28)
            day = 1
            month += 1
        elseif (month == 12 && day == 31)
            day = 1
            month = 1
        else
            day += 1
        end

        year_day += 1
        if year_day > 365
            year_day = 1
        end

        if with_global_warming && current_step % 365 == 0
            temperature = copy(temperature_base)
            for i = 1:length(temperature)
                temperature[i] += rand(Normal(1.0, 0.25))
                # temperature[i] += rand(Normal(2.0, 0.5))
                # temperature[i] += rand(Normal(3.0, 0.75))
                # temperature[i] += rand(Normal(4.0, 1.0))
            end
            append!(temperature_record, temperature)
        end
    end

    if with_global_warming
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "temperature_4.csv"), temperature_record, ',')
    end

    rt = sum(rt_threads, dims = 2)[:, 1]
    rt_count = sum(rt_count_threads, dims = 2)[:, 1]
    rt = rt ./ rt_count

    observed_num_infected_age_groups_viruses_weekly = zeros(Int, (num_weeks), 7, 4)
    for i = 1:(num_weeks)
        observed_num_infected_age_groups_viruses_weekly[i, :, :] = sum(observed_num_infected_age_groups_viruses[(i * 7 - 6):(i * 7), :, :], dims = 1)
    end

    num_infected_age_groups_viruses_weekly = zeros(Int, (num_weeks), 7, 4)
    for i = 1:(num_weeks)
        num_infected_age_groups_viruses_weekly[i, :, :] = sum(num_infected_age_groups_viruses[(i * 7 - 6):(i * 7), :, :], dims = 1)
    end

    return observed_num_infected_age_groups_viruses_weekly, num_infected_age_groups_viruses_weekly, sum(activities_infections_threads, dims = 3)[:, :, 1], rt, sum(num_schools_closed_threads, dims = 2)[:, 1], sum(num_infected_districts_threads, dims = 3)[:, :, 1]
end
