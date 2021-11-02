function get_contact_duration_normal(mean::Float64, sd::Float64, rng::MersenneTwister)
    return rand(rng, truncated(Normal(mean, sd), 0.0, 24.0))
end

function get_contact_duration_gamma(shape::Float64, scale::Float64, rng::MersenneTwister)
    return rand(rng, Gamma(shape, scale))
end

function make_contact(
    infected_agent::Agent,
    susceptible_agent::Agent,
    contact_duration::Float64,
    current_step::Int,
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temp_influences::Array{Float64, 2},
    rng::MersenneTwister,
)
    # Влияние продолжительности контакта на вероятность инфицирования
    duration_influence = 1 / (1 + exp(-contact_duration + duration_parameter))
            
    # Влияние температуры воздуха на вероятность инфицирования
    temperature_influence = temp_influences[infected_agent.virus_id, current_step]

    # Влияние восприимчивости агента на вероятность инфицирования
    susceptibility_influence = 2 / (1 + exp(susceptibility_parameters[infected_agent.virus_id] * susceptible_agent.ig_level))

    # Влияние силы инфекции на вероятность инфицирования
    infectivity_influence = infected_agent.infectivity

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
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    etiology::Matrix{Float64},
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    week_num::Int,
    current_step::Int,
    infected_inside_activity::Array{Int, 3},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        # Агент инфицирован
        if agent.virus_id != 0 && !agent.is_newly_infected && agent.infectivity > 0.0001
            # Инфицированный агент посещает чужое домохозяйство
            if agent.visit_household_id != 0
                for agent2_id in households[agent.visit_household_id].agent_ids
                    agent2 = agents[agent2_id]
                    # Проверка восприимчивости агента к вирусу
                    if agent2.visit_household_id == 0 &&
                        agent2.virus_id == 0 &&
                        agent2.days_immune == 0 &&
                        (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
                        (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
                        (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
                        (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                        (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
                        (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                        (agent.virus_id != 6 || agent2.PIV_days_immune == 0)

                        if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                            (agent.activity_type == 3 && is_university_holiday) ||
                            (agent.activity_type == 2 && is_school_holiday) ||
                            (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                            (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                            (agent2.activity_type == 3 && is_university_holiday) ||
                            (agent2.activity_type == 2 && is_school_holiday) ||
                            (agent2.activity_type == 1 && is_kindergarten_holiday))

                            dur = get_contact_duration_normal(0.95, 0.2, rng)
                            if dur > 0.01
                                make_contact(agent, agent2, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
                                if agent2.is_newly_infected
                                    infected_inside_activity[current_step, 8, thread_id] += 1
                                end
                            end
                        else
                            dur = get_contact_duration_normal(0.42, 0.1, rng)
                            if dur > 0.01
                                make_contact(agent, agent2, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
                                if agent2.is_newly_infected
                                    infected_inside_activity[current_step, 8, thread_id] += 1
                                end
                            end
                        end
                    end
                end
            # Агент-ребенок посещает чужое домохозяйство вместе со своим попечителем
            elseif agent.supporter_id != 0 &&
                agents[agent.supporter_id].visit_household_id != 0 &&
                (agent.needs_supporter_care || rand(rng, Float64) < 0.5)
                for agent2_id in households[agents[agent.supporter_id].visit_household_id].agent_ids
                    agent2 = agents[agent2_id]
                    # Проверка восприимчивости агента к вирусу
                    if agent2.visit_household_id == 0 &&
                        agent2.virus_id == 0 &&
                        agent2.days_immune == 0 &&
                        (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
                        (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
                        (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
                        (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                        (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
                        (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                        (agent.virus_id != 6 || agent2.PIV_days_immune == 0)

                        if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                            (agent.activity_type == 3 && is_university_holiday) ||
                            (agent.activity_type == 2 && is_school_holiday) ||
                            (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                            (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                            (agent2.activity_type == 3 && is_university_holiday) ||
                            (agent2.activity_type == 2 && is_school_holiday) ||
                            (agent2.activity_type == 1 && is_kindergarten_holiday))

                            dur = get_contact_duration_normal(0.95, 0.2, rng)
                            if dur > 0.01
                                make_contact(agent, agent2, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
                                if agent2.is_newly_infected
                                    infected_inside_activity[current_step, 8, thread_id] += 1
                                end
                            end
                        else
                            dur = get_contact_duration_normal(0.42, 0.1, rng)
                            if dur > 0.01
                                make_contact(agent, agent2, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
                                if agent2.is_newly_infected
                                    infected_inside_activity[current_step, 8, thread_id] += 1
                                end
                            end
                        end
                    end
                end
            end
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
                    if dur > 0.01
                        make_contact(agent, agent2, dur, current_step, duration_parameter,
                            susceptibility_parameters, temp_influences, rng)
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
                            make_contact(agent, agent2, dur, current_step, duration_parameter,
                                susceptibility_parameters, temp_influences, rng)
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
                                make_contact(
                                    agent, agent2, get_contact_duration_gamma(1.0, 1.6, rng),
                                    current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
    
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
            # Восприимчивый агент посещает чужое домохозяйство
            if agent.visit_household_id != 0
                for agent2_id in households[agent.visit_household_id].agent_ids
                    agent2 = agents[agent2_id]
                    if agent2.visit_household_id == 0 &&
                        agent2.virus_id != 0 &&
                        !agent2.is_newly_infected &&
                        agent2.infectivity > 0.0001 &&
                        (agent2.virus_id != 1 || agent.FluA_days_immune == 0) &&
                        (agent2.virus_id != 2 || agent.FluB_days_immune == 0) &&
                        (agent2.virus_id != 7 || agent.CoV_days_immune == 0) &&
                        (agent2.virus_id != 3 || agent.RV_days_immune == 0) &&
                        (agent2.virus_id != 4 || agent.RSV_days_immune == 0) &&
                        (agent2.virus_id != 5 || agent.AdV_days_immune == 0) &&
                        (agent2.virus_id != 6 || agent.PIV_days_immune == 0)

                        if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                            (agent.activity_type == 3 && is_university_holiday) ||
                            (agent.activity_type == 2 && is_school_holiday) ||
                            (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                            (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                            (agent2.activity_type == 3 && is_university_holiday) ||
                            (agent2.activity_type == 2 && is_school_holiday) ||
                            (agent2.activity_type == 1 && is_kindergarten_holiday))

                            dur = get_contact_duration_normal(0.95, 0.2, rng)
                            if dur > 0.01
                                make_contact(agent2, agent, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
                                if agent.is_newly_infected
                                    infected_inside_activity[current_step, 8, thread_id] += 1
                                end
                            end
                        else
                            dur = get_contact_duration_normal(0.42, 0.1, rng)
                            if dur > 0.01
                                make_contact(agent2, agent, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
                                if agent.is_newly_infected
                                    infected_inside_activity[current_step, 8, thread_id] += 1
                                end
                            end
                        end
                    end
                end
            # Восприимчивый агент-ребенок посещает чужое домохозяйство вместе со своим попечителем с вероятностью 0.5
            elseif agent.supporter_id != 0 && agents[agent.supporter_id].visit_household_id != 0 && rand(rng, Float64) < 0.5
                for agent2_id in households[agents[agent.supporter_id].visit_household_id].agent_ids
                    agent2 = agents[agent2_id]
                    # Проверка восприимчивости агента к вирусу
                    if agent2.visit_household_id == 0 &&
                        agent2.virus_id != 0 &&
                        !agent2.is_newly_infected &&
                        agent2.infectivity > 0.0001 &&
                        (agent2.virus_id != 1 || agent.FluA_days_immune == 0) &&
                        (agent2.virus_id != 2 || agent.FluB_days_immune == 0) &&
                        (agent2.virus_id != 7 || agent.CoV_days_immune == 0) &&
                        (agent2.virus_id != 3 || agent.RV_days_immune == 0) &&
                        (agent2.virus_id != 4 || agent.RSV_days_immune == 0) &&
                        (agent2.virus_id != 5 || agent.AdV_days_immune == 0) &&
                        (agent2.virus_id != 6 || agent.PIV_days_immune == 0)

                        if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                            (agent.activity_type == 3 && is_university_holiday) ||
                            (agent.activity_type == 2 && is_school_holiday) ||
                            (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                            (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                            (agent2.activity_type == 3 && is_university_holiday) ||
                            (agent2.activity_type == 2 && is_school_holiday) ||
                            (agent2.activity_type == 1 && is_kindergarten_holiday))

                            dur = get_contact_duration_normal(0.95, 0.2, rng)
                            if dur > 0.01
                                make_contact(agent2, agent, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
                                if agent.is_newly_infected
                                    infected_inside_activity[current_step, 8, thread_id] += 1
                                end
                            end
                        else
                            dur = get_contact_duration_normal(0.42, 0.1, rng)
                            if dur > 0.01
                                make_contact(agent2, agent, dur, current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences, rng)
                                if agent.is_newly_infected
                                    infected_inside_activity[current_step, 8, thread_id] += 1
                                end
                            end
                        end
                    end
                end
            end

            # Случайное инфицирование
            if agent.age < 2
                if rand(rng, Float64) < 0.0003
                    infect_randomly(agent, current_step, etiology, rng)
                end
            elseif agent.age < 16
                if rand(rng, Float64) < 0.0002
                    infect_randomly(agent, current_step, etiology, rng)
                end
            else
                if rand(rng, Float64) < 0.0001
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
    infectivities::Array{Float64, 4},
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
            if agent.FluA_days_immune == 270
                agent.FluA_days_immune = 0
            else
                agent.FluA_days_immune += 1
            end
        end
        if agent.FluB_days_immune != 0
            if agent.FluB_days_immune == 270
                agent.FluB_days_immune = 0
            else
                agent.FluB_days_immune += 1
            end
        end
        if agent.RV_days_immune != 0
            if agent.RV_days_immune == 60
                agent.RV_days_immune = 0
            else
                agent.RV_days_immune += 1
            end
        end
        if agent.RSV_days_immune != 0
            if agent.RSV_days_immune == 60
                agent.RSV_days_immune = 0
            else
                agent.RSV_days_immune += 1
            end
        end
        if agent.AdV_days_immune != 0
            if agent.AdV_days_immune == 90
                agent.AdV_days_immune = 0
            else
                agent.AdV_days_immune += 1
            end
        end
        if agent.PIV_days_immune != 0
            if agent.PIV_days_immune == 90
                agent.PIV_days_immune = 0
            else
                agent.PIV_days_immune += 1
            end
        end
        if agent.CoV_days_immune != 0
            if agent.CoV_days_immune == 120
                agent.CoV_days_immune = 0
            else
                agent.CoV_days_immune += 1
            end
        end

        if agent.virus_id != 0 && !agent.is_newly_infected
            if agent.days_infected == agent.infection_period
                if agent.virus_id == 1
                    agent.FluA_days_immune = 1
                elseif agent.virus_id == 2
                    agent.FluB_days_immune = 1
                elseif agent.virus_id == 3
                    agent.RV_days_immune = 1
                elseif agent.virus_id == 4
                    agent.RSV_days_immune = 1
                elseif agent.virus_id == 5
                    agent.AdV_days_immune = 1
                elseif agent.virus_id == 6
                    agent.PIV_days_immune = 1
                else
                    agent.CoV_days_immune = 1
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
                        if agent.age < 8
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
                        if agent.age < 8
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
                        if agent.age < 8
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
                
                agent.infectivity = find_agent_infectivity(
                    agent.age,
                    infectivities[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                    agent.is_asymptomatic && agent.days_infected > 0)

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

            if agent.virus_id == 1 || agent.virus_id == 2
                if agent.age < 16
                    if rand(rng, Float64) < 0.32
                        agent.is_asymptomatic = true
                    else
                        agent.is_asymptomatic = false
                    end
                else
                    if rand(rng, Float64) < 0.16
                        agent.is_asymptomatic = true
                    else
                        agent.is_asymptomatic = false
                    end
                end
            else
                if agent.age < 16
                    if rand(rng, Float64) < 0.5
                        agent.is_asymptomatic = true
                    else
                        agent.is_asymptomatic = false
                    end
                else
                    if rand(rng, Float64) < 0.3
                        agent.is_asymptomatic = true
                    else
                        agent.is_asymptomatic = false
                    end
                end
            end
            
            agent.infectivity = find_agent_infectivity(
                agent.age,
                infectivities[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                agent.is_asymptomatic && agent.days_infected > 0)
            agent.is_newly_infected = false
        end

        agent.attendance = true
        if agent.activity_type == 1 && !agent.is_teacher
            if rand(rng, Float64) < 0.1
                agent.attendance = false
            end
        elseif agent.activity_type == 2 && !agent.is_teacher
            if rand(rng, Float64) < 0.1
                agent.attendance = false
            end
        elseif agent.activity_type == 3 && !agent.is_teacher
            if rand(rng, Float64) < 0.5
                agent.attendance = false
            end
        end
    end
end

function add_additional_connections(
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    households::Vector{Household},
    shops::Vector{Shop},
    restaurants::Vector{Restaurant},
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
)
    for agent_id in start_agent_id:end_agent_id
        agent = agents[agent_id]
        if agent.age >= 14
            if agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                (agent.activity_type == 3 && is_university_holiday) ||
                (agent.activity_type == 2 && is_school_holiday) ||
                (agent.activity_type == 1 && is_kindergarten_holiday)

                if rand(rng, Float64) < 0.269
                    if length(agent.friend_ids) > 0
                        agent.visit_household_id = agents[rand(rng, agent.friend_ids)].household_id
                    else
                        agent.visit_household_id = 0
                    end
                end

                if rand(rng, Float64) < 0.354
                    space_found = false
                    for group in shops[households[agent.household_id].closest_shop_id].groups
                        for i = 1:length(group)
                            group_agent_id = group[i]
                            if group_agent_id == 0
                                num_children = 0
                                if length(agent.dependant_ids) > 0
                                    for children_id in agent.dependant_ids
                                        children = agents[children_id]
                                        if children.needs_supporter_care || rand(rng, Float64) < 0.5
                                            num_children += 1
                                        end
                                    end
                                end
                                if i + num_children <= length(group)
                                    for child_num = 1:num_children
                                        group[i + child_num] = agent.dependant_ids[child_num]
                                    end
                                    group[i] = agent.id
                                    space_found = true
                                    break
                                end
                            end
                        end
                        if space_found
                            break
                        end
                    end
                    if !space_found && households[agent.household_id].closest_shop_id != households[agent.household_id].closest_shop_id2
                        for group in shops[households[agent.household_id].closest_shop_id2].groups
                            for i = 1:length(group)
                                group_agent_id = group[i]
                                if group_agent_id == 0
                                    num_children = 0
                                    if length(agent.dependant_ids) > 0
                                        for children_id in agent.dependant_ids
                                            children = agents[children_id]
                                            if children.needs_supporter_care || rand(rng, Float64) < 0.5
                                                num_children += 1
                                            end
                                        end
                                    end
                                    if i + num_children <= length(group)
                                        for child_num = 1:num_children
                                            group[i + child_num] = agent.dependant_ids[child_num]
                                        end
                                        group[i] = agent.id
                                        space_found = true
                                        break
                                    end
                                end
                            end
                            if space_found
                                break
                            end
                        end
                    end
                end

                if rand(rng, Float64) < 0.295
                    space_found = false
                    for group in restaurants[households[agent.household_id].closest_restaurant_id].groups
                        for i = 1:length(group)
                            group_agent_id = group[i]
                            if group_agent_id == 0
                                num_children = 0
                                if length(agent.dependant_ids) > 0
                                    for children_id in agent.dependant_ids
                                        children = agents[children_id]
                                        if children.needs_supporter_care || rand(rng, Float64) < 0.5
                                            num_children += 1
                                        end
                                    end
                                end
                                if i + num_children <= length(group)
                                    for child_num = 1:num_children
                                        group[i + child_num] = agent.dependant_ids[child_num]
                                    end
                                    group[i] = agent.id
                                    space_found = true
                                    break
                                end
                            end
                        end
                        if space_found
                            break
                        end
                    end
                    if !space_found && households[agent.household_id].closest_restaurant_id != households[agent.household_id].closest_restaurant_id2
                        for group in restaurants[households[agent.household_id].closest_restaurant_id2].groups
                            for i = 1:length(group)
                                group_agent_id = group[i]
                                if group_agent_id == 0
                                    num_children = 0
                                    if length(agent.dependant_ids) > 0
                                        for children_id in agent.dependant_ids
                                            children = agents[children_id]
                                            if children.needs_supporter_care || rand(rng, Float64) < 0.5
                                                num_children += 1
                                            end
                                        end
                                    end
                                    if i + num_children <= length(group)
                                        for child_num = 1:num_children
                                            group[i + child_num] = agent.dependant_ids[child_num]
                                        end
                                        group[i] = agent.id
                                        space_found = true
                                        break
                                    end
                                end
                            end
                            if space_found
                                break
                            end
                        end
                    end
                end
            else
                if rand(rng, Float64) < 0.177
                    if length(agent.friend_ids) > 0
                        agent.visit_household_id = agents[rand(rng, agent.friend_ids)].household_id
                    else
                        agent.visit_household_id = 0
                    end
                end

                if rand(rng, Float64) < 0.291
                    space_found = false
                    for group in shops[households[agent.household_id].closest_shop_id].groups
                        for i = 1:length(group)
                            group_agent_id = group[i]
                            if group_agent_id == 0
                                num_children = 0
                                if length(agent.dependant_ids) > 0
                                    for children_id in agent.dependant_ids
                                        children = agents[children_id]
                                        if children.needs_supporter_care || rand(rng, Float64) < 0.5
                                            num_children += 1
                                        end
                                    end
                                end
                                if i + num_children <= length(group)
                                    for child_num = 1:num_children
                                        group[i + child_num] = agent.dependant_ids[child_num]
                                    end
                                    group[i] = agent.id
                                    space_found = true
                                    break
                                end
                            end
                        end
                        if space_found
                            break
                        end
                    end
                    if !space_found && households[agent.household_id].closest_shop_id != households[agent.household_id].closest_shop_id2
                        for group in shops[households[agent.household_id].closest_shop_id2].groups
                            for i = 1:length(group)
                                group_agent_id = group[i]
                                if group_agent_id == 0
                                    num_children = 0
                                    if length(agent.dependant_ids) > 0
                                        for children_id in agent.dependant_ids
                                            children = agents[children_id]
                                            if children.needs_supporter_care || rand(rng, Float64) < 0.5
                                                num_children += 1
                                            end
                                        end
                                    end
                                    if i + num_children <= length(group)
                                        for child_num = 1:num_children
                                            group[i + child_num] = agent.dependant_ids[child_num]
                                        end
                                        group[i] = agent.id
                                        space_found = true
                                        break
                                    end
                                end
                            end
                            if space_found
                                break
                            end
                        end
                    end
                end

                if rand(rng, Float64) < 0.255
                    space_found = false
                    for group in restaurants[households[agent.household_id].closest_restaurant_id].groups
                        for i = 1:length(group)
                            group_agent_id = group[i]
                            if group_agent_id == 0
                                num_children = 0
                                if length(agent.dependant_ids) > 0
                                    for children_id in agent.dependant_ids
                                        children = agents[children_id]
                                        if children.needs_supporter_care || rand(rng, Float64) < 0.5
                                            num_children += 1
                                        end
                                    end
                                end
                                if i + num_children <= length(group)
                                    for child_num = 1:num_children
                                        group[i + child_num] = agent.dependant_ids[child_num]
                                    end
                                    group[i] = agent.id
                                    space_found = true
                                    break
                                end
                            end
                        end
                        if space_found
                            break
                        end
                    end
                    if !space_found && households[agent.household_id].closest_restaurant_id != households[agent.household_id].closest_restaurant_id2
                        for group in restaurants[households[agent.household_id].closest_restaurant_id2].groups
                            for i = 1:length(group)
                                group_agent_id = group[i]
                                if group_agent_id == 0
                                    num_children = 0
                                    if length(agent.dependant_ids) > 0
                                        for children_id in agent.dependant_ids
                                            children = agents[children_id]
                                            if children.needs_supporter_care || rand(rng, Float64) < 0.5
                                                num_children += 1
                                            end
                                        end
                                    end
                                    if i + num_children <= length(group)
                                        for child_num = 1:num_children
                                            group[i + child_num] = agent.dependant_ids[child_num]
                                        end
                                        group[i] = agent.id
                                        space_found = true
                                        break
                                    end
                                end
                            end
                            if space_found
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

function simulate_additional_contacts(
    thread_id::Int,
    rng::MersenneTwister,
    agents::Vector{Agent},
    start_shop_id::Int,
    end_shop_id::Int,
    start_restaurant_id::Int,
    end_restaurant_id::Int,
    shops::Vector{Shop},
    restaurants::Vector{Restaurant},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    week_num::Int,
    current_step::Int,
    infected_inside_activity::Array{Int, 3},
)
    for shop_id in start_shop_id:end_shop_id
        shop = shops[shop_id]
        for group_id in 1:length(shop.groups)
            group = shop.groups[group_id]
            for agent_id in group
                if agent_id == 0
                    break
                end
                agent = agents[agent_id]
                if agent.virus_id != 0 && !agent.is_newly_infected && agent.infectivity > 0.0001
                    for agent2_id in group
                        if agent2_id == 0
                            break
                        end
                        agent2 = agents[agent2_id]
                        if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                            (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
                            (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
                            (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
                            (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                            (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
                            (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                            (agent.virus_id != 6 || agent2.PIV_days_immune == 0) &&
                            rand(rng, Float64) < 0.25

                            if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                                (agent.activity_type == 3 && is_university_holiday) ||
                                (agent.activity_type == 2 && is_school_holiday) ||
                                (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                                (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                                (agent2.activity_type == 3 && is_university_holiday) ||
                                (agent2.activity_type == 2 && is_school_holiday) ||
                                (agent2.activity_type == 1 && is_kindergarten_holiday))

                                dur = get_contact_duration_normal(0.44, 0.1, rng)
                                if dur > 0.01
                                    make_contact(agent, agent2, dur, current_step, duration_parameter,
                                        susceptibility_parameters, temp_influences, rng)
                                    if agent2.is_newly_infected
                                        infected_inside_activity[current_step, 6, thread_id] += 1
                                    end
                                end
                            else
                                dur = get_contact_duration_normal(0.28, 0.09, rng)
                                if dur > 0.01
                                    make_contact(agent, agent2, dur, current_step, duration_parameter,
                                        susceptibility_parameters, temp_influences, rng)
                                    if agent2.is_newly_infected
                                        infected_inside_activity[current_step, 6, thread_id] += 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
            for i in 1:length(group)
                if group[i] == 0
                    break
                end
                shops[shop_id].groups[group_id][i] = 0
            end
        end
    end

    for restaurant_id in start_restaurant_ids[thread_id]:end_restaurant_ids[thread_id]
        restaurant = restaurants[restaurant_id]
        for group_id in 1:length(restaurant.groups)
            group = restaurant.groups[group_id]
            for agent_id in group
                if agent_id == 0
                    break
                end
                agent = agents[agent_id]
                if agent.virus_id != 0 && !agent.is_newly_infected && agent.infectivity > 0.0001
                    for agent2_id in group
                        if agent2_id == 0
                            break
                        end
                        agent2 = agents[agent2_id]
                        if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                            (agent.virus_id != 1 || agent2.FluA_days_immune == 0) &&
                            (agent.virus_id != 2 || agent2.FluB_days_immune == 0) &&
                            (agent.virus_id != 7 || agent2.CoV_days_immune == 0) &&
                            (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                            (agent.virus_id != 4 || agent2.RSV_days_immune == 0) &&
                            (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                            (agent.virus_id != 6 || agent2.PIV_days_immune == 0) &&
                            rand(rng, Float64) < 0.25

                            if (agent.activity_type == 0 || (agent.activity_type == 4 && is_work_holiday) ||
                                (agent.activity_type == 3 && is_university_holiday) ||
                                (agent.activity_type == 2 && is_school_holiday) ||
                                (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                                (agent2.activity_type == 0 || (agent2.activity_type == 4 && is_work_holiday) ||
                                (agent2.activity_type == 3 && is_university_holiday) ||
                                (agent2.activity_type == 2 && is_school_holiday) ||
                                (agent2.activity_type == 1 && is_kindergarten_holiday))

                                dur = get_contact_duration_normal(0.38, 0.09, rng)
                                if dur > 0.01
                                    make_contact(agent, agent2, dur, current_step, duration_parameter,
                                        susceptibility_parameters, temp_influences, rng)
                                    if agent2.is_newly_infected
                                        infected_inside_activity[current_step, 7, thread_id] += 1
                                    end
                                end
                            else
                                dur = get_contact_duration_normal(0.26, 0.08, rng)
                                if dur > 0.01
                                    make_contact(agent, agent2, dur, current_step, duration_parameter,
                                        susceptibility_parameters, temp_influences, rng)
                                    if agent2.is_newly_infected
                                        infected_inside_activity[current_step, 7, thread_id] += 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
            for i in 1:length(group)
                if group[i] == 0
                    break
                end
                restaurants[restaurant_id].groups[group_id][i] = 0
            end
        end
    end
end

function run_simulation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    agents::Vector{Agent},
    households::Vector{Household},
    shops::Vector{Shop},
    restaurants::Vector{Restaurant},
    infectivities::Array{Float64, 4},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    etiology::Matrix{Float64},
    is_single_run::Bool,
)::Array{Float64, 3}
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 6
    # Номер недели
    week_num = 1

    num_viruses = 7

    num_infected_age_groups_viruses = zeros(52, 7, 4)
    confirmed_daily_new_cases_age_groups_viruses = zeros(365, 4, 7, num_threads)
    infected_inside_activity = zeros(Int, 365, 8, num_threads)

    # DEBUG
    # max_step = 365
    max_step = 15

    for current_step = 1:max_step
        println(current_step)
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

        @threads for thread_id in 1:num_threads
            add_additional_connections(
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                households,
                shops,
                restaurants,
                is_kindergarten_holiday,
                is_school_holiday,
                is_university_holiday,
                is_work_holiday,
            )
        end

        @threads for thread_id in 1:num_threads
            simulate_contacts(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                households,
                temp_influences,
                duration_parameter,
                susceptibility_parameters,
                etiology,
                is_kindergarten_holiday,
                is_school_holiday,
                is_university_holiday,
                is_work_holiday,
                week_num,
                current_step,
                infected_inside_activity)
        end

        @threads for thread_id in 1:num_threads
            simulate_additional_contacts(
                thread_id,
                thread_rng[thread_id],
                agents,
                start_shop_ids[thread_id],
                end_shop_ids[thread_id],
                start_restaurant_ids[thread_id],
                end_restaurant_ids[thread_id],
                shops,
                restaurants,
                temp_influences,
                duration_parameter,
                susceptibility_parameters,
                is_kindergarten_holiday,
                is_school_holiday,
                is_university_holiday,
                is_work_holiday,
                week_num,
                current_step,
                infected_inside_activity)
        end

        @threads for thread_id in 1:num_threads
            update_agent_states(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                infectivities,
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

            week_day = 1
            if week_num == 52
                week_num = 1
            else
                week_num += 1
            end
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
    end


    if is_single_run
        writedlm(joinpath(@__DIR__, "..", "..", "output", "tables", "infected_inside_activity_data.csv"),
            sum(infected_inside_activity, dims = 3)[:, :, 1], ',')
    end

    return num_infected_age_groups_viruses
end
