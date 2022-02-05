# FluA => 1
# FluB => 2
# RV   => 3
# RSV  => 4
# AdV  => 5
# PIV  => 6
# CoV  => 7

# Вирус
mutable struct Virus
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

    # Средние вирусные нагрузки (по умолчанию для младенца)
    mean_viral_load_toddler::Float64
    mean_viral_load_child::Float64
    mean_viral_load_adult::Float64

    # Вероятность симптомного протекания болезни (ребенок до 10 лет)
    symptomatic_probability_child::Float64
    # Вероятность симптомного протекания болезни (ребенок 10-17 лет)
    symptomatic_probability_teenager::Float64
    # Вероятность симптомного протекания болезни (взрослый)
    symptomatic_probability_adult::Float64

    # Средняя продолжительность иммунитета
    mean_immunity_duration::Float64
    # Среднеквадратическое отклонение продолжительности иммунитета
    immunity_duration_sd::Float64

    function Virus(
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

        mean_viral_load_toddler::Float64,
        mean_viral_load_child::Float64,
        mean_viral_load_adult::Float64,

        symptomatic_probability_child::Float64,
        symptomatic_probability_teenager::Float64,
        symptomatic_probability_adult::Float64,

        mean_immunity_duration::Float64,
        immunity_duration_sd::Float64,
    )
        new(
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
            mean_viral_load_toddler,
            mean_viral_load_child,
            mean_viral_load_adult,
            symptomatic_probability_child,
            symptomatic_probability_teenager,
            symptomatic_probability_adult,
            mean_immunity_duration,
            immunity_duration_sd,
        )
    end
end
