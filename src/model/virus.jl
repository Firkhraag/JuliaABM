# Грипп А (FluA) => 1
# Грипп В (FluB) => 2
# Риновирус (RV) => 3
# Респираторно-синцитиальный (RSV) => 4
# Аденовирус (AdV)  => 5
# Парагрипп (PIV)  => 6
# Коронавирус (CoV)  => 7

# Вирус
mutable struct Virus
    # Средняя продолжительность инкубационного периода
    incubation_period_shape::Float64
    # Дисперсия продолжительности инкубационного периода
    incubation_period_scale::Float64

    # Средняя продолжительность периода болезни (взрослый)
    infection_period_adult_shape::Float64
    # Дисперсия продолжительности периода болезни (взрослый)
    infection_period_adult_scale::Float64

    # Средняя продолжительность периода болезни (ребенок)
    infection_period_child_shape::Float64
    # Дисперсия продолжительности периода болезни (ребенок)
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
        mean_incubation_period::Float64,
        incubation_period_sd::Float64,

        mean_infection_period_adult::Float64,
        infection_period_sd_adult::Float64,

        mean_infection_period_child::Float64,
        infection_period_sd_child::Float64,

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
            incubation_period_sd^2,
            mean_infection_period_adult,
            infection_period_sd_adult^2,
            mean_infection_period_child,
            infection_period_sd_child^2,
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
