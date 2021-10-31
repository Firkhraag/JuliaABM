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
    # Id детей за которыми нужен уход в случае болезни
    dependant_ids::Vector{Int}
    # Id того, кто будет ухаживать в случае болезни
    supporter_id::Int
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
    # Продолжительность инкубационного периода
    incubation_period::Int
    # Продолжительность периода болезни
    infection_period::Int
    # День с момента инфицирования
    days_infected::Int
    # Дней в резистентном состоянии
    days_immune::Int
    # Бессимптомное течение болезни
    is_asymptomatic::Bool
    # На больничном
    is_isolated::Bool
    # Инфекционность
    infectivity::Float64

    # Посещение детсада, школы, университета
    attendance::Bool
    # Учитель, воспитатель, профессор
    is_teacher::Bool

    function Agent(
        id::Int,
        household_id::Int,
        viruses::Vector{Virus},
        infectivities::Array{Float64, 4},
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
            if rand(thread_rng[thread_id], Float64) < 0.66
                activity_type = 1
            else
                activity_type = 2
            end
        elseif age == 7
            if rand(thread_rng[thread_id], Float64) < 0.66
                activity_type = 2
            else
                activity_type = 1
            end
        # 8-16 School
        elseif age < 17
            activity_type = 2
        elseif age == 17
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.8
                activity_type = 2
            elseif rand_num < 0.9
                activity_type = 4
            end
        elseif age == 18
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.28
                activity_type = 2
            elseif rand_num < 0.45
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
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.82
                    activity_type = 4
                end
            else
                if rand_num < 0.74
                    activity_type = 4
                end
            end
        elseif age < 40
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.95
                    activity_type = 4
                end
            else
                if rand_num < 0.85
                    activity_type = 4
                end
            end
        elseif age < 50
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.94
                    activity_type = 4
                end
            else
                if rand_num < 0.89
                    activity_type = 4
                end
            end
        elseif age < 60
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.88
                    activity_type = 4
                end
            else
                if rand_num < 0.7
                    activity_type = 4
                end
            end
        elseif age < 65
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.51
                    activity_type = 4
                end
            else
                if rand_num < 0.29
                    activity_type = 4
                end
            end
        elseif age < 70
            if is_male
                if rand(thread_rng[thread_id], Float64) < 0.25
                    activity_type = 4
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.15
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
                # school_group_num = age - 6
            elseif age == 17
                school_group_num = rand(thread_rng[thread_id], 10:11)
                # school_group_num = age - 6
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
            if rand(thread_rng[thread_id], Float64) < 0.016
                is_infected = true
            end
        elseif age < 7
            if rand(thread_rng[thread_id], Float64) < 0.01
                is_infected = true
            end
        elseif age < 15
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
        virus_id = 0
        incubation_period = 0
        infection_period = 0
        days_infected = 0
        is_asymptomatic = false
        is_isolated = false
        infectivity = 0.0
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

            asymp_prob = 0.0
            if age < 16
                asymp_prob = viruses[virus_id].asymptomatic_probab_child
            else
                asymp_prob = viruses[virus_id].asymptomatic_probab_adult
            end

            if rand(thread_rng[thread_id], Float64) < asymp_prob
                # Асимптомный
                is_asymptomatic = true
            else
                # Самоизоляция
                if days_infected >= 1
                    rand_num = rand(thread_rng[thread_id], Float64)
                    if age < 8
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
                    if age < 8
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
                    if age < 8
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

            # Вирусная нагрузкаx
            infectivity = find_agent_infectivity(
                age, infectivities[virus_id, incubation_period, infection_period - 1, days_infected + 7],
                is_asymptomatic && days_infected > 0)
        end

        attendance = true
        is_teacher = false
        if activity_type == 1
            if rand(thread_rng[thread_id], Float64) < 0.1
                attendance = false
            end
        elseif activity_type == 2
            if rand(thread_rng[thread_id], Float64) < 0.1
                attendance = false
            end
        elseif activity_type == 3
            if rand(thread_rng[thread_id], Float64) < 0.5
                attendance = false
            end
        end

        days_immune = 0

        new(
            id, age, infant_age, is_male, household_id, household_conn_ids,
            activity_type, 0, school_group_num, 0, Int[], Int[], Int[], 0, false,
            ig_level, virus_id, false, FluA_days_immune, FluB_days_immune, RV_days_immune,
            RSV_days_immune, AdV_days_immune, PIV_days_immune, CoV_days_immune,
            incubation_period, infection_period, days_infected, days_immune,
            is_asymptomatic, is_isolated, infectivity, attendance, is_teacher)
            # 0, false, false, false, false, false, false)
    end
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

# Получить вирусную нагрузку
function find_agent_infectivity(
    age::Int,
    infectivity_value::Float64,
    is_infectivity_halved::Bool,
)::Float64
    if age < 3
        if is_infectivity_halved
            return infectivity_value * 0.5
        else
            return infectivity_value
        end
    elseif age < 16
        if is_infectivity_halved
            return infectivity_value * 0.375
        else
            return infectivity_value * 0.75
        end
    else
        if is_infectivity_halved
            return infectivity_value * 0.25
        else
            return infectivity_value * 0.5
        end
    end
end
