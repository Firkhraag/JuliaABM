function update_agent_states_r0(
    rng::MersenneTwister,
    agents::Vector{Agent},
    infectivities::Array{Float64, 4},
    current_step::Int
)::Int
    num_of_people_infected = 0
    for agent in agents
        if agent.virus_id != 0 && !agent.is_newly_infected
            if agent.days_infected == agent.infection_period
                if agent.virus_id == 1
                    agent.FluA_immunity = true
                elseif agent.virus_id == 2
                    agent.FluB_immunity = true
                elseif agent.virus_id == 3
                    agent.RV_days_immune = 1
                elseif agent.virus_id == 4
                    agent.RSV_days_immune = 1
                elseif agent.virus_id == 5
                    agent.AdV_days_immune = 1
                elseif agent.virus_id == 6
                    agent.PIV_days_immune = 1
                else
                    agent.CoV_immunity = true
                end
                agent.days_immune = 1
                agent.virus_id = 0
                agent.is_isolated = false

                if agent.supporter_id != 0
                    is_support_still_needed = false
                    for dependant_id in agents[agent.supporter_id].dependant_ids
                        dependant = agents[dependant_id]
                        if dependant.virus_id != 0 && !dependant.is_asymptomatic && (dependant.collective_id == 0 || dependant.is_isolated)
                            is_support_still_needed = true
                        end
                    end
                    if !is_support_still_needed
                        agents[agent.supporter_id].on_parent_leave = false
                    end
                end
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
                    if agent.is_isolated
                        confirmed_daily_new_cases_viruses[current_step, agent.virus_id, thread_id] += 1
                        if agent.age < 3
                            confirmed_daily_new_cases_age_groups[current_step, 1, thread_id] += 1
                        elseif agent.age < 7
                            confirmed_daily_new_cases_age_groups[current_step, 2, thread_id] += 1
                        elseif agent.age < 15
                            confirmed_daily_new_cases_age_groups[current_step, 3, thread_id] += 1
                        else
                            confirmed_daily_new_cases_age_groups[current_step, 4, thread_id] += 1
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
        elseif agent.is_newly_infected
            num_of_people_infected += 1
            agent.is_newly_infected = false
            agent.days_immune = 1
        end
    end
    return num_of_people_infected
end

function run_r0_simulation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    agents::Vector{Agent},
    infectivities::Array{Float64, 4},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    etiology::Matrix{Float64}
)::Int
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    num_viruses = 7

    agent_infected = true
    num_of_people_infected = 0

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

        simulate_contacts(
            agents,
            temp_influences,
            duration_parameter,
            susceptibility_parameters,
            etiology,
            is_holiday,
            is_kindergarten_holiday,
            is_school_holiday,
            is_university_holiday,
            is_work_holiday,
            week_num,
            current_step,
            infected_inside_collective)
        
        num_of_people_infected += update_agent_states(
            agents,
            infectivities,
            current_step)

        # Обновление даты
        if week_day == 7
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

    return num_of_people_infected
end