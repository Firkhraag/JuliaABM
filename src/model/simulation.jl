
# Функция продолжительности контакта
function get_contact_duration(
    # Если нормальное распределение - средняя продолжительность контакта
    # Если гамма распределение - shape
    param1::Float64,
    # Если нормальное распределение - cреднеквадратическое отклонение
    # Если гамма распределение - scale
    param2::Float64,
    # Генератор случайных чисел
    rng::MersenneTwister,
    # Выбирается из нормального распределения
    is_normal::Bool
)
    if is_normal
        return rand(rng, truncated(Normal(param1, param2), 0.0, 24.0))
    else
        # Гамма распределение
        return rand(rng, Gamma(param1, param2))
    end
end

# Функция контакта между агентами
function make_contact(
    # Вирусы
    viruses::Vector{Virus},
    # Инфицированный агент
    infected_agent::Agent,
    # Восприимчивый агент
    susceptible_agent::Agent,
    # Продолжительность контакта
    contact_duration::Float64,
    # Параметр влияния продолжительности контакта на риск инфицирования
    duration_parameter::Float64,
    # Параметр неспецифической восприимчивости
    susceptibility_parameters::Vector{Float64},
    # Параметр температуры воздуха
    temperature_parameters::Vector{Float64},
    # Температура на текущем шаге
    current_temp::Float64,
    # Генератор случайных чисел
    rng::MersenneTwister,
)
    # Риск инфицирования, зависящий от продолжительности контакта
    duration_influence = 1 - exp(-duration_parameter * contact_duration)
            
    # Риск инфицирования, зависящий от температуры воздуха
    temperature_influence = temperature_parameters[infected_agent.virus_id] * current_temp + 1.0

    # Риск инфицирования, зависящий от неспецифического иммунитета восприимчивого агента
    susceptibility_influence = 2 / (1 + exp(susceptibility_parameters[infected_agent.virus_id] * susceptible_agent.ig_level))

    # Риск инфицирования, зависящий от специфического иммунитета восприимчивого агента
    immunity_influence = susceptible_agent.immunity_susceptibility_levels[infected_agent.virus_id]

    # Риск инфицирования, зависящий от силы инфекции инфицированного агента
    infectivity_influence = 0.0
    if infected_agent.age < 3
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_toddler,
            infected_agent.is_asymptomatic)
    elseif infected_agent.age < 16
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_child,
            infected_agent.is_asymptomatic)
    else
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_adult,
            infected_agent.is_asymptomatic)
    end

    # Риск инфицирования как произведение независимых рисков
    infection_probability = infectivity_influence * susceptibility_influence *
        temperature_influence * duration_influence * immunity_influence

    # Если успешно инфицирован
    if rand(rng, Float64) < infection_probability
        susceptible_agent.virus_id = infected_agent.virus_id
        susceptible_agent.is_newly_infected = true
        infected_agent.num_infected_agents += 1
    end
end

# Инфицирование агентов от неизвестного источника
function infect_randomly(
    # Агент
    agent::Agent,
    # Генератор случайных чисел
    rng::MersenneTwister,
)
    # Id случайного вируса
    rand_virus_id = rand(rng, 1:num_viruses)
    # Если случайное инфицирование прошло успешно
    if rand(rng, Float64) < agent.immunity_susceptibility_levels[rand_virus_id]
        agent.virus_id = rand_virus_id
        agent.is_newly_infected = true
    end
end

# Моделирование контактов
function simulate_contacts(
    # Id потока
    thread_id::Int,
    # Генератор случайных чисел
    rng::MersenneTwister,
    # Id первого агента для потока
    start_agent_id::Int,
    # Id последнего агента для потока
    end_agent_id::Int,
    # Агенты
    agents::Vector{Agent},
    # Домохозяйства
    households::Vector{Household},
    # Средние продолжительности контактов в домохозяйствах для разных контактов
    mean_household_contact_durations::Vector{Float64},
    # Среднеквадратические отклонения для контактов в домохозяйствах для разных контактов
    household_contact_duration_sds::Vector{Float64},
    # Средние продолжительности контактов в прочих коллективах
    other_contact_duration_shapes::Vector{Float64},
    # Среднеквадратические отклонения для контактов в прочих коллективах
    other_contact_duration_scales::Vector{Float64},
    # Параметр влияния продолжительности контакта на риск инфицирования
    duration_parameter::Float64,
    # Параметр неспецифической восприимчивости
    susceptibility_parameters::Vector{Float64},
    # Параметр температуры воздуха
    temperature_parameters::Vector{Float64},
    # Вероятности случайного инфицирования
    random_infection_probabilities::Vector{Float64},
    # Вирусы
    viruses::Vector{Virus},
    # Выходной для детсада
    is_kindergarten_holiday::Bool,
    # Выходной в школе
    is_school_holiday::Bool,
    # Выходной в вузе
    is_college_holiday::Bool,
    # Выходной для рабочих коллективов
    is_work_holiday::Bool,
    # Текущий шаг
    current_step::Int,
    # Текущая температура
    current_temp::Float64,
    # Число инфицирований агентов в различных коллективах для потока
    activities_infections_threads::Array{Int, 3},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        # Агент инфицирован
        if agent.virus_id != 0 && !agent.is_newly_infected
            # Моделируем контакты в домохозяйстве
            for agent2_id in households[agent.household_id].agent_ids
                agent2 = agents[agent2_id]
                # Проверка восприимчивости агента к вирусу
                if agent2.virus_id == 0 && agent2.days_immune == 0
                    # Находим продолжительность контакта
                    dur = 0.0
                    # Если агенты посещают другой коллектив, то контакт укорочен
                    # Если оба агента проводят время дома
                    if (agent.is_isolated || agent.quarantine_period > 0 || agent.on_parent_leave || agent.activity_type == 0 ||
                        (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_college_holiday) ||
                        (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                        (agent2.is_isolated || agent2.quarantine_period > 0 || agent2.on_parent_leave || agent2.activity_type == 0 ||
                        (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_college_holiday) ||
                        (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday))
                        
                        dur = get_contact_duration(
                            mean_household_contact_durations[5], household_contact_duration_sds[5], rng, true)
                    # Если один из агентов посещает рабочий коллектив
                    elseif ((agent.activity_type == 4 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 4 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_work_holiday

                        dur = get_contact_duration(
                            mean_household_contact_durations[4], household_contact_duration_sds[4], rng, true)
                    # Если один из агентов посещает школу
                    elseif ((agent.activity_type == 2 && !(agent.is_isolated || agent.on_parent_leave || agent.quarantine_period > 0)) ||
                        (agent2.activity_type == 2 && !(agent2.is_isolated || agent2.on_parent_leave || agent2.quarantine_period > 0))) && !is_school_holiday

                        dur = get_contact_duration(
                            mean_household_contact_durations[2], household_contact_duration_sds[2], rng, true)
                    # Если один из агентов посещает детский сад
                    elseif ((agent.activity_type == 1 && !(agent.is_isolated || agent.on_parent_leave)) ||
                        (agent2.activity_type == 1 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_kindergarten_holiday
                        
                        dur = get_contact_duration(
                            mean_household_contact_durations[1], household_contact_duration_sds[1], rng, true)
                    # Если один из агентов посещает вуз
                    else
                        dur = get_contact_duration(
                            mean_household_contact_durations[3], household_contact_duration_sds[3], rng, true)
                    end
                    
                    if dur > 0.01
                        # Происходит контакт
                        make_contact(viruses, agent, agent2, dur, duration_parameter,
                            susceptibility_parameters, temperature_parameters, current_temp, rng)
                        # Если агент был успешно инфицирован, то добавляем к инфицированиям в домохозяйствах
                        if agent2.is_newly_infected
                            activities_infections_threads[current_step, 5, thread_id] += 1
                        end
                    end
                end
            end
            # Контакты в коллективе, который агент посещает на данном шаге
            if !agent.is_isolated && !agent.on_parent_leave && agent.attendance &&
                ((agent.activity_type == 1 && !is_kindergarten_holiday) ||
                (agent.activity_type == 2 && !is_school_holiday) ||
                (agent.activity_type == 3 && !is_college_holiday) ||
                (agent.activity_type == 4 && !is_work_holiday)) && agent.quarantine_period == 0
                # Проходим по агентам, с которыми имеется связь
                for agent2_id in agent.activity_conn_ids
                    agent2 = agents[agent2_id]
                    # Проверка восприимчивости агента к вирусу и посещение им коллектива
                    if agent2.virus_id == 0 && agent2.days_immune == 0 && agent2.attendance &&
                        !agent2.is_isolated && !agent2.on_parent_leave
                        # Находим продолжительность контакта
                        dur = 0.0
                        # Если детсад
                        if agent.activity_type == 1
                            dur = get_contact_duration(
                                other_contact_duration_shapes[1], other_contact_duration_scales[1], rng, false)
                        # Если школа
                        elseif agent.activity_type == 2
                            dur = get_contact_duration(
                                other_contact_duration_shapes[2], other_contact_duration_scales[2], rng, false)
                        # Если универ
                        elseif agent.activity_type == 3
                            dur = get_contact_duration(
                                other_contact_duration_shapes[3], other_contact_duration_scales[3], rng, false)
                        # Если работа
                        else
                            dur = get_contact_duration(
                                other_contact_duration_shapes[4], other_contact_duration_scales[4], rng, false)
                        end
                        
                        if dur > 0.01
                            # Происходит контакт
                            make_contact(viruses, agent, agent2, dur, duration_parameter,
                                susceptibility_parameters, temperature_parameters, current_temp, rng)
                            # Если агент был успешно инфицирован, то добавляем к инфицированиям в коллективе
                            if agent2.is_newly_infected
                                activities_infections_threads[current_step, agent.activity_type, thread_id] += 1
                            end
                        end
                    end
                end

                # Контакты между университетскими группами
                if agent.activity_type == 3
                    for agent2_id in agent.activity_cross_conn_ids
                        agent2 = agents[agent2_id]
                        # Если агент восприимчив к вирусу и если происходит контакт на текущем шаге
                        if agent2.virus_id == 0 && agent2.days_immune == 0 &&
                            agent2.attendance && !agent2.is_isolated &&
                            !agent2.on_parent_leave && !agent2.is_teacher &&
                            rand(rng, Float64) < 0.25
                            # Находим продолжительность контакта
                            dur = get_contact_duration(
                                other_contact_duration_shapes[5], other_contact_duration_scales[5], rng, false)
                            if dur > 0.01
                                # Происходит контакт
                                make_contact(viruses, agent, agent2, dur, duration_parameter,
                                    susceptibility_parameters, temperature_parameters, current_temp, rng)
                                # Если агент был успешно инфицирован, то добавляем к инфицированиям в универе
                                if agent2.is_newly_infected
                                    activities_infections_threads[current_step, 3, thread_id] += 1
                                end
                            end
                        end
                    end
                end
            end
        # Агент восприимчив
        elseif agent.virus_id == 0 && agent.days_immune == 0
            # Случайное инфицирование
            if agent.age < 3
                if rand(rng, Float64) < random_infection_probabilities[1]
                    infect_randomly(agent, rng)
                end
            elseif agent.age < 7
                if rand(rng, Float64) < random_infection_probabilities[2]
                    infect_randomly(agent, rng)
                end
            elseif agent.age < 15
                if rand(rng, Float64) < random_infection_probabilities[3]
                    infect_randomly(agent, rng)
                end
            else
                if rand(rng, Float64) < random_infection_probabilities[4]
                    infect_randomly(agent, rng)
                end
            end
        end
    end
end

# Обновление свойств агентов
function update_agent_states(
    # Id потока
    thread_id::Int,
    # Генератор случайных чисел
    rng::MersenneTwister,
    # Id первого агента для потока
    start_agent_id::Int,
    # Id последнего агента для потока
    end_agent_id::Int,
    # Агенты
    agents::Vector{Agent},
    # Домохозяйства
    households::Vector{Household},
    # Вирусы
    viruses::Vector{Virus},
    # Средняя продолжительность резистентного состояния
    recovered_duration_mean::Float64,
    # Среднеквадратическое отклонение для резистентного состояния
    recovered_duration_sd::Float64,
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Текущий шаг
    current_step::Int,
    # Выявленная заболеваемость различными вирусами в разных возрастных группах для потоков
    observed_daily_new_cases_age_groups_viruses_threads::Array{Int, 4},
    # Сумма всех инфицирований агентами, зараженными на каждом шаге
    rt_threads::Matrix{Float64},
    # Число агентов, зараженных на каждом шаге
    rt_count_threads::Matrix{Float64},
)
    # Проходим по агентам потока
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]

        # Если агент-школьник находится на карантине
        if agent.quarantine_period > 0
            agent.quarantine_period -= 1
        end

        # Если в резистентном состоянии
        if agent.days_immune != 0
            # Если резистентное состояние закончилось
            if agent.days_immune == agent.days_immune_end
                # Переход из резистентного состояния в восприимчивое
                agent.days_immune = 0
            else
                # Увеличиваем счетчик
                agent.days_immune += 1
            end
        end

        # Продолжительности типоспецифического иммунитета
        # Для каждого вируса
        for i = 1:num_viruses
            # Если есть иммунитет
            if agent.viruses_days_immune[i] != 0
                # Если иммунитет закончился
                if agent.viruses_days_immune[i] == agent.viruses_immunity_end[i]
                    # Снова восприимчив с уровнм восприимчивости равным immune_memory_susceptibility_level
                    agent.viruses_days_immune[i] = 0
                # Если иммунитет еще есть
                else
                    # Увеличиваем счетчик
                    agent.viruses_days_immune[i] += 1
                    # Повышаем восприимчивость к вирусу
                    agent.immunity_susceptibility_levels[i] = find_immunity_susceptibility_level(
                        agent.viruses_days_immune[i], agent.viruses_immunity_end[i])
                end
            end
        end

        # Если агент инфицирован
        if agent.virus_id != 0 && !agent.is_newly_infected
            # Если период болезни закончился
            if agent.days_infected == agent.incubation_period + agent.infection_period
                # Если агент нуждался в уходе за собой
                if agent.age < 12 &&
                    households[agent.household_id].children_need_supporter_care &&
                    !agent.is_asymptomatic &&
                    (agent.is_isolated || agent.activity_type == 0)

                    is_support_still_needed = false
                    for agent2_id in households[agent.household_id].agent_ids
                        agent2 = agents[agent2_id]
                        if agent_id != agent2_id &&
                            agent2.age < 12 &&
                            !agent2.is_asymptomatic &&
                            agent2.days_infected > agent2.incubation_period + 1 &&
                            (agent2.is_isolated || agent2.activity_type == 0)

                            is_support_still_needed = true
                        end
                    end
                    if !is_support_still_needed
                        agents[households[agent.household_id].supporter_id].on_parent_leave = false
                    end
                end

                # Шаг, когда агент был инфицирован
                infection_time = current_step - agent.days_infected - 1
                if infection_time > 0
                    # Добавляем, число людей, которые были инфицированы агентом
                    rt_threads[infection_time, thread_id] += agent.num_infected_agents
                    # Добавляем инфицирование
                    rt_count_threads[infection_time, thread_id] += 1
                end

                # Переход в резистентное состояние
                agent.viruses_days_immune[agent.virus_id] = 1
                agent.viruses_immunity_end[agent.virus_id] = trunc(Int, rand(rng, truncated(Normal(viruses[agent.virus_id].mean_immunity_duration, viruses[agent.virus_id].immunity_duration_sd), min_immunity_duration, max_immunity_duration)))
                agent.days_immune = 1
                agent.days_immune_end = trunc(Int, rand(rng, truncated(Normal(recovered_duration_mean, recovered_duration_sd), min_recovered_duration, max_recovered_duration)))
                # Устанавливаем значения по умолчанию
                agent.num_infected_agents = 0
                agent.virus_id = 0
                agent.is_isolated = false
                agent.days_infected = 0
            else
                # Прибавляем день к счетчику дней в инфицированном состоянии
                agent.days_infected += 1
                # Если присутствуют симптомы и агент еще не самоизолирован
                if !agent.is_asymptomatic && !agent.is_isolated
                    # Агент самоизолируется с некой вероятностью на 1-й, 2-й и 3-й дни болезни
                    if agent.days_infected == agent.incubation_period + 1
                        if agent.age < 3
                            if rand(rng, Float64) < isolation_probabilities_day_1[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand(rng, Float64) < isolation_probabilities_day_1[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand(rng, Float64) < isolation_probabilities_day_1[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand(rng, Float64) < isolation_probabilities_day_1[4]
                                agent.is_isolated = true
                            end
                        end
                    elseif agent.days_infected == agent.incubation_period + 2
                        if agent.age < 3
                            if rand(rng, Float64) < isolation_probabilities_day_2[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand(rng, Float64) < isolation_probabilities_day_2[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand(rng, Float64) < isolation_probabilities_day_2[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand(rng, Float64) < isolation_probabilities_day_2[4]
                                agent.is_isolated = true
                            end
                        end
                    elseif agent.days_infected == agent.incubation_period + 3
                        if agent.age < 3
                            if rand(rng, Float64) < isolation_probabilities_day_3[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand(rng, Float64) < isolation_probabilities_day_3[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand(rng, Float64) < isolation_probabilities_day_3[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand(rng, Float64) < isolation_probabilities_day_3[4]
                                agent.is_isolated = true
                            end
                        end
                    end
                    # Если агент самоизолировался, то добавляем случай в выявленную заболеваемость
                    if agent.is_isolated
                        if agent.age < 3
                            observed_daily_new_cases_age_groups_viruses_threads[current_step, 1, agent.virus_id, thread_id] += 1
                        elseif agent.age < 7
                            observed_daily_new_cases_age_groups_viruses_threads[current_step, 2, agent.virus_id, thread_id] += 1
                        elseif agent.age < 15
                            observed_daily_new_cases_age_groups_viruses_threads[current_step, 3, agent.virus_id, thread_id] += 1
                        else
                            observed_daily_new_cases_age_groups_viruses_threads[current_step, 4, agent.virus_id, thread_id] += 1
                        end
                    end
                end

                # Если нужен уход, то агент-попечитель будет сидеть с ребенком дома
                if agent.age < 12 &&
                    households[agent.household_id].children_need_supporter_care &&
                    !agent.is_asymptomatic &&
                    agent.days_infected > agent.incubation_period + 1 &&
                    (agent.is_isolated || agent.activity_type == 0)

                    agents[households[agent.household_id].supporter_id].on_parent_leave = true
                end
            end
        # Если агент был заражен на текущем шаге
        elseif agent.is_newly_infected
            # Инкубационный период
            agent.incubation_period = round(Int, rand(rng, truncated(
                Gamma(viruses[agent.virus_id].incubation_period_shape, viruses[agent.virus_id].incubation_period_scale), min_incubation_period, max_incubation_period)))
            # Период болезни
            if agent.age < 16
                agent.infection_period = round(Int, rand(rng, truncated(
                    Gamma(viruses[agent.virus_id].infection_period_child_shape, viruses[agent.virus_id].infection_period_child_scale), min_infection_period, max_infection_period)))
            else
                agent.infection_period = round(Int, rand(rng, truncated(
                    Gamma(viruses[agent.virus_id].infection_period_adult_shape, viruses[agent.virus_id].infection_period_adult_scale), min_infection_period, max_infection_period)))
            end

            # Счетчик числа дней в инфицированном состоянии
            agent.days_infected = 1

            # Будет ли болезнь протекать бессимптомно
            if agent.age < 10
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_child
            elseif agent.age < 18
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_teenager
            else
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_adult
            end

            # Переходит в инкубационный период
            agent.is_newly_infected = false
        end

        # Вероятность прогула для вуза
        if agent.activity_type == 3 && !agent.is_teacher
            agent.attendance = true
            if rand(rng, Float64) < skip_college_probability
                agent.attendance = false
            end
        end
    end
end

# Запуск модели
function run_simulation(
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
    # Параметры восприимчивости агентов к различным вирусам
    susceptibility_parameters::Vector{Float64},
    # Параметры для температуры воздуха
    temperature_parameters::Vector{Float64},
    # Температура воздуха
    temperature::Vector{Float64},
    # Средние продолжительности контактов в домохозяйствах
    mean_household_contact_durations::Vector{Float64},
    # Среднеквадр. откл. продолжительности контактов в домохозяйствах
    household_contact_duration_sds::Vector{Float64},
    # Средние продолжительности контактов в прочих коллективах
    other_contact_duration_shapes::Vector{Float64},
    # Среднеквадр. откл. продолжительности контактов в прочих коллективах
    other_contact_duration_scales::Vector{Float64},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Вероятности случайного инфицирования от неизвестного источника
    random_infection_probabilities::Vector{Float64},
    # Средняя продолжительность резистентного состояния
    recovered_duration_mean::Float64,
    # Среднеквадр. откл. продолжительности резистентного состояния
    recovered_duration_sd::Float64,
    # Число лет для моделирования
    num_years::Int,
    # Учитывать эффективное репродуктивное число
    is_rt_run::Bool,
    # Сценарий введения карантина в школах
    # Продолжительность закрытия школы / класса
    school_class_closure_period::Int = 0,
    # Порог заболеваемости для закрытия школы / класса
    school_class_closure_threshold::Float64 = 0.0,
    # Сценарий глобального потепления
    with_global_warming::Bool = false,
)::Tuple{Array{Float64, 3}, Array{Float64, 2}, Vector{Float64}, Vector{Int}}
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    # Если глобальное потепление
    if with_global_warming
        for i = 1:length(temperature)
            temperature[i] += rand(Normal(4.0, 0.25))
        end
    end
    # Минимальная температура воздуха
    min_temp = -7.2
    # Max - min температура
    max_min_temp = 26.6

    # День года
    year_day = 213

    # Число шагов
    max_step = num_years * 365
    # Если нас интересует эффективное репродуктивное число
    if is_rt_run
        # Добавляем еще 21 день
        max_step += 21
    end
    # Число недель
    num_weeks = 52 * num_years

    # Выявленная заболеваемость различными вирусами в разных возрастных группах
    observed_num_infected_age_groups_viruses = zeros(Int, max_step, num_viruses, 4)
    # Выявленная заболеваемость различными вирусами в разных возрастных группах для потоков
    observed_daily_new_cases_age_groups_viruses_threads = zeros(Int, max_step, 4, num_viruses, num_threads)
    # Заболеваемость в коллективах для потоков
    activities_infections_threads = zeros(Int, max_step, 5, num_threads)
    # Сумма всех инфицирований агентами, зараженными на каждом шаге
    rt_threads = zeros(Float64, max_step, num_threads)
    # Число агентов, зараженных на каждом шаге
    rt_count_threads = zeros(Float64, max_step, num_threads)
    # Число закрытий школ на карантин для потоков
    num_schools_closed_threads = zeros(Float64, max_step, num_threads)

    for current_step = 1:max_step
        # Выходные, праздники
        is_holiday = false
        if week_day == 7
            is_holiday = true
        elseif month == 1 && (day == 1 || day == 2 || day == 3 || day == 7)
            is_holiday = true
        elseif month == 5 && (day == 1 || day == 9)
            is_holiday = true
        elseif month == 2 && day == 23
            is_holiday = true
        elseif month == 3 && day == 8
            is_holiday = true
        elseif month == 6 && day == 12
            is_holiday = true
        end

        is_work_holiday = is_holiday
        if week_day == 6
            is_work_holiday = true
        end

        is_kindergarten_holiday = is_work_holiday
        if month == 7 || month == 8
            is_kindergarten_holiday = true
        end

        # Каникулы
        # Летние - 01.06.yyyy - 31.08.yyyy
        # Осенние - 05.11.yyyy - 11.11.yyyy
        # Зимние - 28.12.yyyy - 09.01.yyyy
        # Весенние - 22.03.yyyy - 31.03.yyyy
        is_school_holiday = is_holiday
        if month == 6 || month == 7 || month == 8
            is_school_holiday = true
        elseif month == 11 && day >= 5 && day <= 11
            is_school_holiday = true
        elseif month == 12 && day >= 28 && day <= 31
            is_school_holiday = true
        elseif month == 1 && day >= 1 && day <= 9
            is_school_holiday = true
        elseif month == 3 && day >= 22 && day <= 31
            is_school_holiday = true
        end

        is_college_holiday = is_holiday
        if month == 7 || month == 8
            is_college_holiday = true
        elseif month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_college_holiday = true
        elseif month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_college_holiday = true
        elseif month == 2 && (day >= 1 && day <= 10)
            is_college_holiday = true
        elseif month == 12 && (day >= 22 && day <= 31)
            is_college_holiday = true
        end

        # Моделируем контакты между агентами
        @threads for thread_id in 1:num_threads
            simulate_contacts(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                households,
                mean_household_contact_durations,
                household_contact_duration_sds,
                other_contact_duration_shapes,
                other_contact_duration_scales,
                duration_parameter,
                susceptibility_parameters,
                temperature_parameters,
                random_infection_probabilities,
                viruses,
                is_kindergarten_holiday,
                is_school_holiday,
                is_college_holiday,
                is_work_holiday,
                current_step,
                (temperature[year_day] - min_temp) / max_min_temp,
                activities_infections_threads)
        end

        # Если сценарий карантина
        if school_class_closure_period > 0
            @threads for thread_id in 1:num_threads
                # Проходим по каждой школе потока
                for school_id in start_school_ids[thread_id]:end_school_ids[thread_id]
                    school = schools[school_id]
                    # Если школа не на карантине
                    if school.quarantine_period == 0
                        # Число самоизолированных агентов или людей на карантине в школе
                        school_num_isolated = 0
                        # Число агентов в школе
                        school_num_people = 0
                        # Проходим по каждому году обучения
                        for groups_id in 1:length(school.groups)
                            groups = school.groups[groups_id]
                            # Если параллель не на карантине
                            if school.quarantine_period_groups[groups_id] == 0
                                # Число самоизолированных агентов или людей на карантине в параллели
                                groups_num_isolated = 0
                                # Число агентов в параллели
                                groups_num_people = 0
                                # Проходим по каждому классу
                                for group in groups
                                    # Число самоизолированных агентов или людей на карантине в классе
                                    num_isolated = 0
                                    # Проходим по агентам класса
                                    for agent_id in group
                                        agent = agents[agent_id]
                                        # Если агент не является преподавателем
                                        if !agent.is_teacher
                                            # Если класс уже на карантине
                                            if agent.quarantine_period > 1
                                                # Прибавляем число учеников в классе
                                                school_num_isolated += length(group) - 1
                                                school_num_people += length(group) - 1
                                                groups_num_people += length(group) - 1
                                                break
                                            end
                                            # Если агент самоизолирован
                                            if agent.is_isolated
                                                num_isolated += 1
                                                # Прибавляем одного ученика как изолированного
                                                school_num_isolated += 1
                                                groups_num_isolated += 1
                                            end
                                            school_num_people += 1
                                            groups_num_people += 1
                                        end
                                    end
                                    # Если превышен порог заболеваемости
                                    if length(group) > 1 && num_isolated / (length(group) - 1) > school_class_closure_threshold
                                        for agent_id in group
                                            agent = agents[agent_id]
                                            # Класс закрывается на карантин
                                            agent.quarantine_period = school_class_closure_period + 1
                                            # Если агент не самоизолирован
                                            if !agent.is_isolated
                                                # Прибавляем к числу самоизолированных или людей на карантине для параллели и школы
                                                school_num_isolated += 1
                                                groups_num_isolated += 1
                                            end
                                        end
                                    end
                                end

                                # Если превышен порог заболеваемости для параллели
                                if groups_num_isolated / groups_num_people > school_class_closure_threshold
                                    # Закрываем каждую группу на карантин
                                    for group in groups
                                        for agent_id in group
                                            agent = agents[agent_id]
                                            # Добавляем агентов на карантине к школе
                                            if !agent.is_isolated || agent.quarantine_period == 0
                                                school_num_isolated += 1
                                            end
                                            # Присваиваем агенту карантин
                                            agent.quarantine_period = school_class_closure_period + 1
                                        end
                                    end
                                    # Присваиваем параллели карантин
                                    school.quarantine_period_groups[groups_id] = school_class_closure_period
                                end
                            # Если параллель на карантине
                            else
                               # Уменьшаем число дней на карантине
                                school.quarantine_period_groups[groups_id] -= 1
                                # Если карантин не закончился
                                if school.quarantine_period_groups[groups_id] > 0
                                    for group in groups
                                        # Добавляем число учеников в параллели
                                        school_num_isolated += length(group) - 1
                                        school_num_people += length(group) - 1
                                    end
                                end
                            end
                        end
                        
                        # Если превышен порог заболеваемости для школы
                        if school_num_isolated / school_num_people > school_class_closure_threshold
                            # Проходим по каждой параллели
                            for groups in school.groups
                                # По каждому классу
                                for group in groups
                                    # По каждому агенту
                                    for agent_id in group
                                        agent = agents[agent_id]
                                        # Агент на карантине
                                        agent.quarantine_period = school_class_closure_period + 1
                                    end
                                end
                            end
                            # Закрываем школу на карантин
                            school.quarantine_period = school_class_closure_period
                            num_schools_closed_threads[current_step, thread_id] += 1
                        end
                    # Если школа уже закрыта на карантин
                    else
                        # Уменьшаем число дней на карантине
                        school.quarantine_period -= 1
                        # Параллели классов
                        for groups_id in 1:length(school.groups)
                            groups = school.groups[groups_id]
                            # Если параллель на карантине
                            if school.quarantine_period_groups[groups_id] > 0
                                # Уменьшаем число дней на карантине
                                school.quarantine_period_groups[groups_id] -= 1
                            end
                            # Для классов уменьшение числа дней на карантине происходит в функции обновления состояния агентов ниже
                        end
                    end
                end
            end
        end

        # Обновляем состояния агентов
        @threads for thread_id in 1:num_threads
            update_agent_states(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                households,
                viruses,
                recovered_duration_mean,
                recovered_duration_sd,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                current_step,
                observed_daily_new_cases_age_groups_viruses_threads,
                rt_threads,
                rt_count_threads,
            )
        end

        # Записываем заболеваемость разными вирусами в различных возрастных группах
        for i = 1:4
            for j = 1:num_viruses
                observed_num_infected_age_groups_viruses[current_step, j, i] = sum(
                    observed_daily_new_cases_age_groups_viruses_threads[current_step, i, j, :])
            end
        end

        # Обновление даты
        # День недели
        if week_day == 7
            week_day = 1
        else
            week_day += 1
        end

        # День месяца
        if ((month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10) && day == 31) ||
            ((month == 4 || month == 6 || month == 9 || month == 11) && day == 30) ||
            (month == 2 && day == 28)
            day = 1
            month += 1
        elseif (month == 12 && day == 31)
            day = 1
            month = 1
        else
            day += 1
        end

        # День года
        year_day += 1
        if year_day > 365
            year_day = 1
        end
    end

    # Эффективное репродуктивное число
    rt = sum(rt_threads, dims = 2)[:, 1]
    rt_count = sum(rt_count_threads, dims = 2)[:, 1]
    rt = rt ./ rt_count

    # Еженедельная заболеваемость
    observed_num_infected_age_groups_viruses_weekly = zeros(Int, (num_weeks), num_viruses, 4)
    for i = 1:(num_weeks)
        observed_num_infected_age_groups_viruses_weekly[i, :, :] = sum(observed_num_infected_age_groups_viruses[(i * 7 - 6):(i * 7), :, :], dims = 1)
    end

    return observed_num_infected_age_groups_viruses_weekly, sum(activities_infections_threads, dims = 3)[:, :, 1], rt, sum(num_schools_closed_threads, dims = 2)[:, 1]
end
