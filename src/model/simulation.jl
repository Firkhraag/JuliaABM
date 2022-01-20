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
            viruses[infected_agent.virus_id].mean_viral_load_toddler)
    elseif infected_agent.age < 16
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_child)
    else
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_adult)
    end

    # Вероятность инфицирования
    infection_probability = infectivity_influence * susceptibility_influence *
        temperature_influence * duration_influence

    if rand(rng, Float64) < infection_probability
        susceptible_agent.virus_id = infected_agent.virus_id
        susceptible_agent.is_newly_infected = true
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
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temperature_parameters::Vector{Float64},
    random_infection_probabilities::Vector{Float64},
    etiology::Matrix{Float64},
    viruses::Vector{Virus},
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
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
            #                 (agent.activity_type == 3 && is_university_holiday) ||
            #                 (agent.activity_type == 2 && is_school_holiday) ||
            #                 (agent.activity_type == 1 && is_kindergarten_holiday)) &&
            #                 (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
            #                 (agent2.activity_type == 3 && is_university_holiday) ||
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
                        (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_university_holiday) ||
                        (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                        (agent2.is_isolated || agent2.on_parent_leave || agent2.activity_type == 0 ||
                        (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_university_holiday) ||
                        (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday))

                        dur = get_contact_duration_normal(12.0, 4.0, rng)
                    elseif ((agent.activity_type == 4 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 4 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_work_holiday

                        dur = get_contact_duration_normal(4.5, 1.5, rng)
                    elseif ((agent.activity_type == 2 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 2 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_school_holiday

                        dur = get_contact_duration_normal(5.8, 2.0, rng)
                    elseif ((agent.activity_type == 1 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 1 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_kindergarten_holiday
                        
                        dur = get_contact_duration_normal(6.5, 2.2, rng)
                    else
                        dur = get_contact_duration_normal(9.0, 3.0, rng)
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
                (agent.activity_type == 3 && !is_university_holiday) ||
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
                            dur = get_contact_duration_gamma(2.5, 1.6, rng)
                        elseif agent.activity_type == 2
                            dur = get_contact_duration_gamma(1.78, 1.95, rng)
                        elseif agent.activity_type == 3
                            dur = get_contact_duration_gamma(2.0, 1.07, rng)
                        else
                            dur = get_contact_duration_gamma(1.81, 1.7, rng)
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
                                
                            dur = get_contact_duration_gamma(1.2, 1.07, rng)
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
            #                 (agent.activity_type == 3 && is_university_holiday) ||
            #                 (agent.activity_type == 2 && is_school_holiday) ||
            #                 (agent.activity_type == 1 && is_kindergarten_holiday)) &&
            #                 (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
            #                 (agent2.activity_type == 3 && is_university_holiday) ||
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
    symptomatic_probabilities_children::Vector{Float64},
    symptomatic_probabilities_teenagers::Vector{Float64},
    symptomatic_probabilities_adults::Vector{Float64},
    current_step::Int,
    confirmed_daily_new_cases_age_groups_viruses::Array{Float64, 4},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        if agent.days_immune != 0
            if agent.days_immune == 7
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
            if agent.days_infected == agent.infection_period
                if agent.virus_id == 1
                    agent.FluA_days_immune = 1
                    agent.FluA_immunity_end = trunc(Int, rand(rng, Normal(viruses[1].immunity_duration, immunity_duration_sd)))
                elseif agent.virus_id == 2
                    agent.FluB_days_immune = 1
                    agent.FluB_immunity_end = trunc(Int, rand(rng, Normal(viruses[2].immunity_duration, immunity_duration_sd)))
                elseif agent.virus_id == 3
                    agent.RV_days_immune = 1
                    agent.RV_immunity_end = trunc(Int, rand(rng, Normal(viruses[3].immunity_duration, immunity_duration_sd)))
                elseif agent.virus_id == 4
                    agent.RSV_days_immune = 1
                    agent.RSV_immunity_end = trunc(Int, rand(rng, Normal(viruses[4].immunity_duration, immunity_duration_sd)))
                elseif agent.virus_id == 5
                    agent.AdV_days_immune = 1
                    agent.AdV_immunity_end = trunc(Int, rand(rng, Normal(viruses[5].immunity_duration, immunity_duration_sd)))
                elseif agent.virus_id == 6
                    agent.PIV_days_immune = 1
                    agent.PIV_immunity_end = trunc(Int, rand(rng, Normal(viruses[6].immunity_duration, immunity_duration_sd)))
                else
                    agent.CoV_days_immune = 1
                    agent.CoV_immunity_end = trunc(Int, rand(rng, Normal(viruses[7].immunity_duration, immunity_duration_sd)))
                end
                agent.days_immune = 1
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
                            if rand_num < 0.506
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < 0.305
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < 0.204
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < 0.101
                                agent.is_isolated = true
                            end
                        end
                    elseif agent.days_infected == 2
                        rand_num = rand(rng, Float64)
                        if agent.age < 3
                            if rand_num < 0.769
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < 0.576
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < 0.499
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < 0.334
                                agent.is_isolated = true
                            end
                        end
                    elseif agent.days_infected == 3
                        rand_num = rand(rng, Float64)
                        if agent.age < 3
                            if rand_num < 0.555
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < 0.325
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < 0.376
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < 0.168
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
            if agent.virus_id == 1
                agent.incubation_period = get_period_from_erlang(
                    1.4, 0.09, 1, 7, rng)
            elseif agent.virus_id == 2
                agent.incubation_period = get_period_from_erlang(
                    1.0, 0.048, 1, 7, rng)
            elseif agent.virus_id == 3
                agent.incubation_period = get_period_from_erlang(
                    1.9, 0.175, 1, 7, rng)
            elseif agent.virus_id == 4
                agent.incubation_period = get_period_from_erlang(
                    4.4, 0.937, 1, 7, rng)
            elseif agent.virus_id == 5
                agent.incubation_period = get_period_from_erlang(
                    5.6, 1.51, 1, 7, rng)
            elseif agent.virus_id == 6
                agent.incubation_period = get_period_from_erlang(
                    2.6, 0.327, 1, 7, rng)
            else
                agent.incubation_period = get_period_from_erlang(
                    3.2, 0.496, 1, 7, rng)
            end
            
            if agent.age < 16
                if agent.virus_id == 1
                    agent.infection_period = get_period_from_erlang(
                        8.8, 3.748, 4, 14, rng)
                elseif agent.virus_id == 2
                    agent.infection_period = get_period_from_erlang(
                        7.8, 2.94, 4, 14, rng)
                elseif agent.virus_id == 3
                    agent.infection_period = get_period_from_erlang(
                        11.4, 6.25, 4, 14, rng)
                elseif agent.virus_id == 4
                    agent.infection_period = get_period_from_erlang(
                        9.3, 4.0, 4, 14, rng)
                elseif agent.virus_id == 5
                    agent.infection_period = get_period_from_erlang(
                        9.0, 3.92, 4, 14, rng)
                elseif agent.virus_id == 6
                    agent.infection_period = get_period_from_erlang(
                        8.0, 3.1, 4, 14, rng)
                else
                    agent.infection_period = get_period_from_erlang(
                        8.0, 3.1, 4, 14, rng)
                end
            else
                if agent.virus_id == 1
                    agent.infection_period = get_period_from_erlang(
                        4.8, 1.12, 3, 12, rng)
                elseif agent.virus_id == 2
                    agent.infection_period = get_period_from_erlang(
                        3.7, 0.66, 3, 12, rng)
                elseif agent.virus_id == 3
                    agent.infection_period = get_period_from_erlang(
                        10.1, 4.93, 3, 12, rng)
                elseif agent.virus_id == 4
                    agent.infection_period = get_period_from_erlang(
                        7.4, 2.66, 3, 12, rng)
                elseif agent.virus_id == 5
                    agent.infection_period = get_period_from_erlang(
                        8.0, 3.1, 3, 12, rng)
                elseif agent.virus_id == 6
                    agent.infection_period = get_period_from_erlang(
                        7.0, 2.37, 3, 12, rng)
                else
                    agent.infection_period = get_period_from_erlang(
                        7.0, 2.37, 3, 12, rng)
                end
            end
            agent.days_infected = 1 - agent.incubation_period

            if agent.age < 10
                agent.is_asymptomatic = rand(rng, Float64) > symptomatic_probabilities_children[agent.virus_id]
            elseif agent.age < 18
                agent.is_asymptomatic = rand(rng, Float64) > symptomatic_probabilities_teenagers[agent.virus_id]
            else
                agent.is_asymptomatic = rand(rng, Float64) > symptomatic_probabilities_adults[agent.virus_id]
            end
            
            agent.is_newly_infected = false
        end

        agent.attendance = true
        if agent.activity_type == 3 && !agent.is_teacher && rand(rng, Float64) < 0.5
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
#     is_university_holiday::Bool,
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
#     is_university_holiday::Bool,
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
#                     (agent.activity_type == 3 && is_university_holiday) ||
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
#                 (agent.activity_type == 3 && is_university_holiday) ||
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
#                     is_university_holiday,
#                     is_work_holiday,
#                     restaurant_visit_time_distribution,
#                     shop_visit_time_distribution,
#                     true,
#                 )
#             end

#             if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
#                 (agent.activity_type == 3 && is_university_holiday) ||
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
#                     is_university_holiday,
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
#     is_university_holiday::Bool,
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
#                                 (agent.activity_type == 3 && is_university_holiday) ||
#                                 (agent.activity_type == 2 && is_school_holiday) ||
#                                 (agent.activity_type == 1 && is_kindergarten_holiday)) &&
#                                 (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
#                                 (agent2.activity_type == 3 && is_university_holiday) ||
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
#                                 (agent.activity_type == 3 && is_university_holiday) ||
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
#                                 (agent2.activity_type == 3 && is_university_holiday) ||
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
    symptomatic_probabilities_children::Vector{Float64},
    symptomatic_probabilities_teenagers::Vector{Float64},
    symptomatic_probabilities_adults::Vector{Float64},
    random_infection_probabilities::Vector{Float64},
    etiology::Matrix{Float64},
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
    # max_step = 365
    max_step = 10

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

        is_university_holiday = is_holiday
        if month == 7 || month == 8
            is_university_holiday = true
        elseif month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_university_holiday = true
        elseif month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_university_holiday = true
        elseif month == 2 && (day >= 1 && day <= 10)
            is_university_holiday = true
        elseif month == 12 && (day >= 22 && day <= 31)
            is_university_holiday = true
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
        #         is_university_holiday,
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
                duration_parameter,
                susceptibility_parameters,
                temperature_parameters,
                random_infection_probabilities,
                etiology,
                viruses,
                is_kindergarten_holiday,
                is_school_holiday,
                is_university_holiday,
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
        #         is_university_holiday,
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
        #         is_university_holiday,
        #         is_work_holiday,
        #         current_step,
        #         infected_inside_activity,
        #         false,
        #     )
        # end

        # -------------------------------------------------------------

        @threads for thread_id in 1:num_threads
            update_agent_states(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                viruses,
                symptomatic_probabilities_children,
                symptomatic_probabilities_teenagers,
                symptomatic_probabilities_adults,
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
        writedlm(joinpath(@__DIR__, "..", "..", "output", "tables", "confirmed_daily_new_cases_age_groups_viruses.csv"),
            sum(sum(confirmed_daily_new_cases_age_groups_viruses, dims = 3)[:, :, :, 1], dims = 3)[:, :, 1], ',')
    end

    return num_infected_age_groups_viruses
end
