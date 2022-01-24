function reset_population(
    agents::Vector{Agent},
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    viruses::Vector{Virus},
    immunity_duration_sds::Vector{Float64},
    symptomatic_probabilities_children::Vector{Float64},
    symptomatic_probabilities_teenagers::Vector{Float64},
    symptomatic_probabilities_adults::Vector{Float64},
)
    @threads for thread_id in 1:num_threads
        for agent_id in start_agent_ids[thread_id]:end_agent_ids[thread_id]
            agent = agents[agent_id]
            agent.on_parent_leave = false
            is_infected = false

            if agent.age < 3
                if rand(thread_rng[thread_id], Float64) < 4896 / 272834
                    is_infected = true
                end
            elseif agent.age < 7
                if rand(thread_rng[thread_id], Float64) < 3615 / 319868
                    is_infected = true
                end
            elseif agent.age < 15
                if rand(thread_rng[thread_id], Float64) < 2906 / 559565
                    is_infected = true
                end
            else
                if rand(thread_rng[thread_id], Float64) < 14928 / 8920401
                    is_infected = true
                end
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

            if !is_infected
                if rand(thread_rng[thread_id], Float64) < 0.000206497
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 211:217)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000281861
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 204:210)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000660201
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 197:203)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001605497
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 190:196)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.003478317
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 183:189)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.006433707
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 176:182)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.010078104
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 169:175)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.014095888
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 162:168)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.016454683
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 155:161)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.01634273
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 148:154)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.012538951
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 141:147)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.008756795
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 134:140)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.004209558
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 127:133)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002100738
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 120:126)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001255956
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 113:119)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.00080679
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 106:112)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000458664
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 99:105)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000309442
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 92:98)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000201445
                    agent.FluA_days_immune = rand(thread_rng[thread_id], 85:91)
                    agent.FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                end
    
                if rand(thread_rng[thread_id], Float64) < 0.000261757
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 197:203)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000606962
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 190:196)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001020158
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 183:189)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.00167279
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 176:182)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002434718
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 169:175)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002843872
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 162:168)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002840032
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 155:161)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002464019
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 148:154)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002089219
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 141:147)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001856047
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 134:140)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001629948
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 127:133)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000887825
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 120:126)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000681328
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 113:119)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000666778
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 106:112)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000639699
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 99:105)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000600091
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 92:98)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000424715
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 85:91)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000272578
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 78:84)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.00025439
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 71:77)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000219228
                    agent.FluB_days_immune = rand(thread_rng[thread_id], 64:70)
                    agent.FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                end
    
                if rand(thread_rng[thread_id], Float64) < 0.001578761
                    agent.RV_days_immune = rand(thread_rng[thread_id], 1:7)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001826452
                    agent.RV_days_immune = rand(thread_rng[thread_id], 8:14)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.00184949
                    agent.RV_days_immune = rand(thread_rng[thread_id], 15:21)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002444094
                    agent.RV_days_immune = rand(thread_rng[thread_id], 22:28)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.003069617
                    agent.RV_days_immune = rand(thread_rng[thread_id], 29:35)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.003399151
                    agent.RV_days_immune = rand(thread_rng[thread_id], 36:42)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.004222047
                    agent.RV_days_immune = rand(thread_rng[thread_id], 43:49)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.005706638
                    agent.RV_days_immune = rand(thread_rng[thread_id], 50:56)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.007519551
                    agent.RV_days_immune = rand(thread_rng[thread_id], 57:60)
                    agent.RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                end
    
                if rand(thread_rng[thread_id], Float64) < 0.000377428
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 1:7)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000910397
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 8:14)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001509851
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 15:21)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002404082
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 22:28)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.00274857
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 29:35)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.00307083
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 36:42)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.003956977
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 43:49)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.005496332
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 50:56)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.006939295
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 57:63)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.004276811
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 113:119)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.004852218
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 106:112)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.005723613
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 99:105)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.006328322
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 92:98)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.006621885
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 85:91)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.006368536
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 78:84)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.006325695
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 71:77)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.006643912
                    agent.RSV_days_immune = rand(thread_rng[thread_id], 64:70)
                    trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                end
    
                if rand(thread_rng[thread_id], Float64) < 0.000600061
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 1:7)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000612994
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 8:14)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000911205
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 15:21)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001299343
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 22:28)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001542791
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 29:35)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001806042
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 36:42)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001883237
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 43:49)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002443286
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 50:56)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002731393
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 57:63)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002457432
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 85:90)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002417824
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 78:84)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002190947
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 71:77)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002169728
                    agent.AdV_days_immune = rand(thread_rng[thread_id], 64:70)
                    agent.AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                end
    
                if rand(thread_rng[thread_id], Float64) < 0.00067281
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 1:7)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000671395
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 8:14)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000655633
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 15:21)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000938891
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 22:28)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.00096698
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 29:35)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.00096698
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 36:42)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001221138
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 43:49)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001546832
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 50:56)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.002106275
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 57:63)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001847267
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 85:90)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001263979
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 78:84)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001503789
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 71:77)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001563403
                    agent.PIV_days_immune = rand(thread_rng[thread_id], 64:70)
                    agent.PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                end
    
                if rand(thread_rng[thread_id], Float64) < 0.000395211
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 211:217)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000346509
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 204:210)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000361261
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 197:203)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000608952
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 190:196)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000638052
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 183:189)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000689583
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 176:182)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000932424
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 169:175)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000984359
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 162:168)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.001203557
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 155:161)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000991634
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 148:154)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000986178
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 141:147)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000937072
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 134:140)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000695847
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 127:133)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000386521
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 120:126)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000336001
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 113:119)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000330343
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 106:112)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000347924
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 99:105)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000357421
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 92:98)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000352774
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 85:91)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000327918
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 78:84)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(thread_rng[thread_id], Float64) < 0.000305082
                    agent.CoV_days_immune = rand(thread_rng[thread_id], 71:77)
                    agent.CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
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

                if agent.age < 10
                    agent.is_asymptomatic = rand(thread_rng[thread_id], Float64) > symptomatic_probabilities_children[agent.virus_id]
                elseif agent.age < 18
                    agent.is_asymptomatic = rand(thread_rng[thread_id], Float64) > symptomatic_probabilities_teenagers[agent.virus_id]
                else
                    agent.is_asymptomatic = rand(thread_rng[thread_id], Float64) > symptomatic_probabilities_adults[agent.virus_id]
                end

                if !agent.is_asymptomatic
                    # Самоизоляция
                    if agent.days_infected >= 1
                        rand_num = rand(thread_rng[thread_id], Float64)
                        if agent.age < 3
                            if rand_num < 0.406
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
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
                        if agent.age < 3
                            if rand_num < 0.669
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
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
                        if agent.age < 3
                            if rand_num < 0.45
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
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
            end

            agent.attendance = true
            if agent.activity_type == 3 && !agent.is_teacher && rand(thread_rng[thread_id], Float64) < 0.5
                agent.attendance = false
            end

            agent.days_immune = 0
            agent.days_immune_end = 0
        end
    end
end
