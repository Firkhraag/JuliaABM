function get_contact_duration(mean::Float64, sd::Float64)
    return rand(truncated(Normal(mean, sd), 0.0, Inf))
end

function get_contact_duration_gamma(shape::Float64, scale::Float64)
    return rand(Gamma(shape, scale))
end

function make_contact(
    infected_agent::Agent,
    susceptible_agent::Agent,
    contact_duration::Float64,
    current_step::Int,
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temp_influences::Array{Float64, 2}
)
    # Влияние продолжительности контакта на вероятность инфицирования
    duration_influence = 1 / (1 + exp(-contact_duration + duration_parameter))
            
    # Влияние температуры воздуха на вероятность инфицирования
    temperature_influence = temp_influences[infected_agent.virus_id, current_step]

    # Влияние восприимчивости агента на вероятность инфицирования
    susceptibility_influence = 2 / (1 + exp(susceptibility_parameters[infected_agent.virus_id] * susceptible_agent.ig_level))

    # Влияние силы инфекции на вероятность инфицирования
    infectivity_influence = infected_agent.viral_load

    # Вероятность инфицирования
    infection_probability = infectivity_influence * susceptibility_influence *
        temperature_influence * duration_influence

    rand_num = rand(Float64)

    # println("Virus: $(infected_agent.virus_id); Dur: $duration_influence; Temp: $temperature_influence; Susc: $susceptibility_influence; Inf: $infectivity_influence; Prob: $infection_probability")

    if rand_num < infection_probability
        susceptible_agent.virus_id = infected_agent.virus_id
        susceptible_agent.is_newly_infected = true
    end
end

function infect_randomly(
    viruses::Vector{Virus},
    agent::Agent,
    week_num::Int,
    etiology::Matrix{Float64},
)
    rand_num = rand(Float64)
    if rand_num < etiology[week_num, 1]
        if agent.immunity_days[1] == 0
            agent.virus_id = viruses[1].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 2]
        if agent.immunity_days[2] == 0
            agent.virus_id = viruses[2].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 3]
        if agent.immunity_days[3] == 0
            agent.virus_id = viruses[3].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 4]
        if agent.immunity_days[4] == 0
            agent.virus_id = viruses[4].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 5]
        if agent.immunity_days[5] == 0
            agent.virus_id = viruses[5].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 6]
        if agent.immunity_days[6] == 0
            agent.virus_id = viruses[6].id
            agent.is_newly_infected = true
        end
    else
        if agent.immunity_days[7] == 0
            agent.virus_id = viruses[7].id
            agent.is_newly_infected = true
        end
    end
end

function run_simulation(
    comm_rank::Int,
    comm::MPI.Comm,
    all_agents::Vector{Agent},
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    collectives::Vector{Collective},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    immunity_durations::Vector{Int},
    etiology::Matrix{Float64},
    for_compilation::Bool
)
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    # DEBUG
    max_step = 365

    incidence = Array{Int, 1}(undef, 52)
    etiology_incidence = Array{Int, 2}(undef, 7, 52)
    age_groups_incidence = Array{Int, 2}(undef, 4, 52)

    weekly_new_infections_num = 0
    etiology_weekly_new_infections_num = Int[0, 0, 0, 0, 0, 0, 0]
    age_groups_weekly_new_infections_num = Int[0, 0, 0, 0]

    new_infections_num = zeros(Int, 365)

    daily_new_cases_age_groups = zeros(Int, 7, 365)
    daily_new_recoveries_age_groups = zeros(Int, 7, 365)

    daily_new_cases_viruses_asymptomatic = zeros(Int, 7, 365)
    daily_new_cases_viruses = zeros(Int, 7, 365)
    daily_new_recoveries_viruses = zeros(Int, 7, 365)

    daily_new_cases_collectives = zeros(Int, 4, 365)
    daily_new_recoveries_collectives = zeros(Int, 4, 365)

    immunity_viruses = zeros(Int, 7, 365)

    infected_inside_collective = zeros(Int, 5, 365)

    for current_step = 1:max_step

        if comm_rank == 0
            println("Step: $current_step")
        end

        # Выходные, праздники
        is_holiday = false
        if (week_day == 7)
            is_holiday = true
        elseif (month == 1 && (day == 1 || day == 2 || day == 3 || day == 7))
            is_holiday = true
        elseif (month == 5 && (day == 1 || day == 9))
            is_holiday = true
        elseif (month == 2 && day == 23)
            is_holiday = true
        elseif (month == 3 && day == 8)
            is_holiday = true
        elseif (month == 6 && day == 12)
            is_holiday = true
        end

        is_work_holiday = false
        if (week_day == 6)
            is_work_holiday = true
        end

        is_kindergarten_holiday = is_work_holiday
        if (month == 7 || month == 8)
            is_kindergarten_holiday = true
        end

        # Каникулы
        # Летние - 01.06.yyyy - 31.08.yyyy
        # Осенние - 05.11.yyyy - 11.11.yyyy
        # Зимние - 28.12.yyyy - 09.03.yyyy
        # Весенние - 22.03.yyyy - 31.03.yyyy
        is_school_holiday = false
        if (month == 6 || month == 7 || month == 8)
            is_school_holiday = true
        elseif (month == 11 && (day >= 5 && day <= 11))
            is_school_holiday = true
        elseif (month == 12 && (day >= 28 && day <= 31))
            is_school_holiday = true
        elseif (month == 1 && (day >= 1 && day <= 9))
            is_school_holiday = true
        elseif (month == 3 && (day >= 22 && day <= 31))
            is_school_holiday = true
        end

        is_university_holiday = false
        if (month == 7 || month == 8)
            is_university_holiday = true
        elseif (month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27)
            is_university_holiday = true
        elseif (month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27)
            is_university_holiday = true
        elseif ((month == 2) && (day >= 1 && day <= 10))
            is_university_holiday = true
        elseif (month == 12 && (day >= 22 && day <= 31))
            is_university_holiday = true
        end
        
        for agent in all_agents
            if agent.virus_id != 0 && !agent.is_newly_infected && agent.viral_load > 0.0001
                for agent2_id in agent.household.agent_ids
                    agent2 = all_agents[agent2_id]
                    # Проверка восприимчивости агента к вирусу
                    if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                            agent2.immunity_days[agent.virus_id] == 0
                        agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.collective_id == 0
                        agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.collective_id == 0
                        # if is_holiday || (agent_at_home && agent2_at_home)
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(12.5, 5.5),
                        #         current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        # elseif ((agent.collective_id == 4 && !agent_at_home) ||
                        #     (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(4.5, 2.25),
                        #         current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        # elseif ((agent.collective_id == 2 && !agent_at_home) ||
                        #     (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(6.1, 2.46),
                        #         current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        # elseif ((agent.collective_id == 1 && !agent_at_home) ||
                        #     (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(7.0, 2.65),
                        #         current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        # elseif ((agent.collective_id == 3 && !agent_at_home) ||
                        #     (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday
                        #     make_contact(
                        #         agent, agent2, get_contact_duration(10.0, 3.69),
                        #         current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        # end

                        if is_holiday || (agent_at_home && agent2_at_home)
                            make_contact(
                                agent, agent2, get_contact_duration(12.5, 5.5),
                                current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        elseif ((agent.collective_id == 1 && !agent_at_home) ||
                            (agent2.collective_id == 1 && !agent2_at_home)) && !is_kindergarten_holiday
                            make_contact(
                                agent, agent2, get_contact_duration(5.0, 2.05),
                                current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        elseif ((agent.collective_id == 4 && !agent_at_home) ||
                            (agent2.collective_id == 4 && !agent2_at_home)) && !is_work_holiday
                            make_contact(
                                agent, agent2, get_contact_duration(5.5, 2.25),
                                current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        elseif ((agent.collective_id == 2 && !agent_at_home) ||
                            (agent2.collective_id == 2 && !agent2_at_home)) && !is_school_holiday
                            make_contact(
                                agent, agent2, get_contact_duration(6.0, 2.46),
                                current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        elseif ((agent.collective_id == 3 && !agent_at_home) ||
                            (agent2.collective_id == 3 && !agent2_at_home)) && !is_university_holiday
                            make_contact(
                                agent, agent2, get_contact_duration(7.0, 3.69),
                                current_step, duration_parameter, susceptibility_parameters, temp_influences)
                        end
                        if agent2.virus_id != 0
                            infected_inside_collective[5, current_step] += 1
                        end
                    end
                end
                if !is_holiday && agent.group_num != 0 && !agent.is_isolated && !agent.on_parent_leave &&
                    ((agent.collective_id == 1 && !is_kindergarten_holiday) ||
                        (agent.collective_id == 2 && !is_school_holiday) ||
                        (agent.collective_id == 3 && !is_university_holiday) ||
                        (agent.collective_id == 4 && !is_work_holiday))
                    if agent.collective_id == 4
                        for agent2_id in agent.work_conn_ids
                            agent2 = all_agents[agent2_id]
                            # Проверка восприимчивости агента к вирусу
                            if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                                    agent2.immunity_days[agent.virus_id] == 0 &&
                                        !agent2.is_isolated && !agent2.on_parent_leave
                                    make_contact(
                                        agent, agent2, get_contact_duration(
                                            collectives[4].mean_time_spent,
                                            collectives[4].time_spent_sd),
                                        current_step, duration_parameter,
                                        susceptibility_parameters, temp_influences)
                                    if agent2.virus_id != 0
                                        infected_inside_collective[agent.collective_id, current_step] += 1
                                    end
                            end
                        end
                    else
                        if agent.collective_id != 2|| agent.group_num != 1 || !is_work_holiday
                            group = collectives[agent.collective_id].groups[agent.group_num][agent.group_id]
                            for agent2_id in group.agent_ids
                                agent2 = all_agents[agent2_id]
                                # Проверка восприимчивости агента к вирусу
                                if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                                        agent2.immunity_days[agent.virus_id] == 0 &&
                                            !agent2.is_isolated && !agent2.on_parent_leave
                                        make_contact(
                                            agent, agent2, get_contact_duration(
                                                collectives[agent.collective_id].mean_time_spent,
                                                collectives[agent.collective_id].time_spent_sd),
                                            current_step, duration_parameter,
                                            susceptibility_parameters, temp_influences)
                                    if agent2.virus_id != 0
                                        infected_inside_collective[agent.collective_id, current_step] += 1
                                    end
                                end
                            end
                        end
                    end
                end
            elseif agent.virus_id == 0 && agent.days_immune == 0
                if agent.age < 16
                    if rand(Float64) < 0.0002
                        infect_randomly(viruses, agent, week_num, etiology)
                    end
                else
                    if rand(Float64) < 0.0001
                        infect_randomly(viruses, agent, week_num, etiology)
                    end
                end
            end
        end

        # new_infections_num = 0
        for agent in all_agents
            if agent.days_immune != 0
                if agent.days_immune == 14
                    # Переход из резистентного состояния в восприимчивое
                    agent.days_immune = 0
                else
                    agent.days_immune += 1
                end
            end
            for k = 1:size(agent.immunity_days, 1)
                immunity_days = agent.immunity_days[k]
                if immunity_days > 0
                    if immunity_days == immunity_durations[k]
                        agent.immunity_days[k] = 0
                    else
                        agent.immunity_days[k] += 1
                        immunity_viruses[k, current_step] += 1
                    end
                end
            end

            if agent.virus_id != 0 && !agent.is_newly_infected
                if agent.days_infected == agent.infection_period

                    daily_new_recoveries_viruses[agent.virus_id, current_step] += 1
                    if agent.age < 3
                        daily_new_recoveries_age_groups[1, current_step] += 1
                    elseif agent.age < 7
                        daily_new_recoveries_age_groups[2, current_step] += 1
                    elseif agent.age < 15
                        daily_new_recoveries_age_groups[3, current_step] += 1
                    elseif agent.age < 18
                        daily_new_recoveries_age_groups[4, current_step] += 1
                    elseif agent.age < 25
                        daily_new_recoveries_age_groups[5, current_step] += 1
                    elseif agent.age < 65
                        daily_new_recoveries_age_groups[6, current_step] += 1
                    else
                        daily_new_recoveries_age_groups[7, current_step] += 1
                    end
                    if agent.collective_id != 0
                        daily_new_recoveries_collectives[agent.collective_id, current_step] += 1
                    end

                    agent.immunity_days[agent.virus_id] = 1
                    agent.days_immune = 1
                    agent.virus_id = 0
                    agent.is_isolated = false
    
                    if agent.supporter_id != 0
                        is_support_still_needed = false
                        for dependant_id in all_agents[agent.supporter_id].dependant_ids
                            dependant = all_agents[dependant_id]
                            if dependant.virus_id != 0 && !dependant.is_asymptomatic && (dependant.collective_id == 0 || dependant.is_isolated)
                                is_support_still_needed = true
                            end
                        end
                        if !is_support_still_needed
                            all_agents[agent.supporter_id].on_parent_leave = false
                        end
                    end
                else
                    agent.days_infected += 1
    
                    if !agent.is_asymptomatic && !agent.is_isolated && agent.collective_id != 0 && !agent.on_parent_leave
                        if agent.days_infected == 1
                            rand_num = rand(Float64)
                            if agent.age < 8
                                if rand_num < 0.305
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    else
                                        age_groups_weekly_new_infections_num[3] += 1
                                    end
                                end
                            elseif agent.age < 18
                                if rand_num < 0.204
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            else
                                if rand_num < 0.101
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            end
                        elseif agent.days_infected == 2
                            rand_num = rand(Float64)
                            if agent.age < 8
                                if rand_num < 0.576
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            elseif agent.age < 18
                                if rand_num < 0.499
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            else
                                if rand_num < 0.334
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            end
                        elseif agent.days_infected == 3
                            rand_num = rand(Float64)
                            if agent.age < 8
                                if rand_num < 0.325
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            elseif agent.age < 18
                                if rand_num < 0.376
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            else
                                if rand_num < 0.168
                                    agent.is_isolated = true
                                    new_infections_num[current_step] += 1
                                    etiology_weekly_new_infections_num[agent.virus_id] += 1
                                    if agent.age < 3
                                        age_groups_weekly_new_infections_num[1] += 1
                                    elseif agent.age < 7
                                        age_groups_weekly_new_infections_num[2] += 1
                                    elseif agent.age < 15
                                        age_groups_weekly_new_infections_num[3] += 1
                                    else
                                        age_groups_weekly_new_infections_num[4] += 1
                                    end
                                end
                            end
                        end
                    end
                    
                    agent.viral_load = find_agent_viral_load(
                        agent.age,
                        viral_loads[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                        agent.is_asymptomatic && agent.days_infected > 0)
    
                    if agent.supporter_id != 0 && !agent.is_asymptomatic && agent.days_infected > 0 && (agent.is_isolated || agent.collective_id == 0)
                        all_agents[agent.supporter_id].on_parent_leave = true
                    end
                end
            elseif agent.is_newly_infected

                daily_new_cases_viruses[agent.virus_id, current_step] += 1
                if agent.age < 3
                    daily_new_cases_age_groups[1, current_step] += 1
                elseif agent.age < 7
                    daily_new_cases_age_groups[2, current_step] += 1
                elseif agent.age < 15
                    daily_new_cases_age_groups[3, current_step] += 1
                elseif agent.age < 18
                    daily_new_cases_age_groups[4, current_step] += 1
                elseif agent.age < 25
                    daily_new_cases_age_groups[5, current_step] += 1
                elseif agent.age < 65
                    daily_new_cases_age_groups[6, current_step] += 1
                else
                    daily_new_cases_age_groups[7, current_step] += 1
                end
                if agent.collective_id != 0
                    daily_new_cases_collectives[agent.collective_id, current_step] += 1
                end

                agent.incubation_period = get_period_from_erlang(
                    viruses[agent.virus_id].mean_incubation_period,
                    viruses[agent.virus_id].incubation_period_variance,
                    viruses[agent.virus_id].min_incubation_period,
                    viruses[agent.virus_id].max_incubation_period)
                if agent.age < 16
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_child,
                        viruses[agent.virus_id].infection_period_variance_child,
                        viruses[agent.virus_id].min_infection_period_child,
                        viruses[agent.virus_id].max_infection_period_child)
                else
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_adult,
                        viruses[agent.virus_id].infection_period_variance_adult,
                        viruses[agent.virus_id].min_infection_period_adult,
                        viruses[agent.virus_id].max_infection_period_adult)
                end
                agent.days_infected = 1 - agent.incubation_period
                if rand(Float64) < viruses[agent.virus_id].asymptomatic_probab
                    daily_new_cases_viruses_asymptomatic[agent.virus_id, current_step] += 1
                    agent.is_asymptomatic = true
                else
                    agent.is_asymptomatic = false
                end
                agent.viral_load = find_agent_viral_load(
                    agent.age,
                    viral_loads[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                    agent.is_asymptomatic && agent.days_infected > 0)
                agent.is_newly_infected = false
            end
        end

        weekly_new_infections_num += new_infections_num[current_step]

        # Обновление даты
        if week_day == 7
            incidence[week_num] = weekly_new_infections_num
            weekly_new_infections_num = 0
            for i = 1:size(etiology_weekly_new_infections_num, 1)
                etiology_incidence[i, week_num] = etiology_weekly_new_infections_num[i]
                etiology_weekly_new_infections_num[i] = 0
            end
            for i = 1:size(age_groups_weekly_new_infections_num, 1)
                age_groups_incidence[i, week_num] = age_groups_weekly_new_infections_num[i]
                age_groups_weekly_new_infections_num[i] = 0
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

        if (month in Int[1, 3, 5, 7, 8, 10] && day == 31) ||
            (month in Int[4, 6, 9, 11] && day == 30) ||
            (month == 2 && day == 28)
            day = 1
            month += 1
            if comm_rank == 0 && !for_compilation
                println("Month: $month")
            end
        elseif (month == 12 && day == 31)
            day = 1
            month = 1
            if comm_rank == 0 && !for_compilation
                println("Month: 1")
            end
        else
            day += 1
        end
    end

    num_of_agents = MPI.Allreduce(size(all_agents, 1), MPI.SUM, comm)
    multiplier = 1000 / num_of_agents
    incidence_data = MPI.Reduce(incidence, MPI.SUM, 0, comm)
    etiology_data = MPI.Reduce(etiology_incidence, MPI.SUM, 0, comm)
    age_groups_data = MPI.Reduce(age_groups_incidence, MPI.SUM, 0, comm)

    daily_new_cases_age_groups_data = MPI.Reduce(daily_new_cases_age_groups, MPI.SUM, 0, comm)
    daily_new_recoveries_age_groups_data = MPI.Reduce(daily_new_recoveries_age_groups, MPI.SUM, 0, comm)

    daily_new_cases_viruses_asymptomatic_data = MPI.Reduce(daily_new_cases_viruses_asymptomatic, MPI.SUM, 0, comm)
    daily_new_cases_viruses_data = MPI.Reduce(daily_new_cases_viruses, MPI.SUM, 0, comm)
    daily_new_recoveries_viruses_data = MPI.Reduce(daily_new_recoveries_viruses, MPI.SUM, 0, comm)

    daily_new_cases_collectives_data = MPI.Reduce(daily_new_cases_collectives, MPI.SUM, 0, comm)
    daily_new_recoveries_collectives_data = MPI.Reduce(daily_new_recoveries_collectives, MPI.SUM, 0, comm)

    immunity_viruses_data = MPI.Reduce(immunity_viruses, MPI.SUM, 0, comm)
    infected_inside_collective_data = MPI.Reduce(infected_inside_collective, MPI.SUM, 0, comm)

    if comm_rank == 0 && !for_compilation
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "incidence_data.csv"), incidence_data .* multiplier, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "etiology_data.csv"), etiology_data .* multiplier, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "age_groups_data.csv"), age_groups_data .* multiplier, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_age_groups_data.csv"), daily_new_cases_age_groups_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_age_groups_data.csv"), daily_new_recoveries_age_groups_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_asymptomatic_data.csv"), daily_new_cases_viruses_asymptomatic_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_data.csv"), daily_new_cases_viruses_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_viruses_data.csv"), daily_new_recoveries_viruses_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_collectives_data.csv"), daily_new_cases_collectives_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_recoveries_collectives_data.csv"), daily_new_recoveries_collectives_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "immunity_viruses_data.csv"), immunity_viruses_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "infected_inside_collective_data.csv"), infected_inside_collective_data, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "registered_new_cases_data.csv"), new_infections_num, ',')
    end
end
