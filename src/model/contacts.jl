# Моделирование контактов
function simulate_contacts_evaluation(
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
    # Детские сады
    kindergartens::Vector{School},
    # Школы
    schools::Vector{School},
    # Вузы
    colleges::Vector{School},
    # Средние продолжительности контактов в домохозяйствах для разных контактов
    mean_household_contact_durations::Vector{Float64},
    # Среднеквадратические отклонения для контактов в домохозяйствах для разных контактов
    household_contact_duration_sds::Vector{Float64},
    # Средние продолжительности контактов в прочих коллективах
    other_contact_duration_shapes::Vector{Float64},
    # Среднеквадратические отклонения для контактов в прочих коллективах
    other_contact_duration_scales::Vector{Float64},
    # Праздник или выходной
    is_holiday::Bool,
    # Выходной для детских садов
    is_kindergarten_holiday::Bool,
    # Выходной для школ
    is_school_holiday::Bool,
    # Выходной для вузов
    is_college_holiday::Bool,
    # Выходной для рабочих коллективов
    is_work_holiday::Bool,
    # Матрицы контактов по потокам
    contacts_num_matrix_by_age_threads::Array{Int, 3},
    contacts_dur_matrix_by_age_threads::Array{Float64, 3},
    contacts_num_matrix_by_age_activities_threads::Array{Int, 4},
    contacts_dur_matrix_by_age_activities_threads::Array{Float64, 4},
)
    # Проходим по агентам потока
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        # Контакты в домохозяйстве
        for agent2_id in agent.household_conn_ids
            agent2 = agents[agent2_id]
            if agent2_id != agent_id
                # Продолжительность контакта
                dur = 0.0
                # Если оба агента сидят дома на данном шаге
                if is_holiday || ((agent.activity_type == 0 ||
                    (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_college_holiday) ||
                    (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                    (agent2.activity_type == 0 ||
                    (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_college_holiday) ||
                    (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday)))

                    dur = get_contact_duration(
                        mean_household_contact_durations[5], household_contact_duration_sds[5], rng, true)
                # Если один из агентов посещает работу
                elseif ((agent.activity_type == 4) ||
                    (agent2.activity_type == 4)) && !is_work_holiday

                    dur = get_contact_duration(
                        mean_household_contact_durations[4], household_contact_duration_sds[4], rng, true)
                # Если один из агентов посещает школу
                elseif ((agent.activity_type == 2) ||
                    (agent2.activity_type == 2)) && !is_school_holiday

                    dur = get_contact_duration(
                        mean_household_contact_durations[2], household_contact_duration_sds[2], rng, true)
                # Если один из агентов посещает детский сад
                elseif ((agent.activity_type == 1) ||
                    (agent2.activity_type == 1)) && !is_kindergarten_holiday
                    
                    dur = get_contact_duration(
                        mean_household_contact_durations[1], household_contact_duration_sds[1], rng, true)
                # Если один из агентов посещает вуз
                else
                    dur = get_contact_duration(
                        mean_household_contact_durations[3], household_contact_duration_sds[3], rng, true)
                end

                if dur > 0.01
                    # Записываем контакт
                    contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 5] += 1
                    contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, 5] += dur
                end
            end
        end
        # Контакты в коллективе, который агент посещает на данном шаге
        if agent.attendance &&
            ((agent.activity_type == 1 && !is_kindergarten_holiday) ||
            (agent.activity_type == 2 && !is_school_holiday) ||
            (agent.activity_type == 3 && !is_college_holiday) ||
            (agent.activity_type == 4 && !is_work_holiday))
            # Проходим по агентам, с которыми есть связь
            for agent2_id in agent.activity_conn_ids
                agent2 = agents[agent2_id]
                if agent2.attendance && agent2_id != agent_id
                    dur = 0.0
                    # Находим продолжительность контакта
                    if agent.activity_type == 1
                        dur = get_contact_duration(
                            other_contact_duration_shapes[1], other_contact_duration_scales[1], rng, false)
                    elseif agent.activity_type == 2
                        dur = get_contact_duration(
                            other_contact_duration_shapes[2], other_contact_duration_scales[2], rng, false)
                    elseif agent.activity_type == 3
                        dur = get_contact_duration(
                            other_contact_duration_shapes[3], other_contact_duration_scales[3], rng, false)
                    else
                        dur = get_contact_duration(
                            other_contact_duration_shapes[3], other_contact_duration_scales[3], rng, false)
                    end

                    if dur > 0.01
                        contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                        contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                    end
                end
            end

            # если агент является воспитателем или преподавателем
            if agent.is_teacher
                # Строим связи с другими воспитателями и преподавателями
                num_contacts = 0
                if agent.activity_type == 1
                    while num_contacts < school_num_of_teacher_contacts && num_contacts < length(kindergartens[agent.school_id].teacher_ids)
                        teacher_id = rand(kindergartens[agent.school_id].teacher_ids)
                        if teacher_id != agent.id
                            agent2 = agents[teacher_id]
                            dur = get_contact_duration(
                                other_contact_duration_shapes[5], other_contact_duration_scales[5], rng, false)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                            end
                            num_contacts += 1
                        end
                    end
                elseif agent.activity_type == 2
                    while num_contacts < school_num_of_teacher_contacts && num_contacts < length(schools[agent.school_id].teacher_ids)
                        teacher_id = rand(schools[agent.school_id].teacher_ids)
                        if teacher_id != agent.id
                            agent2 = agents[teacher_id]
                            dur = get_contact_duration(
                                other_contact_duration_shapes[5], other_contact_duration_scales[5], rng, false)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                            end
                            num_contacts += 1
                        end
                    end
                elseif agent.activity_type == 3
                    while num_contacts < school_num_of_teacher_contacts && num_contacts < length(colleges[agent.school_id].teacher_ids)
                        teacher_id = rand(colleges[agent.school_id].teacher_ids)
                        if teacher_id != agent.id
                            agent2 = agents[teacher_id]
                            dur = get_contact_duration(
                                other_contact_duration_shapes[5], other_contact_duration_scales[5], rng, false)
                            if dur > 0.01
                                contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                                contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                                contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                                contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                            end
                            num_contacts += 1
                        end
                    end
                end
            end

            # Контакты между студентами различных университетских групп
            if agent.activity_type == 3
                for agent2_id in agent.activity_cross_conn_ids
                    agent2 = agents[agent2_id]
                    if agent2.attendance && !agent2.is_teacher && rand(rng, Float64) < 0.25
                        dur = get_contact_duration(
                            other_contact_duration_shapes[5], other_contact_duration_scales[5], rng, false)
                        if dur > 0.01
                            contacts_num_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                            contacts_dur_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                            contacts_num_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += 1
                            contacts_dur_matrix_by_age_activities_threads[thread_id, agent.age + 1, agent2.age + 1, agent.activity_type] += dur
                        end
                    end
                end
            end
        end
    end
end

# Моделирование контактов без учета заболеваемости
function run_simulation_evaluation(
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
    # Если выходной
    is_holiday::Bool,
)
    # Матрица числа контактов между возрастами
    contacts_num_matrix_by_age_threads = zeros(Int, num_threads, 90, 90)
    # Матрица продолжительности контактов между возрастами
    contacts_dur_matrix_by_age_threads = zeros(Float64, num_threads, 90, 90)
    # Матрица числа контактов между возрастами в коллективах
    contacts_num_matrix_by_age_activities_threads = zeros(Int, num_threads, 90, 90, 5)
    # Матрица продолжительности контактов между возрастами в коллективах
    contacts_dur_matrix_by_age_activities_threads = zeros(Float64, num_threads, 90, 90, 5)

    # Выходные, праздники
    # Работа
    is_work_holiday = is_holiday
    # Детсад
    is_kindergarten_holiday = is_holiday
    # Школа
    is_school_holiday = is_holiday
    # Вуз
    is_college_holiday = is_holiday

    # Моделируем контакты по потокам
    @threads for thread_id in 1:num_threads
        simulate_contacts_evaluation(
            thread_id,
            thread_rng[thread_id],
            start_agent_ids[thread_id],
            end_agent_ids[thread_id],
            agents,
            kindergartens,
            schools,
            colleges,
            mean_household_contact_durations,
            household_contact_duration_sds,
            other_contact_duration_shapes,
            other_contact_duration_scales,
            is_holiday,
            is_kindergarten_holiday,
            is_school_holiday,
            is_college_holiday,
            is_work_holiday,
            contacts_num_matrix_by_age_threads,
            contacts_dur_matrix_by_age_threads,
            contacts_num_matrix_by_age_activities_threads,
            contacts_dur_matrix_by_age_activities_threads)
    end

    # Суммируем по потокам
    contacts_num_matrix_by_age = sum(contacts_num_matrix_by_age_threads, dims=1)[1, :, :]
    contacts_dur_matrix_by_age = sum(contacts_dur_matrix_by_age_threads, dims=1)[1, :, :]
    contacts_num_matrix_by_age_activities = sum(contacts_num_matrix_by_age_activities_threads, dims=1)[1, :, :, :]
    contacts_dur_matrix_by_age_activities = sum(contacts_dur_matrix_by_age_activities_threads, dims=1)[1, :, :, :]

    # Сумма контактов по коллективам
    println("All contacts: $(sum(contacts_num_matrix_by_age))")
    for i = 1:5
        println("Activity $(i): $(sum(contacts_num_matrix_by_age_activities[:, :, i]))")
    end

    # Если выходной
    if is_holiday
        # Сохраняем число контактов и их продолжительности
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts_holiday.csv"), contacts_num_matrix_by_age, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations_holiday.csv"), contacts_dur_matrix_by_age, ',')
        for i = 1:5
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts_activity_$(i)_holiday.csv"),
                contacts_num_matrix_by_age_activities[:, :, i], ',')
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations_activity_$(i)_holiday.csv"),
                contacts_dur_matrix_by_age_activities[:, :, i], ',')
        end
    # Если будний день
    else
        # Сохраняем число контактов и их продолжительности
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts.csv"), contacts_num_matrix_by_age, ',')
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations.csv"), contacts_dur_matrix_by_age, ',')
        for i = 1:5
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_counts_activity_$(i).csv"),
                contacts_num_matrix_by_age_activities[:, :, i], ',')
            writedlm(
                joinpath(@__DIR__, "..", "..", "output", "tables", "contacts", "contact_durations_activity_$(i).csv"),
                contacts_dur_matrix_by_age_activities[:, :, i], ',')
        end
    end
    
end
