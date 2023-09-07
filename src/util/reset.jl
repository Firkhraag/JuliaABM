function reset_agent_states(
    agents::Vector{Agent},
    start_agent_id::Int,
    end_agent_id::Int,
    viruses::Vector{Virus},
    num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    rng::MersenneTwister,
    immune_memory_susceptibility_levels::Vector{Float64},
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
        agent.viruses_days_immune = zeros(Int, num_viruses)
        agent.viruses_immunity_end = zeros(Int, num_viruses)
        agent.viruses_immunity_susceptibility_levels = zeros(Float64, num_viruses) .+ 1.0

        for i = 1:num_viruses
            if agent.virus_id != i
                for week_num = 1:51
                    if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, i, age_group] / num_agents_age_groups[age_group]
                        agent.viruses_immunity_end[i] = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                        agent.viruses_days_immune = 365 - week_num * 7 + 1
                        if agent.viruses_days_immune[i] > agent.viruses_immunity_end[i]
                            agent.viruses_immunity_end[i] = 0
                            agent.viruses_days_immune[i] = 0
                            agent.immunity_susceptibility_levels[i] = immune_memory_susceptibility_levels[i]
                        else
                            agent.immunity_susceptibility_levels[i] = find_immunity_susceptibility_level(agent.viruses_days_immune[i], agent.viruses_immunity_end[i], immune_memory_susceptibility_levels[i])
                        end
                    end
                end
            end
        end

        if is_infected
            # Инкубационный период
            agent.incubation_period = get_period_from_erlang(
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

            # Дней с момента инфицирования
            agent.days_infected = rand(rng, (1 - agent.incubation_period):agent.infection_period)

            rand_num = rand(rng, Float64)
            if agent.age < 10
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_child
            elseif agent.age < 18
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_teenager
            else
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_adult
            end

            if !agent.is_asymptomatic
                # Самоизоляция
                if agent.days_infected >= 1
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
                if agent.days_infected >= 2 && !agent.is_isolated
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
                if agent.days_infected >= 3 && !agent.is_isolated
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

        agent.attendance = true
        if agent.activity_type == 3 && !agent.is_teacher && rand(rng, Float64) < skip_college_probability
            agent.attendance = false
        end
        agent.days_immune = 0
        agent.days_immune_end = 0
        agent.num_infected_agents = 0
        agent.quarantine_period = 0
    end
end
