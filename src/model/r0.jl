function make_contact_r0(
    infected_agent::Agent,
    susceptible_agent::Agent,
    contact_duration::Float64,
    current_step::Int,
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temp_influences::Array{Float64, 2},
    num_people_infected::Vector{Int},
    infected_agent_ids::Vector{Int},
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
        num_people_infected[1] += 1
        push!(infected_agent_ids, susceptible_agent.id)
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
    num_people_infected::Vector{Int},
    infected_agent_ids::Vector{Int},
    rng::MersenneTwister,
)
    agent = agents[infected_agent_id]
    if agent.infectivity > 0.0001
        for agent2_id in agent.household_conn_ids
            agent2 = agents[agent2_id]
            # Проверка восприимчивости агента к вирусу
            if !(agent2.id in infected_agent_ids)

                agent_at_home = agent.is_isolated || agent.collective_id == 0 ||
                    (agent.collective_id == 4 && is_work_holiday) || (agent.collective_id == 3 && is_university_holiday) ||
                    (agent.collective_id == 2 && is_school_holiday) || (agent.collective_id == 1 && is_kindergarten_holiday)
                agent2_at_home = agent2.collective_id == 0 ||
                    (agent2.collective_id == 4 && is_work_holiday) || (agent2.collective_id == 3 && is_university_holiday) ||
                    (agent2.collective_id == 2 && is_school_holiday) || (agent2.collective_id == 1 && is_kindergarten_holiday)

                if is_holiday || (agent_at_home && agent2_at_home)
                    make_contact_r0(
                        agent, agent2, get_contact_duration_normal(12.5, 5.5, rng),
                        current_step, duration_parameter, susceptibility_parameters, temp_influences,
                        num_people_infected, infected_agent_ids, rng)
                elseif ((agent.collective_id == 4 && !agent_at_home) ||
                    (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday
                    make_contact_r0(
                        agent, agent2, get_contact_duration_normal(4.5, 2.0, rng),
                        current_step, duration_parameter, susceptibility_parameters, temp_influences,
                        num_people_infected, infected_agent_ids, rng)
                elseif ((agent.collective_id == 2 && !agent_at_home) ||
                    (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday
                    make_contact_r0(
                        agent, agent2, get_contact_duration_normal(5.86, 2.65, rng),
                        current_step, duration_parameter, susceptibility_parameters, temp_influences,
                        num_people_infected, infected_agent_ids, rng)
                elseif ((agent.collective_id == 1 && !agent_at_home) ||
                    (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday
                    make_contact_r0(
                        agent, agent2, get_contact_duration_normal(6.5, 2.46, rng),
                        current_step, duration_parameter, susceptibility_parameters, temp_influences,
                        num_people_infected, infected_agent_ids, rng)
                elseif ((agent.collective_id == 3 && !agent_at_home) ||
                    (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday
                    make_contact_r0(
                        agent, agent2, get_contact_duration_normal(10.0, 3.69, rng),
                        current_step, duration_parameter, susceptibility_parameters, temp_influences,
                        num_people_infected, infected_agent_ids, rng)
                end
            end
        end
        if !is_holiday && agent.group_num != 0 && !agent.is_isolated &&
            ((agent.collective_id == 1 && !is_kindergarten_holiday) ||
                (agent.collective_id == 2 && !is_school_holiday) ||
                (agent.collective_id == 3 && !is_university_holiday) ||
                (agent.collective_id == 4 && !is_work_holiday))
            for agent2_id in agent.collective_conn_ids
                agent2 = agents[agent2_id]
                if !(agent2.id in infected_agent_ids)
                    if agent.collective_id == 1
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(4.5, 2.66, rng),
                            current_step, duration_parameter,
                            susceptibility_parameters, temp_influences,
                            num_people_infected, infected_agent_ids, rng)
                    elseif agent.collective_id == 2
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(3.783, 2.67, rng),
                            current_step, duration_parameter,
                            susceptibility_parameters, temp_influences,
                            num_people_infected, infected_agent_ids, rng)
                    elseif agent.collective_id == 3
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(2.5, 1.62, rng),
                            current_step, duration_parameter,
                            susceptibility_parameters, temp_influences,
                            num_people_infected, infected_agent_ids, rng)
                    else
                        make_contact_r0(
                            agent, agent2, get_contact_duration_normal(3.07, 2.5, rng),
                            current_step, duration_parameter,
                            susceptibility_parameters, temp_influences,
                            num_people_infected, infected_agent_ids, rng)
                    end
                end
            end

            if agent.collective_id == 3
                for agent2_id in agent.collective_cross_conn_ids
                    agent2 = agents[agent2_id]
                    if !(agent2.id in infected_agent_ids)
                        make_contact_r0(
                            agent, agent2, get_contact_duration_gamma(1.0, 1.6, rng),
                            current_step, duration_parameter,
                            susceptibility_parameters, temp_influences,
                            num_people_infected, infected_agent_ids, rng)
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
    rng::MersenneTwister,
)::Bool
    agent = agents[infected_agent_id]
    if agent.days_infected == agent.infection_period
        agent.virus_id = 0
        agent.is_isolated = false
        return false
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
        end
        
        agent.infectivity = find_agent_infectivity(
            agent.age,
            infectivities[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
            agent.is_asymptomatic && agent.days_infected > 0)
    end
    return true
end

# Without parent leave to be truly parallel
function run_simulation_r0(
    month_num::Int,
    infected_agent_id::Int,
    agents::Vector{Agent},
    infectivities::Array{Float64, 4},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    rng::MersenneTwister,
)::Int
    # Месяц
    month = month_num

    infected_agent_ids = Int[]

    current_step = 0
    if month == 9
        current_step = 31
    elseif month == 10
        current_step = 61
    elseif month == 11
        current_step = 92
    elseif month == 12
        current_step = 122
    elseif month == 1
        current_step = 153
    elseif month == 2
        current_step = 184
    elseif month == 3
        current_step = 212
    elseif month == 4
        current_step = 243
    elseif month == 5
        current_step = 273
    elseif month == 6
        current_step = 304
    elseif month == 7
        current_step = 334
    end


    # День месяца
    day = 1
    if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12
        day = rand(rng, 1:31)
    elseif month == 4 || month == 6 || month == 9 || month == 11
        day = rand(rng, 1:30)
    else
        day = rand(rng, 1:28)
    end

    current_step += day

    # День недели
    week_day = rand(rng, 1:7)

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
            num_people_infected,
            infected_agent_ids,
            rng)
        
        agent_infected = update_agent_states_r0(
            infected_agent_id,
            agents,
            infectivities,
            rng)

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