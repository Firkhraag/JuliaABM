function make_contact_r0(
    infected_agent::Agent,
    susceptible_agent::Agent,
    contact_duration::Float64,
    current_step::Int,
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temp_influences::Array{Float64, 2},
    num_people_infected::Vector{Int},
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

    if rand(Float64) < infection_probability
        num_people_infected[1] += 1
        susceptible_agent.days_immune = 1
    end
end

function simulate_contacts_r0(
    infected_agent_id::Int,
    agents::Vector{Agent},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    is_holiday::Bool,
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    current_step::Int,
    num_people_infected::Vector{Int}
)
    agent = agents[infected_agent_id]
    if agent.virus_id != 0 && !agent.is_newly_infected && agent.infectivity > 0.0001
        for agent2_id in agent.household_conn_ids
            agent2 = agents[agent2_id]
            # Проверка восприимчивости агента к вирусу
            if agent2.virus_id == 0 && agent2.days_immune == 0
                if (agent.virus_id != 1 || !agent2.FluA_immunity) && (agent.virus_id != 2 || !agent2.FluB_immunity) &&
                    (agent.virus_id != 7 || !agent2.CoV_immunity) && (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                    (agent.virus_id != 4 || agent2.RSV_days_immune == 0) && (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                    (agent.virus_id != 6 || agent2.PIV_days_immune == 0)

                    agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.collective_id == 0
                    agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.collective_id == 0

                    if is_holiday || (agent_at_home && agent2_at_home)
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(12.5, 5.5, MersenneTwister(rand(1:100000))),
                            current_step, duration_parameter, susceptibility_parameters, temp_influences,
                            num_people_infected)
                    elseif ((agent.collective_id == 4 && !agent_at_home) ||
                        (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(4.5, 2.0, MersenneTwister(rand(1:100000))),
                            current_step, duration_parameter, susceptibility_parameters, temp_influences,
                            num_people_infected)
                    elseif ((agent.collective_id == 2 && !agent_at_home) ||
                        (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(5.86, 2.65, MersenneTwister(rand(1:100000))),
                            current_step, duration_parameter, susceptibility_parameters, temp_influences,
                            num_people_infected)
                    elseif ((agent.collective_id == 1 && !agent_at_home) ||
                        (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(6.5, 2.46, MersenneTwister(rand(1:100000))),
                            current_step, duration_parameter, susceptibility_parameters, temp_influences,
                            num_people_infected)
                    elseif ((agent.collective_id == 3 && !agent_at_home) ||
                        (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(10.0, 3.69, MersenneTwister(rand(1:100000))),
                            current_step, duration_parameter, susceptibility_parameters, temp_influences,
                            num_people_infected)
                    end
                end
            end
        end
        if !is_holiday && agent.group_num != 0 && !agent.is_isolated && !agent.on_parent_leave &&
            ((agent.collective_id == 1 && !is_kindergarten_holiday) ||
                (agent.collective_id == 2 && !is_school_holiday) ||
                (agent.collective_id == 3 && !is_university_holiday) ||
                (agent.collective_id == 4 && !is_work_holiday))
            for agent2_id in agent.collective_conn_ids
                agent2 = agents[agent2_id]
                if agent2.virus_id == 0 && agent2.days_immune == 0 && !agent2.is_isolated && !agent2.on_parent_leave
                    if (agent.virus_id != 1 || !agent2.FluA_immunity) && (agent.virus_id != 2 || !agent2.FluB_immunity) &&
                        (agent.virus_id != 7 || !agent2.CoV_immunity) && (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                        (agent.virus_id != 4 || agent2.RSV_days_immune == 0) && (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                        (agent.virus_id != 6 || agent2.PIV_days_immune == 0)
                        if agent.collective_id == 1
                            make_contact_r0(
                                agent, agent2, get_contact_duration_normal(4.5, 2.66, MersenneTwister(rand(1:100000))),
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences,
                                num_people_infected)
                        elseif agent.collective_id == 2
                            make_contact_r0(
                                agent, agent2, get_contact_duration_normal(3.783, 2.67, MersenneTwister(rand(1:100000))),
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences,
                                num_people_infected)
                        elseif agent.collective_id == 3
                            make_contact_r0(
                                agent, agent2, get_contact_duration_normal(2.5, 1.62, MersenneTwister(rand(1:100000))),
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences,
                                num_people_infected)
                        else
                            make_contact_r0(
                                agent, agent2, get_contact_duration_normal(3.07, 2.5, MersenneTwister(rand(1:100000))),
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences,
                                num_people_infected)
                        end
                    end
                end
            end

            if agent.collective_id == 3
                for agent2_id in agent.collective_cross_conn_ids
                    agent2 = agents[agent2_id]
                    if agent2.virus_id == 0 && agent2.days_immune == 0 && !agent2.is_isolated && !agent2.on_parent_leave
                        if (agent.virus_id != 1 || !agent2.FluA_immunity) && (agent.virus_id != 2 || !agent2.FluB_immunity) &&
                            (agent.virus_id != 7 || !agent2.CoV_immunity) && (agent.virus_id != 3 || agent2.RV_days_immune == 0) &&
                            (agent.virus_id != 4 || agent2.RSV_days_immune == 0) && (agent.virus_id != 5 || agent2.AdV_days_immune == 0) &&
                            (agent.virus_id != 6 || agent2.PIV_days_immune == 0)
                            
                            make_contact_r0(
                                agent, agent2, get_contact_duration_gamma(1.0, 1.6, MersenneTwister(rand(1:100000))),
                                current_step, duration_parameter,
                                susceptibility_parameters, temp_influences,
                                num_people_infected)
                        end
                    end
                end
            end
        end
    end
end

function update_agent_states_r0(
    infected_agent_id::Int,
    agents::Vector{Agent},
    infectivities::Array{Float64, 4},
)::Bool
    agent = agents[infected_agent_id]
    if agent.days_infected == agent.infection_period
        return false
    else
        agent.days_infected += 1

        if !agent.is_asymptomatic && !agent.is_isolated && !agent.on_parent_leave
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
        end
        
        agent.infectivity = find_agent_infectivity(
            agent.age,
            infectivities[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
            agent.is_asymptomatic && agent.days_infected > 0)

        if agent.supporter_id != 0 && !agent.is_asymptomatic && agent.days_infected > 0 && (agent.is_isolated || agent.collective_id == 0)
            agents[agent.supporter_id].on_parent_leave = true
        end
    end
    return true
end

function run_r0_simulation(
    month_num::Int,
    infected_agent_id::Int,
    agents::Vector{Agent},
    infectivities::Array{Float64, 4},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
)::Int
    # Месяц
    month = month_num

    # День месяца
    day = 1
    if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12
        day = rand(1:31)
    elseif month == 4 || month == 6 || month == 9 || month == 11
        day = rand(1:30)
    else
        day = rand(1:28)
    end

    # День недели
    week_day = rand(1:7)

    agent_infected = true
    num_people_infected = zeros(Int, 1)

    while(agent_infected)
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

        is_work_holiday = false
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
        # Зимние - 28.12.yyyy - 09.03.yyyy
        # Весенние - 22.03.yyyy - 31.03.yyyy
        is_school_holiday = false
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

        is_university_holiday = false
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

        simulate_contacts_r0(
            infected_agent_id,
            agents,
            temp_influences,
            duration_parameter,
            susceptibility_parameters,
            is_holiday,
            is_kindergarten_holiday,
            is_school_holiday,
            is_university_holiday,
            is_work_holiday,
            current_step,
            num_people_infected)
        
        agent_infected = update_agent_states_r0(
            infected_agent_id,
            agents,
            infectivities)

        # Обновление даты
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
    end

    return num_people_infected[1]
end