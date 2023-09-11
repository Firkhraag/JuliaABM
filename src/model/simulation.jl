
# Функция продолжительности контакта
function get_contact_duration(
    # Средняя продолжительность контакта
    mean::Float64,
    # Среднеквадратическое отклонение
    sd::Float64,
    # Генератор случайных чисел
    rng::MersenneTwister,
    # Выбирается из нормального распределения
    is_normal::Bool
)
    if is_normal
        return rand(rng, truncated(Normal(mean, sd), 0.0, 24.0))
    else
        # Гамма распределение
        return rand(rng, Gamma(shape, scale))
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
    rand_num = rand(rng, 1:num_viruses)
    # Если случайное инфицирование прошло успешно
    if rand(rng, Float64) < agent.immunity_susceptibility_levels[rand_num]
        agent.virus_id = rand_num
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
            for agent2_id in agent.household_conn_ids
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
    observed_daily_new_cases_age_groups_viruses_threads::Array{Int, 4},
    daily_new_cases_age_groups_viruses_threads::Array{Int, 4},
    rt_threads::Matrix{Float64},
    rt_count_threads::Matrix{Float64},
    num_infected_districts_threads::Array{Int, 3},
    # Уровни восприимчивости к инфекции после перенесенной болезни и исчезновения иммунитета
    immune_memory_susceptibility_levels::Vector{Float64},
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]

        if agent.quarantine_period > 0
            agent.quarantine_period -= 1
        end

        if agent.days_immune != 0
            if agent.days_immune == agent.days_immune_end
                # Переход из резистентного состояния в восприимчивое
                agent.days_immune = 0
            else
                agent.days_immune += 1
            end
        end

        # Продолжительности типоспецифического иммунитета
        for i = 1:num_viruses
            if agent.viruses_days_immune[i] != 0
                if agent.viruses_days_immune[i] == agent.viruses_immunity_end[i]
                    agent.viruses_days_immune[i] = 0
                    agent.immunity_susceptibility_levels[i] = immune_memory_susceptibility_levels[i]
                else
                    agent.viruses_days_immune[i] += 1
                    agent.immunity_susceptibility_levels[i] = find_immunity_susceptibility_level(
                        agent.viruses_days_immune[i], agent.viruses_immunity_end[i],immune_memory_susceptibility_levels[i])
                end
            end
        end

        if agent.virus_id != 0 && !agent.is_newly_infected
            if agent.days_infected == agent.infection_period
                infection_time = current_step - agent.infection_period - agent.incubation_period - 1
                if infection_time > 0
                    rt_threads[infection_time, thread_id] += agent.num_infected_agents
                    rt_count_threads[infection_time, thread_id] += 1
                end
                agent.num_infected_agents = 0

                agent.viruses_days_immune[agent.virus_id] = 1
                agent.viruses_immunity_end[agent.virus_id] = trunc(Int, rand(rng, truncated(Normal(viruses[agent.virus_id].mean_immunity_duration, viruses[agent.virus_id].immunity_duration_sd), 1.0, 1000.0)))
                agent.days_immune = 1
                agent.days_immune_end = trunc(Int, rand(rng, truncated(Normal(recovered_duration_mean, recovered_duration_sd), 1.0, 12.0)))
                agent.virus_id = 0
                agent.is_isolated = false

                if agent.needs_supporter_care
                    is_support_still_needed = false
                    for dependant_id in agents[agent.supporter_id].dependant_ids
                        dependant = agents[dependant_id]
                        if dependant.needs_supporter_care &&
                            dependant.virus_id != 0 &&
                            !dependant.is_asymptomatic &&
                            dependant.days_infected > 0 &&
                            (dependant.activity_type == 0 || dependant.is_isolated)

                            is_support_still_needed = true
                        end
                    end
                    if !is_support_still_needed
                        agents[agent.supporter_id].on_parent_leave = false
                    end
                end
            else
                agent.days_infected += 1

                if !agent.is_asymptomatic && !agent.is_isolated
                    if agent.days_infected == 1
                        rand_num = rand(rng, Float64)
                        if agent.age < 3
                            if rand_num < isolation_probabilities_day_1[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < isolation_probabilities_day_1[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < isolation_probabilities_day_1[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < isolation_probabilities_day_1[4]
                                agent.is_isolated = true
                            end
                        end
                    elseif agent.days_infected == 2
                        rand_num = rand(rng, Float64)
                        if agent.age < 3
                            if rand_num < isolation_probabilities_day_2[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < isolation_probabilities_day_2[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < isolation_probabilities_day_2[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < isolation_probabilities_day_2[4]
                                agent.is_isolated = true
                            end
                        end
                    elseif agent.days_infected == 3
                        rand_num = rand(rng, Float64)
                        if agent.age < 3
                            if rand_num < isolation_probabilities_day_3[1]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 8
                            if rand_num < isolation_probabilities_day_3[2]
                                agent.is_isolated = true
                            end
                        elseif agent.age < 18
                            if rand_num < isolation_probabilities_day_3[3]
                                agent.is_isolated = true
                            end
                        else
                            if rand_num < isolation_probabilities_day_3[4]
                                agent.is_isolated = true
                            end
                        end
                    end
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
                        num_infected_districts_threads[households[agent.household_id].district_id, current_step, thread_id] += 1
                    end
                end

                if agent.supporter_id != 0 &&
                    agent.needs_supporter_care &&
                    !agent.is_asymptomatic &&
                    agent.days_infected > 0 &&
                    (agent.is_isolated || agent.activity_type == 0)

                    agents[agent.supporter_id].on_parent_leave = true
                end
            end
        elseif agent.is_newly_infected
            if agent.age < 3
                daily_new_cases_age_groups_viruses_threads[current_step, 1, agent.virus_id, thread_id] += 1
            elseif agent.age < 7
                daily_new_cases_age_groups_viruses_threads[current_step, 2, agent.virus_id, thread_id] += 1
            elseif agent.age < 15
                daily_new_cases_age_groups_viruses_threads[current_step, 3, agent.virus_id, thread_id] += 1
            else
                daily_new_cases_age_groups_viruses_threads[current_step, 4, agent.virus_id, thread_id] += 1
            end

            # Инкубационный период
            incubation_period = get_period_from_erlang(
                viruses[agent.virus_id].mean_incubation_period,
                viruses[agent.virus_id].incubation_period_variance,
                viruses[agent.virus_id].min_incubation_period,
                viruses[agent.virus_id].max_incubation_period,
                rng)
            # Период болезни
            if agent.age < 16
                agent.infection_period = get_period_from_erlang(
                    viruses[agent.virus_id].mean_infection_period_child,
                    viruses[agent.virus_id].infection_period_variance_child,
                    viruses[agent.virus_id].min_infection_period_child,
                    viruses[agent.virus_id].max_infection_period_child,
                    rng)
            else
                agent.infection_period = get_period_from_erlang(
                    viruses[agent.virus_id].mean_infection_period_adult,
                    viruses[agent.virus_id].infection_period_variance_adult,
                    viruses[agent.virus_id].min_infection_period_adult,
                    viruses[agent.virus_id].max_infection_period_adult,
                    rng)
            end

            agent.days_infected = 1 - agent.incubation_period

            rand_num = rand(rng, Float64)
            if agent.age < 10
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_child
            elseif agent.age < 18
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_teenager
            else
                agent.is_asymptomatic = rand(rng, Float64) > viruses[agent.virus_id].symptomatic_probability_adult
            end
            
            agent.is_newly_infected = false
        end

        agent.attendance = true
        if agent.activity_type == 3 && !agent.is_teacher && rand(rng, Float64) < skip_college_probability
            agent.attendance = false
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
    temperature_base::Vector{Float64},
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
    # Уровни восприимчивости (клетки памяти) к инфекции после перенесенной болезни и исчезновения иммунитета
    immune_memory_susceptibility_levels::Vector{Float64},
    # Сценарий введения карантина в школах
    # Продолжительность закрытия школы / класса
    school_class_closure_period::Int = 0,
    # Порог заболеваемости для закрытия школы / класса
    school_class_closure_threshold::Float64 = 0.0,
    # Сценарий глобального потепления
    with_global_warming = false,
)::Tuple{Array{Float64, 3}, Array{Float64, 3}, Array{Float64, 2}, Vector{Float64}, Vector{Int}, Array{Float64, 2}}
    # День месяца
    day = 1
    # Месяц
    month = 8
    # День недели
    week_day = 1
    # Номер недели
    week_num = 1

    global_warming_temp = 1.0

    # Температура воздуха
    temperature = copy(temperature_base)
    # Если глобальное потепление
    if with_global_warming
        for i = 1:length(temperature)
            temperature[i] += rand(Normal(global_warming_temp, 0.25 * global_warming_temp))
        end
    end
    temperature_record = copy(temperature)
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

    # Заболеваемость на каждом шаге
    observed_num_infected_age_groups_viruses = zeros(Int, max_step, num_viruses, 4)
    observed_daily_new_cases_age_groups_viruses_threads = zeros(Int, max_step, 4, num_viruses, num_threads)
    num_infected_age_groups_viruses = zeros(Int, max_step, num_viruses, 4)
    daily_new_cases_age_groups_viruses_threads = zeros(Int, max_step, 4, num_viruses, num_threads)
    activities_infections_threads = zeros(Int, max_step, 5, num_threads)
    rt_threads = zeros(Float64, max_step, num_threads)
    rt_count_threads = zeros(Float64, max_step, num_threads)

    num_schools_closed_threads = zeros(Float64, max_step, num_threads)

    num_infected_districts_threads = zeros(Int, 107, max_step, num_threads)

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

        @threads for thread_id in 1:num_threads
            simulate_contacts(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
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
                for school_id in start_school_ids[thread_id]:end_school_ids[thread_id]
                    school = schools[school_id]
                    # Если школа не на карантине
                    if school.quarantine_period == 0
                        school_num_isolated = 0
                        school_num_people = 0
                        # num_closed_classrooms = 0
                        for groups_id in 1:length(school.groups)
                            # Параллели классов
                            groups = school.groups[groups_id]
                            # Если параллель не на карантине
                            if school.quarantine_period_groups[groups_id] == 0
                                groups_num_isolated = 0
                                groups_num_people = 0
                                for group in groups
                                    num_isolated = 0
                                    for agent_id in group
                                        agent = agents[agent_id]
                                        if !agent.is_teacher
                                            if agent.quarantine_period > 1
                                                # Класс на карантине
                                                # num_closed_classrooms += 1
                                                school_num_isolated += length(group) - 1
                                                school_num_people += length(group) - 1
                                                groups_num_people += length(group) - 1
                                                break
                                            end
                                            if agent.is_isolated
                                                num_isolated += 1
                                                school_num_isolated += 1
                                                groups_num_isolated += 1
                                            end
                                            school_num_people += 1
                                            groups_num_people += 1
                                        end
                                    end
                                    if length(group) > 1 && num_isolated / (length(group) - 1) > school_class_closure_threshold
                                        for agent_id in group
                                            agent = agents[agent_id]
                                            agent.quarantine_period = school_class_closure_period + 1
                                            if !agent.is_isolated
                                                school_num_isolated += 1
                                                groups_num_isolated += 1
                                            end
                                        end
                                    end
                                end

                                if groups_num_isolated / groups_num_people > school_class_closure_threshold
                                    for group in groups
                                        for agent_id in group
                                            agent = agents[agent_id]
                                            agent.quarantine_period = school_class_closure_period + 1
                                        end
                                    end
                                    school.quarantine_period_groups[groups_id] = school_class_closure_period
                                end
                            else
                                # Учитываем учеников на карантине
                                school.quarantine_period_groups[groups_id] -= 1
                                if school.quarantine_period_groups[groups_id] > 0
                                    for group in groups
                                        school_num_isolated += length(group) - 1
                                        school_num_people += length(group) - 1
                                    end
                                end
                            end
                        end
                        # println(school_num_isolated / school_num_people)

                        # if num_closed_classrooms >= school_closure_threshold_classes
                        #     for groups in school.groups
                        #         for group in groups
                        #             for agent_id in group
                        #                 agent = agents[agent_id]
                        #                 agent.quarantine_period = school_class_closure_period + 1
                        #             end
                        #         end
                        #     end
                        #     school.quarantine_period = school_class_closure_period
                        #     num_schools_closed_threads[current_step] += 1
                        # end
                        
                        if school_num_isolated / school_num_people > school_class_closure_threshold
                            for groups in school.groups
                                for group in groups
                                    for agent_id in group
                                        agent = agents[agent_id]
                                        agent.quarantine_period = school_class_closure_period + 1
                                    end
                                end
                            end
                            school.quarantine_period = school_class_closure_period
                            num_schools_closed_threads[current_step, thread_id] += 1
                        end
                    else
                        school.quarantine_period -= 1
                        for groups_id in 1:length(school.groups)
                            # Параллели классов
                            groups = school.groups[groups_id]
                            # Если параллель на карантине
                            if school.quarantine_period_groups[groups_id] > 0
                                school.quarantine_period_groups[groups_id] -= 1
                            end
                        end
                    end
                end
            end
        end

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
                daily_new_cases_age_groups_viruses_threads,
                rt_threads,
                rt_count_threads,
                num_infected_districts_threads,
                immune_memory_susceptibility_levels,
            )
        end

        # Записываем заболеваемость разными вирусами в различных возрастных группах
        for i = 1:4
            for j = 1:num_viruses
                observed_num_infected_age_groups_viruses[current_step, j, i] = sum(
                    observed_daily_new_cases_age_groups_viruses_threads[current_step, i, j, :])
                num_infected_age_groups_viruses[current_step, j, i] = sum(
                    daily_new_cases_age_groups_viruses_threads[current_step, i, j, :])
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

        # Если сценарий глобального потепления
        if with_global_warming && current_step % 365 == 0
            temperature = copy(temperature_base)
            for i = 1:length(temperature)
                temperature[i] += rand(Normal(global_warming_temp, 0.25 * global_warming_temp))
            end
            append!(temperature_record, temperature)
        end
    end

    # Если сценарий глобального потепления, то записываем температуру воздуха
    if with_global_warming
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "temperature_$(round(Int, global_warming_temp)).csv"), temperature_record, ',')
    end

    rt = sum(rt_threads, dims = 2)[:, 1]
    rt_count = sum(rt_count_threads, dims = 2)[:, 1]
    rt = rt ./ rt_count

    observed_num_infected_age_groups_viruses_weekly = zeros(Int, (num_weeks), num_viruses, 4)
    for i = 1:(num_weeks)
        observed_num_infected_age_groups_viruses_weekly[i, :, :] = sum(observed_num_infected_age_groups_viruses[(i * 7 - 6):(i * 7), :, :], dims = 1)
    end

    num_infected_age_groups_viruses_weekly = zeros(Int, (num_weeks), num_viruses, 4)
    for i = 1:(num_weeks)
        num_infected_age_groups_viruses_weekly[i, :, :] = sum(num_infected_age_groups_viruses[(i * 7 - 6):(i * 7), :, :], dims = 1)
    end

    return observed_num_infected_age_groups_viruses_weekly, num_infected_age_groups_viruses_weekly, sum(activities_infections_threads, dims = 3)[:, :, 1], rt, sum(num_schools_closed_threads, dims = 2)[:, 1], sum(num_infected_districts_threads, dims = 3)[:, :, 1]
end
