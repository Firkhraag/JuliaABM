# Агент
mutable struct Agent
    # Идентификатор
    id::Int
    # Возраст
    age::Int
    # Возраст новорожденного
    infant_age::Int
    # Пол
    is_male::Bool
    # Id домохозяйства
    household_id::Int
    # Связи в домохозяйстве
    household_conn_ids::Vector{Int}
    # Тип коллектива
    activity_type::Int
    # Id детсада, школы, универа
    school_id::Int
    # Номер группы
    school_group_num::Int
    # Id работы
    workplace_id::Int
    # Связи в коллективе
    activity_conn_ids::Vector{Int}
    activity_cross_conn_ids::Vector{Int}

    # # Связи с друзьями
    # friend_ids::Vector{Int}
    # visit_household_id::Int

    # Id детей младше 12 лет
    dependant_ids::Vector{Int}
    # Id попечителя
    supporter_id::Int
    # Нуждается в уходе при болезни
    needs_supporter_care::Bool
    # Уход за больным ребенком
    on_parent_leave::Bool
    # Уровень иммуноглобулина
    ig_level::Float64
    # Id вируса
    virus_id::Int
    # Был заражен на текущем шаге
    is_newly_infected::Bool
    # Набор дней после приобретения типоспецифических иммунитетов
    FluA_days_immune::Int
    FluB_days_immune::Int
    RV_days_immune::Int
    RSV_days_immune::Int
    AdV_days_immune::Int
    PIV_days_immune::Int
    CoV_days_immune::Int
    # Набор дней конца типоспецифических иммунитетов
    FluA_immunity_end::Int
    FluB_immunity_end::Int
    RV_immunity_end::Int
    RSV_immunity_end::Int
    AdV_immunity_end::Int
    PIV_immunity_end::Int
    CoV_immunity_end::Int
    # Продолжительность инкубационного периода
    incubation_period::Int
    # Продолжительность периода болезни
    infection_period::Int
    # День с момента инфицирования
    days_infected::Int
    # Дней в резистентном состоянии
    days_immune::Int
    days_immune_end::Int
    # Бессимптомное течение болезни
    is_asymptomatic::Bool
    # На больничном
    is_isolated::Bool
    # Посещение детсада, школы, университета
    attendance::Bool
    # Учитель, воспитатель, профессор
    is_teacher::Bool

    infected_num_agents_on_current_step::Int

    # shopping_time::Int
    # restaurant_time::Int

    function Agent(
        id::Int,
        household_id::Int,
        viruses::Vector{Virus},
        immunity_duration_sds::Vector{Float64},
        symptomatic_probabilities_children::Vector{Float64},
        symptomatic_probabilities_teenagers::Vector{Float64},
        symptomatic_probabilities_adults::Vector{Float64},
        household_conn_ids::Vector{Int},
        is_male::Bool,
        age::Int,
        thread_id::Int,
        thread_rng::Vector{MersenneTwister},
    )
        # Возраст новорожденного
        infant_age = 0
        if age == 0
            infant_age = rand(thread_rng[thread_id], 1:12)
        end

        # Социальный статус
        activity_type = 0
        # Household
        if age == 0
            activity_type = 0
        # 1-5 Kindergarten
        elseif age == 1
            if rand(thread_rng[thread_id], Float64) < 0.2
                activity_type = 1
            end
        elseif age == 2
            if rand(thread_rng[thread_id], Float64) < 0.33
                activity_type = 1
            end
        elseif age < 6
            if rand(thread_rng[thread_id], Float64) < 0.83
                activity_type = 1
            end
        # 6-7 Kindergarten - School
        elseif age == 6
            if rand(thread_rng[thread_id], Float64) < 0.7
                activity_type = 1
            else
                activity_type = 2
            end
        elseif age == 7
            if rand(thread_rng[thread_id], Float64) < 0.7
                activity_type = 2
            else
                activity_type = 1
            end
        # 8-16 School
        elseif age < 15
            activity_type = 2
        elseif age == 15
            if rand(thread_rng[thread_id], Float64) < 0.96
                activity_type = 2
            end
        elseif age == 16
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.92
                activity_type = 2
            elseif rand_num < 0.95
                activity_type = 4
            end
        elseif age == 17
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                activity_type = 2
            elseif rand_num < 0.85
                activity_type = 4
            end
        elseif age == 18
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.29
                activity_type = 2
            elseif rand_num < 0.55
                activity_type = 4
            elseif rand_num < 0.75
                activity_type = 3
            end
        # 18-23 University - Work
        elseif age < 22
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.66
                activity_type = 4
            elseif rand_num < 0.9
                activity_type = 3
            end
        elseif age < 24
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.75
                activity_type = 4
            elseif rand_num < 0.9
                activity_type = 3
            end
        # 24+ Work
        elseif age < 30
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.82
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.74
                    activity_type = 4
                end
            end
        elseif age < 40
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.95
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.85
                    activity_type = 4
                end
            end
        elseif age < 50
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.94
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.89
                    activity_type = 4
                end
            end
        elseif age < 60
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.88
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.7
                    activity_type = 4
                end
            end
        elseif age < 65
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.51
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.29
                    activity_type = 4
                end
            end
        elseif age < 70
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.38
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.21
                    activity_type = 4
                end
            end
        elseif age < 75
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.25
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.15
                    activity_type = 4
                end
            end
        elseif age < 80
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.12
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.07
                    activity_type = 4
                end
            end
        end

        school_group_num = 0
        if activity_type == 1
            school_group_num = age
            if age == 1
                school_group_num = 1
            elseif age == 2
                school_group_num = rand(thread_rng[thread_id], 1:2)
            elseif age < 5
                school_group_num = rand(thread_rng[thread_id], (age - 2):age)
            elseif age == 5
                school_group_num = rand(thread_rng[thread_id], (age - 1):age)
            else
                school_group_num = 5
            end
        elseif activity_type == 2
            if age == 6
                school_group_num = 1
            elseif age == 7
                school_group_num = rand(thread_rng[thread_id], 1:2)
            elseif age < 17
                school_group_num = rand(thread_rng[thread_id], (age - 7):(age - 5))
            elseif age == 17
                if rand(thread_rng[thread_id], Float64) < 0.66
                    school_group_num = 11
                else
                    school_group_num = 10
                end
            else
                school_group_num = 11
            end
        elseif activity_type == 3
            if age == 18
                school_group_num = 1
            elseif age == 19
                school_group_num = rand(thread_rng[thread_id], 1:2)
            elseif age < 24
                school_group_num = rand(thread_rng[thread_id], (age - 19):(age - 17))
            else
                school_group_num = rand(thread_rng[thread_id], 5:6)
            end
        elseif activity_type == 4
            school_group_num = 1
        end

        # Уровень иммуноглобулина
        ig_level = 0.0
        ig_g = 0.0
        ig_a = 0.0
        ig_m = 0.0
        # max_ig_level = 3138.0
        min_ig_level = 238.87
        max_min_ig_level_diff = 2899.13
        if age == 0
            if infant_age == 1
                ig_g = rand(thread_rng[thread_id], truncated(Normal(953, 262.19), 399, 1480))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(6.79, 0.45), 6.67, 8.75))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(20.38, 8.87), 5.1, 50.9))
            elseif infant_age < 4
                ig_g = rand(thread_rng[thread_id], truncated(Normal(429.5, 145.59), 217, 981))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(10.53, 5.16), 6.67, 24.6))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(36.66, 13.55), 15.2, 68.5))
            elseif infant_age < 7
                ig_g = rand(thread_rng[thread_id], truncated(Normal(482.43, 236.8), 270, 1110))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(19.86, 9.77), 6.67, 53))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(75.44, 29.73), 26.9, 130))
            else
                ig_g = rand(thread_rng[thread_id], truncated(Normal(568.97, 186.62), 242, 977))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(29.41, 12.37), 6.68, 114))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(81.05, 35.76), 24.2, 162))
            end
        elseif age == 1
            ig_g = rand(thread_rng[thread_id], truncated(Normal(761.7, 238.61), 389, 1260))
            ig_a = rand(thread_rng[thread_id], truncated(Normal(37.62, 17.1), 13.1, 103))
            ig_m = rand(thread_rng[thread_id], truncated(Normal(122.57, 41.63), 38.6, 195))
        elseif age == 2
            ig_g = rand(thread_rng[thread_id], truncated(Normal(811.5, 249.14), 486, 1970))
            ig_a = rand(thread_rng[thread_id], truncated(Normal(59.77, 24.52), 6.67, 135))
            ig_m = rand(thread_rng[thread_id], truncated(Normal(111.31, 40.55), 42.7, 236))
        elseif age < 6
            ig_g = rand(thread_rng[thread_id], truncated(Normal(839.87, 164.19), 457, 1120))
            ig_a = rand(thread_rng[thread_id], truncated(Normal(68.98, 34.05), 35.7, 192))
            ig_m = rand(thread_rng[thread_id], truncated(Normal(121.79, 39.24), 58.7, 198))
        elseif age < 9
            ig_g = rand(thread_rng[thread_id], truncated(Normal(1014.93, 255.53), 483, 1580))
            ig_a = rand(thread_rng[thread_id], truncated(Normal(106.9, 49.66), 44.8, 276))
            ig_m = rand(thread_rng[thread_id], truncated(Normal(114.73, 41.27), 50.3, 242))
        elseif age < 12
            ig_g = rand(thread_rng[thread_id], truncated(Normal(1055.43, 322.27), 642, 2290))
            ig_a = rand(thread_rng[thread_id], truncated(Normal(115.99, 47.05), 32.6, 262))
            ig_m = rand(thread_rng[thread_id], truncated(Normal(113.18, 43.68), 37.4, 213))
        elseif age < 17
            ig_g = rand(thread_rng[thread_id], truncated(Normal(1142.07, 203.83), 636, 1610))
            ig_a = rand(thread_rng[thread_id], truncated(Normal(120.90, 47.51), 36.4, 305))
            ig_m = rand(thread_rng[thread_id], truncated(Normal(125.78, 39.31), 42.4, 197))
        elseif age < 19
            ig_g = rand(thread_rng[thread_id], truncated(Normal(1322.77, 361.89), 688, 2430))
            ig_a = rand(thread_rng[thread_id], truncated(Normal(201.84, 89.92), 46.3, 385))
            ig_m = rand(thread_rng[thread_id], truncated(Normal(142.54, 64.32), 60.7, 323))
        elseif age < 61
            if is_male
                ig_g = rand(thread_rng[thread_id], truncated(Normal(1250, 214.29), 751, 1750))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(226.5, 65.56), 74, 385))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(139, 41.84), 41, 237))
            else
                ig_g = rand(thread_rng[thread_id], truncated(Normal(1180, 193.8), 729, 1630))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(233.5, 63), 87, 385))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(140.5, 41), 44, 236))
            end
        elseif age < 71
            if is_male
                ig_g = rand(thread_rng[thread_id], truncated(Normal(1105, 232.1), 565, 1645))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(231.5, 78.32), 49, 413.6))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(101, 36.2), 16, 186))
            else
                ig_g = rand(thread_rng[thread_id], truncated(Normal(1155, 216.84), 650, 1660))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(243, 68.37), 83, 402))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(102.5, 35.97), 18, 187))
            end
        else
            if is_male
                ig_g = rand(thread_rng[thread_id], truncated(Normal(1065, 242.3), 500, 1629))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(277, 95.92), 53.9, 500))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(113.5, 39), 22, 205))
            else
                ig_g = rand(thread_rng[thread_id], truncated(Normal(895, 165.8), 509, 1281))
                ig_a = rand(thread_rng[thread_id], truncated(Normal(226.5, 70.15), 63, 390))
                ig_m = rand(thread_rng[thread_id], truncated(Normal(116, 39.3), 24, 208))
            end
        end
        
        ig_level = (ig_g + ig_a + ig_m - min_ig_level) / max_min_ig_level_diff

        # Болен
        is_infected = false

        if age < 3
            if rand(thread_rng[thread_id], Float64) < 4896 / 272834
                is_infected = true
            end
        elseif age < 7
            if rand(thread_rng[thread_id], Float64) < 3615 / 319868
                is_infected = true
            end
        elseif age < 15
            if rand(thread_rng[thread_id], Float64) < 2906 / 559565
                is_infected = true
            end
        else
            if rand(thread_rng[thread_id], Float64) < 14928 / 8920401
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

        # Набор дней окончания типоспецифического иммунитета
        FluA_immunity_end = 0
        FluB_immunity_end = 0
        RV_immunity_end = 0
        RSV_immunity_end = 0
        AdV_immunity_end = 0
        PIV_immunity_end = 0
        CoV_immunity_end = 0

        if !is_infected
            if rand(thread_rng[thread_id], Float64) < 0.000206497
                FluA_days_immune = rand(thread_rng[thread_id], 211:217)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000281861
                FluA_days_immune = rand(thread_rng[thread_id], 204:210)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000660201
                FluA_days_immune = rand(thread_rng[thread_id], 197:203)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001605497
                FluA_days_immune = rand(thread_rng[thread_id], 190:196)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.003478317
                FluA_days_immune = rand(thread_rng[thread_id], 183:189)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.006433707
                FluA_days_immune = rand(thread_rng[thread_id], 176:182)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.010078104
                FluA_days_immune = rand(thread_rng[thread_id], 169:175)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.014095888
                FluA_days_immune = rand(thread_rng[thread_id], 162:168)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.016454683
                FluA_days_immune = rand(thread_rng[thread_id], 155:161)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.01634273
                FluA_days_immune = rand(thread_rng[thread_id], 148:154)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.012538951
                FluA_days_immune = rand(thread_rng[thread_id], 141:147)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.008756795
                FluA_days_immune = rand(thread_rng[thread_id], 134:140)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.004209558
                FluA_days_immune = rand(thread_rng[thread_id], 127:133)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002100738
                FluA_days_immune = rand(thread_rng[thread_id], 120:126)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001255956
                FluA_days_immune = rand(thread_rng[thread_id], 113:119)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.00080679
                FluA_days_immune = rand(thread_rng[thread_id], 106:112)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000458664
                FluA_days_immune = rand(thread_rng[thread_id], 99:105)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000309442
                FluA_days_immune = rand(thread_rng[thread_id], 92:98)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000201445
                FluA_days_immune = rand(thread_rng[thread_id], 85:91)
                FluA_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[1].immunity_duration, immunity_duration_sds[1]), 1.0, 1000.0)))
                if FluA_immunity_end < FluA_days_immune
                    FluA_immunity_end = FluA_days_immune
                end
            end

            if rand(thread_rng[thread_id], Float64) < 0.000261757
                FluB_days_immune = rand(thread_rng[thread_id], 197:203)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000606962
                FluB_days_immune = rand(thread_rng[thread_id], 190:196)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001020158
                FluB_days_immune = rand(thread_rng[thread_id], 183:189)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.00167279
                FluB_days_immune = rand(thread_rng[thread_id], 176:182)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002434718
                FluB_days_immune = rand(thread_rng[thread_id], 169:175)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002843872
                FluB_days_immune = rand(thread_rng[thread_id], 162:168)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002840032
                FluB_days_immune = rand(thread_rng[thread_id], 155:161)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002464019
                FluB_days_immune = rand(thread_rng[thread_id], 148:154)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002089219
                FluB_days_immune = rand(thread_rng[thread_id], 141:147)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001856047
                FluB_days_immune = rand(thread_rng[thread_id], 134:140)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001629948
                FluB_days_immune = rand(thread_rng[thread_id], 127:133)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000887825
                FluB_days_immune = rand(thread_rng[thread_id], 120:126)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000681328
                FluB_days_immune = rand(thread_rng[thread_id], 113:119)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000666778
                FluB_days_immune = rand(thread_rng[thread_id], 106:112)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000639699
                FluB_days_immune = rand(thread_rng[thread_id], 99:105)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000600091
                FluB_days_immune = rand(thread_rng[thread_id], 92:98)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000424715
                FluB_days_immune = rand(thread_rng[thread_id], 85:91)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000272578
                FluB_days_immune = rand(thread_rng[thread_id], 78:84)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.00025439
                FluB_days_immune = rand(thread_rng[thread_id], 71:77)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000219228
                FluB_days_immune = rand(thread_rng[thread_id], 64:70)
                FluB_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[2].immunity_duration, immunity_duration_sds[2]), 1.0, 1000.0)))
                if FluB_immunity_end < FluB_days_immune
                    FluB_immunity_end = FluB_days_immune
                end
            end

            if rand(thread_rng[thread_id], Float64) < 0.001578761
                RV_days_immune = rand(thread_rng[thread_id], 1:7)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001826452
                RV_days_immune = rand(thread_rng[thread_id], 8:14)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.00184949
                RV_days_immune = rand(thread_rng[thread_id], 15:21)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002444094
                RV_days_immune = rand(thread_rng[thread_id], 22:28)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.003069617
                RV_days_immune = rand(thread_rng[thread_id], 29:35)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.003399151
                RV_days_immune = rand(thread_rng[thread_id], 36:42)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.004222047
                RV_days_immune = rand(thread_rng[thread_id], 43:49)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.005706638
                RV_days_immune = rand(thread_rng[thread_id], 50:56)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.007519551
                RV_days_immune = rand(thread_rng[thread_id], 57:60)
                RV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[3].immunity_duration, immunity_duration_sds[3]), 1.0, 1000.0)))
                if RV_immunity_end < RV_days_immune
                    RV_immunity_end = RV_days_immune
                end
            end

            if rand(thread_rng[thread_id], Float64) < 0.000377428
                RSV_days_immune = rand(thread_rng[thread_id], 1:7)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000910397
                RSV_days_immune = rand(thread_rng[thread_id], 8:14)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001509851
                RSV_days_immune = rand(thread_rng[thread_id], 15:21)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002404082
                RSV_days_immune = rand(thread_rng[thread_id], 22:28)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.00274857
                RSV_days_immune = rand(thread_rng[thread_id], 29:35)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.00307083
                RSV_days_immune = rand(thread_rng[thread_id], 36:42)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.003956977
                RSV_days_immune = rand(thread_rng[thread_id], 43:49)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.005496332
                RSV_days_immune = rand(thread_rng[thread_id], 50:56)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.006939295
                RSV_days_immune = rand(thread_rng[thread_id], 57:63)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.004276811
                RSV_days_immune = rand(thread_rng[thread_id], 113:119)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.004852218
                RSV_days_immune = rand(thread_rng[thread_id], 106:112)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.005723613
                RSV_days_immune = rand(thread_rng[thread_id], 99:105)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.006328322
                RSV_days_immune = rand(thread_rng[thread_id], 92:98)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.006621885
                RSV_days_immune = rand(thread_rng[thread_id], 85:91)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.006368536
                RSV_days_immune = rand(thread_rng[thread_id], 78:84)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.006325695
                RSV_days_immune = rand(thread_rng[thread_id], 71:77)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.006643912
                RSV_days_immune = rand(thread_rng[thread_id], 64:70)
                trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[4].immunity_duration, immunity_duration_sds[4]), 1.0, 1000.0)))
                if RSV_immunity_end < RSV_days_immune
                    RSV_immunity_end = RSV_days_immune
                end
            end

            if rand(thread_rng[thread_id], Float64) < 0.000600061
                AdV_days_immune = rand(thread_rng[thread_id], 1:7)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000612994
                AdV_days_immune = rand(thread_rng[thread_id], 8:14)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000911205
                AdV_days_immune = rand(thread_rng[thread_id], 15:21)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001299343
                AdV_days_immune = rand(thread_rng[thread_id], 22:28)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001542791
                AdV_days_immune = rand(thread_rng[thread_id], 29:35)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001806042
                AdV_days_immune = rand(thread_rng[thread_id], 36:42)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001883237
                AdV_days_immune = rand(thread_rng[thread_id], 43:49)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002443286
                AdV_days_immune = rand(thread_rng[thread_id], 50:56)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002731393
                AdV_days_immune = rand(thread_rng[thread_id], 57:63)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002457432
                AdV_days_immune = rand(thread_rng[thread_id], 85:90)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002417824
                AdV_days_immune = rand(thread_rng[thread_id], 78:84)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002190947
                AdV_days_immune = rand(thread_rng[thread_id], 71:77)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002169728
                AdV_days_immune = rand(thread_rng[thread_id], 64:70)
                AdV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[5].immunity_duration, immunity_duration_sds[5]), 1.0, 1000.0)))
                if AdV_immunity_end < AdV_days_immune
                    AdV_immunity_end = AdV_days_immune
                end
            end

            if rand(thread_rng[thread_id], Float64) < 0.00067281
                PIV_days_immune = rand(thread_rng[thread_id], 1:7)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000671395
                PIV_days_immune = rand(thread_rng[thread_id], 8:14)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000655633
                PIV_days_immune = rand(thread_rng[thread_id], 15:21)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000938891
                PIV_days_immune = rand(thread_rng[thread_id], 22:28)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.00096698
                PIV_days_immune = rand(thread_rng[thread_id], 29:35)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.00096698
                PIV_days_immune = rand(thread_rng[thread_id], 36:42)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001221138
                PIV_days_immune = rand(thread_rng[thread_id], 43:49)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001546832
                PIV_days_immune = rand(thread_rng[thread_id], 50:56)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.002106275
                PIV_days_immune = rand(thread_rng[thread_id], 57:63)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001847267
                PIV_days_immune = rand(thread_rng[thread_id], 85:90)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001263979
                PIV_days_immune = rand(thread_rng[thread_id], 78:84)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001503789
                PIV_days_immune = rand(thread_rng[thread_id], 71:77)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001563403
                PIV_days_immune = rand(thread_rng[thread_id], 64:70)
                PIV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[6].immunity_duration, immunity_duration_sds[6]), 1.0, 1000.0)))
                if PIV_immunity_end < PIV_days_immune
                    PIV_immunity_end = PIV_days_immune
                end
            end

            if rand(thread_rng[thread_id], Float64) < 0.000395211
                CoV_days_immune = rand(thread_rng[thread_id], 211:217)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000346509
                CoV_days_immune = rand(thread_rng[thread_id], 204:210)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000361261
                CoV_days_immune = rand(thread_rng[thread_id], 197:203)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000608952
                CoV_days_immune = rand(thread_rng[thread_id], 190:196)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000638052
                CoV_days_immune = rand(thread_rng[thread_id], 183:189)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000689583
                CoV_days_immune = rand(thread_rng[thread_id], 176:182)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000932424
                CoV_days_immune = rand(thread_rng[thread_id], 169:175)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000984359
                CoV_days_immune = rand(thread_rng[thread_id], 162:168)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.001203557
                CoV_days_immune = rand(thread_rng[thread_id], 155:161)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000991634
                CoV_days_immune = rand(thread_rng[thread_id], 148:154)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000986178
                CoV_days_immune = rand(thread_rng[thread_id], 141:147)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000937072
                CoV_days_immune = rand(thread_rng[thread_id], 134:140)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000695847
                CoV_days_immune = rand(thread_rng[thread_id], 127:133)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000386521
                CoV_days_immune = rand(thread_rng[thread_id], 120:126)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000336001
                CoV_days_immune = rand(thread_rng[thread_id], 113:119)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000330343
                CoV_days_immune = rand(thread_rng[thread_id], 106:112)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000347924
                CoV_days_immune = rand(thread_rng[thread_id], 99:105)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000357421
                CoV_days_immune = rand(thread_rng[thread_id], 92:98)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000352774
                CoV_days_immune = rand(thread_rng[thread_id], 85:91)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000327918
                CoV_days_immune = rand(thread_rng[thread_id], 78:84)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            elseif rand(thread_rng[thread_id], Float64) < 0.000305082
                CoV_days_immune = rand(thread_rng[thread_id], 71:77)
                CoV_immunity_end = trunc(Int, rand(thread_rng[thread_id], truncated(Normal(viruses[7].immunity_duration, immunity_duration_sds[7]), 1.0, 1000.0)))
                if CoV_immunity_end < CoV_days_immune
                    CoV_immunity_end = CoV_days_immune
                end
            end
        end

        # Информация при болезни
        virus_id = 0
        incubation_period = 0
        infection_period = 0
        days_infected = 0
        is_asymptomatic = false
        is_isolated = false
        if is_infected
            # Тип инфекции
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.6
                virus_id = viruses[3].id
            elseif rand_num < 0.8
                virus_id = viruses[5].id
            else
                virus_id = viruses[6].id
            end

            # Инкубационный период
            incubation_period = get_period_from_erlang(
                viruses[virus_id].mean_incubation_period,
                viruses[virus_id].incubation_period_variance,
                viruses[virus_id].min_incubation_period,
                viruses[virus_id].max_incubation_period,
                thread_rng[thread_id])
            # Период болезни
            if age < 16
                infection_period = get_period_from_erlang(
                    viruses[virus_id].mean_infection_period_child,
                    viruses[virus_id].infection_period_variance_child,
                    viruses[virus_id].min_infection_period_child,
                    viruses[virus_id].max_infection_period_child,
                    thread_rng[thread_id])
            else
                infection_period = get_period_from_erlang(
                    viruses[virus_id].mean_infection_period_adult,
                    viruses[virus_id].infection_period_variance_adult,
                    viruses[virus_id].min_infection_period_adult,
                    viruses[virus_id].max_infection_period_adult,
                    thread_rng[thread_id])
            end

            # Дней с момента инфицирования
            days_infected = rand(thread_rng[thread_id], (1 - incubation_period):infection_period)

            if age < 10
                is_asymptomatic = rand(thread_rng[thread_id], Float64) > symptomatic_probabilities_children[virus_id]
            elseif age < 18
                is_asymptomatic = rand(thread_rng[thread_id], Float64) > symptomatic_probabilities_teenagers[virus_id]
            else
                is_asymptomatic = rand(thread_rng[thread_id], Float64) > symptomatic_probabilities_adults[virus_id]
            end

            if !is_asymptomatic
                if days_infected >= 1
                    rand_num = rand(thread_rng[thread_id], Float64)
                    if age < 3
                        if rand_num < 0.406
                            is_isolated = true
                        end
                    elseif age < 8
                        if rand_num < 0.305
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < 0.204
                            is_isolated = true
                        end
                    else
                        if rand_num < 0.101
                            is_isolated = true
                        end
                    end
                end
                if days_infected >= 2 && !is_isolated
                    rand_num = rand(thread_rng[thread_id], Float64)
                    if age < 3
                        if rand_num < 0.669
                            is_isolated = true
                        end
                    elseif age < 8
                        if rand_num < 0.576
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < 0.499
                            is_isolated = true
                        end
                    else
                        if rand_num < 0.334
                            is_isolated = true
                        end
                    end
                end
                if days_infected >= 3 && !is_isolated
                    rand_num = rand(thread_rng[thread_id], Float64)
                    if age < 3
                        if rand_num < 0.45
                            is_isolated = true
                        end
                    elseif age < 8
                        if rand_num < 0.325
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < 0.376
                            is_isolated = true
                        end
                    else
                        if rand_num < 0.168
                            is_isolated = true
                        end
                    end
                end
            end
        end

        attendance = true
        is_teacher = false

        days_immune = 0
        days_immune_end = 0
        
        new(
            id, age, infant_age, is_male, household_id, household_conn_ids,
            activity_type, 0, school_group_num, 0, Int[], Int[], Int[], 0, false,
            false, ig_level, virus_id, false, FluA_days_immune, FluB_days_immune, RV_days_immune,
            RSV_days_immune, AdV_days_immune, PIV_days_immune, CoV_days_immune,
            FluA_immunity_end, FluB_immunity_end, RV_immunity_end,
            RSV_immunity_end, AdV_immunity_end, PIV_immunity_end, CoV_immunity_end,
            incubation_period, infection_period, days_infected, days_immune, days_immune_end,
            is_asymptomatic, is_isolated, attendance, is_teacher, 0)
    end
end

# Найти значение вирусной нагрузки агента
function get_infectivity(
    days_infected::Int,
    incubation_period::Int,
    infection_period::Int,
    mean_viral_load::Float64,
    is_asymptomatic::Bool,
)::Float64
    if days_infected < 1
        if incubation_period == 1
            return mean_viral_load / 24
        end
        k = mean_viral_load / (incubation_period - 1)
        b = k * (incubation_period - 1)
        return (k * days_infected + b) / 12
    end
    if is_asymptomatic
        mean_viral_load /= 2.0
    end
    k = 2 * mean_viral_load / (1 - infection_period)
    b = -k * infection_period
    return (k * days_infected + b) / 12
end

# Получить длительность инкубационного периода или периода болезни
function get_period_from_erlang(
    mean::Float64,
    variance::Float64,
    low::Int,
    upper::Int,
    rng::MersenneTwister,
)::Int
    shape::Int = mean * mean ÷ variance
    scale::Float64 = mean / shape
    return round(
        rand(rng, truncated(
            Erlang(shape, scale), low, upper)))
end
