include("virus.jl")
include("collective.jl")

mutable struct Agent
    # Идентификатор
    id::Int
    # Возраст
    age::Int
    # Возраст новорожденного
    infant_age::Int
    # Пол
    is_male::Bool
    # Социальный статус
    social_status::Int
    # Связи в коллективе
    work_conn_ids::Vector{Int}
    # Дети за которыми нужен уход в случае болезни
    dependant_ids::Vector{Int}
    # Кто будет ухаживать в случае болезни
    supporter_id::Int
    # Уход за больным ребенком
    on_parent_leave::Bool
    # Уровень иммуноглобулина
    ig_level::Float64
    # Вирус
    virus_id::Int
    # Набор дней после приобретения типоспецифического иммунитета кроме гриппа
    immunity_days::Vector{Int}
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
    # Вирусная нагрузка
    viral_load::Float64
    # ...
    was_infected_on_current_step::Bool
    # Домохозяйство
    household::Group
    # Группа
    group::Union{Group, Nothing}

    function Agent(
        id::Int,
        viruses::Vector{Virus},
        viral_loads::Array{Float64, 4},
        household::Group,
        is_male::Bool,
        age::Int
    )
        # Возраст новорожденного
        infant_age = 0
        if age == 0
            infant_age = rand(1:12)
        end

        # Социальный статус
        social_status = 0 # безработный
        if age < 3
            if rand(1:100) < 24
                social_status = 1 # детсад
            end
        elseif age < 6
            if rand(1:100) < 84
                social_status = 1 # детсад
            end
        elseif age == 6
            if rand(1:100) < 76
                social_status = 1 # детсад
            else
                social_status = 2 # школа
            end
        elseif age < 18
            social_status = 2 # школа
        elseif age == 18
            rand_num = rand(1:100)
            if rand_num < 51
                social_status = 2 # школа
            elseif rand_num < 76
                social_status = 3 # универ
            elseif rand_num < 86
                social_status = 4 # работа
            end
        elseif age < 23
            rand_num = rand(1:100)
            if rand_num < 34
                social_status = 3 # универ
            elseif rand_num < 67
                social_status = 4 # работа
            end
        elseif age < 25
            rand_num = rand(1:100)
            if rand_num < 83
                social_status = 4 # работа
            elseif rand_num < 89
                social_status = 3 # универ
            end
        elseif age < 30
            rand_num = rand(1:100)
            if is_male
                if rand_num < 83
                    social_status = 4 # работа
                end
            else
                if rand_num < 75
                    social_status = 4 # работа
                end
            end
        elseif age < 40
            rand_num = rand(1:100)
            if is_male
                if rand_num < 96
                    social_status = 4 # работа
                end
            else
                if rand_num < 86
                    social_status = 4 # работа
                end
            end
        elseif age < 50
            rand_num = rand(1:100)
            if is_male
                if rand_num < 95
                    social_status = 4 # работа
                end
            else
                if rand_num < 90
                    social_status = 4 # работа
                end
            end
        elseif age < 60
            rand_num = rand(1:100)
            if is_male
                if rand_num < 89
                    social_status = 4 # работа
                end
            else
                if rand_num < 71
                    social_status = 4 # работа
                end
            end
        elseif age < 65
            rand_num = rand(1:100)
            if is_male
                if rand_num < 52
                    social_status = 4 # работа
                end
            else
                if rand_num < 30
                    social_status = 4 # работа
                end
            end
        end

        # Уровень иммуноглобулина
        ig_level = 0.0
        ig_g = 0.0
        ig_a = 0.0
        ig_m = 0.0
        max_ig_level = 3138.0
        min_ig_level = 238.87
        max_min_ig_level_diff = 2899.13
        if age == 0
            if infant_age == 1
                ig_g = rand(truncated(Normal(953, 262.19), 399, 1480))
                ig_a = rand(truncated(Normal(6.79, 0.45), 6.67, 8.75))
                ig_m = rand(truncated(Normal(20.38, 8.87), 5.1, 50.9))
            elseif infant_age < 4
                ig_g = rand(truncated(Normal(429.5, 145.59), 217, 981))
                ig_a = rand(truncated(Normal(10.53, 5.16), 6.67, 24.6))
                ig_m = rand(truncated(Normal(36.66, 13.55), 15.2, 68.5))
            elseif infant_age < 7
                ig_g = rand(truncated(Normal(482.43, 236.8), 270, 1110))
                ig_a = rand(truncated(Normal(19.86, 9.77), 6.67, 53))
                ig_m = rand(truncated(Normal(75.44, 29.73), 26.9, 130))
            else
                ig_g = rand(truncated(Normal(568.97, 186.62), 242, 977))
                ig_a = rand(truncated(Normal(29.41, 12.37), 6.68, 114))
                ig_m = rand(truncated(Normal(81.05, 35.76), 24.2, 162))
            end
        elseif age == 1
            ig_g = rand(truncated(Normal(761.7, 238.61), 389, 1260))
            ig_a = rand(truncated(Normal(37.62, 17.1), 13.1, 103))
            ig_m = rand(truncated(Normal(122.57, 41.63), 38.6, 195))
        elseif age == 2
            ig_g = rand(truncated(Normal(811.5, 249.14), 486, 1970))
            ig_a = rand(truncated(Normal(59.77, 24.52), 6.67, 135))
            ig_m = rand(truncated(Normal(111.31, 40.55), 42.7, 236))
        elseif age < 6
            ig_g = rand(truncated(Normal(839.87, 164.19), 457, 1120))
            ig_a = rand(truncated(Normal(68.98, 34.05), 35.7, 192))
            ig_m = rand(truncated(Normal(121.79, 39.24), 58.7, 198))
        elseif age < 9
            ig_g = rand(truncated(Normal(1014.93, 255.53), 483, 1580))
            ig_a = rand(truncated(Normal(106.9, 49.66), 44.8, 276))
            ig_m = rand(truncated(Normal(114.73, 41.27), 50.3, 242))
        elseif age < 12
            ig_g = rand(truncated(Normal(1055.43, 322.27), 642, 2290))
            ig_a = rand(truncated(Normal(115.99, 47.05), 32.6, 262))
            ig_m = rand(truncated(Normal(113.18, 43.68), 37.4, 213))
        elseif age < 17
            ig_g = rand(truncated(Normal(1142.07, 203.83), 636, 1610))
            ig_a = rand(truncated(Normal(120.90, 47.51), 36.4, 305))
            ig_m = rand(truncated(Normal(125.78, 39.31), 42.4, 197))
        elseif age < 19
            ig_g = rand(truncated(Normal(1322.77, 361.89), 688, 2430))
            ig_a = rand(truncated(Normal(201.84, 89.92), 46.3, 385))
            ig_m = rand(truncated(Normal(142.54, 64.32), 60.7, 323))
        elseif age < 61
            if is_male
                ig_g = rand(truncated(Normal(1250, 214.29), 751, 1750))
                ig_a = rand(truncated(Normal(226.5, 65.56), 74, 385))
                ig_m = rand(truncated(Normal(139, 41.84), 41, 237))
            else
                ig_g = rand(truncated(Normal(1180, 193.8), 729, 1630))
                ig_a = rand(truncated(Normal(233.5, 63), 87, 385))
                ig_m = rand(truncated(Normal(140.5, 41), 44, 236))
            end
        elseif age < 71
            if is_male
                ig_g = rand(truncated(Normal(1105, 232.1), 565, 1645))
                ig_a = rand(truncated(Normal(231.5, 78.32), 49, 413.6))
                ig_m = rand(truncated(Normal(101, 36.2), 16, 186))
            else
                ig_g = rand(truncated(Normal(1155, 216.84), 650, 1660))
                ig_a = rand(truncated(Normal(243, 68.37), 83, 402))
                ig_m = rand(truncated(Normal(102.5, 35.97), 18, 187))
            end
        else
            if is_male
                ig_g = rand(truncated(Normal(1065, 242.3), 500, 1629))
                ig_a = rand(truncated(Normal(277, 95.92), 53.9, 500))
                ig_m = rand(truncated(Normal(113.5, 39), 22, 205))
            else
                ig_g = rand(truncated(Normal(895, 165.8), 509, 1281))
                ig_a = rand(truncated(Normal(226.5, 70.15), 63, 390))
                ig_m = rand(truncated(Normal(116, 39.3), 24, 208))
            end
        end
        ig_level = (ig_g + ig_a + ig_m - min_ig_level) / max_min_ig_level_diff

        # Болен
        is_infected = false
        if age < 3
            if rand(1:1000) < 17
                is_infected = true
            end
        elseif age < 7
            if rand(1:100) == 1
                is_infected = true
            end
        elseif age < 15
            if rand(1:1000) < 8
                is_infected = true
            end
        else
            if rand(1:1000) < 4
                is_infected = true
            end
        end

        # Набор дней после приобретения типоспецифического иммунитета кроме гриппа
        immunity_days = Int[0, 0, 0, 0, 0, 0, 0]

        # Информация при болезни
        virus_id = 0
        incubation_period = 0
        infection_period = 0
        days_infected = 0
        is_asymptomatic = false
        is_isolated = false
        viral_load = 0.0
        if is_infected
            # Тип инфекции
            rand_num = rand(1:100)
            if rand_num < 61
                virus_id = viruses[3].id
            elseif rand_num < 81
                virus_id = viruses[5].id
            else
                virus_id = viruses[6].id
            end

            # Инкубационный период
            incubation_period = get_period_from_erlang(
                viruses[virus_id].mean_incubation_period,
                viruses[virus_id].incubation_period_variance,
                viruses[virus_id].min_incubation_period,
                viruses[virus_id].max_incubation_period)
            # Период болезни
            if age < 16
                infection_period = get_period_from_erlang(
                    viruses[virus_id].mean_infection_period_child,
                    viruses[virus_id].infection_period_variance_child,
                    viruses[virus_id].min_infection_period_child,
                    viruses[virus_id].max_infection_period_child)
            else
                infection_period = get_period_from_erlang(
                    viruses[virus_id].mean_infection_period_adult,
                    viruses[virus_id].infection_period_variance_adult,
                    viruses[virus_id].min_infection_period_adult,
                    viruses[virus_id].max_infection_period_adult)
            end

            # Дней с момента инфицирования
            days_infected = rand((1 - incubation_period):infection_period)
            # days_infected = rand(1:(infection_period + incubation_period))

            if rand(1:100) <= viruses[virus_id].asymptomatic_probab
                # Асимптомный
                is_asymptomatic = true
            else
                # Самоизоляция
                if days_infected >= 1
                    rand_num = rand(1:1000)
                    if age < 8
                        if rand_num < 305
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < 204
                            is_isolated = true
                        end
                    else
                        if rand_num < 101
                            is_isolated = true
                        end
                    end
                end
                if days_infected >= 2 && !is_isolated
                    rand_num = rand(1:1000)
                    if age < 8
                        if rand_num < 576
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < 499
                            is_isolated = true
                        end
                    else
                        if rand_num < 334
                            is_isolated = true
                        end
                    end
                end
                if days_infected >= 3 && !is_isolated
                    rand_num = rand(1:1000)
                    if age < 8
                        if rand_num < 325
                            is_isolated = true
                        end
                    elseif age < 18
                        if rand_num < 376
                            is_isolated = true
                        end
                    else
                        if rand_num < 168
                            is_isolated = true
                        end
                    end
                end
            end

            # Вирусная нагрузкаx
            viral_load = find_agent_viral_load(
                age, viral_loads[virus_id, incubation_period, infection_period - 1, days_infected + 7],
                is_asymptomatic && days_infected > 0)
        end

        days_immune = 0

        new(
            id, age, infant_age, is_male, social_status,
            Int[], Int[], 0, false, ig_level,
            virus_id, immunity_days, incubation_period,
            infection_period, days_infected,
            days_immune, is_asymptomatic, is_isolated,
            viral_load, false, household, nothing)
    end
end

# Получить длительность инкубационного периода или периода болезни
function get_period_from_erlang(
    mean::Float64,
    variance::Float64,
    low::Int,
    upper::Int
)::Int
    shape::Int = mean * mean ÷ variance
    scale::Float64 = mean / shape
    return round(rand(truncated(Erlang(shape, scale), low, upper)))
end

# Получить вирусную нагрузку
function find_agent_viral_load(
    age::Int,
    viral_load_value::Float64,
    is_viral_load_halved::Bool,
)::Float64
    if age < 3
        if is_viral_load_halved
            return viral_load_value * 0.5
        else
            return viral_load_value
        end
    elseif age < 16
        if is_viral_load_halved
            return viral_load_value * 0.375
        else
            return viral_load_value * 0.75
        end
    else
        if is_viral_load_halved
            return viral_load_value * 0.25
        else
            return viral_load_value * 0.5
        end
    end
end