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
    FluA_immune_memory_susceptibility_level::Float64,
    FluB_immune_memory_susceptibility_level::Float64,
    RV_immune_memory_susceptibility_level::Float64,
    RSV_immune_memory_susceptibility_level::Float64,
    AdV_immune_memory_susceptibility_level::Float64,
    PIV_immune_memory_susceptibility_level::Float64,
    CoV_immune_memory_susceptibility_level::Float64,
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

        age_group = 4
        if agent.age < 3
            age_group = 1
        elseif agent.age < 7
            age_group = 2
        elseif agent.age < 15
            age_group = 3
        end

        v = rand(3:6)
        if rand(rng, Float64) < (num_all_infected_age_groups_viruses_mean[52, v, age_group] + num_all_infected_age_groups_viruses_mean[51, v, age_group] + num_all_infected_age_groups_viruses_mean[50, v, age_group]) / num_agents_age_groups[age_group]
            is_infected = true
            agent.virus_id = v
        end

        # Набор дней после приобретения типоспецифического иммунитета
        agent.FluA_days_immune = 0
        agent.FluB_days_immune = 0
        agent.RV_days_immune = 0
        agent.RSV_days_immune = 0
        agent.AdV_days_immune = 0
        agent.PIV_days_immune = 0
        agent.CoV_days_immune = 0

        # Набор дней окончания типоспецифического иммунитета
        agent.FluA_immunity_end = 0
        agent.FluB_immunity_end = 0
        agent.RV_immunity_end = 0
        agent.RSV_immunity_end = 0
        agent.AdV_immunity_end = 0
        agent.PIV_immunity_end = 0
        agent.CoV_immunity_end = 0

        agent.FluA_immunity_susceptibility_level = 1.0
        agent.FluB_immunity_susceptibility_level = 1.0
        agent.RV_immunity_susceptibility_level = 1.0
        agent.RSV_immunity_susceptibility_level = 1.0
        agent.AdV_immunity_susceptibility_level = 1.0
        agent.PIV_immunity_susceptibility_level = 1.0
        agent.CoV_immunity_susceptibility_level = 1.0

        if agent.virus_id != 1
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 1, age_group] / num_agents_age_groups[age_group]
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    agent.FluA_days_immune = 365 - week_num * 7 + 1
                    if agent.FluA_days_immune > agent.FluA_immunity_end
                        agent.FluA_immunity_end = 0
                        agent.FluA_days_immune = 0
                        agent.FluA_immunity_susceptibility_level = FluA_immune_memory_susceptibility_level
                    else
                        agent.FluA_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.FluA_days_immune, agent.FluA_immunity_end, FluA_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if agent.virus_id != 2
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 2, age_group] / num_agents_age_groups[age_group]
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    agent.FluB_days_immune = 365 - week_num * 7 + 1
                    if agent.FluB_days_immune > agent.FluB_immunity_end
                        agent.FluB_immunity_end = 0
                        agent.FluB_days_immune = 0
                        agent.FluB_immunity_susceptibility_level = FluB_immune_memory_susceptibility_level
                    else
                        agent.FluB_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.FluB_days_immune, agent.FluB_immunity_end, FluB_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if agent.virus_id != 3
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 3, age_group] / num_agents_age_groups[age_group]
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    agent.RV_days_immune = 365 - week_num * 7 + 1
                    if agent.RV_days_immune > agent.RV_immunity_end
                        agent.RV_immunity_end = 0
                        agent.RV_days_immune = 0
                        agent.RV_immunity_susceptibility_level = RV_immune_memory_susceptibility_level
                    else
                        agent.RV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.RV_days_immune, agent.RV_immunity_end, RV_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if agent.virus_id != 4
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 4, age_group] / num_agents_age_groups[age_group]
                    agent.RSV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    agent.RSV_days_immune = 365 - week_num * 7 + 1
                    if agent.RSV_days_immune > agent.RSV_immunity_end
                        agent.RSV_immunity_end = 0
                        agent.RSV_days_immune = 0
                        agent.RSV_immunity_susceptibility_level = RSV_immune_memory_susceptibility_level
                    else
                        agent.RSV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.RSV_days_immune, agent.RSV_immunity_end, RSV_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if agent.virus_id != 5
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 5, age_group] / num_agents_age_groups[age_group]
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    agent.AdV_days_immune = 365 - week_num * 7 + 1
                    if agent.AdV_days_immune > agent.AdV_immunity_end
                        agent.AdV_immunity_end = 0
                        agent.AdV_days_immune = 0
                        agent.AdV_immunity_susceptibility_level = AdV_immune_memory_susceptibility_level
                    else
                        agent.AdV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.AdV_days_immune, agent.AdV_immunity_end, AdV_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if agent.virus_id != 6
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 6, age_group] / num_agents_age_groups[age_group]
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    agent.PIV_days_immune = 365 - week_num * 7 + 1
                    if agent.PIV_days_immune > agent.PIV_immunity_end
                        agent.PIV_immunity_end = 0
                        agent.PIV_days_immune = 0
                        agent.PIV_immunity_susceptibility_level = PIV_immune_memory_susceptibility_level
                    else
                        agent.PIV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.PIV_days_immune, agent.PIV_immunity_end, PIV_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if agent.virus_id != 7
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 7, age_group] / num_agents_age_groups[age_group]
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    agent.CoV_days_immune = 365 - week_num * 7 + 1
                    if agent.CoV_days_immune > agent.CoV_immunity_end
                        agent.CoV_immunity_end = 0
                        agent.CoV_days_immune = 0
                        agent.CoV_immunity_susceptibility_level = CoV_immune_memory_susceptibility_level
                    else
                        agent.CoV_immunity_susceptibility_level = find_immunity_susceptibility_level(agent.CoV_days_immune, agent.CoV_immunity_end, CoV_immune_memory_susceptibility_level)
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
    end
end
