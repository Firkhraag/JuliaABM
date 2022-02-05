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
    duration_influence = 1 / (1 + exp(-contact_duration + duration_parameter))
            
    # Влияние температуры воздуха на вероятность инфицирования
    temperature_influence = temperature_parameters[infected_agent.virus_id] * current_temp + 1.0

    # Влияние восприимчивости агента на вероятность инфицирования
    susceptibility_influence = 2 / (1 + exp(susceptibility_parameters[infected_agent.virus_id] * susceptible_agent.ig_level))

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
        temperature_influence * duration_influence

    if rand(rng, Float64) < infection_probability
        susceptible_agent.virus_id = infected_agent.virus_id
        susceptible_agent.is_newly_infected = true
        infected_agent.infected_num_agents_on_current_step += 1
    end
end

function infect_randomly(
    agent::Agent,
    current_step::Int,
    etiology::Matrix{Float64},
    rng::MersenneTwister,
)
    rand_num = rand(rng, 1:7)
    if (rand_num == 1 && agent.FluA_days_immune == 0) ||
        (rand_num == 2 && agent.FluB_days_immune == 0) ||
        (rand_num == 3 && agent.RV_days_immune == 0) ||
        (rand_num == 4 && agent.RSV_days_immune == 0) ||
        (rand_num == 5 && agent.AdV_days_immune == 0) ||
        (rand_num == 6 && agent.PIV_days_immune == 0) ||
        (rand_num == 7 && agent.CoV_days_immune == 0)

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
    etiology::Matrix{Float64},
    viruses::Vector{Virus},
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_college_holiday::Bool,
    is_work_holiday::Bool,
    current_step::Int,
    current_temp::Float64,
    infected_inside_activity::Array{Int, 3},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        # Агент инфицирован
        if agent.virus_id != 0 && !agent.is_newly_infected

            # --------------------------TBD ZONE-----------------------------------

            # # Инфицированный агент посещает чужое домохозяйство
            # if agent.visit_household_id != 0
            #     for agent2_id in households[agent.visit_household_id].agent_ids
            #         agent2 = agents[agent2_id]
            #         # Проверка восприимчивости агента к вирусу
            #         if agent2.visit_household_id == 0 &&
            #             agent2.virus_id == 0 &&
            #             agent2.days_immune == 0 &&
            #             (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
            #             (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
            #             (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
            #             (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
            #             (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
            #             (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
            #             (agent.virus_id != 6 || agent2.PIV_days_immune == 0)

            #             dur = 0.0
            #             if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
            #                 (agent.activity_type == 3 && is_college_holiday) ||
            #                 (agent.activity_type == 2 && is_school_holiday) ||
            #                 (agent.activity_type == 1 && is_kindergarten_holiday)) &&
            #                 (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
            #                 (agent2.activity_type == 3 && is_college_holiday) ||
            #                 (agent2.activity_type == 2 && is_school_holiday) ||
            #                 (agent2.activity_type == 1 && is_kindergarten_holiday))

            #                 dur = get_contact_duration_normal(0.95, 0.2, rng)
            #             else
            #                 dur = get_contact_duration_normal(0.42, 0.1, rng)
            #             end
            #             if dur > 0.01
            #                 make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
            #                     susceptibility_parameters, temperature_parameters, current_temp, rng)
            #                 if agent2.is_newly_infected
            #                     infected_inside_activity[current_step, 8, thread_id] += 1
            #                 end
            #             end
            #         end
            #     end
            # end

            # -------------------------------------------------------------

            # Контакты в домохозяйстве
            for agent2_id in agent.household_conn_ids
                agent2 = agents[agent2_id]
                # Проверка восприимчивости агента к вирусу
                if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                    (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
                    (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
                    (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
                    (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                    (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
                    (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                    (agent.virus_id != 6 || agent2.PIV_days_immune == 0)

                    dur = 0.0
                    if (agent.is_isolated || agent.on_parent_leave || agent.activity_type == 0 ||
                        (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_college_holiday) ||
                        (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                        (agent2.is_isolated || agent2.on_parent_leave || agent2.activity_type == 0 ||
                        (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_college_holiday) ||
                        (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday))

                        dur = get_contact_duration_normal(mean_household_contact_durations[5], household_contact_duration_sds[5], rng)
                    elseif ((agent.activity_type == 4 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 4 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_work_holiday

                        dur = get_contact_duration_normal(mean_household_contact_durations[4], household_contact_duration_sds[4], rng)
                    elseif ((agent.activity_type == 2 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 2 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_school_holiday

                        dur = get_contact_duration_normal(mean_household_contact_durations[2], household_contact_duration_sds[2], rng)
                    elseif ((agent.activity_type == 1 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 1 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_kindergarten_holiday
                        
                        dur = get_contact_duration_normal(mean_household_contact_durations[1], household_contact_duration_sds[1], rng)
                    else
                        dur = get_contact_duration_normal(mean_household_contact_durations[3], household_contact_duration_sds[3], rng)
                    end

                    # --------------------------TBD ZONE-----------------------------------

                    # if (agent.visit_household_id != 0 || agent2.visit_household_id != 0) &&
                    #     (agent.visit_household_id != agent2.visit_household_id)
                        
                    #     dur -= 1.25
                    # end
    
                    # if agent.restaurant_time != 0 || agent2.restaurant_time != 0
                    #     dur -= 0.75
                    # end
                    # if agent.shopping_time != 0 || agent2.shopping_time != 0
                    #     dur -= 0.75
                    # end

                    # -------------------------------------------------------------

                    if dur > 0.01
                        make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
                            susceptibility_parameters, temperature_parameters, current_temp, rng)
                        if agent2.is_newly_infected
                            infected_inside_activity[current_step, 5, thread_id] += 1
                        end
                    end
                end
            end
            # Контакты в остальных коллективах
            if !agent.is_isolated && !agent.on_parent_leave && agent.attendance &&
                ((agent.activity_type == 1 && !is_kindergarten_holiday) ||
                (agent.activity_type == 2 && !is_school_holiday) ||
                (agent.activity_type == 3 && !is_college_holiday) ||
                (agent.activity_type == 4 && !is_work_holiday))
                
                for agent2_id in agent.activity_conn_ids
                    agent2 = agents[agent2_id]
                    if agent2.virus_id == 0 && agent2.days_immune == 0 && agent2.attendance &&
                        !agent2.is_isolated && !agent2.on_parent_leave &&
                        (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
                        (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
                        (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
                        (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                        (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
                        (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                        (agent.virus_id != 6 || agent2.PIV_days_immune == 0)

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
                                infected_inside_activity[current_step, agent.activity_type, thread_id] += 1
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
                            (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
                            (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
                            (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
                            (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                            (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
                            (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                            (agent.virus_id != 6 || agent2.PIV_days_immune == 0) &&
                            rand(rng, Float64) < 0.25
                                
                            dur = get_contact_duration_gamma(other_contact_duration_shapes[5], other_contact_duration_scales[5], rng)
                            if dur > 0.01
                                make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temperature_parameters, current_temp, rng)
    
                                if agent2.is_newly_infected
                                    infected_inside_activity[current_step, 3, thread_id] += 1
                                end
                            end
                        end
                    end
                end
            end
        # Агент восприимчив
        elseif agent.virus_id == 0 && agent.days_immune == 0

            # --------------------------TBD ZONE-----------------------------------

            # # Восприимчивый агент посещает чужое домохозяйство
            # if agent.visit_household_id != 0
            #     for agent2_id in households[agent.visit_household_id].agent_ids
            #         agent2 = agents[agent2_id]
            #         if agent2.visit_household_id == 0 &&
            #             agent2.virus_id != 0 &&
            #             !agent2.is_newly_infected &&
            #             agent2.infectivity > 0.0001 &&
            #             (agent2.virus_id != 1 || agent.FluA_days_immune == 0) &&
            #             (agent2.virus_id != 2 || agent.FluB_days_immune == 0) &&
            #             (agent2.virus_id != 7 || agent.CoV_days_immune == 0) &&
            #             (agent2.virus_id != 3 || agent.RV_days_immune == 0) &&
            #             (agent2.virus_id != 4 || agent.RSV_days_immune == 0) &&
            #             (agent2.virus_id != 5 || agent.AdV_days_immune == 0) &&
            #             (agent2.virus_id != 6 || agent.PIV_days_immune == 0)

            #             dur = 0.0
            #             if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
            #                 (agent.activity_type == 3 && is_college_holiday) ||
            #                 (agent.activity_type == 2 && is_school_holiday) ||
            #                 (agent.activity_type == 1 && is_kindergarten_holiday)) &&
            #                 (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
            #                 (agent2.activity_type == 3 && is_college_holiday) ||
            #                 (agent2.activity_type == 2 && is_school_holiday) ||
            #                 (agent2.activity_type == 1 && is_kindergarten_holiday))

            #                 dur = get_contact_duration_normal(0.95, 0.2, rng)
            #             else
            #                 dur = get_contact_duration_normal(0.42, 0.1, rng)
            #             end
            #             if dur > 0.01
            #                 make_contact(viruses, agent2, agent, dur, current_step, duration_parameter,
            #                     susceptibility_parameters, temperature_parameters, current_temp, rng)
            #                 if agent.is_newly_infected
            #                     infected_inside_activity[current_step, 8, thread_id] += 1
            #                 end
            #             end
            #         end
            #     end
            # end

            # -------------------------------------------------------------

            # Случайное инфицирование
            if agent.age < 3
                if rand(rng, Float64) < random_infection_probabilities[1]
                    infect_randomly(agent, current_step, etiology, rng)
                end
            elseif agent.age < 7
                if rand(rng, Float64) < random_infection_probabilities[2]
                    infect_randomly(agent, current_step, etiology, rng)
                end
            elseif agent.age < 15
                if rand(rng, Float64) < random_infection_probabilities[3]
                    infect_randomly(agent, current_step, etiology, rng)
                end
            else
                if rand(rng, Float64) < random_infection_probabilities[4]
                    infect_randomly(agent, current_step, etiology, rng)
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
    viruses::Vector{Virus},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    current_step::Int,
    confirmed_daily_new_cases_age_groups_viruses::Array{Float64, 4},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
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
            else
                agent.FluA_days_immune += 1
            end
        end
        if agent.FluB_days_immune != 0
            if agent.FluB_days_immune == agent.FluB_immunity_end
                agent.FluB_days_immune = 0
            else
                agent.FluB_days_immune += 1
            end
        end
        if agent.RV_days_immune != 0
            if agent.RV_days_immune == agent.RV_immunity_end
                agent.RV_days_immune = 0
            else
                agent.RV_days_immune += 1
            end
        end
        if agent.RSV_days_immune != 0
            if agent.RSV_days_immune == agent.RSV_immunity_end
                agent.RSV_days_immune = 0
            else
                agent.RSV_days_immune += 1
            end
        end
        if agent.AdV_days_immune != 0
            if agent.AdV_days_immune == agent.AdV_immunity_end
                agent.AdV_days_immune = 0
            else
                agent.AdV_days_immune += 1
            end
        end
        if agent.PIV_days_immune != 0
            if agent.PIV_days_immune == agent.PIV_immunity_end
                agent.PIV_days_immune = 0
            else
                agent.PIV_days_immune += 1
            end
        end
        if agent.CoV_days_immune != 0
            if agent.CoV_days_immune == agent.CoV_immunity_end
                agent.CoV_days_immune = 0
            else
                agent.CoV_days_immune += 1
            end
        end

        if agent.virus_id != 0 && !agent.is_newly_infected
            agent.infected_num_agents_on_current_step = 0

            if agent.days_infected == agent.infection_period
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
                agent.days_immune_end = trunc(Int, rand(rng, truncated(Normal(recovered_duration_mean, recovered_duration_sd), 1.0, 1000.0)))
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
                            confirmed_daily_new_cases_age_groups_viruses[current_step, 1, agent.virus_id, thread_id] += 1
                        elseif agent.age < 7
                            confirmed_daily_new_cases_age_groups_viruses[current_step, 2, agent.virus_id, thread_id] += 1
                        elseif agent.age < 15
                            confirmed_daily_new_cases_age_groups_viruses[current_step, 3, agent.virus_id, thread_id] += 1
                        else
                            confirmed_daily_new_cases_age_groups_viruses[current_step, 4, agent.virus_id, thread_id] += 1
                        end
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

# --------------------------TBD ZONE-----------------------------------

# function add_agent_to_public_space(
#     agent::Agent,
#     rng::MersenneTwister,
#     agents::Vector{Agent},
#     households::Vector{Household},
#     public_spaces::Vector{PublicSpace},
#     closest_public_space_id1::Int,
#     closest_public_space_id2::Int,
#     is_kindergarten_holiday::Bool,
#     is_school_holiday::Bool,
#     is_college_holiday::Bool,
#     is_work_holiday::Bool,
#     restaurant_visit_time_distribution::MixtureModel,
#     shop_visit_time_distribution::MixtureModel,
#     is_shopping::Bool,
# )
#     space_found = false
#     selected_time = 0
#     for agent2_id in households[agent.household_id].agent_ids
#         agent2 = agents[agent2_id]
#         if is_shopping && agent2.shopping_time != 0 && rand(rng, Float64) < prob_shopping_together
#             selected_time = agent2.shopping_time
#         elseif !is_shopping && agent2.restaurant_time != 0 && rand(rng, Float64) < prob_restaurant_together
#             selected_time = agent2.restaurant_time
#         end
#     end
#     if selected_time == 0
#         if is_shopping
#             selected_time = round(Int, rand(rng, shop_visit_time_distribution))
#             if selected_time > shop_num_groups
#                 selected_time = shop_num_groups
#             end
#         else
#             selected_time = round(Int, rand(rng, restaurant_visit_time_distribution))
#             if selected_time > restaurant_num_groups
#                 selected_time = restaurant_num_groups
#             end
#         end
#         if selected_time < 1
#             selected_time = 1
#         end
#     end
#     group = public_spaces[closest_public_space_id1].groups[selected_time]
#     if group.num_agents < length(group.agent_ids)
#         group.num_agents += 1
#         group.agent_ids[group.num_agents] = agent.id
#         if is_shopping
#             agent.shopping_time = selected_time
#         else
#             agent.restaurant_time = selected_time
#         end
#         if group.num_agents < length(group.agent_ids)
#             for agent2_id in agent.dependant_ids
#                 agent2 = agents[agent2_id]
#                 if (agent2.needs_supporter_care && length(households[agent.household_id].agent_ids) == length(agent.dependant_ids) + 1) || rand(rng, Float64) < 1 / (2 * length(agent.dependant_ids))
#                     group.num_agents += 1
#                     group.agent_ids[group.num_agents] = agent2_id
#                     if is_shopping
#                         agent2.shopping_time = selected_time
#                     else
#                         agent2.restaurant_time = selected_time
#                     end
#                     if group.num_agents == length(group.agent_ids)
#                         break
#                     end
#                 end
#             end
#         end
#         space_found = true
#     end
#     if !space_found && closest_public_space_id1 != closest_public_space_id2
#         group = public_spaces[closest_public_space_id2].groups[selected_time]
#         if group.num_agents < length(group.agent_ids)
#             group.num_agents += 1
#             group.agent_ids[group.num_agents] = agent.id
#             if is_shopping
#                 agent.shopping_time = selected_time
#             else
#                 agent.restaurant_time = selected_time
#             end
#             if group.num_agents < length(group.agent_ids)
#                 for agent2_id in agent.dependant_ids
#                     agent2 = agents[agent2_id]
#                     if (agent2.needs_supporter_care && length(households[agent.household_id].agent_ids) == length(agent.dependant_ids) + 1) || rand(rng, Float64) < 1 / (2 * length(agent.dependant_ids))
#                         group.num_agents += 1
#                         group.agent_ids[group.num_agents] = agent2_id
#                         if is_shopping
#                             agent2.shopping_time = selected_time
#                         else
#                             agent2.restaurant_time = selected_time
#                         end
#                         if group.num_agents == length(group.agent_ids)
#                             break
#                         end
#                     end
#                 end
#             end
#         end
#     end
# end

# function add_additional_connections_each_step(
#     rng::MersenneTwister,
#     start_agent_id::Int,
#     end_agent_id::Int,
#     agents::Vector{Agent},
#     households::Vector{Household},
#     shops::Vector{PublicSpace},
#     restaurants::Vector{PublicSpace},
#     is_kindergarten_holiday::Bool,
#     is_school_holiday::Bool,
#     is_college_holiday::Bool,
#     is_work_holiday::Bool,
#     restaurant_visit_time_distribution::MixtureModel,
#     shop_visit_time_distribution::MixtureModel,
# )
#     for agent_id in start_agent_id:end_agent_id
#         agent = agents[agent_id]
#         agent.visit_household_id = 0
#         agent.shopping_time = 0
#         agent.restaurant_time = 0
#     end
#     for agent_id in start_agent_id:end_agent_id
#         agent = agents[agent_id]
#         if agent.age >= 12
#             if !agent.is_isolated
#                 prob = 0.0
#                 if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                     (agent.activity_type == 3 && is_college_holiday) ||
#                     (agent.activity_type == 2 && is_school_holiday) ||
#                     (agent.activity_type == 1 && is_kindergarten_holiday)

#                     prob = 0.269
#                 else
#                     prob = 0.177
#                 end
#                 if !agent.on_parent_leave && rand(rng, Float64) < prob
#                     if length(agent.friend_ids) > 0
#                         agent_to_visit = agents[rand(rng, agent.friend_ids)]
#                         num_tries = 1
#                         while (agent_to_visit.is_isolated || agent_to_visit.on_parent_leave) && num_tries < length(agent.friend_ids)
#                             agent_to_visit = agents[rand(rng, agent.friend_ids)]
#                             num_tries += 1
#                         end
#                         agent.visit_household_id = agent_to_visit.household_id
#                         for agent2_id in households[agent.household_id].agent_ids
#                             agent2 = agents[agent2_id]
#                             if agent2_id in agent.dependant_ids
#                                 if !agent2.is_isolated && agent2.visit_household_id == 0 && rand(rng, Float64) < 1 / (2 * length(agent.dependant_ids))
#                                     agent2.visit_household_id = agent.visit_household_id
#                                 end
#                             else
#                                 if !agent2.is_isolated && agent2.visit_household_id == 0 && abs(agent.age - agent2.age) < 15 && rand(rng, Float64) < 1 / (2 * length(households[agent.household_id].agent_ids))
#                                     agent2.visit_household_id = agent.visit_household_id
#                                 end
#                             end
                            
#                         end
#                     end
#                 end
#             end

#             prob = 0.0
#             if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                 (agent.activity_type == 3 && is_college_holiday) ||
#                 (agent.activity_type == 2 && is_school_holiday) ||
#                 (agent.activity_type == 1 && is_kindergarten_holiday)

#                 prob = 0.354
#             else
#                 prob = 0.291
#             end
#             if agent.activity_type != 5 && rand(rng, Float64) < prob
#                 add_agent_to_public_space(
#                     agent,
#                     rng,
#                     agents,
#                     households,
#                     shops,
#                     households[agent.household_id].closest_shop_id,
#                     households[agent.household_id].closest_shop_id2,
#                     is_kindergarten_holiday,
#                     is_school_holiday,
#                     is_college_holiday,
#                     is_work_holiday,
#                     restaurant_visit_time_distribution,
#                     shop_visit_time_distribution,
#                     true,
#                 )
#             end

#             if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                 (agent.activity_type == 3 && is_college_holiday) ||
#                 (agent.activity_type == 2 && is_school_holiday) ||
#                 (agent.activity_type == 1 && is_kindergarten_holiday)

#                 prob = 0.295
#             else
#                 prob = 0.255
#             end
#             if agent.activity_type != 6 && rand(rng, Float64) < prob
#                 add_agent_to_public_space(
#                     agent,
#                     rng,
#                     agents,
#                     households,
#                     restaurants,
#                     households[agent.household_id].closest_restaurant_id,
#                     households[agent.household_id].closest_restaurant_id2,
#                     is_kindergarten_holiday,
#                     is_school_holiday,
#                     is_college_holiday,
#                     is_work_holiday,
#                     restaurant_visit_time_distribution,
#                     shop_visit_time_distribution,
#                     false,
#                 )
#             end
#         end
#     end
# end

# function simulate_public_space_contacts(
#     thread_id::Int,
#     rng::MersenneTwister,
#     agents::Vector{Agent},
#     households::Vector{Household},
#     start_public_space_id::Int,
#     end_public_space_id::Int,
#     public_spaces::Vector{PublicSpace},
#     mean_num_contacts_in_public_space::Int,
#     mean_contact_time_weekday::Float64,
#     contact_time_sd_weekday::Float64,
#     mean_contact_time_holiday::Float64,
#     contact_time_sd_holiday::Float64,
#     temp_influences::Array{Float64, 2},
#     duration_parameter::Float64,
#     susceptibility_parameters::Vector{Float64},
#     is_kindergarten_holiday::Bool,
#     is_school_holiday::Bool,
#     is_college_holiday::Bool,
#     is_work_holiday::Bool,
#     current_step::Int,
#     infected_inside_activity::Array{Int, 3},
#     is_shopping::Bool,
# )
#     for public_space_id in start_public_space_id:end_public_space_id
#         public_space = public_spaces[public_space_id]
#         for group_id in 1:length(public_space.groups)
#             group = public_space.groups[group_id]
#             for agent_num in 1:group.num_agents
#                 agent_id = group.agent_ids[agent_num]
#                 agent = agents[agent_id]
#                 if agent.virus_id != 0 && !agent.is_newly_infected
#                     household_members = 0
#                     for agent2_id in households[agent.household_id].agent_ids
#                         agent2 = agents[agent2_id]
#                         if is_shopping && agent2.shopping_time == agent.shopping_time
#                             household_members += 1
#                         elseif !is_shopping && agent2.restaurant_time == agent.restaurant_time
#                             household_members += 1
#                         end
#                     end
#                     # Контакты посетителей друг с другом
#                     for agent2_num in (agent_num + 1):group.num_agents
#                         agent2_id = group.agent_ids[agent2_num]
#                         agent2 = agents[agent2_id]
#                         if agent2.virus_id == 0 && agent2.days_immune == 0 &&
#                             (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
#                             (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
#                             (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
#                             (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
#                             (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
#                             (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
#                             (agent.virus_id != 6 || agent2.PIV_days_immune == 0) &&
#                             (agent2_id in households[agent.household_id].agent_ids || rand(rng, Float64) < ((mean_num_contacts_in_public_space - household_members) / group.num_agents))

#                             dur = 0.0
#                             if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                                 (agent.activity_type == 3 && is_college_holiday) ||
#                                 (agent.activity_type == 2 && is_school_holiday) ||
#                                 (agent.activity_type == 1 && is_kindergarten_holiday)) &&
#                                 (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
#                                 (agent2.activity_type == 3 && is_college_holiday) ||
#                                 (agent2.activity_type == 2 && is_school_holiday) ||
#                                 (agent2.activity_type == 1 && is_kindergarten_holiday))

#                                 dur = get_contact_duration_normal(0.44, 0.1, rng)
#                             else
#                                 dur = get_contact_duration_normal(0.28, 0.09, rng)
#                             end
#                             if dur > 0.01
#                                 make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
#                                     susceptibility_parameters, temperature_parameters, current_temp, rng)
#                                 if agent2.is_newly_infected
#                                     infected_inside_activity[current_step, is_shopping ? 7 : 8, thread_id] += 1
#                                 end
#                             end
#                         end
#                     end
#                     # Контакты посетителей с персоналом
#                     for agent2_id in public_space.worker_ids
#                         agent2 = agents[agent2_id]
#                         if !agent2.on_parent_leave && agent2.virus_id == 0 && agent2.days_immune == 0 &&
#                             (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
#                             (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
#                             (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
#                             (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
#                             (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
#                             (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
#                             (agent.virus_id != 6 || agent2.PIV_days_immune == 0) &&
#                             rand(rng, Float64) < (1 / length(public_space.worker_ids))
            
#                             dur = 0.0
#                             if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                                 (agent.activity_type == 3 && is_college_holiday) ||
#                                 (agent.activity_type == 2 && is_school_holiday) ||
#                                 (agent.activity_type == 1 && is_kindergarten_holiday)
            
#                                 dur = get_contact_duration_normal(0.44, 0.1, rng)
#                             else
#                                 dur = get_contact_duration_normal(0.28, 0.09, rng)
#                             end
#                             if dur > 0.01
#                                 make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
#                                     susceptibility_parameters, temp_influences, rng)
#                                 if agent2.is_newly_infected
#                                     infected_inside_activity[current_step, is_shopping ? 7 : 8, thread_id] += 1
#                                 end
#                             end
#                         end
#                     end
#                 end
#             end
#             # Контакты персонала с посетителями
#             for agent_id in public_space.worker_ids
#                 agent = agents[agent_id]
#                 if !agent.is_isolated && !agent.on_parent_leave && agent.virus_id != 0 &&
#                     !agent.is_newly_infected

#                     for agent2_num in 1:group.num_agents
#                         agent2_id = group.agent_ids[agent2_num]
#                         agent2 = agents[agent2_id]
#                         if agent2.virus_id == 0 && agent2.days_immune == 0 &&
#                             (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
#                             (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
#                             (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
#                             (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
#                             (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
#                             (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
#                             (agent.virus_id != 6 || agent2.PIV_days_immune == 0) &&
#                             rand(rng, Float64) < (1 / length(public_space.worker_ids))
    
#                             dur = 0.0
#                             if agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
#                                 (agent2.activity_type == 3 && is_college_holiday) ||
#                                 (agent2.activity_type == 2 && is_school_holiday) ||
#                                 (agent2.activity_type == 1 && is_kindergarten_holiday)
    
#                                 dur = get_contact_duration_normal(0.44, 0.1, rng)
#                             else
#                                 dur = get_contact_duration_normal(0.28, 0.09, rng)
#                             end
#                             if dur > 0.01
#                                 make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
#                                     susceptibility_parameters, temperature_parameters, current_temp, rng)
#                                 if agent2.is_newly_infected
#                                     infected_inside_activity[current_step, is_shopping ? 7 : 8, thread_id] += 1
#                                 end
#                             end
#                         end
#                     end
#                 end
#             end
#             # Очистка групп
#             for i = 1:group.num_agents
#                 group.agent_ids[i] = 0
#             end
#             group.num_agents = 0
#         end
#         # Контакты персонала друг с другом
#         for agent_id in public_space.worker_ids
#             agent = agents[agent_id]
#             if !agent.is_isolated && !agent.on_parent_leave && agent.virus_id != 0 &&
#                 !agent.is_newly_infected
                
#                 for agent2_id in public_space.worker_ids
#                     agent2 = agents[agent2_id]
#                     if !agent2.on_parent_leave && agent2.virus_id == 0 && agent2.days_immune == 0 &&
#                         (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
#                         (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
#                         (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
#                         (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
#                         (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
#                         (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
#                         (agent.virus_id != 6 || agent2.PIV_days_immune == 0)
        
#                         dur = get_contact_duration_gamma(1.81, 1.7, rng)
#                         if dur > 0.01
#                             make_contact(viruses, agent, agent2, dur, current_step, duration_parameter,
#                                 susceptibility_parameters, temperature_parameters, current_temp, rng)
#                             if agent2.is_newly_infected
#                                 infected_inside_activity[current_step, is_shopping ? 7 : 8, thread_id] += 1
#                             end
#                         end
#                     end
#                 end
#             end
#         end
#     end
# end

# -------------------------------------------------------------

function run_simulation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    viruses::Vector{Virus},
    households::Vector{Household},
    # shops::Vector{PublicSpace},
    # restaurants::Vector{PublicSpace},
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
    etiology::Matrix{Float64},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    is_single_run::Bool,
)::Array{Float64, 3}
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    # Минимальная температура воздуха
    min_temp = -7.2
    # Max - Min температура
    max_min_temp = 26.6

    num_viruses = 7

    year_day = 213

    num_infected_age_groups_viruses = zeros(52, 7, 4)
    confirmed_daily_new_cases_age_groups_viruses = zeros(365, 4, 7, num_threads)
    infected_inside_activity = zeros(Int, 365, 8, num_threads)

    # DEBUG
    max_step = 365
    # max_step = 10

    rt = zeros(Float64, max_step)

    for current_step = 1:max_step
        # println(current_step)
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

        # --------------------------TBD ZONE-----------------------------------

        # restaurant_visit_time_distribution = MixtureModel(Normal[
        #     Normal(3.0, 0.7),
        #     Normal(8.0, 0.7)], [0.4, 0.6])
        # shop_visit_time_distribution = MixtureModel(Normal[
        #     Normal(4.0, 1.0),
        #     Normal(9.0, 1.0)], [0.4, 0.6])

        # @threads for thread_id in 1:num_threads
        #     add_additional_connections_each_step(
        #         thread_rng[thread_id],
        #         start_agent_ids[thread_id],
        #         end_agent_ids[thread_id],
        #         agents,
        #         households,
        #         shops,
        #         restaurants,
        #         is_kindergarten_holiday,
        #         is_school_holiday,
        #         is_college_holiday,
        #         is_work_holiday,
        #         restaurant_visit_time_distribution,
        #         shop_visit_time_distribution,
        #     )
        # end

        # -------------------------------------------------------------

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
                etiology,
                viruses,
                is_kindergarten_holiday,
                is_school_holiday,
                is_college_holiday,
                is_work_holiday,
                current_step,
                (temperature[year_day] - min_temp) / max_min_temp,
                infected_inside_activity)
        end

        # --------------------------TBD ZONE-----------------------------------

        # @threads for thread_id in 1:num_threads
        #     simulate_public_space_contacts(
        #         thread_id,
        #         thread_rng[thread_id],
        #         agents,
        #         households,
        #         start_shop_ids[thread_id],
        #         end_shop_ids[thread_id],
        #         shops,
        #         shop_num_nearest_agents_as_contact,
        #         0.28,
        #         0.09,
        #         0.44,
        #         0.1,
        #         temp_influences,
        #         duration_parameter,
        #         susceptibility_parameters,
        #         is_kindergarten_holiday,
        #         is_school_holiday,
        #         is_college_holiday,
        #         is_work_holiday,
        #         current_step,
        #         infected_inside_activity,
        #         true,
        #     )

        #     simulate_public_space_contacts(
        #         thread_id,
        #         thread_rng[thread_id],
        #         agents,
        #         households,
        #         start_restaurant_ids[thread_id],
        #         end_restaurant_ids[thread_id],
        #         restaurants,
        #         restaurant_num_nearest_agents_as_contact,
        #         0.26,
        #         0.08,
        #         0.38,
        #         0.09,
        #         temp_influences,
        #         duration_parameter,
        #         susceptibility_parameters,
        #         is_kindergarten_holiday,
        #         is_school_holiday,
        #         is_college_holiday,
        #         is_work_holiday,
        #         current_step,
        #         infected_inside_activity,
        #         false,
        #     )
        # end

        # -------------------------------------------------------------

        if is_single_run
            rt_count = 0
            for agent in agents
                if agent.virus_id != 0 && !agent.is_newly_infected
                    rt[current_step] += agent.infected_num_agents_on_current_step
                    rt_count += 1
                end
            end
            rt[current_step] /= rt_count
        end

        @threads for thread_id in 1:num_threads
            update_agent_states(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                viruses,
                recovered_duration_mean,
                recovered_duration_sd,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                current_step,
                confirmed_daily_new_cases_age_groups_viruses)
        end

        # Обновление даты
        if current_step % 7 == 0
            for i = 1:4
                for j = 1:7
                    num_infected_age_groups_viruses[week_num, j, i] = sum(
                        confirmed_daily_new_cases_age_groups_viruses[current_step - 6:current_step, i, j, :])
                end
            end
            if week_num == 52
                break
            else
                week_num += 1
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
    end


    if is_single_run
        writedlm(joinpath(@__DIR__, "..", "..", "output", "tables", "infected_inside_activity_data.csv"),
            sum(infected_inside_activity, dims = 3)[:, :, 1], ',')
        writedlm(joinpath(@__DIR__, "..", "..", "output", "tables", "rt.csv"), rt, ',')
    end

    # -----------

    # num_agents = zeros(Int, 90)

    # FluA_days_immune = zeros(Float64, 90, 365)
    # FluB_days_immune = zeros(Float64, 90, 365)
    # RV_days_immune = zeros(Float64, 90, 365)
    # RSV_days_immune = zeros(Float64, 90, 365)
    # AdV_days_immune = zeros(Float64, 90, 365)
    # PIV_days_immune = zeros(Float64, 90, 365)
    # CoV_days_immune = zeros(Float64, 90, 365)

    # FluA_immunity_end = zeros(Float64, 90, 600)
    # FluB_immunity_end = zeros(Float64, 90, 600)
    # RV_immunity_end = zeros(Float64, 90, 600)
    # RSV_immunity_end = zeros(Float64, 90, 600)
    # AdV_immunity_end = zeros(Float64, 90, 600)
    # PIV_immunity_end = zeros(Float64, 90, 600)
    # CoV_immunity_end = zeros(Float64, 90, 600)

    # for agent in agents
    #     num_agents[agent.age] += 1
    #     if agent.FluA_days_immune > 0
    #         FluA_days_immune[agent.age, agent.FluA_days_immune] += 1
    #         FluA_immunity_end[agent.age, agent.FluA_immunity_end] += 1
    #     end
    #     if agent.FluB_days_immune > 0
    #         FluB_days_immune[agent.age, agent.FluB_days_immune] += 1
    #         FluB_immunity_end[agent.age, agent.FluB_immunity_end] += 1
    #     end
    #     if agent.RV_days_immune > 0
    #         RV_days_immune[agent.age, agent.RV_days_immune] += 1
    #         RV_immunity_end[agent.age, agent.RV_immunity_end] += 1
    #     end
    #     if agent.RSV_days_immune > 0
    #         RSV_days_immune[agent.age, agent.RSV_days_immune] += 1
    #         RSV_immunity_end[agent.age, agent.RSV_immunity_end] += 1
    #     end
    #     if agent.AdV_days_immune > 0
    #         AdV_days_immune[agent.age, agent.AdV_days_immune] += 1
    #         AdV_immunity_end[agent.age, agent.AdV_immunity_end] += 1
    #     end
    #     if agent.PIV_days_immune > 0
    #         PIV_days_immune[agent.age, agent.PIV_days_immune] += 1
    #         PIV_immunity_end[agent.age, agent.PIV_immunity_end] += 1
    #     end
    #     if agent.CoV_days_immune > 0
    #         CoV_days_immune[agent.age, agent.CoV_days_immune] += 1
    #         CoV_immunity_end[agent.age, agent.CoV_immunity_end] += 1
    #     end
    # end

    # for k = 1:90
    #     FluA_days_immune[k, :] ./= num_agents[k]
    #     FluA_immunity_end[k, :] ./= num_agents[k]

    #     FluB_days_immune[k, :] ./= num_agents[k]
    #     FluB_immunity_end[k, :] ./= num_agents[k]

    #     RV_days_immune[k, :] ./= num_agents[k]
    #     RV_immunity_end[k, :] ./= num_agents[k]

    #     RSV_days_immune[k, :] ./= num_agents[k]
    #     RSV_immunity_end[k, :] ./= num_agents[k]

    #     AdV_days_immune[k, :] ./= num_agents[k]
    #     AdV_immunity_end[k, :] ./= num_agents[k]

    #     PIV_days_immune[k, :] ./= num_agents[k]
    #     PIV_immunity_end[k, :] ./= num_agents[k]

    #     CoV_days_immune[k, :] ./= num_agents[k]
    #     CoV_immunity_end[k, :] ./= num_agents[k]
    # end

    # # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "num_agents.csv"), num_agents, ',')

    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "FluA_days_immune.csv"), FluA_days_immune, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "FluB_days_immune.csv"), FluB_days_immune, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "RV_days_immune.csv"), RV_days_immune, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "RSV_days_immune.csv"), RSV_days_immune, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "AdV_days_immune.csv"), AdV_days_immune, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "PIV_days_immune.csv"), PIV_days_immune, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "CoV_days_immune.csv"), CoV_days_immune, ',')

    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "FluA_immunity_end.csv"), FluA_immunity_end, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "FluB_immunity_end.csv"), FluB_immunity_end, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "RV_immunity_end.csv"), RV_immunity_end, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "RSV_immunity_end.csv"), RSV_immunity_end, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "AdV_immunity_end.csv"), AdV_immunity_end, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "PIV_immunity_end.csv"), PIV_immunity_end, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "immunity", "CoV_immunity_end.csv"), CoV_immunity_end, ',')

    # -----------

    return num_infected_age_groups_viruses
end
