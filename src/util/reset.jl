function reset_agent_states(
    # Агенты
    agents::Vector{Agent},
    # Id первого агента для потока
    start_agent_id::Int,
    # Id последнего агента для потока
    end_agent_id::Int,
    # Вирусы
    viruses::Vector{Virus},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам
    num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Генератор случайных чисел
    rng::MersenneTwister,
)
    for agent_id in start_agent_id:end_agent_id
        agent = agents[agent_id]
        agent.on_parent_leave = false
        is_infected = false

        # Информация при болезни
        agent.virus_id = 0
        agent.incubation_period = 0
        agent.infection_period = 0
        agent.days_infected = 0
        agent.is_asymptomatic = false
        agent.is_isolated = false

        # Возрастная группа
        age_group = 4
        if agent.age < 3
            age_group = 1
        elseif agent.age < 7
            age_group = 2
        elseif agent.age < 15
            age_group = 3
        end

        # Инфицирование агентов перед началом работы модели
        v = rand(3:6)
        if rand(rng, Float64) < (num_all_infected_age_groups_viruses_mean[52, v, age_group] + num_all_infected_age_groups_viruses_mean[51, v, age_group] + num_all_infected_age_groups_viruses_mean[50, v, age_group]) / num_agents_age_groups[age_group]
            is_infected = true
            agent.virus_id = v
        end

        # Информация по иммунитету к вирусам
        for i = eachindex(agent.viruses_days_immune)
            agent.viruses_days_immune[i] = 0
        end
        for i = eachindex(agent.viruses_immunity_end)
            agent.viruses_immunity_end[i] = 0
        end

        for i = 1:num_viruses
            if agent.virus_id != i
                for week_num = 1:51
                    if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, i, age_group] / num_agents_age_groups[age_group]
                        agent.viruses_immunity_end[i] = trunc(Int, rand(rng, truncated(Normal(viruses[i].mean_immunity_duration, viruses[i].immunity_duration_sd), min_immunity_duration, max_immunity_duration)))
                        agent.viruses_days_immune[i] = 365 - week_num * 7 + 1
                        if agent.viruses_days_immune[i] > agent.viruses_immunity_end[i]
                            agent.viruses_immunity_end[i] = 0
                            agent.viruses_days_immune[i] = 0
                        end
                    end
                end
            end
        end

        if is_infected
            # Инкубационный период
            agent.incubation_period = round(Int, rand(rng, truncated(
                Gamma(viruses[agent.virus_id].incubation_period_shape, viruses[agent.virus_id].incubation_period_scale), min_incubation_period, max_incubation_period)))
            # Период болезни
            if agent.age < 16
                agent.infection_period = round(Int, rand(rng, truncated(
                    Gamma(viruses[agent.virus_id].infection_period_child_shape, viruses[agent.virus_id].infection_period_child_scale), min_infection_period, max_infection_period)))
            else
                agent.infection_period = round(Int, rand(rng, truncated(
                    Gamma(viruses[agent.virus_id].infection_period_adult_shape, viruses[agent.virus_id].infection_period_adult_scale), min_infection_period, max_infection_period)))
            end

            # Дней с момента инфицирования
            agent.days_infected = rand(rng, 1:(agent.incubation_period + agent.infection_period))

            # Бессимптомное течение болезни
            if agent.age < 10
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_child
            elseif agent.age < 18
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_teenager
            else
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_adult
            end

            # Если имеются симптомы
            if !agent.is_asymptomatic
                # Самоизоляция
                # 1-й день
                if agent.days_infected > agent.incubation_period
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
                end
                # 2-й день
                if agent.days_infected > agent.incubation_period + 1 && !agent.is_isolated
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
                end
                # 3-й день
                if agent.days_infected > agent.incubation_period + 2 && !agent.is_isolated
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
            end
        end

        # Посещение коллектива
        agent.attendance = true
        # Для вузов есть вероятность прогула
        if agent.activity_type == 3 && !agent.is_teacher && rand(rng, Float64) < skip_college_probability
            agent.attendance = false
        end
        # Значения по умолчанию
        agent.days_immune = 0
        agent.days_immune_end = 0
        agent.num_infected_agents = 0
    end
end
