# Агент
mutable struct Agent
    # Идентификатор
    id::Int
    # Возраст
    age::Int
    # Возраст новорожденного агента-ребенка
    infant_age::Int
    # Пол
    is_male::Bool
    # Id домохозяйства
    household_id::Int
    # Связи в домохозяйстве (id агентов)
    household_conn_ids::Vector{Int}
    # Тип коллектива, к которому привязан агент
    activity_type::Int
    # Id образовательного учреждения
    school_id::Int
    # Номер группы в образовательном учреждении
    school_group_num::Int
    # Id рабочего коллектива
    workplace_id::Int
    # Связи в рабочем коллективе или группе образовательного учреждения
    activity_conn_ids::Vector{Int}
    # Связи между группами образовательного учреждения
    activity_cross_conn_ids::Vector{Int}
    # Id детей в домохозяйстве младше 12 лет
    dependant_ids::Vector{Int}
    # Id попечителя в домохозяйстве
    supporter_id::Int
    # Если агент-ребенок нуждается в уходе при болезни
    needs_supporter_care::Bool
    # Уход за больным ребенком
    on_parent_leave::Bool
    # Уровень иммуноглобулинов
    ig_level::Float64
    # Id вируса, которым инфицирован агент
    virus_id::Int
    # Если агент был заражен на текущем шаге
    is_newly_infected::Bool
    # Счетчики числа дней после приобретения типоспецифических иммунитетов
    viruses_days_immune::Vector{Int}
    # Продолжительности типоспецифических иммунитетов
    viruses_immunity_end::Vector{Int}
    # Продолжительность инкубационного периода
    incubation_period::Int
    # Продолжительность периода болезни
    infection_period::Int
    # День с момента инфицирования
    days_infected::Int
    # Счетчик числа дней в резистентном состоянии
    days_immune::Int
    # Продолжительность резистентного состояния
    days_immune_end::Int
    # Бессимптомное течение болезни
    is_asymptomatic::Bool
    # На больничном
    is_isolated::Bool
    # Посещение образовательного учреждения
    attendance::Bool
    # Является ли агент учителем, воспитателем или профессором
    is_teacher::Bool
    # Число агентов, инфицированных данным агентом на текущем шаге
    num_infected_agents::Int
    # Число дней на школьном карантине
    quarantine_period::Int
    # Уровни специфической восприимчивости к вирусам
    immunity_susceptibility_levels::Vector{Float64}

    function Agent(
        # Идентификатор
        id::Int,
        # Id домохозяйства
        household_id::Int,
        # Вирусы
        viruses::Vector{Virus},
        # Средняя заболеваемость по неделям, возрастным группам и вирусам
        num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
        # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
        isolation_probabilities_day_1::Vector{Float64},
        isolation_probabilities_day_2::Vector{Float64},
        isolation_probabilities_day_3::Vector{Float64},
        # Id агентов, с которыми имеется связь в домохозяйстве
        household_conn_ids::Vector{Int},
        # Пол
        is_male::Bool,
        # Возраст
        age::Int,
        # Генератор случайных чисел
        rng::MersenneTwister,
    )
        # Возраст новорожденного
        infant_age = 0
        if age == 0
            infant_age = rand(rng, 1:12)
        end

        # Социальный статус
        activity_type = 0
        # 0 лет: агент сидит дома
        if age == 0
            activity_type = 0
        # 1-5 лет: посещение детского сада
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
        # 6-7 лет: посещение детского сада / школы
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
        # 8-15 лет: посещение школы
        elseif age < 15
            activity_type = 2
        elseif age == 15
            if rand(rng, Float64) < 0.96
                activity_type = 2
            end
        # 16-18 лет: посещение школы / вуза
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
        # 19-23 лет: посещение вуза / работы
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
        # 24+ лет: посещение работы
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

        # Значения по умолчанию
        school_id = 0
        workplace_id = 0

        # Находим номер группы в образовательном учреждении, в которой состоит детсадовец / школьник / студент
        # Максимальный разброс возрастов агентов в группе - 3
        school_group_num = 0
        # Детский сад
        if activity_type == 1
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
        # Школа
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
        # Вуз
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
        # Работа
        elseif activity_type == 4
            # Только одна группа
            school_group_num = 1
        end

        # Значения по умолчанию
        supporter_id = 0
        needs_supporter_care = false
        on_parent_leave = false

        # Общий уровень иммуноглобулинов
        ig_level = 0.0
        # IgG
        ig_g = 0.0
        # IgA
        ig_a = 0.0
        # IgM
        ig_m = 0.0
        # Минимальный общий уровень иммуноглобулинов
        min_ig_level = 238.87
        # Разница между максимальным и минимальным общими уровенями иммуноглобулинов
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
        # Нормализованный общий уровень иммуноглобулинов
        ig_level = (ig_g + ig_a + ig_m - min_ig_level) / max_min_ig_level_diff

        # Информация при болезни
        # Значения по умолчанию
        is_infected = false
        virus_id = 0
        is_newly_infected = false
        incubation_period = 0
        infection_period = 0
        days_infected = 0
        is_asymptomatic = false
        is_isolated = false

        # Возрастная группа
        age_group = 4
        if age < 3
            age_group = 1
        elseif age < 7
            age_group = 2
        elseif age < 15
            age_group = 3
        end

        # Инфицирование агентов перед началом работы модели
        v = rand(3:6)
        if rand(rng, Float64) < (num_all_infected_age_groups_viruses_mean[52, v, age_group] + num_all_infected_age_groups_viruses_mean[51, v, age_group] + num_all_infected_age_groups_viruses_mean[50, v, age_group]) / num_agents_age_groups[age_group]
            is_infected = true
            virus_id = v
        end

        # Информация по иммунитету к вирусам
        viruses_days_immune = zeros(Int, num_viruses)
        viruses_immunity_end = zeros(Int, num_viruses)
        immunity_susceptibility_levels = zeros(Float64, num_viruses) .+ 1.0

        for i = 1:num_viruses
            if virus_id != i
                for week_num = 1:51
                    if rand(rng, Float64) < num_all_infected_age_groups_viruses_mean[week_num, i, age_group] / num_agents_age_groups[age_group]
                        viruses_immunity_end[i] = trunc(Int, rand(rng, truncated(Normal(viruses[i].mean_immunity_duration, viruses[i].immunity_duration_sd), min_immunity_duration, max_immunity_duration)))
                        viruses_days_immune[i] = 365 - week_num * 7 + 1
                        if viruses_days_immune[i] > viruses_immunity_end[i]
                            viruses_immunity_end[i] = 0
                            viruses_days_immune[i] = 0
                        else
                            immunity_susceptibility_levels[i] = find_immunity_susceptibility_level(viruses_days_immune[i], viruses_immunity_end[i])
                        end
                    end
                end
            end
        end

        # Если агент инфицирован
        if is_infected
            # Инкубационный период
            incubation_period = round(Int, rand(rng, truncated(
                Gamma(viruses[virus_id].incubation_period_shape, viruses[virus_id].incubation_period_scale), min_incubation_period, max_incubation_period)))
            # Период болезни
            if age < 16
                infection_period = round(Int, rand(rng, truncated(
                    Gamma(viruses[virus_id].infection_period_child_shape, viruses[virus_id].infection_period_child_scale), min_infection_period, max_infection_period)))
            else
                infection_period = round(Int, rand(rng, truncated(
                    Gamma(viruses[virus_id].infection_period_adult_shape, viruses[virus_id].infection_period_adult_scale), min_infection_period, max_infection_period)))
            end

            # Дней с момента инфицирования
            days_infected = rand(rng, 1:(infection_period + incubation_period))

            # Бессимптомное течение болезни
            if age < 10
                is_asymptomatic = rand(rng, Float64) > viruses[virus_id].symptomatic_probability_child
            elseif age < 18
                is_asymptomatic = rand(rng, Float64) > viruses[virus_id].symptomatic_probability_teenager
            else
                is_asymptomatic = rand(rng, Float64) > viruses[virus_id].symptomatic_probability_adult
            end

            # Если имеются симптомы, то есть вероятность, что агент самоизолируется
            if !is_asymptomatic
                # 1-й день болезни
                if days_infected > incubation_period
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
                # 2-й день болезни
                if days_infected > incubation_period + 1 && !is_isolated
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
                # 3-й день болезни
                if days_infected > incubation_period + 2 && !is_isolated
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

        # Посещение коллектива
        attendance = true
        # Для вузов есть вероятность прогула
        if activity_type == 3 && rand(rng, Float64) < skip_college_probability
            attendance = false
        end
        # Значения по умолчанию
        is_teacher = false
        days_immune = 0
        days_immune_end = 0
        num_infected_agents = 0
        quarantine_period = 0

        new(
            id, age, infant_age, is_male, household_id, household_conn_ids,
            activity_type, school_id, school_group_num, workplace_id, Int[], Int[],
            Int[], supporter_id, needs_supporter_care, on_parent_leave, ig_level,
            virus_id, is_newly_infected, viruses_days_immune, viruses_immunity_end,
            incubation_period, infection_period, days_infected, days_immune,
            days_immune_end, is_asymptomatic, is_isolated, attendance, is_teacher,
            num_infected_agents, quarantine_period, immunity_susceptibility_levels)
    end
end

# Вирусная нагрузка агента
function get_infectivity(
    # Счетчик числа дней в инфицированном состоянии
    days_infected::Int,
    # Продолжительность инкубационного периода
    incubation_period::Int,
    # Продолжительность периода болезни
    infection_period::Int,
    # Средняя вирусная нагрузка
    mean_viral_load::Float64,
    # Бессимптомное течение болезни
    is_asymptomatic::Bool,
)::Float64
    # Если инкубационный период
    if days_infected <= incubation_period
        # Если продолжительность инкубационного периода = 1
        if incubation_period == 1
            return mean_viral_load / 24
        end
        return mean_viral_load / 12 * (days_infected - 1) / (incubation_period - 1)
    # Если период болезни
    else
        result = mean_viral_load / 6 * (days_infected - incubation_period - infection_period) / (1 - infection_period)
        # Если бессимптомное течение
        if is_asymptomatic
            result /= 2
        end
        return result
    end
end

# Специфическая восприимчивость к вирусу, после перенесенной болезни
function find_immunity_susceptibility_level(
    # Счетчик числа дней с иммунитетом
    days_immune::Int,
    # Продолжительность иммунитета
    immunity_end::Int,
)::Float64
    # Если иммунитет закончился
    if days_immune > immunity_end
        return 1.0
    end
    return 1.0 / (immunity_end - 1) * (days_immune - 1)
end
