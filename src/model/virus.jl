# Грипп А (FluA) => 1
# Грипп В (FluB) => 2
# Риновирус (RV) => 3
# Респираторно-синцитиальный (RSV) => 4
# Аденовирус (AdV) => 5
# Парагрипп (PIV) => 6
# Коронавирус (CoV) => 7

# Вирус
mutable struct Virus
    # Продолжительность инкубационного периода
    incubation_period_shape::Int
    incubation_period_scale::Float64

    # Продолжительность периода болезни (взрослый)
    infection_period_adult_shape::Int
    infection_period_adult_scale::Float64

    # Продолжительность периода болезни (ребенок)
    infection_period_child_shape::Int
    infection_period_child_scale::Float64

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
        incubation_period_shape::Int,
        incubation_period_scale::Float64,

        infection_period_adult_shape::Int,
        infection_period_adult_scale::Float64,

        infection_period_child_shape::Int,
        infection_period_child_scale::Float64,

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
            incubation_period_shape,
            incubation_period_scale,
            infection_period_adult_shape,
            infection_period_adult_scale,
            infection_period_child_shape,
            infection_period_child_scale,
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
