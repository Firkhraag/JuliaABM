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

            # Набор дней после приобретения типоспецифического иммунитета

            FluA_days_immune = 0
            FluB_days_immune = 0
            RV_days_immune = 0
            RSV_days_immune = 0
            AdV_days_immune = 0
            PIV_days_immune = 0
            CoV_days_immune = 0

            if !is_infected
                if rand(thread_rng[thread_id], Float64) < 0.000106497
                    FluA_days_immune = rand(thread_rng[thread_id], 211:217)
                elseif rand(thread_rng[thread_id], Float64) < 0.000141861
                    FluA_days_immune = rand(thread_rng[thread_id], 204:210)
                elseif rand(thread_rng[thread_id], Float64) < 0.000330201
                    FluA_days_immune = rand(thread_rng[thread_id], 197:203)
                elseif rand(thread_rng[thread_id], Float64) < 0.000805497
                    FluA_days_immune = rand(thread_rng[thread_id], 190:196)
                elseif rand(thread_rng[thread_id], Float64) < 0.001778317
                    FluA_days_immune = rand(thread_rng[thread_id], 183:189)
                elseif rand(thread_rng[thread_id], Float64) < 0.003233707
                    FluA_days_immune = rand(thread_rng[thread_id], 176:182)
                elseif rand(thread_rng[thread_id], Float64) < 0.005078104
                    FluA_days_immune = rand(thread_rng[thread_id], 169:175)
                elseif rand(thread_rng[thread_id], Float64) < 0.007095888
                    FluA_days_immune = rand(thread_rng[thread_id], 162:168)
                elseif rand(thread_rng[thread_id], Float64) < 0.008454683
                    FluA_days_immune = rand(thread_rng[thread_id], 155:161)
                elseif rand(thread_rng[thread_id], Float64) < 0.00834273
                    FluA_days_immune = rand(thread_rng[thread_id], 148:154)
                elseif rand(thread_rng[thread_id], Float64) < 0.006538951
                    FluA_days_immune = rand(thread_rng[thread_id], 141:147)
                elseif rand(thread_rng[thread_id], Float64) < 0.004756795
                    FluA_days_immune = rand(thread_rng[thread_id], 134:140)
                elseif rand(thread_rng[thread_id], Float64) < 0.002209558
                    FluA_days_immune = rand(thread_rng[thread_id], 127:133)
                elseif rand(thread_rng[thread_id], Float64) < 0.001100738
                    FluA_days_immune = rand(thread_rng[thread_id], 120:126)
                elseif rand(thread_rng[thread_id], Float64) < 0.000655956
                    FluA_days_immune = rand(thread_rng[thread_id], 113:119)
                elseif rand(thread_rng[thread_id], Float64) < 0.00040679
                    FluA_days_immune = rand(thread_rng[thread_id], 106:112)
                elseif rand(thread_rng[thread_id], Float64) < 0.000258664
                    FluA_days_immune = rand(thread_rng[thread_id], 99:105)
                elseif rand(thread_rng[thread_id], Float64) < 0.000159442
                    FluA_days_immune = rand(thread_rng[thread_id], 92:98)
                elseif rand(thread_rng[thread_id], Float64) < 0.000101445
                    FluA_days_immune = rand(thread_rng[thread_id], 85:91)
                end

                if rand(thread_rng[thread_id], Float64) < 0.000131757
                    FluB_days_immune = rand(thread_rng[thread_id], 197:203)
                elseif rand(thread_rng[thread_id], Float64) < 0.000306962
                    FluB_days_immune = rand(thread_rng[thread_id], 190:196)
                elseif rand(thread_rng[thread_id], Float64) < 0.000520158
                    FluB_days_immune = rand(thread_rng[thread_id], 183:189)
                elseif rand(thread_rng[thread_id], Float64) < 0.00087279
                    FluB_days_immune = rand(thread_rng[thread_id], 176:182)
                elseif rand(thread_rng[thread_id], Float64) < 0.001234718
                    FluB_days_immune = rand(thread_rng[thread_id], 169:175)
                elseif rand(thread_rng[thread_id], Float64) < 0.001443872
                    FluB_days_immune = rand(thread_rng[thread_id], 162:168)
                elseif rand(thread_rng[thread_id], Float64) < 0.001440032
                    FluB_days_immune = rand(thread_rng[thread_id], 155:161)
                elseif rand(thread_rng[thread_id], Float64) < 0.001264019
                    FluB_days_immune = rand(thread_rng[thread_id], 148:154)
                elseif rand(thread_rng[thread_id], Float64) < 0.001089219
                    FluB_days_immune = rand(thread_rng[thread_id], 141:147)
                elseif rand(thread_rng[thread_id], Float64) < 0.000956047
                    FluB_days_immune = rand(thread_rng[thread_id], 134:140)
                elseif rand(thread_rng[thread_id], Float64) < 0.000829948
                    FluB_days_immune = rand(thread_rng[thread_id], 127:133)
                elseif rand(thread_rng[thread_id], Float64) < 0.000487825
                    FluB_days_immune = rand(thread_rng[thread_id], 120:126)
                elseif rand(thread_rng[thread_id], Float64) < 0.000381328
                    FluB_days_immune = rand(thread_rng[thread_id], 113:119)
                elseif rand(thread_rng[thread_id], Float64) < 0.000366778
                    FluB_days_immune = rand(thread_rng[thread_id], 106:112)
                elseif rand(thread_rng[thread_id], Float64) < 0.000339699
                    FluB_days_immune = rand(thread_rng[thread_id], 99:105)
                elseif rand(thread_rng[thread_id], Float64) < 0.000300091
                    FluB_days_immune = rand(thread_rng[thread_id], 92:98)
                elseif rand(thread_rng[thread_id], Float64) < 0.000224715
                    FluB_days_immune = rand(thread_rng[thread_id], 85:91)
                elseif rand(thread_rng[thread_id], Float64) < 0.000172578
                    FluB_days_immune = rand(thread_rng[thread_id], 78:84)
                elseif rand(thread_rng[thread_id], Float64) < 0.00015439
                    FluB_days_immune = rand(thread_rng[thread_id], 71:77)
                elseif rand(thread_rng[thread_id], Float64) < 0.000119228
                    FluB_days_immune = rand(thread_rng[thread_id], 64:70)
                end

                if rand(thread_rng[thread_id], Float64) < 0.000578761
                    RV_days_immune = rand(thread_rng[thread_id], 1:7)
                elseif rand(thread_rng[thread_id], Float64) < 0.000626452
                    RV_days_immune = rand(thread_rng[thread_id], 8:14)
                elseif rand(thread_rng[thread_id], Float64) < 0.00064949
                    RV_days_immune = rand(thread_rng[thread_id], 15:21)
                elseif rand(thread_rng[thread_id], Float64) < 0.000844094
                    RV_days_immune = rand(thread_rng[thread_id], 22:28)
                elseif rand(thread_rng[thread_id], Float64) < 0.001069617
                    RV_days_immune = rand(thread_rng[thread_id], 29:35)
                elseif rand(thread_rng[thread_id], Float64) < 0.001199151
                    RV_days_immune = rand(thread_rng[thread_id], 36:42)
                elseif rand(thread_rng[thread_id], Float64) < 0.001422047
                    RV_days_immune = rand(thread_rng[thread_id], 43:49)
                elseif rand(thread_rng[thread_id], Float64) < 0.001906638
                    RV_days_immune = rand(thread_rng[thread_id], 50:56)
                elseif rand(thread_rng[thread_id], Float64) < 0.002519551
                    RV_days_immune = rand(thread_rng[thread_id], 57:60)
                end

                if rand(thread_rng[thread_id], Float64) < 0.000177428
                    RSV_days_immune = rand(thread_rng[thread_id], 1:7)
                elseif rand(thread_rng[thread_id], Float64) < 0.000310397
                    RSV_days_immune = rand(thread_rng[thread_id], 8:14)
                elseif rand(thread_rng[thread_id], Float64) < 0.000509851
                    RSV_days_immune = rand(thread_rng[thread_id], 15:21)
                elseif rand(thread_rng[thread_id], Float64) < 0.000804082
                    RSV_days_immune = rand(thread_rng[thread_id], 22:28)
                elseif rand(thread_rng[thread_id], Float64) < 0.00094857
                    RSV_days_immune = rand(thread_rng[thread_id], 29:35)
                elseif rand(thread_rng[thread_id], Float64) < 0.00107083
                    RSV_days_immune = rand(thread_rng[thread_id], 36:42)
                elseif rand(thread_rng[thread_id], Float64) < 0.001356977
                    RSV_days_immune = rand(thread_rng[thread_id], 43:49)
                elseif rand(thread_rng[thread_id], Float64) < 0.001896332
                    RSV_days_immune = rand(thread_rng[thread_id], 50:56)
                elseif rand(thread_rng[thread_id], Float64) < 0.002339295
                    RSV_days_immune = rand(thread_rng[thread_id], 57:63)
                elseif rand(thread_rng[thread_id], Float64) < 0.001476811
                    RSV_days_immune = rand(thread_rng[thread_id], 113:119)
                elseif rand(thread_rng[thread_id], Float64) < 0.001652218
                    RSV_days_immune = rand(thread_rng[thread_id], 106:112)
                elseif rand(thread_rng[thread_id], Float64) < 0.001923613
                    RSV_days_immune = rand(thread_rng[thread_id], 99:105)
                elseif rand(thread_rng[thread_id], Float64) < 0.002128322
                    RSV_days_immune = rand(thread_rng[thread_id], 92:98)
                elseif rand(thread_rng[thread_id], Float64) < 0.002221885
                    RSV_days_immune = rand(thread_rng[thread_id], 85:91)
                elseif rand(thread_rng[thread_id], Float64) < 0.002168536
                    RSV_days_immune = rand(thread_rng[thread_id], 78:84)
                elseif rand(thread_rng[thread_id], Float64) < 0.002125695
                    RSV_days_immune = rand(thread_rng[thread_id], 71:77)
                elseif rand(thread_rng[thread_id], Float64) < 0.002243912
                    RSV_days_immune = rand(thread_rng[thread_id], 64:70)
                end

                if rand(thread_rng[thread_id], Float64) < 0.000200061
                    AdV_days_immune = rand(thread_rng[thread_id], 1:7)
                elseif rand(thread_rng[thread_id], Float64) < 0.000212994
                    AdV_days_immune = rand(thread_rng[thread_id], 8:14)
                elseif rand(thread_rng[thread_id], Float64) < 0.000311205
                    AdV_days_immune = rand(thread_rng[thread_id], 15:21)
                elseif rand(thread_rng[thread_id], Float64) < 0.000499343
                    AdV_days_immune = rand(thread_rng[thread_id], 22:28)
                elseif rand(thread_rng[thread_id], Float64) < 0.000542791
                    AdV_days_immune = rand(thread_rng[thread_id], 29:35)
                elseif rand(thread_rng[thread_id], Float64) < 0.000606042
                    AdV_days_immune = rand(thread_rng[thread_id], 36:42)
                elseif rand(thread_rng[thread_id], Float64) < 0.000683237
                    AdV_days_immune = rand(thread_rng[thread_id], 43:49)
                elseif rand(thread_rng[thread_id], Float64) < 0.000843286
                    AdV_days_immune = rand(thread_rng[thread_id], 50:56)
                elseif rand(thread_rng[thread_id], Float64) < 0.000931393
                    AdV_days_immune = rand(thread_rng[thread_id], 57:63)
                elseif rand(thread_rng[thread_id], Float64) < 0.000857432
                    AdV_days_immune = rand(thread_rng[thread_id], 85:90)
                elseif rand(thread_rng[thread_id], Float64) < 0.000817824
                    AdV_days_immune = rand(thread_rng[thread_id], 78:84)
                elseif rand(thread_rng[thread_id], Float64) < 0.000790947
                    AdV_days_immune = rand(thread_rng[thread_id], 71:77)
                elseif rand(thread_rng[thread_id], Float64) < 0.000769728
                    AdV_days_immune = rand(thread_rng[thread_id], 64:70)
                end

                if rand(thread_rng[thread_id], Float64) < 0.00027281
                    PIV_days_immune = rand(thread_rng[thread_id], 1:7)
                elseif rand(thread_rng[thread_id], Float64) < 0.000271395
                    PIV_days_immune = rand(thread_rng[thread_id], 8:14)
                elseif rand(thread_rng[thread_id], Float64) < 0.000255633
                    PIV_days_immune = rand(thread_rng[thread_id], 15:21)
                elseif rand(thread_rng[thread_id], Float64) < 0.000338891
                    PIV_days_immune = rand(thread_rng[thread_id], 22:28)
                elseif rand(thread_rng[thread_id], Float64) < 0.00036698
                    PIV_days_immune = rand(thread_rng[thread_id], 29:35)
                elseif rand(thread_rng[thread_id], Float64) < 0.00036698
                    PIV_days_immune = rand(thread_rng[thread_id], 36:42)
                elseif rand(thread_rng[thread_id], Float64) < 0.000421138
                    PIV_days_immune = rand(thread_rng[thread_id], 43:49)
                elseif rand(thread_rng[thread_id], Float64) < 0.000546832
                    PIV_days_immune = rand(thread_rng[thread_id], 50:56)
                elseif rand(thread_rng[thread_id], Float64) < 0.000706275
                    PIV_days_immune = rand(thread_rng[thread_id], 57:63)
                elseif rand(thread_rng[thread_id], Float64) < 0.000647267
                    PIV_days_immune = rand(thread_rng[thread_id], 85:90)
                elseif rand(thread_rng[thread_id], Float64) < 0.000463979
                    PIV_days_immune = rand(thread_rng[thread_id], 78:84)
                elseif rand(thread_rng[thread_id], Float64) < 0.000503789
                    PIV_days_immune = rand(thread_rng[thread_id], 71:77)
                elseif rand(thread_rng[thread_id], Float64) < 0.000563403
                    PIV_days_immune = rand(thread_rng[thread_id], 64:70)
                end

                if rand(thread_rng[thread_id], Float64) < 0.000195211
                    CoV_days_immune = rand(thread_rng[thread_id], 211:217)
                elseif rand(thread_rng[thread_id], Float64) < 0.000146509
                    CoV_days_immune = rand(thread_rng[thread_id], 204:210)
                elseif rand(thread_rng[thread_id], Float64) < 0.000161261
                    CoV_days_immune = rand(thread_rng[thread_id], 197:203)
                elseif rand(thread_rng[thread_id], Float64) < 0.000208952
                    CoV_days_immune = rand(thread_rng[thread_id], 190:196)
                elseif rand(thread_rng[thread_id], Float64) < 0.000238052
                    CoV_days_immune = rand(thread_rng[thread_id], 183:189)
                elseif rand(thread_rng[thread_id], Float64) < 0.000289583
                    CoV_days_immune = rand(thread_rng[thread_id], 176:182)
                elseif rand(thread_rng[thread_id], Float64) < 0.000332424
                    CoV_days_immune = rand(thread_rng[thread_id], 169:175)
                elseif rand(thread_rng[thread_id], Float64) < 0.000384359
                    CoV_days_immune = rand(thread_rng[thread_id], 162:168)
                elseif rand(thread_rng[thread_id], Float64) < 0.000403557
                    CoV_days_immune = rand(thread_rng[thread_id], 155:161)
                elseif rand(thread_rng[thread_id], Float64) < 0.000391634
                    CoV_days_immune = rand(thread_rng[thread_id], 148:154)
                elseif rand(thread_rng[thread_id], Float64) < 0.000386178
                    CoV_days_immune = rand(thread_rng[thread_id], 141:147)
                elseif rand(thread_rng[thread_id], Float64) < 0.000337072
                    CoV_days_immune = rand(thread_rng[thread_id], 134:140)
                elseif rand(thread_rng[thread_id], Float64) < 0.000295847
                    CoV_days_immune = rand(thread_rng[thread_id], 127:133)
                elseif rand(thread_rng[thread_id], Float64) < 0.000186521
                    CoV_days_immune = rand(thread_rng[thread_id], 120:126)
                elseif rand(thread_rng[thread_id], Float64) < 0.000136001
                    CoV_days_immune = rand(thread_rng[thread_id], 113:119)
                elseif rand(thread_rng[thread_id], Float64) < 0.000130343
                    CoV_days_immune = rand(thread_rng[thread_id], 106:112)
                elseif rand(thread_rng[thread_id], Float64) < 0.000147924
                    CoV_days_immune = rand(thread_rng[thread_id], 99:105)
                elseif rand(thread_rng[thread_id], Float64) < 0.000157421
                    CoV_days_immune = rand(thread_rng[thread_id], 92:98)
                elseif rand(thread_rng[thread_id], Float64) < 0.000152774
                    CoV_days_immune = rand(thread_rng[thread_id], 85:91)
                elseif rand(thread_rng[thread_id], Float64) < 0.000127918
                    CoV_days_immune = rand(thread_rng[thread_id], 78:84)
                elseif rand(thread_rng[thread_id], Float64) < 0.000105082
                    CoV_days_immune = rand(thread_rng[thread_id], 71:77)
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
