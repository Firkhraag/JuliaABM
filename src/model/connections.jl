# Построение связей в синтетической популяции
function set_connections(
    # Агенты
    agents::Vector{Agent},
    # Домохозяйства
    households::Vector{Household},
    # Детские сады
    kindergartens::Vector{School},
    # Школы
    schools::Vector{School},
    # Вузы
    colleges::Vector{School},
    # Рабочие коллективы
    workplaces::Vector{Workplace},
    # Генератор случайных чисел для потоков
    thread_rng::Vector{MersenneTwister},
    # Число потоков
    num_threads::Int,
    # Координаты домов, использующиеся для задания координат рабочих коллективов
    homes_coords_df::DataFrame,
    # Минимальный размер рабочего коллектива
    firm_min_size::Int,
    # Максимальный размер рабочего коллектива
    firm_max_size::Int,
    # Параметр предпочтительного присоединения графа Барабаши-Альберт для рабочих коллективов
    work_num_barabasi_albert_attachments::Int,
    # Параметр предпочтительного присоединения графа Барабаши-Альберт для школ
    school_num_barabasi_albert_attachments::Int,
)
    # Проходим по каждому агенту
    for agent_id in 1:length(agents)
        agent = agents[agent_id]

        # Если детсадовец
        if agent.activity_type == 1
            # Ближайший детсад
            agent.school_id = households[agent.household_id].closest_kindergarten_id
            # Год обучения
            groups = kindergartens[agent.school_id].groups[agent.school_group_num]
            # Последняя созданная группа для выбранного года обучения
            group_id = length(groups)
            # Если группа заполнена
            if (agent.school_group_num == 1 && 
                size(groups[group_id], 1) == kindergarten_groups_size_1) ||
                ((agent.school_group_num == 2 || agent.school_group_num == 3) && size(groups[group_id], 1) == kindergarten_groups_size_2_3) ||
                ((agent.school_group_num == 4 || agent.school_group_num == 5) && size(groups[group_id], 1) == kindergarten_groups_size_4_5)
                # Создаем новую группу
                push!(groups, Int[])
                group_id += 1
            end
            # Добавляем id агента в группу
            push!(groups[group_id], agent.id)
            # Если полный граф
            # agent.activity_conn_ids = groups[group_id]
        # Если школьник
        elseif agent.activity_type == 2
            # Ближайшая школа
            agent.school_id = households[agent.household_id].closest_school_id
            # Год обучения
            groups = schools[agent.school_id].groups[agent.school_group_num]
            # Последний созданный класс для выбранного года обучения
            group_id = length(groups)
            # Если класс заполнен
            if (agent.school_group_num < 5 && 
                size(groups[group_id], 1) == school_groups_size_5_9) ||
                (agent.school_group_num < 9 && size(groups[group_id], 1) == school_groups_size_10_14) ||
                (agent.school_group_num < 12 && size(groups[group_id], 1) == school_groups_size_15)
                # Создаем новый класс
                push!(groups, Int[])
                group_id += 1
            end
            # Добавляем id агента в класс
            push!(groups[group_id], agent.id)
            # Если полный граф
            # agent.activity_conn_ids = groups[group_id]
        # Если студент
        elseif agent.activity_type == 3
            # Ближайший вуз
            agent.school_id = rand(1:num_colleges)
            # Год обучения
            groups = colleges[agent.school_id].groups[agent.school_group_num]
            # Последняя созданная группа для выбранного года обучения
            group_id = length(groups)
            # Если группа заполнена
            if (agent.school_group_num == 1 && size(groups[group_id], 1) == college_groups_size_1) ||
                ((agent.school_group_num == 2 || agent.school_group_num == 3) && size(groups[group_id], 1) == college_groups_size_2_3) ||
                (agent.school_group_num == 4 && size(groups[group_id], 1) == college_groups_size_4) ||
                (agent.school_group_num == 5 && size(groups[group_id], 1) == college_groups_size_5) ||
                (agent.school_group_num == 6 && size(groups[group_id], 1) == college_groups_size_6)
                # Создаем новую группу
                push!(groups, Int[])
                group_id += 1
            end
            # Добавляем id агента в группу
            push!(groups[group_id], agent.id)
            # Если полный граф
            # agent.activity_conn_ids = groups[group_id]
        end
    end

    # Присваиваем воспитателей / преподавателей группам образовательных учреждений
    # Проходим по всем детским садам
    for kindergarten_id = 1:num_kindergartens
        kindergarten = kindergartens[kindergarten_id]
        # Проходим по каждому году обучения
        for school_group_num = 1:size(kindergarten.groups, 1)
            groups = kindergarten.groups[school_group_num]
            # Проходим по каждой группе
            for group_id = eachindex(groups)
                group = groups[group_id]
                # Идет поиск воспитателя
                searching = true
                agent_id = 1
                while searching
                    # Выбираем случайного агента
                    agent_id = rand(1:num_agents)
                    # Если работает и старше 18 лет
                    if agents[agent_id].activity_type == 4 && agents[agent_id].age >= 18
                        # Нашли воспитателя
                        searching = false
                    end
                end
                # Добавляем воспитателя в группу
                push!(group, agent_id)
                # Присваиваем детский сад в качестве коллектива
                agents[agent_id].activity_type = 1
                # Является воспитателем
                agents[agent_id].is_teacher = true
                # Присваиваем id детсада
                agents[agent_id].school_id = kindergarten_id
                # Присваиваем номер группы
                agents[agent_id].school_group_num = school_group_num
                # Устанавливаем связи с каждым агентом группы
                agents[agent_id].activity_conn_ids = group
                for agent2_id in group
                    if agent2_id == agent_id
                        continue
                    end
                    push!(agents[agent2_id].activity_conn_ids, agent_id)
                end
                # Добавляем агента в набор воспитателей для данного детского сада
                push!(kindergarten.teacher_ids, agent_id)
            end
        end
    end

    # Присваиваем воспитателей / преподавателей группам образовательных учреждений
    # Проходим по всем школам
    for school_id = 1:num_schools
        school = schools[school_id]
        # Проходим по каждому году обучения
        for school_group_num = 1:size(school.groups, 1)
            groups = school.groups[school_group_num]
            # Проходим по каждой группе
            for group_id = eachindex(groups)
                group = groups[group_id]
                # Идет поиск преподавателя
                searching = true
                agent_id = 1
                while searching
                    # Выбираем случайного агента
                    agent_id = rand(1:num_agents)
                    # Если работает и старше 20 лет
                    if agents[agent_id].activity_type == 4 && agents[agent_id].age >= 20
                        # Нашли преподавателя
                        searching = false
                    end
                end
                # Добавляем преподавателя в группу
                push!(group, agent_id)
                # Присваиваем школу в качестве коллектива
                agents[agent_id].activity_type = 2
                # Является преподавателем
                agents[agent_id].is_teacher = true
                # Присваиваем id школы
                agents[agent_id].school_id = school_id
                # Присваиваем номер группы
                agents[agent_id].school_group_num = school_group_num
                # Устанавливаем связи с каждым агентом группы
                agents[agent_id].activity_conn_ids = group
                for agent2_id in group
                    if agent2_id == agent_id
                        continue
                    end
                    push!(agents[agent2_id].activity_conn_ids, agent_id)
                end
                # Добавляем агента в набор преподавателей для данной школы
                push!(school.teacher_ids, agent_id)
            end
        end
    end

    # Присваиваем воспитателей / преподавателей группам образовательных учреждений
    # Проходим по всем вузам
    for college_id = 1:num_colleges
        college = colleges[college_id]
        # Проходим по каждому году обучения
        for school_group_num = 1:size(college.groups, 1)
            groups = college.groups[school_group_num]
            # Проходим по каждой группе
            for group_id = eachindex(groups)
                group = groups[group_id]
                # Идет поиск преподавателя
                searching = true
                agent_id = 1
                while searching
                    # Выбираем случайного агента
                    agent_id = rand(1:num_agents)
                    if agents[agent_id].activity_type == 4 && agents[agent_id].age >= 25
                        searching = false
                    end
                end
                # Добавляем преподавателя в группу
                push!(group, agent_id)
                # Присваиваем вуз в качестве коллектива
                agents[agent_id].activity_type = 3
                # Является преподавателем
                agents[agent_id].is_teacher = true
                # Присваиваем id вуза
                agents[agent_id].school_id = college_id
                # Присваиваем номер группы
                agents[agent_id].school_group_num = school_group_num
                # Устанавливаем связи с каждым агентом группы
                agents[agent_id].activity_conn_ids = group
                for agent2_id in group
                    if agent2_id == agent_id
                        continue
                    end
                    push!(agents[agent2_id].activity_conn_ids, agent_id)
                end
                # Добавляем агента в набор преподавателей для данной школы
                push!(college.teacher_ids, agent_id)
            end
        end
    end

    # Находим число работающих агентов
    num_working_agents = 0
    for agent_id in 1:length(agents)
        agent = agents[agent_id]
        if agent.activity_type == 4
            num_working_agents += 1
        end
    end

    # Проходим по всем агентам и присваиваем им рабочий коллектив, если они работают
    start_agent_id = 1
    # Перемешиваем агентов
    agents_shuffled = shuffle(agents)
    while num_working_agents > 0
        # Выбираем число работников из усеченного логнормального распределения
        num_workers = round(Int, rand(truncated(LogNormal(1.3, 1.7), firm_min_size, firm_max_size)))
        # Если больше оставшегося числа агентов
        if num_working_agents - num_workers < 0
            num_workers = num_working_agents
        end
        # Набор работников
        agent_ids = Array{Int, 1}(undef, num_workers)
        # Число найденных работников
        j = 0
        # Число рассмотренных агентов
        num_agent_passed = 0
        # Проходим по агентам
        for agent_id in start_agent_id:num_agents
            agent = agents_shuffled[agent_id]
            # Если работает
            if agent.activity_type == 4
                # Нашли +1 работника
                j += 1
                # Присваиваем набору работников
                agent_ids[j] = agent.id
                # Присваиваем рабочий коллектив
                agent.workplace_id = length(workplaces) + 1
            end
            num_agent_passed += 1
            # Если число найденных работников равно число работников в рабочем коллективе
            if j == num_workers
                break
            end
        end
        # Увеличиваем стартовый индекс для следующей итерации
        start_agent_id += num_agent_passed
        # Присваиваем координаты случайного дома
        home_id = rand(1:size(homes_coords_df, 1))
        # Создаем рабочий коллектив
        workplace = Workplace(agent_ids, homes_coords_df[home_id, "x"], homes_coords_df[home_id, "y"])
        # Добавляем его в набор рабочих коллективов
        push!(workplaces, workplace)
        # Уменьшаем число рабочих агентов, которых нужно присвоить рабочим коллективам
        num_working_agents -= num_workers
    end

    # Разбиваем рабочие коллективы по потокам
    num_workplaces = size(workplaces, 1)
    start_workplace_ids = Array{Int, 1}(undef, num_threads)
    end_workplace_ids = Array{Int, 1}(undef, num_threads)
    for i in 1:num_threads - 1
        start_workplace_ids[i] = (i - 1) * (num_workplaces ÷ num_threads) + 1
        end_workplace_ids[i] = i * (num_workplaces ÷ num_threads)
    end
    start_workplace_ids[num_threads] = (num_threads - 1) * (num_workplaces ÷ num_threads) + 1
    end_workplace_ids[num_threads] = num_workplaces

    # Строим связи в коллективах, разбивая их по потокам
    @threads for thread_id in 1:num_threads
        # Проходим по вузам
        for college_id in start_college_ids[thread_id]:end_college_ids[thread_id]
            college = colleges[college_id]
            # Проходим по каждому году обучения
            for i = 1:6
                # Проходим по каждым 4-м группам
                for j = 1:4:length(college.groups[i])
                    if length(college.groups[i]) - j >= 4
                        # Последовательно выбираем 4 группы
                        group1 = college.groups[i][j]
                        group2 = college.groups[i][j + 1]
                        group3 = college.groups[i][j + 2]
                        group4 = college.groups[i][j + 3]
                        # Строим связи между агентами в них
                        connections_for_group1 = vcat(group2, group3, group4)
                        connections_for_group2 = vcat(group1, group3, group4)
                        connections_for_group3 = vcat(group2, group1, group4)
                        connections_for_group4 = vcat(group2, group3, group1)
                        for agent_id in group1
                            agent = agents[agent_id]
                            agent.activity_cross_conn_ids = connections_for_group1
                        end
                        for agent_id in group2
                            agent = agents[agent_id]
                            agent.activity_cross_conn_ids = connections_for_group2
                        end
                        for agent_id in group3
                            agent = agents[agent_id]
                            agent.activity_cross_conn_ids = connections_for_group3
                        end
                        for agent_id in group4
                            agent = agents[agent_id]
                            agent.activity_cross_conn_ids = connections_for_group4
                        end
                    end
                end
            end
        end

        # Строим графы Барабаши-Альберт для детских садов
        for kindergarten_id in start_kindergarten_ids[thread_id]:end_kindergarten_ids[thread_id]
            kindergarten = kindergartens[kindergarten_id]
            for groups in kindergarten.groups
                for group in groups
                    generate_barabasi_albert_network(
                        agents, group, school_num_barabasi_albert_attachments, thread_rng[thread_id])
                end
            end
        end

        # Строим графы Барабаши-Альберт для школ
        for school_id in start_school_ids[thread_id]:end_school_ids[thread_id]
            school = schools[school_id]
            for groups in school.groups
                for group in groups
                    generate_barabasi_albert_network(
                        agents, group, school_num_barabasi_albert_attachments, thread_rng[thread_id])
                end
            end
        end

        # Строим графы Барабаши-Альберт для вузов
        for college_id in start_college_ids[thread_id]:end_college_ids[thread_id]
            college = colleges[college_id]
            for groups in college.groups
                for group in groups
                    generate_barabasi_albert_network(
                        agents, group, school_num_barabasi_albert_attachments, thread_rng[thread_id])
                end
            end
        end

        # Строим графы Барабаши-Альберт для рабочих коллективов
        for workplace_id in start_workplace_ids[thread_id]:end_workplace_ids[thread_id]
            generate_barabasi_albert_network(
                agents, workplaces[workplace_id].agent_ids, work_num_barabasi_albert_attachments, thread_rng[thread_id])
        end
    end
end

# Создание графа Барабаши-Альберта
# На вход подаются группа с набором агентов (group) и число минимальных связей, которые должен иметь агент (m)
function generate_barabasi_albert_network(
    # Общий набор агентов
    agents::Vector{Agent},
    # Группа с набором агентов
    agent_ids::Vector{Int},
    # Параметр предпочтительного присоединения
    m::Int,
    # Генератор случайных чисел
    rng::MersenneTwister
)
    # Если число агентов меньше параметра предпочтительного присоединения
    if length(agent_ids) < m
        m = length(agent_ids)
    end
    # Связный граф с m вершинами
    for i = 1:m
        agent = agents[agent_ids[i]]
        # Если агент является преподавателем, то игнорируем
        if agent.is_teacher
            continue
        end
        for j = (i + 1):m
            agent2 = agents[agent_ids[j]]
            # Если агент является преподавателем, то игнорируем
            if agent2.is_teacher
                continue
            end
            # Строим связь между агентами i и j
            push!(agents[agent_ids[i]].activity_conn_ids, agent_ids[j])
            push!(agents[agent_ids[j]].activity_conn_ids, agent_ids[i])
        end
    end
    # Добавление новых вершин



    # Сумма связей всех вершин
    degree_sum = m * (m - 1)
    # Добавление новых вершин
    for i = (m + 1):length(agent_ids)
        agent = agents[agent_ids[i]]
        # Если агент является преподавателем, то игнорируем
        if agent.is_teacher
            continue
        end
        # Сумма связей всех вершин, с которыми у новой вершины нет связи
        degree_sum_temp = degree_sum
        # Строим m связей
        for _ = 1:m
            # Сумма вероятностей
            cumulative = 0.0
            # Случайное число для выбора вершины
            rand_num = rand(rng, Float64)
            # Проходим по каждой вершине
            for j = 1:(i - 1)
                # Если связь уже установлена
                if agent_ids[j] in agent.activity_conn_ids
                    continue
                end
                agent2 = agents[agent_ids[j]]
                # Прибавляем вероятность присоединения к данному узлу
                cumulative += length(agent2.activity_conn_ids) / degree_sum_temp
                # Если есть связь
                if rand_num < cumulative
                    degree_sum_temp -= length(agent2.activity_conn_ids)
                    push!(agent.activity_conn_ids, agent2.id)
                    push!(agent2.activity_conn_ids, agent.id)
                    break
                end
            end
        end
        # Прибавляем новые связи к сумме связей
        degree_sum += 2m

        # Если случайный выбор вершины
        # for _ = 1:m
        #     j = rand(rng, 1:(i - 1))
        #     while agent_ids[j] in agent.activity_conn_ids
        #         j = rand(rng, 1:(i - 1))
        #     end

        #     agent2 = agents[agent_ids[j]]
        #     push!(agent.activity_conn_ids, agent2.id)
        #     push!(agent2.activity_conn_ids, agent.id)
        # end
    end
end
