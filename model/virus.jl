using Distributions, Random

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

# Кэшируем всевозможные вирусные нагрузки
function init_viral_loads()::Vector{Vector{Vector{Vector{Float64}}}}
    arr1 = fill(0.0, 7)
    arr2 = fill(arr1, 7)
    arr3 = fill(arr2, 13)
    arr = fill(arr3, 21)

    for days_infected in -6:14
        days_infected_index = days_infected + 7
        for infection_period in 2:14
            infection_period_index = infection_period - 1
            for incubation_period in 1:7
                min_days_infected = 1 - incubation_period
                mean_viral_loads = [4.6, 4.7, 3.5, 6.0, 4.1, 4.7, 4.93]
                for i in 1:7
                    if (days_infected < min_days_infected) || (days_infected > infection_period)
                        arr[days_infected_index][infection_period_index][incubation_period][i] = -1.0
                    else
                        arr[days_infected_index][infection_period_index][incubation_period][i] = get_viral_load(
                            days_infected, incubation_period, infection_period, mean_viral_loads[i])
                    end
                end
            end
        end
    end

    return arr
end
