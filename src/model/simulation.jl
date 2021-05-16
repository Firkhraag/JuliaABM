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

    if rand(Float64) < infection_probability
        # println("Virus: $(infected_agent.virus_id); Dur: $duration_influence; Temp: $temperature_influence; Susc: $susceptibility_influence; Inf: $infectivity_influence; Prob: $infection_probability")
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
        if !agent.FluA_immunity
            agent.virus_id = viruses[1].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 2]
        if !agent.FluB_immunity
            agent.virus_id = viruses[2].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 3]
        if agent.RV_days_immune == 0
            agent.virus_id = viruses[3].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 4]
        if agent.RSV_days_immune == 0
            agent.virus_id = viruses[4].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 5]
        if agent.AdV_days_immune == 0
            agent.virus_id = viruses[5].id
            agent.is_newly_infected = true
        end
    elseif rand_num < etiology[week_num, 6]
        if agent.PIV_days_immune == 0
            agent.virus_id = viruses[6].id
            agent.is_newly_infected = true
        end
    else
        if !agent.CoV_immunity
            agent.virus_id = viruses[7].id
            agent.is_newly_infected = true
        end
    end
end

function simulate_contacts(
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    viruses::Vector{Virus},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    etiology::Matrix{Float64},
    is_holiday::Bool,
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    week_num::Int,
    current_step
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        if agent.virus_id != 0 && !agent.is_newly_infected && agent.viral_load > 0.0001
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
                                make_contact(
                                    agent, agent2, get_contact_duration(5.88, 2.52),
                                    current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences)
                            elseif agent.collective_id == 2
                                make_contact(
                                    agent, agent2, get_contact_duration(4.783, 2.67),
                                    current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences)
                            elseif agent.collective_id == 3
                                make_contact(
                                    agent, agent2, get_contact_duration(2.1, 3.0),
                                    current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences)
                            else
                                make_contact(
                                    agent, agent2, get_contact_duration(3.0, 3.0),
                                    current_step, duration_parameter,
                                    susceptibility_parameters, temp_influences)
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
end

function update_agent_states(
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    current_step::Int,
    daily_new_cases_viruses::Matrix{Int},
    confirmed_daily_new_cases_viruses::Matrix{Int}
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        if agent.days_immune != 0
            if agent.days_immune == 14
                # Переход из резистентного состояния в восприимчивое
                agent.days_immune = 0
            else
                agent.days_immune += 1
            end
        end

        # Продолжительности типоспецифического иммунитета
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

                if !agent.is_asymptomatic && !agent.is_isolated && agent.collective_id != 0 && !agent.on_parent_leave
                    if agent.days_infected == 1
                        rand_num = rand(Float64)
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
                        rand_num = rand(Float64)
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
                        rand_num = rand(Float64)
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
                        confirmed_daily_new_cases_viruses[agent.virus_id, current_step] += 1
                    end
                end
                
                agent.viral_load = find_agent_viral_load(
                    agent.age,
                    viral_loads[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                    agent.is_asymptomatic && agent.days_infected > 0)

                if agent.supporter_id != 0 && !agent.is_asymptomatic && agent.days_infected > 0 && (agent.is_isolated || agent.collective_id == 0)
                    agents[agent.supporter_id].on_parent_leave = true
                end
            end
        elseif agent.is_newly_infected
            daily_new_cases_viruses[agent.virus_id, current_step] += 1

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
end

function run_simulation(
    num_threads::Int,
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    agents::Vector{Agent},
    viruses::Vector{Virus},
    viral_loads::Array{Float64, 4},
    temp_influences::Array{Float64, 2},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    etiology::Matrix{Float64}
)
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    # incidence = Array{Int, 1}(undef, 52)
    # etiology_incidence = Array{Int, 2}(undef, 7, 52)
    # age_groups_incidence = Array{Int, 2}(undef, 4, 52)
    incidence = zeros(Int, 52)
    etiology_incidence = zeros(Int, 7, 52)
    age_groups_incidence = zeros(Int, 4, 52)

    daily_new_cases_viruses = zeros(Int, 7, 365)
    confirmed_daily_new_cases_viruses = zeros(Int, 7, 365)

    # DEBUG
    max_step = 365
    # max_step = 100

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
        elseif month == 11 && (day >= 5 && day <= 11)
            is_school_holiday = true
        elseif month == 12 && (day >= 28 && day <= 31)
            is_school_holiday = true
        elseif month == 1 && (day >= 1 && day <= 9)
            is_school_holiday = true
        elseif month == 3 && (day >= 22 && day <= 31)
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

        @threads for thread_id in 1:num_threads
            simulate_contacts(
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                viruses,
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
                current_step)
        end
        
        @threads for thread_id in 1:num_threads
            update_agent_states(
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                viruses,
                viral_loads,
                current_step,
                daily_new_cases_viruses,
                confirmed_daily_new_cases_viruses)
        end

        # Обновление даты
        if week_day == 7

            incidence[week_num] = sum(confirmed_daily_new_cases_viruses[:, current_step - 6:current_step])
            for i = 1:7
                etiology_incidence[i, week_num] = sum(confirmed_daily_new_cases_viruses[i, current_step - 6:current_step])
            end
            # for i = 1:size(age_groups_weekly_new_infections_num, 1)
            #     age_groups_incidence[i, week_num] = age_groups_weekly_new_infections_num[i]
            #     age_groups_weekly_new_infections_num[i] = 0
            # end

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
            println("Month: ", month)
        elseif (month == 12 && day == 31)
            day = 1
            month = 1
            println("Month: 1")
        else
            day += 1
        end
    end
    multiplier = 1000 / size(agents, 1)

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "incidence_data.csv"), incidence .* multiplier, ',')
    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "etiology_data.csv"), etiology_incidence .* multiplier, ',')
    # writedlm(
    #     joinpath(@__DIR__, "..", "..", "output", "tables", "age_groups_data.csv"), age_groups_data .* multiplier, ',')
    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "daily_new_cases_viruses_data.csv"), daily_new_cases_viruses, ',')
end
