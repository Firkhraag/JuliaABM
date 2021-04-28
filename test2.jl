using Distributions, Random
using InteractiveUtils
using CSV
using DataFrames

max_incubation_period_duration = 7

struct Virus
    # Идентификатор
    id::Int
    # Наименование
    name::String
    # Средняя продолжительность инкубационного периода
    mean_incubation_period::Float64
    # Дисперсия продолжительности инкубационного периода
    incubation_period_variance::Float64
    # Минимальная продолжительность инкубационного периода
    min_incubation_period::Int
    # Максимальная продолжительность инкубационного периода
    max_incubation_period::Int

    # Средняя продолжительность периода болезни (взрослый)
    mean_infection_period_adult::Float64
    # Дисперсия продолжительности периода болезни (взрослый)
    infection_period_variance_adult::Float64
    # Минимальная продолжительность периода болезни(взрослый)
    min_infection_period_adult::Int
    # Максимальная продолжительность периода болезни(взрослый)
    max_infection_period_adult::Int

    # Средняя продолжительность периода болезни (ребенок)
    mean_infection_period_child::Float64
    # Дисперсия продолжительности периода болезни (ребенок)
    infection_period_variance_child::Float64
    # Минимальная продолжительность периода болезни(ребенок)
    min_infection_period_child::Int
    # Максимальная продолжительность периода болезни(ребенок)
    max_infection_period_child::Int

    # Средняя вирусная нагрузка (по умолчю для младенеца)
    mean_viral_load::Float64

    # Вероятность бессимптомного протекания болезни
    asymptomatic_probab::Int

    function Virus(
        id::Int,
        name::String,
        mean_incubation_period::Float64,
        incubation_period_variance::Float64,
        min_incubation_period::Int,
        max_incubation_period::Int,
        mean_infection_period_adult::Float64,
        infection_period_variance_adult::Float64,
        min_infection_period_adult::Int,
        max_infection_period_adult::Int,
        mean_infection_period_child::Float64,
        infection_period_variance_child::Float64,
        min_infection_period_child::Int,
        max_infection_period_child::Int,
        mean_viral_load::Float64,
        asymptomatic_probab::Int
    )
        new(
            id,
            name,
            mean_incubation_period,
            incubation_period_variance,
            min_incubation_period,
            max_incubation_period,
            mean_infection_period_adult,
            infection_period_variance_adult,
            min_infection_period_adult,
            max_infection_period_adult,
            mean_infection_period_child,
            infection_period_variance_child,
            min_infection_period_child,
            max_infection_period_child,
            mean_viral_load,
            asymptomatic_probab
        )
    end
end

    # Найти значение вирусной нагрузки
    function get_viral_load(
        days_infected::Int,
        incubation_period::Int,
        infection_period::Int,
        mean_viral_load::Float64
    )::Float64
        if days_infected < 1
            if incubation_period == 1
                return mean_viral_load / 2
            end
            k = mean_viral_load / (incubation_period - 1)
            b = k * (incubation_period - 1)
            return k * days_infected + b
        end
        k = 2 * mean_viral_load / (1 - infection_period)
        b = -k * infection_period
        return k * days_infected + b
    end

    # Вирусы
    viruses = Dict(
        "FluA" => Virus(1, "FluA", 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 16),
        "FluB" => Virus(2, "FluB", 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 16),
        "RV" => Virus(3, "RV", 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 30),
        "RSV" => Virus(4, "RSV", 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 30),
        "AdV" => Virus(5, "AdV", 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 30),
        "PIV" => Virus(6, "PIV", 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 30),
        "CoV" => Virus(7, "CoV", 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 30)
    )

    # Кэшируем всевозможные вирусные нагрузки
    function init_viral_loads()::Vector{Vector{Vector{Vector{Float64}}}}
        arr1 = fill(0.0, 7)
        arr2 = fill(arr1, 7)
        arr3 = fill(arr2, 13)
        arr4 = fill(arr3, 21)
        return arr4
    end
    viral_loads = init_viral_loads()

    for days_infected in -6:14
        for infection_period in 2:14
            for incubation_period in 1:7
                mean_viral_loads = [4.6, 4.7, 3.5, 6.0, 4.1, 4.7, 4.93]
                for i in 1:7
                    viral_loads[days_infected + 7][infection_period - 1][incubation_period][i] = get_viral_load(
                        days_infected, incubation_period, infection_period, mean_viral_loads[i])
                end
            end
        end
    end






    abstract type AbstractGroup end
abstract type AbstractCollective end

mutable struct Agent
    # Возраст
    age::Int
    # Возраст новорожденного
    infant_age::Int
    # Пол
    is_male::Bool
    # Социальный статус
    social_status::Int
    # Связи в коллективе
    work_conn::Vector{Agent}
    # Дети за которыми нужен уход в случае болезни
    dependants::Vector{Agent}
    # Кто будет ухаживать в случае болезни
    supporter::Union{Agent, Nothing}
    # Уход за больным ребенком
    on_parent_leave::Bool
    # Уровень иммуноглобулина
    ig_level::Float64
    # Вирус
    virus::Union{Virus, Nothing}
    # Набор дней после приобретения типоспецифического иммунитета кроме гриппа
    immunity_days::Dict{String, Int}
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
    # Домохозяйство
    household::AbstractGroup
    # Группа
    group::Union{AbstractGroup, Nothing}

    function Agent(household::AbstractGroup, is_male::Bool, age::Int)
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
        immunity_days = Dict(
            "FluA" => 0, "FluB" => 0, "RV" => 0, "RSV" => 0, "AdV" => 0, "PIV" => 0, "CoV" => 0)

        # Информация при болезни
        virus::Union{Virus, Nothing} = nothing
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
                virus = viruses["RV"]
            elseif rand_num < 81
                virus = viruses["AdV"]
            else
                virus = viruses["PIV"]
            end

            # Инкубационный период
            incubation_period = get_period_from_erlang(
                virus.mean_incubation_period,
                virus.incubation_period_variance,
                virus.min_incubation_period,
                virus.max_incubation_period)
            # Период болезни
            if age < 16
                infection_period = get_period_from_erlang(
                    virus.mean_infection_period_child,
                    virus.infection_period_variance_child,
                    virus.min_infection_period_child,
                    virus.max_infection_period_child)
            else
                infection_period = get_period_from_erlang(
                    virus.mean_infection_period_adult,
                    virus.infection_period_variance_adult,
                    virus.min_infection_period_adult,
                    virus.max_infection_period_adult)
            end

            # Дней с момента инфицирования
            days_infected = rand((1 - incubation_period):infection_period)
            # days_infected = rand(1:(infection_period + incubation_period))

            if rand(1:100) <= virus.asymptomatic_probab
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
                age, days_infected, infection_period, incubation_period,
                is_asymptomatic && days_infected > 0, virus.id)
        end

        days_immune = 0

        new(
            age, infant_age, is_male, social_status,
            Agent[], Agent[], nothing, false, ig_level,
            virus, immunity_days, incubation_period,
            infection_period, days_infected,
            days_immune, is_asymptomatic, is_isolated,
            viral_load, household, nothing)
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
    days_infected::Int,
    infection_period::Int,
    incubation_period::Int,
    is_viral_load_halved::Bool,
    virus_id::Int
)::Float64
    if age < 3
        if is_viral_load_halved
            return viral_loads[
                days_infected + 7, infection_period - 1, incubation_period, virus_id] * 0.5
        else
            return viral_loads[
                days_infected + 7, infection_period - 1, incubation_period, virus_id]
        end
    elseif age < 16
        if is_viral_load_halved
            return viral_loads[
                days_infected + 7, infection_period - 1, incubation_period, virus_id] * 0.375
        else
            return viral_loads[
                days_infected + 7, infection_period - 1, incubation_period, virus_id] * 0.75
        end
    else
        if is_viral_load_halved
            return viral_loads[
                days_infected + 7, infection_period - 1, incubation_period, virus_id] * 0.25
        else
            return viral_loads[
                days_infected + 7, infection_period - 1, incubation_period, virus_id] * 0.5
        end
    end
end


mutable struct Group <: AbstractGroup
    # Агенты
    agents::Vector{Agent}
    # Коллектив
    collective::Union{AbstractCollective, Nothing}

    function Group(agents::Vector{Agent} = Agent[], collective::Union{AbstractCollective, Nothing} = nothing)
        new(agents, collective)
    end
end

mutable struct Collective <: AbstractCollective
    # Среднее время проводимое агентами
    mean_time_spent::Float64
    # Среднеквадратическое отклонение времени проводимого агентами
    time_spent_sd::Float64
    # Агенты
    groups::Vector{Vector{Group}}

    function Collective(mean_time_spent::Float64, time_spent_sd::Float64, groups::Vector{Vector{Group}})
        new(mean_time_spent, time_spent_sd, groups)
    end
end

function get_kindergarten_group_size(group_num::Int)
    rand_num = rand(1:100)
    if group_num == 1
        if rand_num <= 20
            return 9
        elseif rand_num <= 80
            return 10
        else
            return 11
        end
    elseif group_num == 2 || group_num == 3
        if rand_num <= 20
            return 14
        elseif rand_num <= 80
            return 15
        else
            return 16
        end
    else
        if rand_num <= 20
            return 19
        elseif rand_num <= 80
            return 20
        else
            return 21
        end
    end
end

function get_school_group_size(group_num::Int)
    rand_num = rand(1:100)
    if rand_num <= 20
        return 24
    elseif rand_num <= 80
        return 25
    else
        return 26
    end
end

function get_university_group_size(group_num::Int)
    rand_num = rand(1:100)
    if group_num == 1
        if rand_num <= 20
            return 14
        elseif rand_num <= 80
            return 15
        else
            return 16
        end
    elseif group_num == 2 || group_num == 3
        if rand_num <= 20
            return 13
        elseif rand_num <= 80
            return 14
        else
            return 15
        end
    elseif group_num == 4
        if rand_num <= 20
            return 12
        elseif rand_num <= 80
            return 13
        else
            return 14
        end
    elseif group_num == 5
        if rand_num <= 20
            return 10
        elseif rand_num <= 80
            return 11
        else
            return 12
        end
    else
        if rand_num <= 20
            return 9
        elseif rand_num <= 80
            return 10
        else
            return 11
        end
    end
end

function get_workplace_group_size(group_num::Int)
    # zipfDistribution.sample() + (minFirmSize - 1)
    return rand(3:15)
end

# function test()
    # DEBUG
    max_simulation_step = 20
    is_break = true

    # Параметры
    duration_parameter = 7.05
    temperature_parameters = Dict(
        "FluA" => -0.8,
        "FluB" => -0.8,
        "RV" => -0.05,
        "RSV" => -0.64,
        "AdV" => -0.2,
        "PIV" => -0.05,
        "CoV" => -0.8)
    susceptibility_parameters = Dict(
        "FluA" => 2.61,
        "FluB" => 2.61,
        "RV" => 3.17,
        "RSV" => 5.11,
        "AdV" => 4.69,
        "PIV" => 3.89,
        "CoV" => 3.77)
    immunity_durations = Dict(
        "FluA" => 366,
        "FluB" => 366,
        "RV" => 60,
        "RSV" => 60,
        "AdV" => 366,
        "PIV" => 366,
        "CoV" => 366)

    # Набор агентов
    all_agents = Agent[]
    # Набор инфицированных агентов
    infected_agents = Agent[]

    district_df = CSV.read(
        joinpath(@__DIR__, "tables", "districts.csv"), DataFrame, tasks=1)
    district_household_df = CSV.read(
        joinpath(@__DIR__, "tables", "districts_households.csv"), DataFrame, tasks=1)
    etiologies = CSV.read(
        joinpath(@__DIR__, "tables", "etiologies.csv"), DataFrame, tasks=1)
    temperature_df = CSV.read(
        joinpath(@__DIR__, "tables", "temperature.csv"), DataFrame, tasks=1)
# end








function create_agent(
    household::Group,
    index::Int,
    district_household_index::Int,
    is_male::Union{Bool, Nothing} = nothing,
    is_child::Bool = false,
    parent_age::Union{Int, Nothing} = nothing,
    is_older::Bool = false,
    is_parent_of_parent::Bool = false
):: Agent
    age_rand_num = rand(1:100)
    sex_random_num = rand(1:100)
    if is_child
        if parent_age < 23
            return Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:(parent_age - 18)))
        elseif parent_age < 28
            if (age_rand_num <= district_df[index, "T0-4_0–9"])
                Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:4))
            else
                Agent(household, sex_random_num <= district_df[index, "M5–9"], rand(5:(parent_age - 18)))
            end
        elseif parent_age < 33
            if (age_rand_num <= district_df[index, "T0-4_0–14"])
                Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:4))
            elseif (age_rand_num <= district_df[index, "T0-9_0–14"])
                Agent(household, sex_random_num <= district_df[index, "M5–9"], rand(5:9))
            else
                Agent(household, sex_random_num <= district_df[index, "M10–14"], rand(10:(parent_age - 18)))
            end
        elseif parent_age < 35
            age_group_rand_num = rand(1:100)
            if age_group_rand_num <= district_household_df[1, district_household_index]
                if (age_rand_num <= district_df[index, "T0-4_0–14"])
                    Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:4))
                elseif (age_rand_num <= district_df[index, "T0-9_0–14"])
                    Agent(household, sex_random_num <= district_df[index, "M5–9"], rand(5:9))
                else
                    Agent(household, sex_random_num <= district_df[index, "M10–14"], rand(10:14))
                end
            else
                return Agent(household, sex_random_num <= district_df[index, "M15–19"], rand(15:(parent_age - 18)))
            end
        else
            age_group_rand_num = rand(1:100)
            if age_group_rand_num <= district_household_df[1, district_household_index]
                if (age_rand_num <= district_df[index, "T0-4_0–14"])
                    Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:4))
                elseif (age_rand_num <= district_df[index, "T0-9_0–14"])
                    Agent(household, sex_random_num <= district_df[index, "M5–9"], rand(5:9))
                else
                    Agent(household, sex_random_num <= district_df[index, "M10–14"], rand(10:14))
                end
            else
                return Agent(household, sex_random_num <= district_df[index, "M15–19"], rand(15:17))
            end
        end
    else
        age_group_rand_num = rand(1:100)
        if is_older
            age_group_rand_num = rand((district_household_df[3, district_household_index] + 1):100)
        elseif parent_age !== nothing
            if parent_age < 45
                age_group_rand_num = 1
            elseif parent_age < 55
                age_group_rand_num = rand(1:district_household_df[3, district_household_index])
            elseif parent_age < 65
                age_group_rand_num = rand(1:district_household_df[4, district_household_index])
            else
                age_group_rand_num = rand(1:district_household_df[5, district_household_index])
            end
        elseif is_parent_of_parent
            if parent_age < 25
                age_group_rand_num = rand((district_household_df[3, district_household_index] + 1):100)
            elseif parent_age < 35
                age_group_rand_num = rand((district_household_df[4, district_household_index] + 1):100)
            elseif parent_age < 45
                age_group_rand_num = rand((district_household_df[5, district_household_index] + 1):100)
            else
                age_group_rand_num = 100
            end
        end
        if age_group_rand_num <= district_household_df[2, district_household_index]
            if is_male !== nothing
                return Agent(household, is_male, rand(18:24))
            else
                return Agent(household, sex_random_num <= district_df[index, "M20–24"], rand(18:24))
            end
        elseif age_group_rand_num <= district_household_df[3, district_household_index]
            if age_rand_num <= district_df[index, "T25-29_25–34"]
                if is_male !== nothing
                    return Agent(household, is_male, rand(25:29))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M25–29"], rand(25:29))
                end
            else
                if is_male !== nothing
                    return Agent(household, is_male, rand(30:34))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M30–34"], rand(30:34))
                end
            end
        elseif age_group_rand_num <= district_household_df[4, district_household_index]
            if age_rand_num <= district_df[index, "T35-39_35–44"]
                if is_male !== nothing
                    return Agent(household, is_male, rand(35:39))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M35–39"], rand(35:39))
                end
            else
                if is_male !== nothing
                    return Agent(household, is_male, rand(40:44))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M40–44"], rand(40:44))
                end
            end
        elseif age_group_rand_num <= district_household_df[5, district_household_index]
            if age_rand_num <= district_df[index, "T45-49_45–54"]
                if is_male !== nothing
                    return Agent(household, is_male, rand(45:49))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M45–49"], rand(45:49))
                end
            else
                if is_male !== nothing
                    return Agent(household, is_male, rand(50:54))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M50–54"], rand(50:54))
                end
            end
        elseif age_group_rand_num <= district_household_df[6, district_household_index]
            if age_rand_num <= district_df[index, "T55-59_55–64"]
                if is_male !== nothing
                    return Agent(household, is_male, rand(55:59))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M55–59"], rand(55:59))
                end
            else
                if is_male !== nothing
                    return Agent(household, is_male, rand(60:64))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M60–64"], rand(60:64))
                end
            end
        else
            if age_rand_num <= district_df[index, "T65-69_65–89"]
                if is_male !== nothing
                    return Agent(household, is_male, rand(65:69))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M65–69"], rand(65:69))
                end
            elseif age_rand_num <= district_df[index, "T65-74_65–89"]
                if is_male !== nothing
                    return Agent(household, is_male, rand(70:74))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M70–74"], rand(70:74))
                end
            elseif age_rand_num <= district_df[index, "T65-79_65–89"]
                if is_male !== nothing
                    return Agent(household, is_male, rand(75:79))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M75–79"], rand(75:79))
                end
            elseif age_rand_num <= district_df[index, "T65-84_65–89"]
                if is_male !== nothing
                    return Agent(household, is_male, rand(80:84))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M80–84"], rand(80:84))
                end
            else
                if is_male !== nothing
                    return Agent(household, is_male, rand(85:89))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M85–89"], rand(85:89))
                end
            end
        end
    end
end

function create_spouse(household::Group, partner_age::Int)
    rand_num = rand(1:100)
    difference = 0
    if rand_num <= 3
        difference = rand(-20:-15)
    elseif rand_num <= 8
        difference = rand(-14:-10)
    elseif rand_num <= 20
        difference = rand(-9:-6)
    elseif rand_num <= 33
        difference = rand(-5:-4)
    elseif rand_num <= 53
        difference = rand(-3:-2)
    elseif rand_num <= 86
        difference = rand(-1:1)
    elseif rand_num <= 93
        difference = rand(2:3)
    elseif rand_num <= 96
        difference = rand(4:5)
    elseif rand_num <= 98
        difference = rand(6:9)
    else
        difference = rand(10:14)
    end

    spouse_age = partner_age + difference
    if spouse_age < 18
        spouse_age = 18
    elseif spouse_age > 89
        spouse_age = 89
    end
    return Agent(household, false, spouse_age)
end

function check_parent_leave(no_one_at_home::Bool, adult::Agent, child::Agent)
    if no_one_at_home && child.age < 14
        push!(adult.dependants, child)
        child.supporter = adult
        if child.age < 3 && child.social_status == 0
            adult.social_status == 0
        end
    end
end

function create_parents_with_children(
    household::Group,
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int
)::Vector{Agent}
    agent_male = create_agent(household, index, district_household_index, true)
    agent_female = create_spouse(household, agent_male.age)
    agent_other::Union{Agent, Nothing} = nothing
    agent_other2::Union{Agent, Nothing} = nothing
    agent_other3::Union{Agent, Nothing} = nothing
    agent_other4::Union{Agent, Nothing} = nothing
    if num_of_other_people > 0
        agent_other = create_agent(household, index, district_household_index)
        if num_of_other_people > 1
            agent_other2 = create_agent(household, index, district_household_index)
            if num_of_other_people > 2
                agent_other3 = create_agent(household, index, district_household_index)
                if num_of_other_people > 3
                    agent_other4 = create_agent(household, index, district_household_index)
                end
            end
        end
    end
    if num_of_children > 0
        child = create_agent(household, index, district_household_index, nothing, true, agent_female.age)
        no_one_at_home = agent_male.social_status != 0 && agent_female.social_status != 0
        if agent_other !== nothing && agent_other.social_status == 0
            no_one_at_home = false
        elseif agent_other2 !== nothing && agent_other2.social_status == 0
            no_one_at_home = false
        elseif agent_other3 !== nothing && agent_other3.social_status == 0
            no_one_at_home = false
        elseif agent_other4 !== nothing && agent_other4.social_status == 0
            no_one_at_home = false
        end
        check_parent_leave(no_one_at_home, agent_female, child)
        if num_of_children == 1
            if agent_other4 !== nothing
                return Agent[agent_male, agent_female, child, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[agent_male, agent_female, child, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[agent_male, agent_female, child, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[agent_male, agent_female, child, agent_other]
            end
            return Agent[agent_male, agent_female, child]
        end

        child2 = create_agent(household, index, district_household_index, nothing, true, agent_female.age)
        check_parent_leave(no_one_at_home, agent_female, child2)
        if num_of_children == 2
            if agent_other4 !== nothing
                return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[agent_male, agent_female, child, child2, agent_other]
            end
            return Agent[agent_male, agent_female, child, child2]
        end

        child3 = create_agent(household, index, district_household_index, nothing, true, agent_female.age)
        check_parent_leave(no_one_at_home, agent_female, child3)
        if agent_other4 !== nothing
            return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
        elseif agent_other3 !== nothing
            return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2, agent_other3]
        elseif agent_other2 !== nothing
            return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2]
        elseif agent_other !== nothing
            return Agent[agent_male, agent_female, child, child2, child3, agent_other]
        end
        return Agent[agent_male, agent_female, child, child2, child3]
    end
    if agent_other4 !== nothing
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4]
    elseif agent_other3 !== nothing
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
    elseif agent_other2 !== nothing
        return Agent[agent_male, agent_female, agent_other, agent_other2]
    elseif agent_other !== nothing
        return Agent[agent_male, agent_female, agent_other]
    end
    return Agent[agent_male, agent_female]
end

function create_parent_with_children(
    household::Group,
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int,
    is_male_parent::Union{Bool, Nothing},
    with_parent_of_parent::Bool = false
)::Vector{Agent}
    parent = create_agent(household, index, district_household_index, is_male_parent, false, nothing, num_of_other_people > 0)
    agent_other::Union{Agent, Nothing} = nothing
    agent_other2::Union{Agent, Nothing} = nothing
    agent_other3::Union{Agent, Nothing} = nothing
    agent_other4::Union{Agent, Nothing} = nothing
    if num_of_other_people > 0
        if with_parent_of_parent
            agent_other = create_agent(household, index, district_household_index, nothing, false, parent.age, false, true)
        else
            agent_other = create_agent(household, index, district_household_index, nothing, false, parent.age)
        end
        if num_of_other_people > 1
            agent_other2 = create_agent(household, index, district_household_index, nothing, false, parent.age)
            if num_of_other_people > 2
                agent_other3 = create_agent(household, index, district_household_index, nothing, false, parent.age)
                if num_of_other_people > 3
                    agent_other4 = create_agent(household, index, district_household_index, nothing, false, parent.age)
                end
            end
        end
    end
    if num_of_children > 0
        child = create_agent(household, index, district_household_index, nothing, true, parent.age)
        no_one_at_home = parent.social_status != 0
        if agent_other !== nothing && agent_other.social_status == 0
            no_one_at_home = false
        elseif agent_other2 !== nothing && agent_other2.social_status == 0
            no_one_at_home = false
        elseif agent_other3 !== nothing && agent_other3.social_status == 0
            no_one_at_home = false
        elseif agent_other4 !== nothing && agent_other4.social_status == 0
            no_one_at_home = false
        end
        check_parent_leave(no_one_at_home, parent, child)
        if num_of_children == 1
            if agent_other4 !== nothing
                return Agent[parent, child, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[parent, child, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[parent, child, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[parent, child, agent_other]
            end
            return Agent[parent, child]
        end

        child2 = create_agent(household, index, district_household_index, nothing, true, parent.age)
        check_parent_leave(no_one_at_home, parent, child2)
        if num_of_children == 2
            if agent_other4 !== nothing
                return Agent[parent, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[parent, child, child2, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[parent, child, child2, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[parent, child, child2, agent_other]
            end
            return Agent[parent, child, child2]
        end

        child3 = create_agent(household, index, district_household_index, nothing, true, parent.age)
        check_parent_leave(no_one_at_home, parent, child3)
        if agent_other4 !== nothing
            return Agent[parent, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
        elseif agent_other3 !== nothing
            return Agent[parent, child, child2, child3, agent_other, agent_other2, agent_other3]
        elseif agent_other2 !== nothing
            return Agent[parent, child, child2, child3, agent_other, agent_other2]
        elseif agent_other !== nothing
            return Agent[parent, child, child2, child3, agent_other]
        end
        return Agent[parent, child, child2, child3]
    end
    if agent_other4 !== nothing
        return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4]
    elseif agent_other3 !== nothing
        return Agent[parent, agent_other, agent_other2, agent_other3]
    elseif agent_other2 !== nothing
        return Agent[parent, agent_other, agent_other2]
    elseif agent_other !== nothing
        return Agent[parent, agent_other]
    end
end

function create_others(
    household::Group,
    district_household_index::Int,
    num_of_children::Int,
    num_of_other_people::Int,
    index::Int
)::Vector{Agent}
    agent = create_agent(household, index, district_household_index)
    agent_other::Union{Agent, Nothing} = nothing
    agent_other2::Union{Agent, Nothing} = nothing
    agent_other3::Union{Agent, Nothing} = nothing
    agent_other4::Union{Agent, Nothing} = nothing
    if num_of_other_people > 1
        agent_other = create_agent(household, index, district_household_index)
        if num_of_other_people > 2
            agent_other2 = create_agent(household, index, district_household_index)
            if num_of_other_people > 3
                agent_other3 = create_agent(household, index, district_household_index)
                if num_of_other_people > 4
                    agent_other4 = create_agent(household, index, district_household_index)
                end
            end
        end
    end
    if num_of_children > 0
        child = create_agent(household, index, district_household_index, nothing, true, 35)
        no_one_at_home = agent.social_status != 0
        if agent_other !== nothing && agent_other.social_status == 0
            no_one_at_home = false
        elseif agent_other2 !== nothing && agent_other2.social_status == 0
            no_one_at_home = false
        elseif agent_other3 !== nothing && agent_other3.social_status == 0
            no_one_at_home = false
        elseif agent_other4 !== nothing && agent_other4.social_status == 0
            no_one_at_home = false
        end
        check_parent_leave(no_one_at_home, agent, child)
        if num_of_children == 1
            if agent_other4 !== nothing
                return Agent[agent, child, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[agent, child, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[agent, child, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[agent, child, agent_other]
            end
            return Agent[agent, child]
        end

        child2 = create_agent(household, index, district_household_index, nothing, true, 35)
        check_parent_leave(no_one_at_home, agent, child2)
        if num_of_children == 2
            if agent_other4 !== nothing
                return Agent[agent, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[agent, child, child2, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[agent, child, child2, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[agent, child, child2, agent_other]
            end
            return Agent[agent, child, child2]
        end

        child3 = create_agent(household, index, district_household_index, nothing, true, 35)
        check_parent_leave(no_one_at_home, agent, child3)
        if agent_other4 !== nothing
            return Agent[agent, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
        elseif agent_other3 !== nothing
            return Agent[agent, child, child2, child3, agent_other, agent_other2, agent_other3]
        elseif agent_other2 !== nothing
            return Agent[agent, child, child2, child3, agent_other, agent_other2]
        elseif agent_other !== nothing
            return Agent[agent, child, child2, child3, agent_other]
        end
        return Agent[agent, child, child2, child3]
    end
    if agent_other4 !== nothing
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
    elseif agent_other3 !== nothing
        return Agent[agent, agent_other, agent_other2, agent_other3]
    elseif agent_other2 !== nothing
        return Agent[agent, agent_other, agent_other2]
    elseif agent_other !== nothing
        return Agent[agent, agent_other]
    end
end

function add_agent_to_group(
    agent::Agent,
    collective::Collective,
    group_num::Int,
    group_sizes::Vector{Int},
    get_group_size
)
    if size(collective.groups[group_num], 1) == 0
        group = Group()
        push!(collective.groups[group_num], group)
        group.collective = collective
    end
    length = size(collective.groups[group_num], 1)
    last_group = collective.groups[group_num][length]
    if size(last_group.agents, 1) == group_sizes[group_num]
        last_group = Group()
        push!(collective.groups[group_num], last_group)
        last_group.collective = collective
        group_sizes[group_num] = get_group_size(group_num)
    end
    push!(last_group.agents, agent)
    agent.group = last_group
end

function add_agent_to_kindergarten(
    agent::Agent,
    kindergarten::Collective,
    group_sizes::Vector{Int}
)
    group_num = 1
    if agent.age == 1
        group_num = 2
    elseif agent.age == 2
        group_num = rand(2:3)
    elseif agent.age == 3
        group_num = rand(3:4)
    elseif agent.age == 4
        group_num = rand(4:5)
    elseif agent.age == 5
        group_num = rand(5:6)
    elseif agent.age == 6
        group_num = 6
    end
    add_agent_to_group(agent, kindergarten, group_num, group_sizes, get_kindergarten_group_size)
end

function add_agent_to_school(
    agent::Agent,
    school::Collective,
    group_sizes::Vector{Int}
)
    school_group_size = 25
    group_num = 1
    if agent.age == 8
        group_num = 2
    elseif agent.age == 9
        group_num = rand(2:3)
    elseif agent.age == 10
        group_num = rand(3:4)
    elseif agent.age == 11
        group_num = rand(4:5)
    elseif agent.age == 12
        group_num = rand(5:6)
    elseif agent.age == 13
        group_num = rand(6:7)
    elseif agent.age == 14
        group_num = rand(7:8)
    elseif agent.age == 15
        group_num = rand(8:9)
    elseif agent.age == 16
        group_num = rand(9:10)
    elseif agent.age == 17
        group_num = rand(10:11)
    elseif agent.age == 18
        group_num = 11
    end
    add_agent_to_group(agent, school, group_num, group_sizes, get_school_group_size)
end

function add_agent_to_university(
    agent::Agent,
    university::Collective,
    group_sizes::Vector{Int}
)
    university_group_size = 12
    group_num = 1
    if agent.age == 19
        group_num = rand(1:2)
    elseif agent.age == 20
        group_num = rand(2:3)
    elseif agent.age == 21
        group_num = rand(3:4)
    elseif agent.age == 22
        group_num = rand(4:5)
    elseif agent.age == 23
        group_num = rand(5:6)
    elseif agent.age == 24
        group_num = 6
    end
    add_agent_to_group(agent, university, group_num, group_sizes, get_university_group_size)
end

function add_agent_to_workplace(
    agent::Agent,
    workplace::Collective,
    group_sizes::Vector{Int}
)
    workplace_group_size = 8
    add_agent_to_group(agent, workplace, 1, group_sizes, get_workplace_group_size)
end

function add_agents_to_collectives(
    agents::Vector{Agent},
    kindergarten::Collective,
    kindergarten_group_sizes::Vector{Int},
    school::Collective,
    school_group_sizes::Vector{Int},
    university::Collective,
    university_group_sizes::Vector{Int},
    workplace::Collective,
    workplace_group_sizes::Vector{Int},
    thread_agents::Vector{Agent},
    thread_infected_agents::Vector{Agent}
)
    for agent in agents
        if agent.virus !== nothing
            push!(thread_infected_agents, agent)
        end
        if agent.social_status == 1
            add_agent_to_kindergarten(agent, kindergarten, kindergarten_group_sizes)
        elseif agent.social_status == 2
            add_agent_to_school(agent, school, school_group_sizes)
        elseif agent.social_status == 3
            add_agent_to_university(agent, university, university_group_sizes)
        elseif agent.social_status == 4
            add_agent_to_workplace(agent, workplace, workplace_group_sizes)
        end
        push!(thread_agents, agent)
    end
end

function create_population()
    for index = 1:107
        println("Index: $(index)")

        kindergarten = Collective(5.88, 2.52, fill(Group[], 6))
        kindergarten_group_sizes = Int[
            get_kindergarten_group_size(1),
            get_kindergarten_group_size(2),
            get_kindergarten_group_size(3),
            get_kindergarten_group_size(4),
            get_kindergarten_group_size(5),
            get_kindergarten_group_size(6)]

        school = Collective(4.783, 2.67, fill(Group[], 11))
        school_group_sizes = Int[
            get_school_group_size(1),
            get_school_group_size(2),
            get_school_group_size(3),
            get_school_group_size(4),
            get_school_group_size(5),
            get_school_group_size(6),
            get_school_group_size(7),
            get_school_group_size(8),
            get_school_group_size(9),
            get_school_group_size(10),
            get_school_group_size(11)]

        university = Collective(2.1, 3.0, fill(Group[], 6))
        university_group_sizes = Int[
            get_university_group_size(1),
            get_university_group_size(2),
            get_university_group_size(3),
            get_university_group_size(4),
            get_university_group_size(5),
            get_university_group_size(6)]

        workplace = Collective(3.0, 3.0, fill(Group[], 1))
        workplace_group_sizes = Int[get_workplace_group_size(1)]

        thread_agents = Agent[]
        thread_infected_agents = Agent[]

        index_for_1_people::Int = (index - 1) * 5 + 1
        index_for_2_people::Int = index_for_1_people + 1
        index_for_3_people::Int = index_for_2_people + 1
        index_for_4_people::Int = index_for_3_people + 1
        index_for_5_people::Int = index_for_4_people + 1
        for i in 1:district_df[index, "1P"]
            household = Group()
            agents = Agent[create_agent(household, index, index_for_1_people)]
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)

            
        end
        for i in 1:district_df[index, "PWOP2P0C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_2_people, 0, 0, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)

                
        end
        # return
        for i in 1:district_df[index, "PWOP3P0C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_3_people, 0, 1, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)

                
        end
        for i in 1:district_df[index, "PWOP3P1C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_3_people, 1, 0, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)

                # agent = agents[1]
                # if agent.virus !== nothing
                #     println("Age: $(agent.age)")
                #     println("Social status: $(agent.social_status)")
                #     println("Sex: $(agent.is_male)")
                #     println("Work conn: $(size(agent.work_conn, 1))")
                #     println("Dependants: $(size(agent.dependants, 1))")
                #     println("Supporter: $(agent.supporter !== nothing)")
                #     println("On parent leave: $(agent.on_parent_leave)")
                #     println("Ig level: $(agent.ig_level)")
                #     println("Virus: $(agent.virus)")
                #     println("Incubation period: $(agent.incubation_period)")
                #     println("Infection period: $(agent.infection_period)")
                #     println("Days infected: $(agent.days_infected)")
                #     println("Days immune: $(agent.days_immune)")
                #     println("Is asymptomatic: $(agent.is_asymptomatic)")
                #     println("Is isolated: $(agent.is_isolated)")
                #     println("Viral load: $(agent.viral_load)")

                #     println("Household: $(size(agent.household.agents, 1))")
                #     println("Group: $(agent.group !== nothing)")
                #     println()
                # end

                # agent = agents[2]
                # if agent.virus !== nothing
                #     println("Age: $(agent.age)")
                #     println("Social status: $(agent.social_status)")
                #     println("Sex: $(agent.is_male)")
                #     println("Work conn: $(size(agent.work_conn, 1))")
                #     println("Dependants: $(size(agent.dependants, 1))")
                #     println("Supporter: $(agent.supporter !== nothing)")
                #     println("On parent leave: $(agent.on_parent_leave)")
                #     println("Ig level: $(agent.ig_level)")
                #     println("Virus: $(agent.virus)")
                #     println("Incubation period: $(agent.incubation_period)")
                #     println("Infection period: $(agent.infection_period)")
                #     println("Days infected: $(agent.days_infected)")
                #     println("Days immune: $(agent.days_immune)")
                #     println("Is asymptomatic: $(agent.is_asymptomatic)")
                #     println("Is isolated: $(agent.is_isolated)")
                #     println("Viral load: $(agent.viral_load)")

                #     println("Household: $(size(agent.household.agents, 1))")
                #     println("Group: $(agent.group !== nothing)")
                #     println()
                # end

                # agent = agents[3]
                # if agent.virus !== nothing
                #     println("Age: $(agent.age)")
                #     println("Social status: $(agent.social_status)")
                #     println("Sex: $(agent.is_male)")
                #     println("Work conn: $(size(agent.work_conn, 1))")
                #     println("Dependants: $(size(agent.dependants, 1))")
                #     println("Supporter: $(agent.supporter !== nothing)")
                #     println("On parent leave: $(agent.on_parent_leave)")
                #     println("Ig level: $(agent.ig_level)")
                #     println("Virus: $(agent.virus)")
                #     println("Incubation period: $(agent.incubation_period)")
                #     println("Infection period: $(agent.infection_period)")
                #     println("Days infected: $(agent.days_infected)")
                #     println("Days immune: $(agent.days_immune)")
                #     println("Is asymptomatic: $(agent.is_asymptomatic)")
                #     println("Is isolated: $(agent.is_isolated)")
                #     println("Viral load: $(agent.viral_load)")

                #     println("Household: $(size(agent.household.agents, 1))")
                #     println("Group: $(agent.group !== nothing)")
                #     return
                # end
        end
        for i in 1:district_df[index, "PWOP4P0C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_4_people, 0, 2, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP4P1C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_4_people, 1, 1, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP4P2C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_4_people, 2, 0, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP5P0C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_5_people, 0, 3, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP5P1C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_5_people, 1, 2, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP5P2C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_5_people, 2, 1, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP5P3C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_5_people, 3, 0, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP6P0C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_5_people, 0, 4, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP6P1C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_5_people, 1, 3, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP6P2C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_5_people, 2, 2, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "PWOP6P3C"]
            household = Group()
            agents = create_parents_with_children(household, index_for_5_people, 3, 1, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "2PWOP4P0C"]
            household = Group()
            pair1 = create_parents_with_children(household, index_for_4_people, 0, 0, index)
            pair2 = create_parents_with_children(household, index_for_4_people, 0, 0, index)
            agents = vcat(pair1, pair2)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "2PWOP5P0C"]
            household = Group()
            pair1 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
            pair2 = create_parents_with_children(household, index_for_5_people, 0, 0, index)
            agents = vcat(pair1, pair2)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "2PWOP5P1C"]
            household = Group()
            pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
            pair2 = create_parents_with_children(household, index_for_5_people, 0, 0, index)
            agents = vcat(pair1, pair2)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "2PWOP6P0C"]
            household = Group()
            pair1 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
            pair2 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
            agents = vcat(pair1, pair2)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "2PWOP6P1C"]
            household = Group()
            pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
            pair2 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
            agents = vcat(pair1, pair2)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "2PWOP6P2C"]
            household = Group()
            pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
            pair2 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
            agents = vcat(pair1, pair2)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC2P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_2_people, 0, 1, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC2P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_2_people, 1, 0, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC3P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC3P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC3P2C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC3P2C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC4P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC4P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC4P2C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SMWC4P3C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 3, 0, index, false)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SFWC2P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_2_people, 0, 1, index, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SFWC2P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_2_people, 1, 0, index, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SFWC3P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SFWC3P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SFWC3P2C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWP3P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWP3P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWP4P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWP4P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWP4P2C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end

        for i in 1:district_df[index, "SPWCWPWOP3P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWPWOP3P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWPWOP4P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWPWOP4P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWPWOP4P2C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWPWOP5P0C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_5_people, 0, 4, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWPWOP5P1C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_5_people, 1, 3, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "SPWCWPWOP5P2C"]
            household = Group()
            agents = create_parent_with_children(household, index_for_5_people, 2, 2, index, nothing, true)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end

        for i in 1:district_df[index, "O2P0C"]
            household = Group()
            agents = create_others(household, index_for_2_people, 0, 2, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O2P1C"]
            household = Group()
            agents = create_others(household, index_for_2_people, 1, 1, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O3P0C"]
            household = Group()
            agents = create_others(household, index_for_3_people, 0, 3, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O3P1C"]
            household = Group()
            agents = create_others(household, index_for_3_people, 1, 2, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O3P2C"]
            household = Group()
            agents = create_others(household, index_for_3_people, 2, 1, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O4P0C"]
            household = Group()
            agents = create_others(household, index_for_4_people, 0, 4, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O4P1C"]
            household = Group()
            agents = create_others(household, index_for_4_people, 1, 3, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O4P2C"]
            household = Group()
            agents = create_others(household, index_for_4_people, 2, 2, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O5P0C"]
            household = Group()
            agents = create_others(household, index_for_5_people, 0, 5, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O5P1C"]
            household = Group()
            agents = create_others(household, index_for_5_people, 1, 4, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        for i in 1:district_df[index, "O5P2C"]
            household = Group()
            agents = create_others(household, index_for_5_people, 2, 3, index)
            household.agents = agents
            add_agents_to_collectives(
                agents, kindergarten, kindergarten_group_sizes,
                school, school_group_sizes,
                university, university_group_sizes,
                workplace, workplace_group_sizes,
                thread_agents, thread_infected_agents)
        end
        break
    end
end







@code_warntype create_population()
# test()











# using CSV
# using DataFrames
# using InteractiveUtils

# function f(x)
#     y = pos(x)
#     return sin(y*x + 1)
# end

# function test()
#     for i = 1:1000
#         b = f(i)
#     end
# end

# @code_warntype f(3.2)

# @time test()








# arr = []
# for i = 1:365
#     push!(arr, i)
# end

# println(arr)

# processes_df = CSV.read(
#     joinpath(@__DIR__, "tables", "num_of_households.csv"), DataFrame, tasks=1)


# # println(processes_df[:, processes_df[!, "Process_$(4)"] == 2])
# println(filter(x -> x["Process_$(4)"] == 1, processes_df)[:, "District"])
