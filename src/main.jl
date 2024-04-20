using Base.Threads
using Random
using DelimitedFiles
using LatinHypercubeSampling
using Distributions
using DataFrames
using CSV
using JLD

# Модель на сервере
include("../server/lib/data/etiology.jl")
include("../server/lib/data/incidence.jl")

include("../server/lib/global/variables.jl")

include("../server/lib/model/virus.jl")
include("../server/lib/model/agent.jl")
include("../server/lib/model/household.jl")
include("../server/lib/model/workplace.jl")
include("../server/lib/model/school.jl")
include("../server/lib/model/initialization.jl")
include("../server/lib/model/connections.jl")
include("../server/lib/model/contacts.jl")

include("../server/lib/util/moving_avg.jl")
include("../server/lib/util/stats.jl")
include("../server/lib/util/reset.jl")

# Локальная модель
include("model/simulation.jl")

# Моделирование контактов
function simulate_contacts(
    # Число потоков
    num_threads::Int,
    # Генератор случайных чисел для потоков
    thread_rng::Vector{MersenneTwister},
    # Агенты
    agents::Vector{Agent},
    # Детские сады
    kindergartens::Vector{School},
    # Школы
    schools::Vector{School},
    # Вузы
    colleges::Vector{School},
    # Средняя продолжительность контактов в домохозяйствах
    mean_household_contact_durations::Vector{Float64},
    # Среднеквадр. откл. продолжительности контактов в домохозяйствах
    household_contact_duration_sds::Vector{Float64},
    # Средняя продолжительность контактов в прочих коллективах
    other_contact_duration_shapes::Vector{Float64},
    # Среднеквадр. откл. продолжительности контактов в прочих коллективах
    other_contact_duration_scales::Vector{Float64},
)
    # Выходной
    println("Holiday")
    @time run_simulation_evaluation(
        num_threads, thread_rng, agents, households, kindergartens,
        schools, colleges, mean_household_contact_durations,
        household_contact_duration_sds, other_contact_duration_shapes,
        other_contact_duration_scales, true)
    # Будний день
    println("Weekday")
    @time run_simulation_evaluation(
        num_threads, thread_rng, agents, households, kindergartens,
        schools, colleges, mean_household_contact_durations,
        household_contact_duration_sds, other_contact_duration_shapes,
        other_contact_duration_scales, false)
end

# Анализ чувствительности всех параметров модели
function global_sensitivity(
    # Число прогонов модели
    run_num::Int,
    # Число сохраненных прогонов модели
    starting_bias::Int,
    # Отклонение белого гауссовского шума
    disturbance::Float64,
    # Число потоков
    num_threads::Int,
    # Генератор случайных чисел для потоков
    thread_rng::Vector{MersenneTwister},
    # Агенты
    agents::Vector{Agent},
    # Вирусы
    viruses::Vector{Virus},
    # Домохозяйства
    households::Vector{Household},
    # Школы
    schools::Vector{School},
    # Температура воздуха
    temperature::Vector{Float64},
    # Заболеваемость в различных возрастных группах разными вирусами
    num_infected_age_groups_viruses::Array{Float64, 3},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам за прошлый год
    num_infected_age_groups_viruses_prev::Array{Float64, 3},
    # Число лет для моделирования
    num_years::Int,
    # Стандартные значения параметров модели
    # Параметр влияния продолжительности контакта на риск инфицирования
    duration_parameter::Float64,
    # Параметры восприимчивости агентов для различных вирусов
    susceptibility_parameters::Vector{Float64},
    # Параметры влияния температуры воздуха на вирусы
    temperature_parameters::Vector{Float64},
    # Средняя продолжительность контактов в домохозяйствах
    mean_household_contact_durations::Vector{Float64},
    # Среднеквадр. откл. продолжительность контактов в домохозяйствах
    household_contact_duration_sds::Vector{Float64},
    # Средняя продолжительность контактов в прочих коллективах
    other_contact_duration_shapes::Vector{Float64},
    # Среднеквадр. откл. продолжительность контактов в прочих коллективах
    other_contact_duration_scales::Vector{Float64},
    # Вероятности самоизолироваться на 1-й, 2-й и 3-й день болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Вероятности случайного инфицирования для различных возрастных групп
    random_infection_probabilities::Vector{Float64},
    # Средняя продолжительность резистентного состояния
    recovered_duration_mean::Float64,
    # Среднеквадр. откл. продолжительности резистентного состояния
    recovered_duration_sd::Float64,
    # Средние продолжительности иммунитета
    mean_immunity_durations::Vector{Float64},
)
    incubation_period_shape_noise = [rand(Normal(0.0, disturbance * viruses[k].incubation_period_shape)) for k = eachindex(viruses)]
    incubation_period_scale_noise = [rand(Normal(0.0, disturbance * viruses[k].incubation_period_scale)) for k = eachindex(viruses)]
    infection_period_child_shape_noise = [rand(Normal(0.0, disturbance * viruses[k].infection_period_child_shape)) for k = eachindex(viruses)]
    infection_period_child_scale_noise = [rand(Normal(0.0, disturbance * viruses[k].infection_period_child_scale)) for k = eachindex(viruses)]
    infection_period_adult_shape_noise = [rand(Normal(0.0, disturbance * viruses[k].infection_period_adult_shape)) for k = eachindex(viruses)]
    infection_period_adult_scale_noise = [rand(Normal(0.0, disturbance * viruses[k].infection_period_adult_scale)) for k = eachindex(viruses)]
    symptomatic_probability_child_noise = [rand(Normal(0.0, disturbance * viruses[k].symptomatic_probability_child)) for k = eachindex(viruses)]
    symptomatic_probability_teenager_noise = [rand(Normal(0.0, disturbance * viruses[k].symptomatic_probability_teenager)) for k = eachindex(viruses)]
    symptomatic_probability_adult_noise = [rand(Normal(0.0, disturbance * viruses[k].symptomatic_probability_adult)) for k = eachindex(viruses)]
    mean_viral_load_toddler_noise = [rand(Normal(0.0, disturbance * viruses[k].mean_viral_load_toddler)) for k = eachindex(viruses)]
    mean_viral_load_child_noise = [rand(Normal(0.0, disturbance * viruses[k].mean_viral_load_child)) for k = eachindex(viruses)]
    mean_viral_load_adult_noise = [rand(Normal(0.0, disturbance * viruses[k].mean_viral_load_adult)) for k = eachindex(viruses)]

    for k = eachindex(viruses)
        viruses[k].incubation_period_shape += incubation_period_shape_noise[k]
        viruses[k].incubation_period_scale += incubation_period_scale_noise[k]
        viruses[k].infection_period_child_shape += infection_period_child_shape_noise[k]
        viruses[k].infection_period_child_scale += infection_period_child_scale_noise[k]
        viruses[k].infection_period_adult_shape += infection_period_adult_shape_noise[k]
        viruses[k].infection_period_adult_scale += infection_period_adult_scale_noise[k]
        viruses[k].symptomatic_probability_child += symptomatic_probability_child_noise[k]
        viruses[k].symptomatic_probability_teenager += symptomatic_probability_teenager_noise[k]
        viruses[k].symptomatic_probability_adult += symptomatic_probability_adult_noise[k]
        viruses[k].mean_viral_load_toddler += mean_viral_load_toddler_noise[k]
        viruses[k].mean_viral_load_child += mean_viral_load_child_noise[k]
        viruses[k].mean_viral_load_adult += mean_viral_load_adult_noise[k]
    end

    # Моделируем заболеваемость
    @time observed_num_infected_age_groups_viruses, _, __, ___ = run_simulation(
        num_threads,
        thread_rng,
        agents,
        viruses,
        households,
        schools,
        duration_parameter + rand(Normal(0.0, disturbance * duration_parameter)),
        susceptibility_parameters + rand.(Normal.(0.0, disturbance .* susceptibility_parameters)),
        temperature_parameters + rand.(Normal.(0.0, -disturbance .* temperature_parameters)),
        temperature,
        mean_household_contact_durations + rand.(Normal.(0.0, disturbance .* mean_household_contact_durations)),
        household_contact_duration_sds + rand.(Normal.(0.0, disturbance .* household_contact_duration_sds)),
        other_contact_duration_shapes + rand.(Normal.(0.0, disturbance .* other_contact_duration_shapes)),
        other_contact_duration_scales + rand.(Normal.(0.0, disturbance .* other_contact_duration_scales)),
        isolation_probabilities_day_1 + rand.(Normal.(0.0, disturbance .* isolation_probabilities_day_1)),
        isolation_probabilities_day_2 + rand.(Normal.(0.0, disturbance .* isolation_probabilities_day_2)),
        isolation_probabilities_day_3 + rand.(Normal.(0.0, disturbance .* isolation_probabilities_day_3)),
        random_infection_probabilities + rand.(Normal.(0.0, disturbance .* random_infection_probabilities)),
        recovered_duration_mean + rand.(Normal.(0.0, disturbance .* recovered_duration_mean)),
        recovered_duration_sd + rand.(Normal.(0.0, disturbance .* recovered_duration_sd)),
        num_years,
        false
    )

    # Сохраняем результаты
    save(joinpath(@__DIR__, "..", "output", "tables", "sensitivity", "results_$(run_num + starting_bias).jld"),
        "observed_cases", observed_num_infected_age_groups_viruses,
        "isolation_probabilities_day_1", isolation_probabilities_day_1,
        "isolation_probabilities_day_2", isolation_probabilities_day_2,
        "isolation_probabilities_day_3", isolation_probabilities_day_3,
        "recovered_duration_mean", recovered_duration_mean,
        "recovered_duration_sd", recovered_duration_sd,
        "mean_household_contact_durations", mean_household_contact_durations,
        "household_contact_duration_sds", household_contact_duration_sds,
        "other_contact_duration_shapes", other_contact_duration_shapes,
        "other_contact_duration_scales", other_contact_duration_scales,
        "duration_parameter", duration_parameter,
        "susceptibility_parameters", susceptibility_parameters,
        "temperature_parameters", temperature_parameters,
        "random_infection_probabilities", random_infection_probabilities,
        "immune_memory_susceptibility_levels", immune_memory_susceptibility_levels,
        "mean_immunity_durations", mean_immunity_durations,
        "incubation_period_shapes", [viruses[k].incubation_period_shape for k = eachindex(viruses)],
        "incubation_period_duration_variances", [viruses[k].incubation_period_shape for k = eachindex(viruses)],
        "infection_period_durations_child", infection_period_durations_child,
        "infection_period_duration_variances_child", infection_period_duration_variances_child,
        "infection_period_durations_adult", infection_period_durations_adult,
        "infection_period_duration_variances_adult", infection_period_duration_variances_adult,
        "symptomatic_probabilities_child", symptomatic_probabilities_child,
        "symptomatic_probabilities_teenager", symptomatic_probabilities_teenager,
        "symptomatic_probabilities_adult", symptomatic_probabilities_adult,
        "mean_viral_loads_infant", mean_viral_loads_infant,
        "mean_viral_loads_child", mean_viral_loads_child,
        "mean_viral_loads_adult", mean_viral_loads_adult)

    # Сбрасываем состояние синтетической популяции до начального
    @threads for thread_id in 1:num_threads
        reset_agent_states(
            agents,
            start_agent_ids[thread_id],
            end_agent_ids[thread_id],
            viruses,
            num_infected_age_groups_viruses_prev,
            isolation_probabilities_day_1,
            isolation_probabilities_day_2,
            isolation_probabilities_day_3,
            thread_rng[thread_id],
        )
    end

    # Убираем добавленный на текущем шаге шум
    for k = eachindex(viruses)
        viruses[k].incubation_period_shape -= incubation_period_shape_noise[k]
        viruses[k].incubation_period_scale -= incubation_period_scale_noise[k]
        viruses[k].infection_period_child_shape -= infection_period_child_shape_noise[k]
        viruses[k].infection_period_child_scale -= infection_period_child_scale_noise[k]
        viruses[k].infection_period_adult_shape -= infection_period_adult_shape_noise[k]
        viruses[k].infection_period_adult_scale -= infection_period_adult_scale_noise[k]
        viruses[k].symptomatic_probability_child -= symptomatic_probability_child_noise[k]
        viruses[k].symptomatic_probability_teenager -= symptomatic_probability_teenager_noise[k]
        viruses[k].symptomatic_probability_adult -= symptomatic_probability_adult_noise[k]
        viruses[k].mean_viral_load_toddler -= mean_viral_load_toddler_noise[k]
        viruses[k].mean_viral_load_child -= mean_viral_load_child_noise[k]
        viruses[k].mean_viral_load_adult -= mean_viral_load_adult_noise[k]
    end
end

function parameter_sensitivity(
    # Число потоков
    num_threads::Int,
    # Генератор случайных чисел для потоков
    thread_rng::Vector{MersenneTwister},
    # Агенты
    agents::Vector{Agent},
    # Вирусы
    viruses::Vector{Virus},
    # Домохозяйства
    households::Vector{Household},
    # Школы
    schools::Vector{School},
    # Параметр влияния продолжительности контакта на риск инфицирования
    duration_parameter::Float64,
    # Параметры восприимчивости к вирусам
    susceptibility_parameters::Vector{Float64},
    # Параметры влияния температуры воздуха на вирусы
    temperature_parameters::Vector{Float64},
    # Температура воздуха
    temperature::Vector{Float64},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам за прошлый год
    num_infected_age_groups_viruses_prev::Array{Float64, 3},
    # Средние продолжительности контактов в домохозяйствах для разных контактов
    mean_household_contact_durations::Vector{Float64},
    # Среднеквадратические отклонения для контактов в домохозяйствах для разных контактов
    household_contact_duration_sds::Vector{Float64},
    # Средние продолжительности контактов в прочих коллективах
    other_contact_duration_shapes::Vector{Float64},
    # Среднеквадратические отклонения для контактов в прочих коллективах
    other_contact_duration_scales::Vector{Float64},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Вероятности случайного инфицирования
    random_infection_probabilities::Vector{Float64},
    # Средняя продолжительность резистентного состояния
    recovered_duration_mean::Float64,
    # Среднеквадр. откл. продолжительности резистентного состояния
    recovered_duration_sd::Float64,
    # Число лет для моделирования
    num_years::Int,
    # Средние продолжительности иммунитета
    mean_immunity_durations::Vector{Float64},
)
    # Множители для значений параметров
    multipliers = [0.8, 0.9, 1.1, 1.2]

    # Параметр влияния продолжительности контакта на риск инфицирования
    # Индекс для выходного файла
    k = -2
    # Проходим по множителям
    for m in multipliers
        # Моделируем заболеваемость
        @time observed_num_infected_age_groups_viruses, _, __, ___ = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter * m,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, false)
        # Сохраняем результат
        writedlm(
            joinpath(@__DIR__, "..", "output", "tables", "sensitivity", "2nd", "infected_data_d_$k.csv"),
            sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
        # Сбрасываем состояние синтетической популяции до начального
        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_infected_age_groups_viruses_prev,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
            )
        end
        if k == -1
            k = 1
        else
            k += 1
        end
    end

    # Параметры неспецифической восприимчивости к различным вирусам
    # Для каждого вируса
    for i in 1:num_viruses
        k = -2
        # Проходим по множителям
        for m in multipliers
            # Новые значения параметров
            susceptibility_parameters_new = copy(susceptibility_parameters)
            susceptibility_parameters_new[i] *= m
            # Моделируем заболеваемость
            @time observed_num_infected_age_groups_viruses, _, __, ___ = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
                susceptibility_parameters_new, temperature_parameters, temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities,
                recovered_duration_mean, recovered_duration_sd, num_years, false)
            # Сохраняем результат
            writedlm(
                joinpath(@__DIR__, "..", "output", "tables", "sensitivity", "2nd", "infected_data_s$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
            # Сбрасываем состояние синтетической популяции до начального
            @threads for thread_id in 1:num_threads
                reset_agent_states(
                    agents,
                    start_agent_ids[thread_id],
                    end_agent_ids[thread_id],
                    viruses,
                    num_infected_age_groups_viruses_prev,
                    isolation_probabilities_day_1,
                    isolation_probabilities_day_2,
                    isolation_probabilities_day_3,
                    thread_rng[thread_id],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end

    # Значения параметров влияния температуры воздуха
    values = -[0.25, 0.5, 0.75, 1.0]
    # Для каждого вируса
    for i in 1:num_viruses
        k = -2
        # Проходим по значениям
        for v in values
            # Присваиваем их
            temperature_parameters_new = copy(temperature_parameters)
            temperature_parameters_new[i] = v
            # Моделируем заболеваемость
            @time observed_num_infected_age_groups_viruses, _, __, ___ = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
                susceptibility_parameters, temperature_parameters_new, temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities,
                recovered_duration_mean, recovered_duration_sd, num_years, false)
            writedlm(
                joinpath(@__DIR__, "..", "output", "tables", "sensitivity", "2nd", "infected_data_t$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
            # Сбрасываем состояние синтетической популяции до начального
            @threads for thread_id in 1:num_threads
                reset_agent_states(
                    agents,
                    start_agent_ids[thread_id],
                    end_agent_ids[thread_id],
                    viruses,
                    num_infected_age_groups_viruses_prev,
                    isolation_probabilities_day_1,
                    isolation_probabilities_day_2,
                    isolation_probabilities_day_3,
                    thread_rng[thread_id],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end

    # Множители для вероятностей случайного инфицирования
    prob_multipliers = [0.1, 0.5, 2.0, 10.0]
    # Для каждой возрастной группы
    for i in 1:4
        k = -2
        # Проходим по каждому множителю
        for m in prob_multipliers
            # Новые значения
            random_infection_probabilities_new = copy(random_infection_probabilities)
            random_infection_probabilities_new[i] *= m
            # Моделируем заболеваемость
            @time observed_num_infected_age_groups_viruses, _, __, ___ = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
                susceptibility_parameters, temperature_parameters, temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities_new,
                recovered_duration_mean, recovered_duration_sd, num_years, false)
            # Сохраняем результаты
            writedlm(
                joinpath(@__DIR__, "..", "output", "tables", "sensitivity", "2nd", "infected_data_p$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
            # Сбрасываем состояние синтетической популяции до начального
            @threads for thread_id in 1:num_threads
                reset_agent_states(
                    agents,
                    start_agent_ids[thread_id],
                    end_agent_ids[thread_id],
                    viruses,
                    num_infected_age_groups_viruses_prev,
                    isolation_probabilities_day_1,
                    isolation_probabilities_day_2,
                    isolation_probabilities_day_3,
                    thread_rng[thread_id],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end
        end
    end

    # Продолжительности иммунитета
    # Для каждого вируса
    for i in 1:num_viruses
        k = -2
        # Проходим по множителям
        for m in multipliers
            # Новые значения
            mean_immunity_durations_new = copy(mean_immunity_durations)
            mean_immunity_durations_new[i] *= m
            for k = 1:length(viruses)
                viruses[k].mean_immunity_duration = mean_immunity_durations_new[k]
            end
            # Моделируем заболеваемость
            @time observed_num_infected_age_groups_viruses, _, __, ___ = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
                susceptibility_parameters, temperature_parameters, temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities,
                recovered_duration_mean, recovered_duration_sd, num_years, false)
            # Сохраняем результаты
            writedlm(
                joinpath(@__DIR__, "..", "output", "tables", "sensitivity", "2nd", "infected_data_r$(i)_$k.csv"),
                sum(sum(observed_num_infected_age_groups_viruses, dims = 2)[:, 1, :], dims = 2)[:, 1], ',')
            # Сбрасываем состояние синтетической популяции до начального
            @threads for thread_id in 1:num_threads
                reset_agent_states(
                    agents,
                    start_agent_ids[thread_id],
                    end_agent_ids[thread_id],
                    viruses,
                    num_infected_age_groups_viruses_prev,
                    isolation_probabilities_day_1,
                    isolation_probabilities_day_2,
                    isolation_probabilities_day_3,
                    thread_rng[thread_id],
                )
            end
            if k == -1
                k = 1
            else
                k += 1
            end

            for k = 1:length(viruses)
                viruses[k].mean_immunity_duration = mean_immunity_durations[k]
            end
        end
    end
end

function lhs_simulations(
    # Моделируется средняя заболеваемость за год
    is_one_mean_year_modeled::Bool,
    # Число прогонов модели
    num_runs::Int,
    # Агенты
    agents::Vector{Agent},
    # Домохозяйства
    households::Vector{Household},
    # Школы
    schools::Vector{School},
    # Число потоков
    num_threads::Int,
    # Генератор случайных чисел для потоков
    thread_rng::Vector{MersenneTwister},
    # Id первого агента для потоков
    start_agent_ids::Vector{Int},
    # Id последнего агента для потоков
    end_agent_ids::Vector{Int},
    # Температура воздуха
    temperature::Vector{Float64},
    # Вирусы
    viruses::Vector{Virus},
    # Заболеваемость в различных возрастных группах разными вирусами
    num_infected_age_groups_viruses::Array{Float64, 3},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам за прошлый год
    num_infected_age_groups_viruses_prev::Array{Float64, 3},
    # Средние продолжительности контактов в домохозяйствах для разных контактов
    mean_household_contact_durations::Vector{Float64},
    # Среднеквадратические отклонения для контактов в домохозяйствах для разных контактов
    household_contact_duration_sds::Vector{Float64},
    # Средние продолжительности контактов в прочих коллективах
    other_contact_duration_shapes::Vector{Float64},
    # Среднеквадратические отклонения для контактов в прочих коллективах
    other_contact_duration_scales::Vector{Float64},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Средняя продолжительность резистентного состояния
    recovered_duration_mean::Float64,
    # Среднеквадр. откл. продолжительности резистентного состояния
    recovered_duration_sd::Float64,
    # Вероятности случайного инфицирования для различных возрастных групп
    random_infection_probabilities_default::Vector{Float64},
    # Средние продолжительности иммунитета
    mean_immunity_durations::Vector{Float64},
    # Число лет
    num_years::Int,
    # Имя папки
    folder_name::String,
)
    # Число прогонов модели
    num_files = 0
    for _ in readdir(joinpath(@__DIR__, "..", "output", "tables", "lhs", folder_name))
        num_files +=1
    end

    # Число параметров
    # num_parameters = 33
    num_parameters = 26

    # Латинский гиперкуб
    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 500)

    # В случае, если значения загружаются из таблицы
    # points = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "output", "tables", "lhs", "parameters.csv"), header = false)))

    # Интервалы значений параметров
    points = scaleLHC(latin_hypercube_plan, [
        (0.1, 1.0), # duration_parameter
        (1.0, 7.0), # susceptibility_parameters
        (1.0, 7.0),
        (1.0, 7.0),
        (1.0, 7.0),
        (1.0, 7.0),
        (1.0, 7.0),
        (1.0, 7.0),
        (-1.0, -0.01), # temperature_parameters
        (-1.0, -0.01),
        (-1.0, -0.01),
        (-1.0, -0.01),
        (-1.0, -0.01),
        (-1.0, -0.01),
        (-1.0, -0.01),
        (30, 365), # mean_immunity_durations
        (30, 365),
        (30, 365),
        (30, 365),
        (30, 365),
        (30, 365),
        (30, 365),
        (0.0008, 0.0012), # random_infection_probabilities
        (0.0005, 0.001),
        (0.0002, 0.0005),
        (0.000005, 0.00001),
    ])
    writedlm(joinpath(@__DIR__, "..", "output", "tables", "lhs", "parameters.csv"), points, ',')

    nMAE_min = 1.0e12

    for i = (num_files + 1):num_runs
        println(i)

        duration_parameter = points[i, 1]
        susceptibility_parameters = points[i, 2:8]
        temperature_parameters = points[i, 9:15]
        for k = 1:length(viruses)
            viruses[k].mean_immunity_duration = points[i, 15 + k]
            viruses[k].immunity_duration_sd = points[i, 15 + k] * 0.33
        end
        random_infection_probabilities = points[i, 23:26]

        # Моделируем заболеваемость
        @time observed_num_infected_age_groups_viruses, _, __, ___ = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, false)

        nMAE = 0.0
        # Если рассматривается 1 год
        if is_one_mean_year_modeled
            observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
            for i = 2:num_years
                for j = 1:52
                    observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
                end
            end
            observed_num_infected_age_groups_viruses_mean ./= num_years
    
            nMAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        else
            nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        end
    
        if nMAE < nMAE_min
            nMAE_min = nMAE
            println("nMAE_min = ", nMAE_min)
            println("duration_parameter = ", duration_parameter)
            println("susceptibility_parameters = ", susceptibility_parameters)
            println("temperature_parameters = ", temperature_parameters)
            println("mean_immunity_durations = ", [points[i, 16], points[i, 17], points[i, 18], points[i, 19], points[i, 20], points[i, 21], points[i, 22]])
            println("random_infection_probabilities = ", random_infection_probabilities)
        end

        save(joinpath(@__DIR__, "..", "output", "tables", "lhs", folder_name, "results_$(i).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "duration_parameter", duration_parameter,
            "susceptibility_parameters", susceptibility_parameters,
            "temperature_parameters", temperature_parameters,
            "mean_immunity_durations", [points[i, 16], points[i, 17], points[i, 18], points[i, 19], points[i, 20], points[i, 21], points[i, 22]],
            "random_infection_probabilities", random_infection_probabilities)

        # Сбрасываем состояние синтетической популяции до начального
        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_infected_age_groups_viruses_prev,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
            )
        end
    end
end

function mcmc_simulations(
    # Если моделируется среднее за год
    is_one_mean_year_modeled::Bool,
    # Агенты
    agents::Vector{Agent},
    # Домохозяйства
    households::Vector{Household},
    # Школы
    schools::Vector{School},
    # Число потоков
    num_threads::Int,
    # Генератор случайных чисел для потоков
    thread_rng::Vector{MersenneTwister},
    # Id первого агента для потоков
    start_agent_ids::Vector{Int},
    # Id последнего агента для потоков
    end_agent_ids::Vector{Int},
    # Температура воздуха
    temperature::Vector{Float64},
    # Вирусы
    viruses::Vector{Virus},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам
    num_infected_age_groups_viruses::Array{Float64, 3},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам за прошлый год
    num_infected_age_groups_viruses_prev::Array{Float64, 3},
    # Средние продолжительности контактов в домохозяйствах для разных контактов
    mean_household_contact_durations::Vector{Float64},
    # Среднеквадратические отклонения для контактов в домохозяйствах для разных контактов
    household_contact_duration_sds::Vector{Float64},
    # Средние продолжительности контактов в прочих коллективах
    other_contact_duration_shapes::Vector{Float64},
    # Среднеквадратические отклонения для контактов в прочих коллективах
    other_contact_duration_scales::Vector{Float64},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    random_infection_probabilities::Vector{Float64},
    # Число лет для моделирования
    num_years::Int,
)
    # hypercube / manual
    nMAE_output_table_name = "tables_mcmc_hypercube"
    nMAE_output_file_location = joinpath(@__DIR__, "..", "parameters", "output_mcmc_hypercube.txt")

    # Получаем значения параметров
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = duration_parameter_array[end]

    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))
    susceptibility_parameters = [
        susceptibility_parameter_1_array[end],
        susceptibility_parameter_2_array[end],
        susceptibility_parameter_3_array[end],
        susceptibility_parameter_4_array[end],
        susceptibility_parameter_5_array[end],
        susceptibility_parameter_6_array[end],
        susceptibility_parameter_7_array[end]
    ]

    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
    temperature_parameters = -[
        temperature_parameter_1_array[end],
        temperature_parameter_2_array[end],
        temperature_parameter_3_array[end],
        temperature_parameter_4_array[end],
        temperature_parameter_5_array[end],
        temperature_parameter_6_array[end],
        temperature_parameter_7_array[end]
    ]

    mean_immunity_duration_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_1_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_2_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_3_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_4_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_5_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_5_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_6_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_6_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration_7_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_7_array.csv"), ',', Float64, '\n'))
    mean_immunity_duration = [
        mean_immunity_duration_1_array[end],
        mean_immunity_duration_2_array[end],
        mean_immunity_duration_3_array[end],
        mean_immunity_duration_4_array[end],
        mean_immunity_duration_5_array[end],
        mean_immunity_duration_6_array[end],
        mean_immunity_duration_7_array[end]
    ]

    random_infection_probability_1_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_1_array.csv"), ',', Float64, '\n'))
    random_infection_probability_2_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_2_array.csv"), ',', Float64, '\n'))
    random_infection_probability_3_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_3_array.csv"), ',', Float64, '\n'))
    random_infection_probability_4_array = vec(readdlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_4_array.csv"), ',', Float64, '\n'))
    random_infection_probability = [
        random_infection_probability_1_array[end],
        random_infection_probability_2_array[end],
        random_infection_probability_3_array[end],
        random_infection_probability_4_array[end],
    ]

    # Получаем результаты моделирования для начального набора значений параметров
    @time observed_num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
        num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        mean_household_contact_durations, household_contact_duration_sds,
        other_contact_duration_shapes, other_contact_duration_scales,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, random_infection_probabilities,
        recovered_duration_mean, recovered_duration_sd, num_years, false)

    # Число принятий новых значений параметров
    accept_num = 0
    # Число последовательных отказов
    local_rejected_num = 0

    # Разброс для значений параметров-кандидатов
    # duration_parameter_delta = 0.05
    # susceptibility_parameter_deltas = [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
    # temperature_parameter_deltas = [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
    # mean_immunity_duration_deltas = [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
    # random_infection_probability_deltas = [0.05, 0.05, 0.05, 0.05]

    duration_parameter_delta = 0.1
    susceptibility_parameter_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    temperature_parameter_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    mean_immunity_duration_deltas = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
    random_infection_probability_deltas = [0.1, 0.1, 0.1, 0.1]

    nMAE = 0.0
    nMAE_min = 99999.0
    # Если рассматривается 1 год
    if is_one_mean_year_modeled
        observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
        for i = 2:num_years
            for j = 1:52
                observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
            end
        end
        observed_num_infected_age_groups_viruses_mean ./= num_years

        nMAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    else
        nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end
    nMAE_prev = nMAE
    nMAE_min = nMAE

    if countlines(nMAE_output_file_location) == 0
        open(nMAE_output_file_location, "a") do io
            println(io, nMAE)
        end
    end

    for n = 1:1000
        # Кандидат для параметра продолжительности контакта в диапазоне (0.1, 1)
        x = duration_parameter_array[end]
        y = rand(Normal(log((x - 0.1) / (1 - x)), duration_parameter_delta))
        duration_parameter_candidate = (exp(y) + 0.1) / (1 + exp(y))

        # Кандидаты для параметров неспецифической восприимчивости к вирусам в диапазоне (1, 7)
        x = susceptibility_parameter_1_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[1]))
        susceptibility_parameter_1_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_2_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[2]))
        susceptibility_parameter_2_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_3_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[3]))
        susceptibility_parameter_3_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_4_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[4]))
        susceptibility_parameter_4_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_5_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[5]))
        susceptibility_parameter_5_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_6_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[6]))
        susceptibility_parameter_6_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        x = susceptibility_parameter_7_array[end]
        y = rand(Normal(log((x - 1) / (7 - x)), susceptibility_parameter_deltas[7]))
        susceptibility_parameter_7_candidate = (7 * exp(y) + 1) / (1 + exp(y))

        # Кандидаты для параметров температуры воздуха в диапазоне (0.01, 1)
        x = temperature_parameter_1_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[1]))
        temperature_parameter_1_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_2_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[2]))
        temperature_parameter_2_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_3_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[3]))
        temperature_parameter_3_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_4_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[4]))
        temperature_parameter_4_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_5_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[5]))
        temperature_parameter_5_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_6_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[6]))
        temperature_parameter_6_candidate = (exp(y) + 0.01) / (1 + exp(y))

        x = temperature_parameter_7_array[end]
        y = rand(Normal(log((x - 0.01) / (1 - x)), temperature_parameter_deltas[7]))
        temperature_parameter_7_candidate = (exp(y) + 0.01) / (1 + exp(y))

        # Кандидаты для параметров температуры воздуха в диапазоне (30, 365)
        x = mean_immunity_duration_1_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[1]))
        mean_immunity_duration_1_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_2_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[2]))
        mean_immunity_duration_2_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_3_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[3]))
        mean_immunity_duration_3_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_4_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[4]))
        mean_immunity_duration_4_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_5_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[5]))
        mean_immunity_duration_5_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_6_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[6]))
        mean_immunity_duration_6_candidate = (365 * exp(y) + 30) / (1 + exp(y))

        x = mean_immunity_duration_7_array[end]
        y = rand(Normal(log((x - 30) / (365 - x)), mean_immunity_duration_deltas[7]))
        mean_immunity_duration_7_candidate = (365 * exp(y) + 30) / (1 + exp(y))
        
        # Кандидаты для параметра вероятности случайного инфицирования для возрастной группы 0-2 лет в диапазоне (0.0009, 0.0015)
        x = random_infection_probability_1_array[end]
        y = rand(Normal(log((x - 0.0009) / (0.0015 - x)), random_infection_probability_deltas[1]))
        random_infection_probability_1_candidate = (0.0015 * exp(y) + 0.0009) / (1 + exp(y))

        # Кандидаты для параметра вероятности случайного инфицирования для возрастной группы 3-6 лет в диапазоне (0.0005, 0.001)
        x = random_infection_probability_2_array[end]
        y = rand(Normal(log((x - 0.0005) / (0.001 - x)), random_infection_probability_deltas[2]))
        random_infection_probability_2_candidate = (0.001 * exp(y) + 0.0005) / (1 + exp(y))

        # Кандидаты для параметра вероятности случайного инфицирования для возрастной группы 7-14 лет в диапазоне (0.0002, 0.0005)
        x = random_infection_probability_3_array[end]
        y = rand(Normal(log((x - 0.0002) / (0.0005 - x)), random_infection_probability_deltas[3]))
        random_infection_probability_3_candidate = (0.0005 * exp(y) + 0.0002) / (1 + exp(y))

        # Кандидаты для параметра вероятности случайного инфицирования для возрастной группы 15+ лет в диапазоне (0.000005, 0.00001)
        x = random_infection_probability_4_array[end]
        y = rand(Normal(log((x - 0.000005) / (0.00001 - x)), random_infection_probability_deltas[4]))
        random_infection_probability_4_candidate = (0.00001 * exp(y) + 0.000005) / (1 + exp(y))

        duration_parameter = duration_parameter_candidate
        susceptibility_parameters = [
            susceptibility_parameter_1_candidate,
            susceptibility_parameter_2_candidate,
            susceptibility_parameter_3_candidate,
            susceptibility_parameter_4_candidate,
            susceptibility_parameter_5_candidate,
            susceptibility_parameter_6_candidate,
            susceptibility_parameter_7_candidate,
        ]
        temperature_parameters = -[
            temperature_parameter_1_candidate,
            temperature_parameter_2_candidate,
            temperature_parameter_3_candidate,
            temperature_parameter_4_candidate,
            temperature_parameter_5_candidate,
            temperature_parameter_6_candidate,
            temperature_parameter_7_candidate,
        ]
        mean_immunity_durations = [
            mean_immunity_duration_1_candidate,
            mean_immunity_duration_2_candidate,
            mean_immunity_duration_3_candidate,
            mean_immunity_duration_4_candidate,
            mean_immunity_duration_5_candidate,
            mean_immunity_duration_6_candidate,
            mean_immunity_duration_7_candidate,
        ]
        random_infection_probabilities = [
            random_infection_probability_1_candidate,
            random_infection_probability_2_candidate,
            random_infection_probability_3_candidate,
            random_infection_probability_4_candidate,
        ]

        for k = eachindex(viruses)
            viruses[k].mean_immunity_duration = mean_immunity_durations[k]
            viruses[k].immunity_duration_sd = mean_immunity_durations[k] * 0.33
        end

        # Сбрасываем состояние синтетической популяции до начального
        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_infected_age_groups_viruses_prev,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
            )
        end

        # Моделируем заболеваемость
        @time observed_num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
            num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
            susceptibility_parameters, temperature_parameters, temperature,
            mean_household_contact_durations, household_contact_duration_sds,
            other_contact_duration_shapes, other_contact_duration_scales,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, random_infection_probabilities,
            recovered_duration_mean, recovered_duration_sd, num_years, false)

        save(joinpath(@__DIR__, "..", "output", "tables", "mcmc", "results_$(n + 249).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "duration_parameter", duration_parameter,
            "susceptibility_parameters", susceptibility_parameters,
            "temperature_parameters", temperature_parameters,
            "mean_immunity_durations", mean_immunity_durations,
            "random_infection_probabilities", random_infection_probabilities)

        nMAE = 0.0
        # Если рассматривается 1 год
        if is_one_mean_year_modeled
            observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
            for i = 2:num_years
                for j = 1:52
                    observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
                end
            end
            observed_num_infected_age_groups_viruses_mean ./= num_years

            nMAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        else
            nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
        end

        open(nMAE_output_file_location, "a") do io
            println(io, nMAE)
        end

        # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
        if nMAE < nMAE_prev || local_rejected_num >= 10
            if nMAE < nMAE_min
                println("nMAE min = $(nMAE)")
                println("duration_parameter = $(duration_parameter_candidate)")
                println("susceptibility_parameters = $(susceptibility_parameters)")
                println("temperature_parameters = $(temperature_parameters)")
                println("mean_immunity_durations = $(mean_immunity_durations)")
                println("random_infection_probabilities = $(random_infection_probabilities)")
            end
            push!(duration_parameter_array, duration_parameter_candidate)

            push!(susceptibility_parameter_1_array, susceptibility_parameter_1_candidate)
            push!(susceptibility_parameter_2_array, susceptibility_parameter_2_candidate)
            push!(susceptibility_parameter_3_array, susceptibility_parameter_3_candidate)
            push!(susceptibility_parameter_4_array, susceptibility_parameter_4_candidate)
            push!(susceptibility_parameter_5_array, susceptibility_parameter_5_candidate)
            push!(susceptibility_parameter_6_array, susceptibility_parameter_6_candidate)
            push!(susceptibility_parameter_7_array, susceptibility_parameter_7_candidate)

            push!(temperature_parameter_1_array, temperature_parameter_1_candidate)
            push!(temperature_parameter_2_array, temperature_parameter_2_candidate)
            push!(temperature_parameter_3_array, temperature_parameter_3_candidate)
            push!(temperature_parameter_4_array, temperature_parameter_4_candidate)
            push!(temperature_parameter_5_array, temperature_parameter_5_candidate)
            push!(temperature_parameter_6_array, temperature_parameter_6_candidate)
            push!(temperature_parameter_7_array, temperature_parameter_7_candidate)

            push!(mean_immunity_duration_1_array, mean_immunity_duration_1_candidate)
            push!(mean_immunity_duration_2_array, mean_immunity_duration_2_candidate)
            push!(mean_immunity_duration_3_array, mean_immunity_duration_3_candidate)
            push!(mean_immunity_duration_4_array, mean_immunity_duration_4_candidate)
            push!(mean_immunity_duration_5_array, mean_immunity_duration_5_candidate)
            push!(mean_immunity_duration_6_array, mean_immunity_duration_6_candidate)
            push!(mean_immunity_duration_7_array, mean_immunity_duration_7_candidate)

            push!(random_infection_probability_1_array, random_infection_probability_1_candidate)
            push!(random_infection_probability_2_array, random_infection_probability_2_candidate)
            push!(random_infection_probability_3_array, random_infection_probability_3_candidate)
            push!(random_infection_probability_4_array, random_infection_probability_4_candidate)

            nMAE_prev = nMAE

            # Увеличиваем число принятий новых параметров
            accept_num += 1
            # Число последовательных отказов приравниваем нулю
            local_rejected_num = 0
        else
            # Добавляем предыдущие значения параметров
            push!(duration_parameter_array, duration_parameter_array[end])

            push!(susceptibility_parameter_1_array, susceptibility_parameter_1_array[end])
            push!(susceptibility_parameter_2_array, susceptibility_parameter_2_array[end])
            push!(susceptibility_parameter_3_array, susceptibility_parameter_3_array[end])
            push!(susceptibility_parameter_4_array, susceptibility_parameter_4_array[end])
            push!(susceptibility_parameter_5_array, susceptibility_parameter_5_array[end])
            push!(susceptibility_parameter_6_array, susceptibility_parameter_6_array[end])
            push!(susceptibility_parameter_7_array, susceptibility_parameter_7_array[end])

            push!(temperature_parameter_1_array, temperature_parameter_1_array[end])
            push!(temperature_parameter_2_array, temperature_parameter_2_array[end])
            push!(temperature_parameter_3_array, temperature_parameter_3_array[end])
            push!(temperature_parameter_4_array, temperature_parameter_4_array[end])
            push!(temperature_parameter_5_array, temperature_parameter_5_array[end])
            push!(temperature_parameter_6_array, temperature_parameter_6_array[end])
            push!(temperature_parameter_7_array, temperature_parameter_7_array[end])

            push!(mean_immunity_duration_1_array, mean_immunity_duration_1_array[end])
            push!(mean_immunity_duration_2_array, mean_immunity_duration_2_array[end])
            push!(mean_immunity_duration_3_array, mean_immunity_duration_3_array[end])
            push!(mean_immunity_duration_4_array, mean_immunity_duration_4_array[end])
            push!(mean_immunity_duration_5_array, mean_immunity_duration_5_array[end])
            push!(mean_immunity_duration_6_array, mean_immunity_duration_6_array[end])
            push!(mean_immunity_duration_7_array, mean_immunity_duration_7_array[end])

            push!(random_infection_probability_1_array, random_infection_probability_1_array[end])
            push!(random_infection_probability_2_array, random_infection_probability_2_array[end])
            push!(random_infection_probability_3_array, random_infection_probability_3_array[end])
            push!(random_infection_probability_4_array, random_infection_probability_4_array[end])
            
            local_rejected_num += 1
        end

        # Раз в 2 шага
        # if n % 2 == 0
        if n % 1 == 0
            # Сохраняем значения параметров
            writedlm(joinpath(@__DIR__, "..", "parameters", nMAE_output_table_name, "duration_parameter_array.csv"), duration_parameter_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_1_array.csv"), susceptibility_parameter_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_2_array.csv"), susceptibility_parameter_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_3_array.csv"), susceptibility_parameter_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_4_array.csv"), susceptibility_parameter_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_5_array.csv"), susceptibility_parameter_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_6_array.csv"), susceptibility_parameter_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "susceptibility_parameter_7_array.csv"), susceptibility_parameter_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_1_array.csv"), temperature_parameter_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_2_array.csv"), temperature_parameter_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_3_array.csv"), temperature_parameter_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_4_array.csv"), temperature_parameter_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_5_array.csv"), temperature_parameter_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_6_array.csv"), temperature_parameter_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "temperature_parameter_7_array.csv"), temperature_parameter_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_1_array.csv"), mean_immunity_duration_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_2_array.csv"), mean_immunity_duration_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_3_array.csv"), mean_immunity_duration_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_4_array.csv"), mean_immunity_duration_4_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_5_array.csv"), mean_immunity_duration_5_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_6_array.csv"), mean_immunity_duration_6_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "mean_immunity_duration_7_array.csv"), mean_immunity_duration_7_array, ',')

            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_1_array.csv"), random_infection_probability_1_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_2_array.csv"), random_infection_probability_2_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_3_array.csv"), random_infection_probability_3_array, ',')
            writedlm(joinpath(
                @__DIR__, "..", "parameters", nMAE_output_table_name, "random_infection_probability_4_array.csv"), random_infection_probability_4_array, ',')
        end
    end
end

function main(
    # Набор параметров модели (порядок для вирусов: FluA, FluB, RV, RSV, AdV, PIV, CoV)
    duration_parameter::Float64 = 0.15574760338153604,
    susceptibility_parameters::Vector{Float64} = [2.432383535521401, 2.238084657549736, 3.9300635165658035, 5.1720010915454235, 5.144684292234647, 4.341625180301945, 5.6260953331716905],
    temperature_parameters::Vector{Float64} = -[0.9251684333883052, 0.7239220149884157, 0.049812103111112345, 0.10582041043086308, 0.038630895494711034, 0.03723490323281524, 0.20131912645634797],
    mean_immunity_durations::Vector{Float64} = [155.9752583833697, 247.24115717945472, 147.8575990177909, 203.0420746358355, 79.78372383057398, 177.17279810129776, 99.15211361389254],
    random_infection_probabilities::Vector{Float64} = [0.001, 0.0007000333340668348, 0.000438925392941535, 8.746936501061745e-6],

    # Сценарий работы модели
    # -----------------------------------
    # Число дней закрытия класса или школы на карантин
    school_class_closure_period::Int = 0,
    # school_class_closure_period = 7
    # Процент отсутствующих учеников по причине болезни для того, чтобы школа закрылась на карантин
    school_class_closure_threshold::Float64 = 0.2,
    # [0.2  0.1  0.3  0.2_14  0.1_14]

    # Для сценария глобального потепления
    global_warming_temperature::Float64 = 0.0,
    # ["+1 °С" "+2 °С" "+3 °С" "+4 °С"]
    # -----------------------------------
)
    println("Initialization...")

    # Номер запуска модели
    run_num = 0
    is_rt_run = true
    try
        run_num = parse(Int64, ARGS[1])
    catch
        run_num = 0
    end

    # Число моделируемых лет
    num_years = 1
    # Среднее по num_years
    is_one_mean_year_modeled = true

    # Число потоков
    num_threads = nthreads()

    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    recovered_duration_mean = 6.0
    recovered_duration_sd = 2.0
    # Продолжительности контактов в домохозяйствах
    # Укороченные для различных коллективов и полная: детсад, школа, вуз, работа, полный контакт
    mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
    # Продолжительности контактов в прочих коллективах: детсад, школа, вуз, работа, вуз (между группами)
    other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
    # Минимальный размер рабочего коллектива
    firm_min_size = 1
    # Максимальный размер рабочего коллектива
    firm_max_size = 1000
    # Параметр предпочтительного присоединения графа Барабаши-Альберт для рабочих коллективов
    work_num_barabasi_albert_attachments = 5
    # Параметр предпочтительного присоединения графа Барабаши-Альберт для школ
    school_num_barabasi_albert_attachments = 10

    # Набор вирусов
    # shape = mean * mean / variance
    # scale = variance / mean
    viruses = Virus[
        # Flu A
        Virus(round(Int, 1.4 * 1.4 / 0.67), 0.67 / 1.4,   round(Int, 4.8 * 4.8 / 2.04), 2.04 / 4.8,    round(Int, 8.0 * 8.0 / 3.4), 3.4 / 8.0,      3.53, 2.63, 1.8,    0.38, 0.47, 0.57,   mean_immunity_durations[1], mean_immunity_durations[1] * 0.33),
        # Flu B
        Virus(round(Int, 0.6 * 0.6 / 0.19), 0.19 / 0.6,   round(Int, 3.7 * 3.7 / 3.0), 3.0 / 3.7,      round(Int, 6.1 * 6.1 / 4.8), 4.8 / 6.1,      3.53, 2.63, 1.8,    0.38, 0.47, 0.57,   mean_immunity_durations[2], mean_immunity_durations[2] * 0.33),
        # RV
        Virus(round(Int, 1.9 * 1.9 / 1.11), 1.11 / 1.9,   round(Int, 10.1 * 10.1 / 7.0), 7.0 / 10.1,   round(Int, 11.4 * 11.4 / 7.7), 7.7 / 11.4,   3.5, 2.6, 1.8,      0.19, 0.24, 0.29,   mean_immunity_durations[3], mean_immunity_durations[3] * 0.33),
        # RSV
        Virus(round(Int, 4.4 * 4.4 / 1.0), 1.0 / 4.4,     round(Int, 6.5 * 6.5 / 2.7), 2.7 / 6.5,      round(Int, 6.7 * 6.7 / 2.8), 2.8 / 6.7,      6.0, 4.5, 3.0,      0.24, 0.3, 0.36,    mean_immunity_durations[4], mean_immunity_durations[4] * 0.33),
        # AdV
        Virus(round(Int, 5.6 * 5.6 / 1.3), 1.3 / 5.6,     round(Int, 8.0 * 8.0 / 5.6), 5.6 / 8.0,      round(Int, 9.0 * 9.0 / 6.3), 6.3 / 9.0,      4.1, 3.1, 2.1,      0.15, 0.19, 0.23,   mean_immunity_durations[5], mean_immunity_durations[5] * 0.33),
        # PIV
        Virus(round(Int, 2.6 * 2.6 / 0.85), 0.85 / 2.6,   round(Int, 7.0 * 7.0 / 2.9), 2.9 / 7.0,      round(Int, 8.0 * 8.0 / 3.4), 3.4 / 8.0,      4.8, 3.6, 2.4,      0.16, 0.2, 0.24,    mean_immunity_durations[6], mean_immunity_durations[6] * 0.33),
        # CoV
        Virus(round(Int, 3.2 * 3.2 / 0.44), 0.44 / 3.2,   round(Int, 6.5 * 6.5 / 4.5), 4.5 / 6.5,      round(Int, 7.5 * 7.5 / 5.2), 5.2 / 7.5,      4.9, 3.7, 2.5,      0.21, 0.26, 0.32,   mean_immunity_durations[7], mean_immunity_durations[7] * 0.33)]

    # Число домохозяйств каждого типа по муниципалитетам
    district_households = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_households.csv"))))
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_people.csv"))))
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_people_households.csv"))))
    # Распределение вирусов в течение года
    etiology = get_etiology()
    # Температура воздуха, начиная с 1 января
    temperature = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "temperature.csv"))))[1, :]

    # Набор агентов
    agents = Array{Agent, 1}(undef, num_agents)

    # Генератор случайных чисел для потоков
    thread_rng = [MersenneTwister(i + run_num * num_threads) for i = 1:num_threads]

    # Координаты домов
    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv")))
    # Массив для хранения домохозяйств
    households = Array{Household, 1}(undef, num_households)

    # Координаты детских садов
    kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
    # Массив для хранения детских садов
    kindergartens = Array{School, 1}(undef, num_kindergartens)
    for i in 1:size(kindergarten_coords_df, 1)
        kindergartens[i] = School(
            1,
            kindergarten_coords_df[i, :dist],
            kindergarten_coords_df[i, :x],
            kindergarten_coords_df[i, :y],
        )
    end

    # Координаты школ
    school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
    # Массив для хранения школ
    schools = Array{School, 1}(undef, num_schools)
    for i in 1:size(school_coords_df, 1)
        schools[i] = School(
            2,
            school_coords_df[i, :dist],
            school_coords_df[i, :x],
            school_coords_df[i, :y],
        )
    end

    # Координаты вузов
    college_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "colleges.csv")))
    # Массив для хранения институтов
    colleges = Array{School, 1}(undef, num_colleges)
    for i in 1:size(college_coords_df, 1)
        colleges[i] = School(
            3,
            college_coords_df[i, :dist],
            college_coords_df[i, :x],
            college_coords_df[i, :y],
        )
    end

    # Массив для хранения фирм
    workplaces = Workplace[]

    # Заболеваемость различными вирусами в разных возрастных группах за рассматриваемые года
    num_infected_age_groups_viruses = get_incidence(etiology, is_one_mean_year_modeled, flu_starting_index, true)
    # Заболеваемость различными вирусами в разных возрастных группах за предыдущий год
    num_infected_age_groups_viruses_prev = get_incidence(etiology, false, 1, false)

    for virus_id in eachindex(viruses)
        num_infected_age_groups_viruses_prev[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_infected_age_groups_viruses_prev[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_infected_age_groups_viruses_prev[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_infected_age_groups_viruses_prev[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    # Создание популяции
    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id],
            agents, households, viruses, num_infected_age_groups_viruses_prev, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households)
    end

    # Установление связей между агентами
    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, work_num_barabasi_albert_attachments,
        school_num_barabasi_albert_attachments)

    # Информация о популяции
    # get_stats(agents, households, schools, workplaces)
    # return

    println("Simulation...")

    # Моделирование контактов
    # --------------------------
    # simulate_contacts(
    #     num_threads,
    #     thread_rng,
    #     agents,
    #     kindergartens,
    #     schools,
    #     colleges,
    #     mean_household_contact_durations,
    #     household_contact_duration_sds,
    #     other_contact_duration_shapes,
    #     other_contact_duration_scales,
    # )
    # return
    # --------------------------

    # Анализ чувствительности для всех параметров модели
    # --------------------------
    # for run_num = 1:100
    #     global_sensitivity(
    #         run_num,
    #         0,
    #         0.05,
    #         num_threads,
    #         thread_rng,
    #         agents,
    #         viruses,
    #         households,
    #         schools,
    #         temperature,
    #         num_infected_age_groups_viruses,
    #         num_infected_age_groups_viruses_prev,
    #         num_years,
    #         duration_parameter,
    #         susceptibility_parameters,
    #         temperature_parameters,
    #         mean_household_contact_durations,
    #         household_contact_duration_sds,
    #         other_contact_duration_shapes,
    #         other_contact_duration_scales,
    #         isolation_probabilities_day_1,
    #         isolation_probabilities_day_2,
    #         isolation_probabilities_day_3,
    #         random_infection_probabilities,
    #         recovered_duration_mean,
    #         recovered_duration_sd,
    #         mean_immunity_durations,
    #     )
    # end
    # return
    # --------------------------

    # Анализ чувствительности для настраиваемых параметров модели
    # --------------------------
    # parameter_sensitivity(
    #     num_threads,
    #     thread_rng,
    #     agents,
    #     viruses,
    #     households,
    #     schools,
    #     duration_parameter,
    #     susceptibility_parameters,
    #     temperature_parameters,
    #     temperature,
    #     num_infected_age_groups_viruses_prev,
    #     mean_household_contact_durations,
    #     household_contact_duration_sds,
    #     other_contact_duration_shapes,
    #     other_contact_duration_scales,
    #     isolation_probabilities_day_1,
    #     isolation_probabilities_day_2,
    #     isolation_probabilities_day_3,
    #     random_infection_probabilities,
    #     recovered_duration_mean,
    #     recovered_duration_sd,
    #     num_years,
    #     mean_immunity_durations,
    # )
    # return
    # --------------------------

    # Использование выборки латинского гиперкуба для исследования пространства параметров модели
    # --------------------------
    # lhs_simulations(
    #     is_one_mean_year_modeled,
    #     50,
    #     agents,
    #     households,
    #     schools,
    #     num_threads,
    #     thread_rng,
    #     start_agent_ids,
    #     end_agent_ids,
    #     temperature,
    #     viruses,
    #     num_infected_age_groups_viruses,
    #     num_infected_age_groups_viruses_prev,
    #     mean_household_contact_durations,
    #     household_contact_duration_sds,
    #     other_contact_duration_shapes,
    #     other_contact_duration_scales,
    #     isolation_probabilities_day_1,
    #     isolation_probabilities_day_2,
    #     isolation_probabilities_day_3,
    #     recovered_duration_mean,
    #     recovered_duration_sd,
    #     random_infection_probabilities,
    #     mean_immunity_durations,
    #     num_years,
    #     # "initial",
    #     "swarm",
    # )
    # return
    # --------------------------

    # Модифицированный алгоритм Метрополиса-Гастингса для поиска значений параметров, дающих минимум для модели
    # --------------------------
    mcmc_simulations(
        is_one_mean_year_modeled,
        agents,
        households,
        schools,
        num_threads,
        thread_rng,
        start_agent_ids,
        end_agent_ids,
        temperature,
        viruses,
        num_infected_age_groups_viruses,
        num_infected_age_groups_viruses_prev,
        mean_household_contact_durations,
        household_contact_duration_sds,
        other_contact_duration_shapes,
        other_contact_duration_scales,
        isolation_probabilities_day_1,
        isolation_probabilities_day_2,
        isolation_probabilities_day_3,
        recovered_duration_mean,
        recovered_duration_sd,
        random_infection_probabilities,
        num_years
    )
    return
    # --------------------------
    
    # Моделируем заболеваемость
    @time observed_num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
        num_threads, thread_rng, agents, viruses, households, schools, duration_parameter,
        susceptibility_parameters, temperature_parameters, temperature,
        mean_household_contact_durations, household_contact_duration_sds,
        other_contact_duration_shapes, other_contact_duration_scales,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, random_infection_probabilities,
        recovered_duration_mean, recovered_duration_sd, num_years, is_rt_run,
        school_class_closure_period, school_class_closure_threshold, global_warming_temperature)

    # Сохранение результатов работы модели
    if abs(global_warming_temperature) > 0.1
        # Сценарий глобального потепления
        save(joinpath(@__DIR__, "..", "output", "tables", "results_warming_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt)
    elseif school_class_closure_period == 0
        # Базовый сценарий
        save(joinpath(@__DIR__, "..", "output", "tables", "results_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt)
    else
        # Сценарий карантина в школах
        save(joinpath(@__DIR__, "..", "output", "tables", "results_quarantine_$(run_num + 1).jld"),
            "observed_cases", observed_num_infected_age_groups_viruses,
            "activities_cases", activities_infections,
            "rt", rt,
            "num_schools_closed", num_schools_closed)
    end

    # Функция потерь
    nMAE = 0.0
    # Если рассматривается 1 год
    if is_one_mean_year_modeled
        observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
        for i = 2:num_years
            for j = 1:52
                observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
            end
        end
        observed_num_infected_age_groups_viruses_mean ./= num_years
        nMAE = sum(abs.(observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    else
        nMAE = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    end
    println("nMAE = $(nMAE)")
end

main()
