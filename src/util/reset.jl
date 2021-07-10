function reset_population(
    agents::Vector{Agent},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    infectivities::Array{Float64, 4},
    viruses::Vector{Virus},
)
    @threads for thread_id in 1:num_threads
        for agent_id in start_agent_ids[thread_id]:end_agent_ids[thread_id]
            agent = agents[agent_id]
            agent.on_parent_leave = false
            is_infected = false
            if agent.age < 3
                if rand(thread_rng[thread_id], Float64) < 0.016
                    is_infected = true
                end
            elseif agent.age < 7
                if rand(thread_rng[thread_id], Float64) < 0.01
                    is_infected = true
                end
            elseif agent.age < 15
                if rand(thread_rng[thread_id], Float64) < 0.007
                    is_infected = true
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.003
                    is_infected = true
                end
            end

            # Набор дней после приобретения типоспецифического иммунитета кроме гриппа
            agent.RV_days_immune = 0
            agent.RSV_days_immune = 0
            agent.AdV_days_immune = 0
            agent.PIV_days_immune = 0

            agent.FluA_immunity = false
            agent.FluB_immunity = false
            agent.CoV_immunity = false

            if !is_infected
                if agent.age < 3
                    if rand(thread_rng[thread_id], Float64) < 0.63
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(thread_rng[thread_id], 1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                        else
                            agent.PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                        end
                    end
                elseif agent.age < 7
                    if rand(thread_rng[thread_id], Float64) < 0.44
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(thread_rng[thread_id], 1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                        else
                            agent.PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                        end
                    end
                elseif agent.age < 15
                    if rand(thread_rng[thread_id], Float64) < 0.37
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(thread_rng[thread_id], 1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                        else
                            agent.PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                        end
                    end
                else
                    if rand(thread_rng[thread_id], Float64) < 0.2
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if rand_num < 0.6
                            agent.RV_days_immune = rand(thread_rng[thread_id], 1:60)
                        elseif rand_num < 0.8
                            agent.AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                        else
                            agent.PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                        end
                    end
                end
            end

            # Информация при болезни
            agent.virus_id = 0
            agent.incubation_period = 0
            agent.infection_period = 0
            agent.days_infected = 0
            agent.is_asymptomatic = false
            agent.is_isolated = false
            agent.infectivity = 0.0
            if is_infected
                # Тип инфекции
                rand_num = rand(thread_rng[thread_id], Float64)
                if rand_num < 0.6
                    agent.virus_id = viruses[3].id
                elseif rand_num < 0.8
                    agent.virus_id = viruses[5].id
                else
                    agent.virus_id = viruses[6].id
                end

                # Инкубационный период
                agent.incubation_period = get_period_from_erlang(
                    viruses[agent.virus_id].mean_incubation_period,
                    viruses[agent.virus_id].incubation_period_variance,
                    viruses[agent.virus_id].min_incubation_period,
                    viruses[agent.virus_id].max_incubation_period,
                    thread_rng[thread_id])
                # Период болезни
                if agent.age < 16
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_child,
                        viruses[agent.virus_id].infection_period_variance_child,
                        viruses[agent.virus_id].min_infection_period_child,
                        viruses[agent.virus_id].max_infection_period_child,
                        thread_rng[thread_id])
                else
                    agent.infection_period = get_period_from_erlang(
                        viruses[agent.virus_id].mean_infection_period_adult,
                        viruses[agent.virus_id].infection_period_variance_adult,
                        viruses[agent.virus_id].min_infection_period_adult,
                        viruses[agent.virus_id].max_infection_period_adult,
                        thread_rng[thread_id])
                end

                # Дней с момента инфицирования
                agent.days_infected = rand(thread_rng[thread_id], (1 - agent.incubation_period):agent.infection_period)

                asymp_prob = 0.0
                if agent.age < 16
                    asymp_prob = viruses[agent.virus_id].asymptomatic_probab_child
                else
                    asymp_prob = viruses[agent.virus_id].asymptomatic_probab_adult
                end

                if rand(thread_rng[thread_id], Float64) < asymp_prob
                    # Асимптомный
                    agent.is_asymptomatic = true
                else
                    # Самоизоляция
                    if agent.days_infected >= 1
                        rand_num = rand(thread_rng[thread_id], Float64)
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
                    end
                    if agent.days_infected >= 2 && !agent.is_isolated
                        rand_num = rand(thread_rng[thread_id], Float64)
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
                    end
                    if agent.days_infected >= 3 && !agent.is_isolated
                        rand_num = rand(thread_rng[thread_id], Float64)
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

                # Вирусная нагрузкаx
                agent.infectivity = find_agent_infectivity(
                    agent.age, infectivities[agent.virus_id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
                    agent.is_asymptomatic && agent.days_infected > 0)
            end
        end
    end
end
