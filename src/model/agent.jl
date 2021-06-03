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
    # Связи в домохозяйстве
    household_conn_ids::Vector{Int}
    # Id коллектива
    collective_id::Int
    # Номер группы
    group_num::Int
    # Связи в коллективе
    collective_conn_ids::Vector{Int}
    collective_cross_conn_ids::Vector{Int}
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
    # Набор дней после приобретения непродолжительных типоспецифических иммунитетов
    RV_days_immune::Int
    RSV_days_immune::Int
    AdV_days_immune::Int
    PIV_days_immune::Int
    # Набор годовых типоспецифических иммунитетов
    FluA_immunity::Bool
    FluB_immunity::Bool
    CoV_immunity::Bool
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

    function Agent(
        id::Int,
        viruses::Vector{Virus},
        infectivities::Array{Float64, 4},
        household_conn_ids::Vector{Int},
        is_male::Bool,
        age::Int,
        thread_id::Int,
        thread_rng::Vector{MersenneTwister},
        num_of_people_in_kindergarten::Vector{Int},
        num_of_people_in_school::Vector{Int},
        num_of_people_in_university::Vector{Int},
        num_of_people_in_workplace::Vector{Int}
    )
        # Возраст новорожденного
        infant_age = 0
        if age == 0
            infant_age = rand(thread_rng[thread_id], 1:12)
        end

        # Социальный статус
        collective_id = 0
        if age == 0
            collective_id = 0
        elseif age == 1
            if rand(thread_rng[thread_id], Float64) < 0.2
                collective_id = 1
            end
        elseif age == 2
            if rand(thread_rng[thread_id], Float64) < 0.33
                collective_id = 1
            end
        elseif age < 7
            if rand(thread_rng[thread_id], Float64) < 0.83
                collective_id = 1
            end
        elseif age < 18
            collective_id = 2
        elseif age < 22
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.33
                collective_id = 3
            elseif rand_num < 0.66
                collective_id = 4
            end
        elseif age < 24
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.82
                collective_id = 4
            elseif rand_num < 0.88
                collective_id = 3
            end
        elseif age < 30
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.82
                    collective_id = 4
                end
            else
                if rand_num < 0.74
                    collective_id = 4
                end
            end
        elseif age < 40
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.95
                    collective_id = 4
                end
            else
                if rand_num < 0.85
                    collective_id = 4
                end
            end
        elseif age < 50
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.94
                    collective_id = 4
                end
            else
                if rand_num < 0.89
                    collective_id = 4
                end
            end
        elseif age < 60
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.88
                    collective_id = 4
                end
            else
                if rand_num < 0.7
                    collective_id = 4
                end
            end
        elseif age < 65
            rand_num = rand(thread_rng[thread_id], Float64)
            if is_male
                if rand_num < 0.51
                    collective_id = 4
                end
            else
                if rand_num < 0.29
                    collective_id = 4
                end
            end
        end

        group_num = 0
        if collective_id == 1
            group_num = age
        elseif collective_id == 2
            group_num = age - 6
        elseif collective_id == 3
            group_num = age - 17
        elseif collective_id == 4
            group_num = 1
        end

        if collective_id == 1
            num_of_people_in_kindergarten[group_num] += 1
        elseif collective_id == 2
            num_of_people_in_school[group_num] += 1
        elseif collective_id == 3
            num_of_people_in_university[group_num] += 1
        elseif collective_id == 4
            num_of_people_in_workplace[1] += 1
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

        # Набор дней после приобретения типоспецифического иммунитета кроме гриппа
        RV_days_immune = 0
        RSV_days_immune = 0
        AdV_days_immune = 0
        PIV_days_immune = 0

        if !is_infected
            if age < 3
                if rand(thread_rng[thread_id], Float64) < 0.63
                    rand_num = rand(thread_rng[thread_id], Float64)
                    if rand_num < 0.6
                        RV_days_immune = rand(thread_rng[thread_id], 1:60)
                    elseif rand_num < 0.8
                        AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                    else
                        PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                    end
                end
            elseif age < 7
                if rand(thread_rng[thread_id], Float64) < 0.44
                    rand_num = rand(thread_rng[thread_id], Float64)
                    if rand_num < 0.6
                        RV_days_immune = rand(thread_rng[thread_id], 1:60)
                    elseif rand_num < 0.8
                        AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                    else
                        PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                    end
                end
            elseif age < 15
                if rand(thread_rng[thread_id], Float64) < 0.37
                    rand_num = rand(thread_rng[thread_id], Float64)
                    if rand_num < 0.6
                        RV_days_immune = rand(thread_rng[thread_id], 1:60)
                    elseif rand_num < 0.8
                        AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                    else
                        PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                    end
                end
            else
                if rand(thread_rng[thread_id], Float64) < 0.2
                    rand_num = rand(thread_rng[thread_id], Float64)
                    if rand_num < 0.6
                        RV_days_immune = rand(thread_rng[thread_id], 1:60)
                    elseif rand_num < 0.8
                        AdV_days_immune = rand(thread_rng[thread_id], 1:60)
                    else
                        PIV_days_immune = rand(thread_rng[thread_id], 1:60)
                    end
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

            if rand(thread_rng[thread_id], Float64) < viruses[virus_id].asymptomatic_probab
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

        days_immune = 0

        new(
            id, age, infant_age, is_male, household_conn_ids,
            collective_id, group_num,
            Int[], Int[], Int[], 0, false, ig_level,
            virus_id, false, RV_days_immune,
            RSV_days_immune, AdV_days_immune, PIV_days_immune,
            false, false, false,
            incubation_period, infection_period, days_infected,
            days_immune, is_asymptomatic, is_isolated, infectivity)
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
    return round(rand(rng, truncated(Erlang(shape, scale), low, upper)))
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
