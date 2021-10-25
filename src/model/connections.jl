function set_connections(
    agents::Vector{Agent},
    households::Vector{Household},
    kindergartens::Vector{School},
    schools::Vector{School},
    universities::Vector{School},
    workplaces::Vector{Workplace},
    thread_rng::Vector{MersenneTwister},
    num_threads::Int,
    homes_coords_df::DataFrame,
)
    num_working_agents = 0
    for agent in agents
        if agent.collective_id == 1
            agent.school_id = households[agent.household_id].closest_kindergarten_id
            groups = kindergartens[agent.school_id].groups[agent.group_num]
            group_id = size(groups, 1)
            if (agent.group_num == 1 && 
                size(groups[group_id], 1) == kindergarten_groups_size_1) ||
                ((agent.group_num == 2 || agent.group_num == 3) && size(groups[group_id], 1) == kindergarten_groups_size_2_3) ||
                ((agent.group_num == 4 || agent.group_num == 5) && size(groups[group_id], 1) == kindergarten_groups_size_4_5)
                
                push!(groups, Int[])
                group_id += 1
            end
            push!(groups[group_id], agent.id)
            agent.collective_conn_ids = groups[group_id]
            # agent.school_group_id = group_id
        elseif agent.collective_id == 2
            agent.school_id = households[agent.household_id].closest_school_id
            groups = schools[agent.school_id].groups[agent.group_num]
            group_id = size(groups, 1)
            if size(groups[group_id], 1) == school_groups_size_10_11
                push!(groups, Int[])
                group_id += 1
            end
            push!(groups[group_id], agent.id)
            agent.collective_conn_ids = groups[group_id]
            # agent.school_group_id = group_id
        elseif agent.collective_id == 3
            agent.school_id = rand(1:num_universities)
            groups = universities[agent.school_id].groups[agent.group_num]
            group_id = size(groups, 1)
            if (agent.group_num == 1 && size(groups[group_id], 1) == university_groups_size_1) ||
                ((agent.group_num == 2 || agent.group_num == 3) && size(groups[group_id], 1) == university_groups_size_2_3) ||
                (agent.group_num == 4 && size(groups[group_id], 1) == university_groups_size_4) ||
                (agent.group_num == 5 && size(groups[group_id], 1) == university_groups_size_5) ||
                (agent.group_num == 6 && size(groups[group_id], 1) == university_groups_size_6)

                push!(groups, Int[])
                group_id += 1
            end
            push!(groups[group_id], agent.id)
            agent.collective_conn_ids = groups[group_id]
            # agent.school_group_id = group_id
        elseif agent.collective_id == 4
            num_working_agents += 1
        end
    end

    for kindergarten_id in 1:num_kindergartens
        kindergarten = kindergartens[kindergarten_id]
        for group_num in 1:size(kindergarten.groups, 1)
            groups = kindergarten.groups[group_num]
            groups_size = size(groups, 1)
            for group_id in 1:groups_size
                group = groups[group_id]
                searching = true
                agent_id = 1
                while searching
                    agent_id = rand(1:num_agents)
                    if agents[agent_id].collective_id == 4 && agents[agent_id].age >= 18
                        searching = false
                    end
                end

                push!(group, agent_id)
                agents[agent_id].collective_id = 1
                agents[agent_id].is_teacher = true
                agents[agent_id].school_id = kindergarten_id
                agents[agent_id].group_num = group_num
                agents[agent_id].collective_conn_ids = group
                # agents[agent_id].school_group_id = group_id
            end
            num_working_agents -= groups_size
        end
    end

    for school_id in 1:num_schools
        school = schools[school_id]
        for group_num in 1:size(school.groups, 1)
            groups = school.groups[group_num]
            groups_size = size(groups, 1)
            for group_id in 1:groups_size
                group = groups[group_id]
                searching = true
                agent_id = 1
                while searching
                    agent_id = rand(1:num_agents)
                    if agents[agent_id].collective_id == 4 && agents[agent_id].age >= 20
                        searching = false
                    end
                end

                push!(group, agent_id)
                agents[agent_id].collective_id = 2
                agents[agent_id].is_teacher = true
                agents[agent_id].school_id = school_id
                agents[agent_id].group_num = group_num
                agents[agent_id].collective_conn_ids = group
                # agents[agent_id].school_group_id = group_id
            end
            num_working_agents -= groups_size
        end
    end

    for university_id in 1:num_universities
        university = universities[university_id]
        for group_num in 1:size(university.groups, 1)
            groups = university.groups[group_num]
            groups_size = size(groups, 1)
            for group_id in 1:groups_size
                group = groups[group_id]
                searching = true
                agent_id = 1
                while searching
                    agent_id = rand(1:num_agents)
                    if agents[agent_id].collective_id == 4 && agents[agent_id].age >= 25
                        searching = false
                    end
                end

                push!(group, agent_id)
                agents[agent_id].collective_id = 3
                agents[agent_id].is_teacher = true
                agents[agent_id].school_id = university_id
                agents[agent_id].group_num = group_num
                agents[agent_id].collective_conn_ids = group
                # agents[agent_id].school_group_id = group_id
            end
            num_working_agents -= groups_size
        end
    end

    # log_norm_dist = truncated(LogNormal(1.3, 1.7), 1, 1000)

    start_agent_id = 1
    while num_working_agents > 0
        num_workers = sample_from_zipf_distribution(1.059, zipf_max_size) + barabasi_albert_attachments
        if num_working_agents - num_workers < 0
            num_workers = num_working_agents
        end

        agent_ids = Array{Int, 1}(undef, num_workers)
        j = 0
        for agent_id in start_agent_id:num_agents
            agent = agents[agent_id]
            if agent.collective_id == 4 && agent.workplace_id == 0
                j += 1
                agent_ids[j] = agent.id
            end
            if j == num_workers
                break
            end
        end
        start_agent_id += j

        home_id = rand(1:size(homes_coords_df, 1))
        workplace = Workplace(agent_ids, homes_coords_df[home_id, "x"], homes_coords_df[home_id, "y"])
        push!(workplaces, workplace)

        num_working_agents -= num_workers
    end

    num_workplaces = size(workplaces, 1)
    start_workplace_ids = Array{Int, 1}(undef, num_threads)
    end_workplace_ids = Array{Int, 1}(undef, num_threads)
    for i in 1:num_threads - 1
        start_workplace_ids[i] = (i - 1) * (num_workplaces ÷ num_threads) + 1
        end_workplace_ids[i] = i * (num_workplaces ÷ num_threads)
    end
    start_workplace_ids[num_threads] = (num_threads - 1) * (num_workplaces ÷ num_threads) + 1
    end_workplace_ids[num_threads] = num_workplaces

    @threads for thread_id in 1:num_threads
        for workplace_id in start_workplace_ids[thread_id]:end_workplace_ids[thread_id]
            generate_barabasi_albert_network(
                agents, workplaces[workplace_id].agent_ids, barabasi_albert_attachments, thread_rng[thread_id])
        end
    end
end

# Создание графа Барабаши-Альберта
# На вход подаются группа с набором агентов (group) и число минимальных связей, которые должен иметь агент (m)
function generate_barabasi_albert_network(agents::Vector{Agent}, agent_ids::Vector{Int}, m::Int, rng::MersenneTwister)
    if size(agent_ids, 1) < m
        m = size(agent_ids, 1)
    end
    # Связный граф с m вершинами
    for i = 1:m
        for j = (i + 1):m
            push!(agents[agent_ids[i]].collective_conn_ids, agent_ids[j])
            push!(agents[agent_ids[j]].collective_conn_ids, agent_ids[i])
        end
    end
    # Сумма связей всех вершин
    degree_sum = m * (m - 1)
    # Добавление новых вершин
    for i = (m + 1):size(agent_ids, 1)
        agent = agents[agent_ids[i]]
        degree_sum_temp = degree_sum
        for _ = 1:m
            cumulative = 0.0
            rand_num = rand(rng, Float64)
            for j = 1:(i - 1)
                if agent_ids[j] in agent.collective_conn_ids
                    continue
                end
                agent2 = agents[agent_ids[j]]
                cumulative += size(agent2.collective_conn_ids, 1) / degree_sum_temp
                if rand_num < cumulative
                    degree_sum_temp -= size(agent2.collective_conn_ids, 1)
                    push!(agent.collective_conn_ids, agent2.id)
                    push!(agent2.collective_conn_ids, agent.id)
                    break
                end
            end
        end
        degree_sum += 2m
    end
end


function sample_from_zipf_distribution(
    parameter::Float64, max_size::Int
)::Int
    cumulative = 0.0
    rand_num = rand(Float64)
    multiplier = 1 / sum((1:max_size).^(-parameter))
    for i = 1:max_size
        cumulative += i^(-parameter) * multiplier
        if rand_num < cumulative
            return i
        end
    end
    return max_size
end
