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
    # Число агентов, инфицированных данным агентом на текущем шаге
    num_infected_agents::Int

    quarantine_period::Int

    FluA_immunity_susceptibility_level::Float64
    FluB_immunity_susceptibility_level::Float64
    RV_immunity_susceptibility_level::Float64
    RSV_immunity_susceptibility_level::Float64
    AdV_immunity_susceptibility_level::Float64
    PIV_immunity_susceptibility_level::Float64
    CoV_immunity_susceptibility_level::Float64

    function Agent(
        id::Int,
        household_id::Int,
        viruses::Vector{Virus},
        num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
        # initially_infected::Vector{Float64},
        isolation_probabilities_day_1::Vector{Float64},
        isolation_probabilities_day_2::Vector{Float64},
        isolation_probabilities_day_3::Vector{Float64},
        household_conn_ids::Vector{Int},
        is_male::Bool,
        age::Int,
        rng::MersenneTwister,
        FluA_immune_memory_susceptibility_level::Float64,
        FluB_immune_memory_susceptibility_level::Float64,
        RV_immune_memory_susceptibility_level::Float64,
        RSV_immune_memory_susceptibility_level::Float64,
        AdV_immune_memory_susceptibility_level::Float64,
        PIV_immune_memory_susceptibility_level::Float64,
        CoV_immune_memory_susceptibility_level::Float64,
    )
        # Возраст новорожденного
        infant_age = 0
        if age == 0
            infant_age = rand(rng, 1:12)
        end

        # Социальный статус
        activity_type = 0
        # Household
        if age == 0
            activity_type = 0
        # 1-5 Kindergarten
        elseif age == 1
            if rand(rng, Float64) < 0.2
                activity_type = 1
            end
        elseif age == 2
            if rand(rng, Float64) < 0.33
                activity_type = 1
            end
        elseif age < 6
            if rand(rng, Float64) < 0.83
                activity_type = 1
            end
        # 6-7 Kindergarten - School
        elseif age == 6
            if rand(rng, Float64) < 0.7
                activity_type = 1
            else
                activity_type = 2
            end
        elseif age == 7
            if rand(rng, Float64) < 0.7
                activity_type = 2
            else
                activity_type = 1
            end
        # 8-16 School
        elseif age < 15
            activity_type = 2
        elseif age == 15
            if rand(rng, Float64) < 0.96
                activity_type = 2
            end
        elseif age == 16
            rand_num = rand(rng, Float64)
            if rand_num < 0.92
                activity_type = 2
            elseif rand_num < 0.95
                activity_type = 4
            end
        elseif age == 17
            rand_num = rand(rng, Float64)
            if rand_num < 0.72
                activity_type = 2
            elseif rand_num < 0.85
                activity_type = 4
            end
        elseif age == 18
            rand_num = rand(rng, Float64)
            if rand_num < 0.29
                activity_type = 2
            elseif rand_num < 0.55
                activity_type = 4
            elseif rand_num < 0.75
                activity_type = 3
            end
        # 18-23 College - Work
        elseif age < 22
            rand_num = rand(rng, Float64)
            if rand_num < 0.66
                activity_type = 4
            elseif rand_num < 0.9
                activity_type = 3
            end
        elseif age < 24
            rand_num = rand(rng, Float64)
            if rand_num < 0.75
                activity_type = 4
            elseif rand_num < 0.9
                activity_type = 3
            end
        # 24+ Work
        elseif age < 30
            if is_male
                if rand(rng, Float64) < 0.82
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.74
                    activity_type = 4
                end
            end
        elseif age < 40
            if is_male
                if rand(rng, Float64) < 0.95
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.85
                    activity_type = 4
                end
            end
        elseif age < 50
            if is_male
                if rand(rng, Float64) < 0.94
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.89
                    activity_type = 4
                end
            end
        elseif age < 55
            if is_male
                if rand(rng, Float64) < 0.88
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.7
                    activity_type = 4
                end
            end
        elseif age < 60
            if is_male
                if rand(rng, Float64) < 0.695
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.495
                    activity_type = 4
                end
            end
        elseif age < 65
            if is_male
                if rand(rng, Float64) < 0.51
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.29
                    activity_type = 4
                end
            end
        elseif age < 70
            if is_male
                if rand(rng, Float64) < 0.38
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.21
                    activity_type = 4
                end
            end
        elseif age < 75
            if is_male
                if rand(rng, Float64) < 0.25
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.15
                    activity_type = 4
                end
            end
        elseif age < 80
            if is_male
                if rand(rng, Float64) < 0.12
                    activity_type = 4
                end
            else
                if rand(rng, Float64) < 0.07
                    activity_type = 4
                end
            end
        end

        school_id = 0
        workplace_id = 0

        school_group_num = 0
        if activity_type == 1
            school_group_num = age
            if age == 1
                school_group_num = 1
            elseif age == 2
                school_group_num = rand(rng, 1:2)
            elseif age < 5
                school_group_num = rand(rng, (age - 2):age)
            elseif age == 5
                school_group_num = rand(rng, (age - 1):age)
            else
                school_group_num = 5
            end
        elseif activity_type == 2
            if age == 6
                school_group_num = 1
            elseif age == 7
                school_group_num = rand(rng, 1:2)
            elseif age < 17
                school_group_num = rand(rng, (age - 7):(age - 5))
            elseif age == 17
                if rand(rng, Float64) < 0.66
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
                school_group_num = rand(rng, 1:2)
            elseif age < 24
                school_group_num = rand(rng, (age - 19):(age - 17))
            else
                school_group_num = rand(rng, 5:6)
            end
        elseif activity_type == 4
            school_group_num = 1
        end

        supporter_id = 0
        needs_supporter_care = false
        on_parent_leave = false

        # Уровень иммуноглобулина
        ig_level = 0.0
        ig_g = 0.0
        ig_a = 0.0
        ig_m = 0.0
        min_ig_level = 238.87
        max_min_ig_level_diff = 2899.13
        if age == 0
            if infant_age == 1
                ig_g = rand(rng, truncated(Normal(953, 262.19), 399, 1480))
                ig_a = rand(rng, truncated(Normal(6.79, 0.45), 6.67, 8.75))
                ig_m = rand(rng, truncated(Normal(20.38, 8.87), 5.1, 50.9))
            elseif infant_age < 4
                ig_g = rand(rng, truncated(Normal(429.5, 145.59), 217, 981))
                ig_a = rand(rng, truncated(Normal(10.53, 5.16), 6.67, 24.6))
                ig_m = rand(rng, truncated(Normal(36.66, 13.55), 15.2, 68.5))
            elseif infant_age < 7
                ig_g = rand(rng, truncated(Normal(482.43, 236.8), 270, 1110))
                ig_a = rand(rng, truncated(Normal(19.86, 9.77), 6.67, 53))
                ig_m = rand(rng, truncated(Normal(75.44, 29.73), 26.9, 130))
            else
                ig_g = rand(rng, truncated(Normal(568.97, 186.62), 242, 977))
                ig_a = rand(rng, truncated(Normal(29.41, 12.37), 6.68, 114))
                ig_m = rand(rng, truncated(Normal(81.05, 35.76), 24.2, 162))
            end
        elseif age == 1
            ig_g = rand(rng, truncated(Normal(761.7, 238.61), 389, 1260))
            ig_a = rand(rng, truncated(Normal(37.62, 17.1), 13.1, 103))
            ig_m = rand(rng, truncated(Normal(122.57, 41.63), 38.6, 195))
        elseif age == 2
            ig_g = rand(rng, truncated(Normal(811.5, 249.14), 486, 1970))
            ig_a = rand(rng, truncated(Normal(59.77, 24.52), 6.67, 135))
            ig_m = rand(rng, truncated(Normal(111.31, 40.55), 42.7, 236))
        elseif age < 6
            ig_g = rand(rng, truncated(Normal(839.87, 164.19), 457, 1120))
            ig_a = rand(rng, truncated(Normal(68.98, 34.05), 35.7, 192))
            ig_m = rand(rng, truncated(Normal(121.79, 39.24), 58.7, 198))
        elseif age < 9
            ig_g = rand(rng, truncated(Normal(1014.93, 255.53), 483, 1580))
            ig_a = rand(rng, truncated(Normal(106.9, 49.66), 44.8, 276))
            ig_m = rand(rng, truncated(Normal(114.73, 41.27), 50.3, 242))
        elseif age < 12
            ig_g = rand(rng, truncated(Normal(1055.43, 322.27), 642, 2290))
            ig_a = rand(rng, truncated(Normal(115.99, 47.05), 32.6, 262))
            ig_m = rand(rng, truncated(Normal(113.18, 43.68), 37.4, 213))
        elseif age < 17
            ig_g = rand(rng, truncated(Normal(1142.07, 203.83), 636, 1610))
            ig_a = rand(rng, truncated(Normal(120.90, 47.51), 36.4, 305))
            ig_m = rand(rng, truncated(Normal(125.78, 39.31), 42.4, 197))
        elseif age < 19
            ig_g = rand(rng, truncated(Normal(1322.77, 361.89), 688, 2430))
            ig_a = rand(rng, truncated(Normal(201.84, 89.92), 46.3, 385))
            ig_m = rand(rng, truncated(Normal(142.54, 64.32), 60.7, 323))
        elseif age < 61
            if is_male
                ig_g = rand(rng, truncated(Normal(1250, 214.29), 751, 1750))
                ig_a = rand(rng, truncated(Normal(226.5, 65.56), 74, 385))
                ig_m = rand(rng, truncated(Normal(139, 41.84), 41, 237))
            else
                ig_g = rand(rng, truncated(Normal(1180, 193.8), 729, 1630))
                ig_a = rand(rng, truncated(Normal(233.5, 63), 87, 385))
                ig_m = rand(rng, truncated(Normal(140.5, 41), 44, 236))
            end
        elseif age < 71
            if is_male
                ig_g = rand(rng, truncated(Normal(1105, 232.1), 565, 1645))
                ig_a = rand(rng, truncated(Normal(231.5, 78.32), 49, 413.6))
                ig_m = rand(rng, truncated(Normal(101, 36.2), 16, 186))
            else
                ig_g = rand(rng, truncated(Normal(1155, 216.84), 650, 1660))
                ig_a = rand(rng, truncated(Normal(243, 68.37), 83, 402))
                ig_m = rand(rng, truncated(Normal(102.5, 35.97), 18, 187))
            end
        else
            if is_male
                ig_g = rand(rng, truncated(Normal(1065, 242.3), 500, 1629))
                ig_a = rand(rng, truncated(Normal(277, 95.92), 53.9, 500))
                ig_m = rand(rng, truncated(Normal(113.5, 39), 22, 205))
            else
                ig_g = rand(rng, truncated(Normal(895, 165.8), 509, 1281))
                ig_a = rand(rng, truncated(Normal(226.5, 70.15), 63, 390))
                ig_m = rand(rng, truncated(Normal(116, 39.3), 24, 208))
            end
        end
        ig_level = (ig_g + ig_a + ig_m - min_ig_level) / max_min_ig_level_diff

        # Информация при болезни
        is_infected = false
        virus_id = 0
        is_newly_infected = false
        incubation_period = 0
        infection_period = 0
        days_infected = 0
        is_asymptomatic = false
        is_isolated = false

        age_group = 4
        if age < 3
            age_group = 1
        elseif age < 7
            age_group = 2
        elseif age < 15
            age_group = 3
        end

        v = rand(3:6)
        if rand(rng, Float64) < (num_all_infected_age_groups_viruses_mean[52, v, age_group] + num_all_infected_age_groups_viruses_mean[51, v, age_group] + num_all_infected_age_groups_viruses_mean[50, v, age_group]) / num_agents_age_groups[age_group]
            is_infected = true
            virus_id = v
        end

        # Если задавать начальное число больных вручную
        # if rand(rng, Float64) < initially_infected[age_group]
        #     is_infected = true
        # end

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

        FluA_immunity_susceptibility_level = 1.0
        FluB_immunity_susceptibility_level = 1.0
        RV_immunity_susceptibility_level = 1.0
        RSV_immunity_susceptibility_level = 1.0
        AdV_immunity_susceptibility_level = 1.0
        PIV_immunity_susceptibility_level = 1.0
        CoV_immunity_susceptibility_level = 1.0

        # if virus_id != 1
        #     for week_num = 17:43
        #         if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 1, age_group] / num_agents_age_groups[age_group]
        #             FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
        #             FluA_days_immune = 365 - (week_num + 1) * 7 + 1
        #             if FluA_days_immune > FluA_immunity_end
        #                 FluA_immunity_end = 0
        #                 FluA_days_immune = 0
        #             else
        #                 FluA_immunity_susceptibility_level = find_immunity_susceptibility_level(FluA_days_immune, FluA_immunity_end, FluA_immune_memory_susceptibility_level)
        #             end
        #         end
        #     end
        # elseif virus_id != 2
        #     for week_num = 17:43
        #         if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 2, age_group] / num_agents_age_groups[age_group]
        #             FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
        #             FluB_days_immune = 365 - (week_num + 1) * 7 + 1
        #             if FluB_days_immune > FluB_immunity_end
        #                 FluB_immunity_end = 0
        #                 FluB_days_immune = 0
        #             else
        #                 FluB_immunity_susceptibility_level = find_immunity_susceptibility_level(FluB_days_immune, FluB_immunity_end, FluB_immune_memory_susceptibility_level)
        #             end
        #         end
        #     end
        # elseif virus_id != 3
        #     for week_num = 25:51
        #         if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 3, age_group] / num_agents_age_groups[age_group]
        #             RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
        #             RV_days_immune = 365 - (week_num + 1) * 7 + 1
        #             if RV_days_immune > RV_immunity_end
        #                 RV_immunity_end = 0
        #                 RV_days_immune = 0
        #             else
        #                 RV_immunity_susceptibility_level = find_immunity_susceptibility_level(RV_days_immune, RV_immunity_end, RV_immune_memory_susceptibility_level)
        #             end
        #         end
        #     end
        # elseif virus_id != 4
        #     for week_num = 25:51
        #         if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 4, age_group] / num_agents_age_groups[age_group]
        #             RSV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
        #             RSV_days_immune = 365 - (week_num + 1) * 7 + 1
        #             if RSV_days_immune > RSV_immunity_end
        #                 RSV_immunity_end = 0
        #                 RSV_days_immune = 0
        #             else
        #                 RSV_immunity_susceptibility_level = find_immunity_susceptibility_level(RSV_days_immune, RSV_immunity_end, RSV_immune_memory_susceptibility_level)
        #             end
        #         end
        #     end
        # elseif virus_id != 5
        #     for week_num = 25:51
        #         if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 5, age_group] / num_agents_age_groups[age_group]
        #             AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
        #             AdV_days_immune = 365 - (week_num + 1) * 7 + 1
        #             if AdV_days_immune > AdV_immunity_end
        #                 AdV_immunity_end = 0
        #                 AdV_days_immune = 0
        #             else
        #                 AdV_immunity_susceptibility_level = find_immunity_susceptibility_level(AdV_days_immune, AdV_immunity_end, AdV_immune_memory_susceptibility_level)
        #             end
        #         end
        #     end
        # elseif virus_id != 6
        #     for week_num = 25:51
        #         if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 6, age_group] / num_agents_age_groups[age_group]
        #             PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
        #             PIV_days_immune = 365 - (week_num + 1) * 7 + 1
        #             if PIV_days_immune > PIV_immunity_end
        #                 PIV_immunity_end = 0
        #                 PIV_days_immune = 0
        #             else
        #                 PIV_immunity_susceptibility_level = find_immunity_susceptibility_level(PIV_days_immune, PIV_immunity_end, PIV_immune_memory_susceptibility_level)
        #             end
        #         end
        #     end
        # elseif virus_id != 7
        #     for week_num = 17:43
        #         if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 7, age_group] / num_agents_age_groups[age_group]
        #             CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
        #             CoV_days_immune = 365 - (week_num + 1) * 7 + 1
        #             if CoV_days_immune > CoV_immunity_end
        #                 CoV_immunity_end = 0
        #                 CoV_days_immune = 0
        #             else
        #                 CoV_immunity_susceptibility_level = find_immunity_susceptibility_level(CoV_days_immune, CoV_immunity_end, CoV_immune_memory_susceptibility_level)
        #             end
        #         end
        #     end
        # end

        if virus_id != 1
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 1, age_group] / num_agents_age_groups[age_group]
                    FluA_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[1].mean_immunity_duration, viruses[1].immunity_duration_sd), 1.0, 1000.0)))
                    FluA_days_immune = 365 - week_num * 7 + 1
                    if FluA_days_immune > FluA_immunity_end
                        FluA_immunity_end = 0
                        FluA_days_immune = 0
                        FluA_immunity_susceptibility_level = FluA_immune_memory_susceptibility_level
                    else
                        FluA_immunity_susceptibility_level = find_immunity_susceptibility_level(FluA_days_immune, FluA_immunity_end, FluA_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if virus_id != 2
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 2, age_group] / num_agents_age_groups[age_group]
                    FluB_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[2].mean_immunity_duration, viruses[2].immunity_duration_sd), 1.0, 1000.0)))
                    FluB_days_immune = 365 - week_num * 7 + 1
                    if FluB_days_immune > FluB_immunity_end
                        FluB_immunity_end = 0
                        FluB_days_immune = 0
                        FluB_immunity_susceptibility_level = FluB_immune_memory_susceptibility_level
                    else
                        FluB_immunity_susceptibility_level = find_immunity_susceptibility_level(FluB_days_immune, FluB_immunity_end, FluB_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if virus_id != 3
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 3, age_group] / num_agents_age_groups[age_group]
                    RV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[3].mean_immunity_duration, viruses[3].immunity_duration_sd), 1.0, 1000.0)))
                    RV_days_immune = 365 - week_num * 7 + 1
                    if RV_days_immune > RV_immunity_end
                        RV_immunity_end = 0
                        RV_days_immune = 0
                        RV_immunity_susceptibility_level = RV_immune_memory_susceptibility_level
                    else
                        RV_immunity_susceptibility_level = find_immunity_susceptibility_level(RV_days_immune, RV_immunity_end, RV_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if virus_id != 4
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 4, age_group] / num_agents_age_groups[age_group]
                    RSV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[4].mean_immunity_duration, viruses[4].immunity_duration_sd), 1.0, 1000.0)))
                    RSV_days_immune = 365 - week_num * 7 + 1
                    if RSV_days_immune > RSV_immunity_end
                        RSV_immunity_end = 0
                        RSV_days_immune = 0
                        RSV_immunity_susceptibility_level = RSV_immune_memory_susceptibility_level
                    else
                        RSV_immunity_susceptibility_level = find_immunity_susceptibility_level(RSV_days_immune, RSV_immunity_end, RSV_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if virus_id != 5
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 5, age_group] / num_agents_age_groups[age_group]
                    AdV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[5].mean_immunity_duration, viruses[5].immunity_duration_sd), 1.0, 1000.0)))
                    AdV_days_immune = 365 - week_num * 7 + 1
                    if AdV_days_immune > AdV_immunity_end
                        AdV_immunity_end = 0
                        AdV_days_immune = 0
                        AdV_immunity_susceptibility_level = AdV_immune_memory_susceptibility_level
                    else
                        AdV_immunity_susceptibility_level = find_immunity_susceptibility_level(AdV_days_immune, AdV_immunity_end, AdV_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if virus_id != 6
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 6, age_group] / num_agents_age_groups[age_group]
                    PIV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[6].mean_immunity_duration, viruses[6].immunity_duration_sd), 1.0, 1000.0)))
                    PIV_days_immune = 365 - week_num * 7 + 1
                    if PIV_days_immune > PIV_immunity_end
                        PIV_immunity_end = 0
                        PIV_days_immune = 0
                        PIV_immunity_susceptibility_level = PIV_immune_memory_susceptibility_level
                    else
                        PIV_immunity_susceptibility_level = find_immunity_susceptibility_level(PIV_days_immune, PIV_immunity_end, PIV_immune_memory_susceptibility_level)
                    end
                end
            end
        end
        if virus_id != 7
            for week_num = 1:51
                if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, 7, age_group] / num_agents_age_groups[age_group]
                    CoV_immunity_end = trunc(Int, rand(rng, truncated(Normal(viruses[7].mean_immunity_duration, viruses[7].immunity_duration_sd), 1.0, 1000.0)))
                    CoV_days_immune = 365 - week_num * 7 + 1
                    if CoV_days_immune > CoV_immunity_end
                        CoV_immunity_end = 0
                        CoV_days_immune = 0
                        CoV_immunity_susceptibility_level = CoV_immune_memory_susceptibility_level
                    else
                        CoV_immunity_susceptibility_level = find_immunity_susceptibility_level(CoV_days_immune, CoV_immunity_end, CoV_immune_memory_susceptibility_level)
                    end
                end
            end
        end

        if is_infected
            # Инкубационный период
            incubation_period = get_period_from_erlang(
                viruses[virus_id].mean_incubation_period,
                viruses[virus_id].incubation_period_variance,
                viruses[virus_id].min_incubation_period,
                viruses[virus_id].max_incubation_period,
                rng)
            # Период болезни
            if age < 16
                infection_period = get_period_from_erlang(
                    viruses[virus_id].mean_infection_period_child,
                    viruses[virus_id].infection_period_variance_child,
                    viruses[virus_id].min_infection_period_child,
                    viruses[virus_id].max_infection_period_child,
                    rng)
            else
                infection_period = get_period_from_erlang(
                    viruses[virus_id].mean_infection_period_adult,
                    viruses[virus_id].infection_period_variance_adult,
                    viruses[virus_id].min_infection_period_adult,
                    viruses[virus_id].max_infection_period_adult,
                    rng)
            end

            # Дней с момента инфицирования
            days_infected = rand(rng, (1 - incubation_period):infection_period)

            rand_num = rand(rng, Float64)
            if age < 10
                is_asymptomatic = rand_num > viruses[virus_id].symptomatic_probability_child
            elseif age < 18
                is_asymptomatic = rand_num > viruses[virus_id].symptomatic_probability_teenager
            else
                is_asymptomatic = rand_num > viruses[virus_id].symptomatic_probability_adult
            end

            if !is_asymptomatic
                if days_infected >= 1
                    rand_num = rand(rng, Float64)
                    if age < 3
                        if rand_num < isolation_probabilities_day_1[1]
                            is_isolated = true
                        end
                    elseif age < 8
                        if rand_num < isolation_probabilities_day_1[2]
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < isolation_probabilities_day_1[3]
                            is_isolated = true
                        end
                    else
                        if rand_num < isolation_probabilities_day_1[4]
                            is_isolated = true
                        end
                    end
                end
                if days_infected >= 2 && !is_isolated
                    rand_num = rand(rng, Float64)
                    if age < 3
                        if rand_num < isolation_probabilities_day_2[1]
                            is_isolated = true
                        end
                    elseif age < 8
                        if rand_num < isolation_probabilities_day_2[2]
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < isolation_probabilities_day_2[3]
                            is_isolated = true
                        end
                    else
                        if rand_num < isolation_probabilities_day_2[4]
                            is_isolated = true
                        end
                    end
                end
                if days_infected >= 3 && !is_isolated
                    rand_num = rand(rng, Float64)
                    if age < 3
                        if rand_num < isolation_probabilities_day_3[1]
                            is_isolated = true
                        end
                    elseif age < 8
                        if rand_num < isolation_probabilities_day_3[2]
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < isolation_probabilities_day_3[3]
                            is_isolated = true
                        end
                    else
                        if rand_num < isolation_probabilities_day_3[4]
                            is_isolated = true
                        end
                    end
                end
            end
        end

        attendance = true
        if activity_type == 3 && rand(rng, Float64) < skip_college_probability
            attendance = false
        end

        is_teacher = false

        days_immune = 0
        days_immune_end = 0

        num_infected_agents = 0

        quarantine_period = 0

        new(
            id, age, infant_age, is_male, household_id, household_conn_ids,
            activity_type, school_id, school_group_num, workplace_id, Int[], Int[],
            Int[], supporter_id, needs_supporter_care, on_parent_leave, ig_level,
            virus_id, is_newly_infected, FluA_days_immune, FluB_days_immune,
            RV_days_immune, RSV_days_immune, AdV_days_immune, PIV_days_immune,
            CoV_days_immune, FluA_immunity_end, FluB_immunity_end, RV_immunity_end,
            RSV_immunity_end, AdV_immunity_end, PIV_immunity_end, CoV_immunity_end,
            incubation_period, infection_period, days_infected, days_immune,
            days_immune_end, is_asymptomatic, is_isolated, attendance, is_teacher,
            num_infected_agents, quarantine_period, FluA_immunity_susceptibility_level,
            FluB_immunity_susceptibility_level, RV_immunity_susceptibility_level,
            RSV_immunity_susceptibility_level, AdV_immunity_susceptibility_level,
            PIV_immunity_susceptibility_level, CoV_immunity_susceptibility_level)
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

function find_immunity_susceptibility_level(
    days_immune::Int,
    immunity_end::Int,
    immune_memory_susceptibility_level::Float64,
)::Float64
    # return 0.0
    if days_immune > immunity_end
        return immune_memory_susceptibility_level
    end
    k = immune_memory_susceptibility_level / (immunity_end - 1)
    # return k * days_immune - k
    return immune_memory_susceptibility_level / (immunity_end - 1) * (days_immune - 1)
end
