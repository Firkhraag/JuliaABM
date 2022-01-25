function reset_population(
    agents::Vector{Agent},
    start_agent_id::Int,
    end_agent_id::Int,
    viruses::Vector{Virus},
    initially_infected::Vector{Float64},
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    rng::MersenneTwister,
)
    @threads for thread_id in 1:num_threads
        for agent_id in start_agent_ids[thread_id]:end_agent_ids[thread_id]
            agent = agents[agent_id]
            agent.on_parent_leave = false
            is_infected = false

            if agent.age < 3
                if rand(rng, Float64) < initially_infected[1]
                    is_infected = true
                end
            elseif agent.age < 7
                if rand(rng, Float64) < initially_infected[2]
                    is_infected = true
                end
            elseif agent.age < 15
                if rand(rng, Float64) < initially_infected[3]
                    is_infected = true
                end
            else
                if rand(rng, Float64) < initially_infected[4]
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
                if rand(rng, Float64) < 0.000206497
                    agent.FluA_days_immune = rand(rng, 211:217)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.000281861
                    agent.FluA_days_immune = rand(rng, 204:210)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.000660201
                    agent.FluA_days_immune = rand(rng, 197:203)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.001605497
                    agent.FluA_days_immune = rand(rng, 190:196)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.003478317
                    agent.FluA_days_immune = rand(rng, 183:189)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.006433707
                    agent.FluA_days_immune = rand(rng, 176:182)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.010078104
                    agent.FluA_days_immune = rand(rng, 169:175)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.014095888
                    agent.FluA_days_immune = rand(rng, 162:168)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.016454683
                    agent.FluA_days_immune = rand(rng, 155:161)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.01634273
                    agent.FluA_days_immune = rand(rng, 148:154)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.012538951
                    agent.FluA_days_immune = rand(rng, 141:147)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.008756795
                    agent.FluA_days_immune = rand(rng, 134:140)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.004209558
                    agent.FluA_days_immune = rand(rng, 127:133)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.002100738
                    agent.FluA_days_immune = rand(rng, 120:126)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.001255956
                    agent.FluA_days_immune = rand(rng, 113:119)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.00080679
                    agent.FluA_days_immune = rand(rng, 106:112)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.000458664
                    agent.FluA_days_immune = rand(rng, 99:105)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.000309442
                    agent.FluA_days_immune = rand(rng, 92:98)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                elseif rand(rng, Float64) < 0.000201445
                    agent.FluA_days_immune = rand(rng, 85:91)
                    agent.FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluA_immunity_end < agent.FluA_days_immune
                        agent.FluA_immunity_end = agent.FluA_days_immune
                    end
                end
    
                if rand(rng, Float64) < 0.000261757
                    agent.FluB_days_immune = rand(rng, 197:203)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000606962
                    agent.FluB_days_immune = rand(rng, 190:196)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.001020158
                    agent.FluB_days_immune = rand(rng, 183:189)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.00167279
                    agent.FluB_days_immune = rand(rng, 176:182)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.002434718
                    agent.FluB_days_immune = rand(rng, 169:175)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.002843872
                    agent.FluB_days_immune = rand(rng, 162:168)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.002840032
                    agent.FluB_days_immune = rand(rng, 155:161)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.002464019
                    agent.FluB_days_immune = rand(rng, 148:154)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.002089219
                    agent.FluB_days_immune = rand(rng, 141:147)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.001856047
                    agent.FluB_days_immune = rand(rng, 134:140)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.001629948
                    agent.FluB_days_immune = rand(rng, 127:133)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000887825
                    agent.FluB_days_immune = rand(rng, 120:126)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000681328
                    agent.FluB_days_immune = rand(rng, 113:119)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000666778
                    agent.FluB_days_immune = rand(rng, 106:112)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000639699
                    agent.FluB_days_immune = rand(rng, 99:105)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000600091
                    agent.FluB_days_immune = rand(rng, 92:98)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000424715
                    agent.FluB_days_immune = rand(rng, 85:91)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000272578
                    agent.FluB_days_immune = rand(rng, 78:84)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.00025439
                    agent.FluB_days_immune = rand(rng, 71:77)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                elseif rand(rng, Float64) < 0.000219228
                    agent.FluB_days_immune = rand(rng, 64:70)
                    agent.FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.FluB_immunity_end < agent.FluB_days_immune
                        agent.FluB_immunity_end = agent.FluB_days_immune
                    end
                end
    
                if rand(rng, Float64) < 0.001578761
                    agent.RV_days_immune = rand(rng, 1:7)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001826452
                    agent.RV_days_immune = rand(rng, 8:14)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(rng, Float64) < 0.00184949
                    agent.RV_days_immune = rand(rng, 15:21)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002444094
                    agent.RV_days_immune = rand(rng, 22:28)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(rng, Float64) < 0.003069617
                    agent.RV_days_immune = rand(rng, 29:35)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(rng, Float64) < 0.003399151
                    agent.RV_days_immune = rand(rng, 36:42)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(rng, Float64) < 0.004222047
                    agent.RV_days_immune = rand(rng, 43:49)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(rng, Float64) < 0.005706638
                    agent.RV_days_immune = rand(rng, 50:56)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                elseif rand(rng, Float64) < 0.007519551
                    agent.RV_days_immune = rand(rng, 57:60)
                    agent.RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RV_immunity_end < agent.RV_days_immune
                        agent.RV_immunity_end = agent.RV_days_immune
                    end
                end
    
                if rand(rng, Float64) < 0.000377428
                    agent.RSV_days_immune = rand(rng, 1:7)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000910397
                    agent.RSV_days_immune = rand(rng, 8:14)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001509851
                    agent.RSV_days_immune = rand(rng, 15:21)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002404082
                    agent.RSV_days_immune = rand(rng, 22:28)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.00274857
                    agent.RSV_days_immune = rand(rng, 29:35)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.00307083
                    agent.RSV_days_immune = rand(rng, 36:42)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.003956977
                    agent.RSV_days_immune = rand(rng, 43:49)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.005496332
                    agent.RSV_days_immune = rand(rng, 50:56)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.006939295
                    agent.RSV_days_immune = rand(rng, 57:63)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.004276811
                    agent.RSV_days_immune = rand(rng, 113:119)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.004852218
                    agent.RSV_days_immune = rand(rng, 106:112)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.005723613
                    agent.RSV_days_immune = rand(rng, 99:105)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.006328322
                    agent.RSV_days_immune = rand(rng, 92:98)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.006621885
                    agent.RSV_days_immune = rand(rng, 85:91)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.006368536
                    agent.RSV_days_immune = rand(rng, 78:84)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.006325695
                    agent.RSV_days_immune = rand(rng, 71:77)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                elseif rand(rng, Float64) < 0.006643912
                    agent.RSV_days_immune = rand(rng, 64:70)
                    trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.RSV_immunity_end < agent.RSV_days_immune
                        agent.RSV_immunity_end = agent.RSV_days_immune
                    end
                end
    
                if rand(rng, Float64) < 0.000600061
                    agent.AdV_days_immune = rand(rng, 1:7)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000612994
                    agent.AdV_days_immune = rand(rng, 8:14)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000911205
                    agent.AdV_days_immune = rand(rng, 15:21)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001299343
                    agent.AdV_days_immune = rand(rng, 22:28)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001542791
                    agent.AdV_days_immune = rand(rng, 29:35)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001806042
                    agent.AdV_days_immune = rand(rng, 36:42)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001883237
                    agent.AdV_days_immune = rand(rng, 43:49)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002443286
                    agent.AdV_days_immune = rand(rng, 50:56)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002731393
                    agent.AdV_days_immune = rand(rng, 57:63)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002457432
                    agent.AdV_days_immune = rand(rng, 85:90)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002417824
                    agent.AdV_days_immune = rand(rng, 78:84)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002190947
                    agent.AdV_days_immune = rand(rng, 71:77)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002169728
                    agent.AdV_days_immune = rand(rng, 64:70)
                    agent.AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.AdV_immunity_end < agent.AdV_days_immune
                        agent.AdV_immunity_end = agent.AdV_days_immune
                    end
                end
    
                if rand(rng, Float64) < 0.00067281
                    agent.PIV_days_immune = rand(rng, 1:7)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000671395
                    agent.PIV_days_immune = rand(rng, 8:14)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000655633
                    agent.PIV_days_immune = rand(rng, 15:21)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000938891
                    agent.PIV_days_immune = rand(rng, 22:28)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.00096698
                    agent.PIV_days_immune = rand(rng, 29:35)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.00096698
                    agent.PIV_days_immune = rand(rng, 36:42)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001221138
                    agent.PIV_days_immune = rand(rng, 43:49)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001546832
                    agent.PIV_days_immune = rand(rng, 50:56)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.002106275
                    agent.PIV_days_immune = rand(rng, 57:63)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001847267
                    agent.PIV_days_immune = rand(rng, 85:90)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001263979
                    agent.PIV_days_immune = rand(rng, 78:84)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001503789
                    agent.PIV_days_immune = rand(rng, 71:77)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001563403
                    agent.PIV_days_immune = rand(rng, 64:70)
                    agent.PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.PIV_immunity_end < agent.PIV_days_immune
                        agent.PIV_immunity_end = agent.PIV_days_immune
                    end
                end
    
                if rand(rng, Float64) < 0.000395211
                    agent.CoV_days_immune = rand(rng, 211:217)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000346509
                    agent.CoV_days_immune = rand(rng, 204:210)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000361261
                    agent.CoV_days_immune = rand(rng, 197:203)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000608952
                    agent.CoV_days_immune = rand(rng, 190:196)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000638052
                    agent.CoV_days_immune = rand(rng, 183:189)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000689583
                    agent.CoV_days_immune = rand(rng, 176:182)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000932424
                    agent.CoV_days_immune = rand(rng, 169:175)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000984359
                    agent.CoV_days_immune = rand(rng, 162:168)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.001203557
                    agent.CoV_days_immune = rand(rng, 155:161)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000991634
                    agent.CoV_days_immune = rand(rng, 148:154)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000986178
                    agent.CoV_days_immune = rand(rng, 141:147)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000937072
                    agent.CoV_days_immune = rand(rng, 134:140)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000695847
                    agent.CoV_days_immune = rand(rng, 127:133)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000386521
                    agent.CoV_days_immune = rand(rng, 120:126)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000336001
                    agent.CoV_days_immune = rand(rng, 113:119)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000330343
                    agent.CoV_days_immune = rand(rng, 106:112)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000347924
                    agent.CoV_days_immune = rand(rng, 99:105)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000357421
                    agent.CoV_days_immune = rand(rng, 92:98)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000352774
                    agent.CoV_days_immune = rand(rng, 85:91)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000327918
                    agent.CoV_days_immune = rand(rng, 78:84)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    if agent.CoV_immunity_end < agent.CoV_days_immune
                        agent.CoV_immunity_end = agent.CoV_days_immune
                    end
                elseif rand(rng, Float64) < 0.000305082
                    agent.CoV_days_immune = rand(rng, 71:77)
                    agent.CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
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
                rand_num = rand(rng, Float64)
                if rand_num < 0.6
                    agent.virus_id = 3
                elseif rand_num < 0.8
                    agent.virus_id = 5
                else
                    agent.virus_id = 6
                end

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
            if agent.activity_type == 3 && !agent.is_teacher && rand(rng, Float64) < 0.5
                agent.attendance = false
            end

            agent.days_immune = 0
            agent.days_immune_end = 0
        end
    end
end
