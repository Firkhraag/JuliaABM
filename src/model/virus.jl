# FluA => 1
# FluB => 2
# RV   => 3
# RSV  => 4
# AdV  => 5
# PIV  => 6
# CoV  => 7

# Вирус
struct Virus
    # Идентификатор
    id::Int
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

    # Средняя вирусная нагрузка (по умолчанию для младенца)
    mean_viral_load::Float64

    # Вероятность бессимптомного протекания болезни
    asymptomatic_probab_child::Float64
    asymptomatic_probab_adult::Float64

    # Продолжительность иммунитета
    immunity_duration::Int

    function Virus(
        id::Int,
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
        asymptomatic_probab_child::Float64,
        asymptomatic_probab_adult::Float64,
        immunity_duration::Int
    )
        new(
            id,
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
            asymptomatic_probab_child,
            asymptomatic_probab_adult,
            immunity_duration
        )
    end
end

# Найти значение вирусной нагрузки
function get_infectivity(
    days_infected::Int,
    incubation_period::Int,
    infection_period::Int,
    mean_viral_load::Float64
)::Float64
    if days_infected < 1
        if incubation_period == 1
            return mean_viral_load / 24
        end
        k = mean_viral_load / (incubation_period - 1)
        b = k * (incubation_period - 1)
        return (k * days_infected + b) / 12
    end
    k = 2 * mean_viral_load / (1 - infection_period)
    b = -k * infection_period
    return (k * days_infected + b) / 12
end
