function set_connections(
    agents::Vector{Agent},
    households::Vector{Household},
    kindergartens::Vector{School},
    schools::Vector{School},
    colleges::Vector{School},
    workplaces::Vector{Workplace},
    # shops::Vector{PublicSpace},
    # restaurants::Vector{PublicSpace},
    thread_rng::Vector{MersenneTwister},
    num_threads::Int,
    homes_coords_df::DataFrame,
    # min_size_bias::Int,
    firm_min_size::Int,
    firm_max_size::Int,
    num_barabasi_albert_attachments::Int,
)
    num_working_agents = 0
    for agent_id in 1:length(agents)
        agent = agents[agent_id]

        # --------------------------TBD ZONE-----------------------------------

        # num_of_conn = round(Int, rand(Normal(num_of_close_friends_mean, num_of_close_friends_sd)))
        # if num_of_conn > length(agent.friend_ids)
        #     for agent2_id = (agent_id + 1):length(agents)
        #         agent2 = agents[agent2_id]
        #         if rand(Float64) < get_similarity_between_agents(agent, agent)
        #             push!(agent.friend_ids, agent2_id)
        #             push!(agent2.friend_ids, agent_id)
        #             if length(agent.friend_ids) == num_of_conn
        #                 break
        #             end
        #         end
        #     end
        # end

        # -------------------------------------------------------------

        if agent.activity_type == 1
            agent.school_id = households[agent.household_id].closest_kindergarten_id
            groups = kindergartens[agent.school_id].groups[agent.school_group_num]
            group_id = length(groups)
            if (agent.school_group_num == 1 && 
                size(groups[group_id], 1) == kindergarten_groups_size_1) ||
                ((agent.school_group_num == 2 || agent.school_group_num == 3) && size(groups[group_id], 1) == kindergarten_groups_size_2_3) ||
                ((agent.school_group_num == 4 || agent.school_group_num == 5) && size(groups[group_id], 1) == kindergarten_groups_size_4_5)
                
                push!(groups, Int[])
                group_id += 1
            end
            push!(groups[group_id], agent.id)
            agent.activity_conn_ids = groups[group_id]
        elseif agent.activity_type == 2
            agent.school_id = households[agent.household_id].closest_school_id
            groups = schools[agent.school_id].groups[agent.school_group_num]
            group_id = length(groups)
            if size(groups[group_id], 1) == school_groups_size
                push!(groups, Int[])
                group_id += 1
            end
            push!(groups[group_id], agent.id)
            agent.activity_conn_ids = groups[group_id]
        elseif agent.activity_type == 3
            agent.school_id = rand(1:num_colleges)
            groups = colleges[agent.school_id].groups[agent.school_group_num]
            group_id = length(groups)
            if (agent.school_group_num == 1 && size(groups[group_id], 1) == college_groups_size_1) ||
                ((agent.school_group_num == 2 || agent.school_group_num == 3) && size(groups[group_id], 1) == college_groups_size_2_3) ||
                (agent.school_group_num == 4 && size(groups[group_id], 1) == college_groups_size_4) ||
                (agent.school_group_num == 5 && size(groups[group_id], 1) == college_groups_size_5) ||
                (agent.school_group_num == 6 && size(groups[group_id], 1) == college_groups_size_6)

                push!(groups, Int[])
                group_id += 1
            end
            push!(groups[group_id], agent.id)
            agent.activity_conn_ids = groups[group_id]
        elseif agent.activity_type == 4
            num_working_agents += 1
        end
    end

    for kindergarten_id in 1:num_kindergartens
        kindergarten = kindergartens[kindergarten_id]
        for school_group_num in 1:size(kindergarten.groups, 1)
            groups = kindergarten.groups[school_group_num]
            groups_size = size(groups, 1)
            for group_id in 1:groups_size
                group = groups[group_id]
                searching = true
                agent_id = 1
                while searching
                    agent_id = rand(1:num_agents)
                    if agents[agent_id].activity_type == 4 && agents[agent_id].age >= 18
                        searching = false
                    end
                end

                push!(group, agent_id)
                agents[agent_id].activity_type = 1
                agents[agent_id].is_teacher = true
                agents[agent_id].school_id = kindergarten_id
                agents[agent_id].school_group_num = school_group_num
                agents[agent_id].activity_conn_ids = group
                push!(kindergarten.teacher_ids, agent_id)
                # agents[agent_id].school_group_id = group_id
            end
            num_working_agents -= groups_size
        end
    end

    for school_id in 1:num_schools
        school = schools[school_id]
        for school_group_num in 1:size(school.groups, 1)
            groups = school.groups[school_group_num]
            groups_size = size(groups, 1)
            for group_id in 1:groups_size
                group = groups[group_id]
                searching = true
                agent_id = 1
                while searching
                    agent_id = rand(1:num_agents)
                    if agents[agent_id].activity_type == 4 && agents[agent_id].age >= 20
                        searching = false
                    end
                end

                push!(group, agent_id)
                agents[agent_id].activity_type = 2
                agents[agent_id].is_teacher = true
                agents[agent_id].school_id = school_id
                agents[agent_id].school_group_num = school_group_num
                agents[agent_id].activity_conn_ids = group
                push!(school.teacher_ids, agent_id)
                # agents[agent_id].school_group_id = group_id
            end
            num_working_agents -= groups_size
        end
    end

    for college_id in 1:num_colleges
        college = colleges[college_id]
        for school_group_num in 1:size(college.groups, 1)
            groups = college.groups[school_group_num]
            groups_size = size(groups, 1)
            for group_id in 1:groups_size
                group = groups[group_id]
                searching = true
                agent_id = 1
                while searching
                    agent_id = rand(1:num_agents)
                    if agents[agent_id].activity_type == 4 && agents[agent_id].age >= 25
                        searching = false
                    end
                end

                push!(group, agent_id)
                agents[agent_id].activity_type = 3
                agents[agent_id].is_teacher = true
                agents[agent_id].school_id = college_id
                agents[agent_id].school_group_num = school_group_num
                agents[agent_id].activity_conn_ids = group
                push!(college.teacher_ids, agent_id)
                # agents[agent_id].school_group_id = group_id
            end
            num_working_agents -= groups_size
        end
    end

    # --------------------------TBD ZONE-----------------------------------

    # for shop_id in 1:num_shops
    #     shop = shops[shop_id]
    #     for i in 1:length(shop.worker_ids)
    #         if shop.worker_ids[i] == 0
    #             searching = true
    #             agent_id = 1
    #             while searching
    #                 agent_id = rand(1:num_agents)
    #                 if agents[agent_id].activity_type == 4
    #                     searching = false
    #                 end
    #             end
    #             shop.worker_ids[i] = agent_id
    #             agents[agent_id].activity_type = 5
    #         end
    #     end
    #     num_working_agents -= length(shop.worker_ids)
    # end

    # for restaurant_id in 1:num_restaurants
    #     restaurant = restaurants[restaurant_id]
    #     for i in 1:length(restaurant.worker_ids)
    #         if restaurant.worker_ids[i] == 0
    #             searching = true
    #             agent_id = 1
    #             while searching
    #                 agent_id = rand(1:num_agents)
    #                 if agents[agent_id].activity_type == 4
    #                     searching = false
    #                 end
    #             end
    #             restaurant.worker_ids[i] = agent_id
    #             agents[agent_id].activity_type = 6
    #         end
    #     end
    #     num_working_agents -= length(restaurant.worker_ids)
    # end

    # -------------------------------------------------------------

    start_agent_id = 1
    while num_working_agents > 0
        # num_workers = sample_from_zipf_distribution(zipf_parameter, firm_max_size)
        num_workers = round(Int, rand(truncated(LogNormal(1.3, 1.7), firm_min_size, firm_max_size)))
        if num_workers < 1
            num_workers = 1
        end
        if num_working_agents - num_workers < 0
            num_workers = num_working_agents
        end

        agent_ids = Array{Int, 1}(undef, num_workers)
        j = 0
        for agent_id in start_agent_id:num_agents
            agent = agents[agent_id]
            if agent.activity_type == 4 && agent.workplace_id == 0
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
        for college_id in start_college_ids[thread_id]:end_college_ids[thread_id]
            college = colleges[college_id]
            for i = 1:6
                for j = 1:4:length(college.groups[i])
                    if size(college.groups[i], 1) - j >= 4
                        group1 = college.groups[i][j]
                        group2 = college.groups[i][j + 1]
                        group3 = college.groups[i][j + 2]
                        group4 = college.groups[i][j + 3]
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

        for workplace_id in start_workplace_ids[thread_id]:end_workplace_ids[thread_id]
            generate_barabasi_albert_network(
                agents, workplaces[workplace_id].agent_ids, num_barabasi_albert_attachments, thread_rng[thread_id])
        end
    end
end

# --------------------------TBD ZONE-----------------------------------

# function get_similarity_between_agents(
#     agent1::Agent,
#     agent2::Agent,
# )::Float64
#     if (agent1.age < 18 || agent2.age < 18) && abs(agent1.age - agent2.age > 5)
#         return 0.0
#     elseif abs(agent1.age - agent2.age > 45)
#         return 0.0
#     elseif agent1.age < 18 || agent2.age < 18
#         sex_multiplier = 1.0
#         if agent1.is_male != agent2.is_male
#             sex_multiplier = 0.5
#         end
#         return 1.0 - (sex_multiplier * abs(agent1.age - agent2.age) / 5)
#     else
#         sex_multiplier = 1.0
#         if agent1.is_male != agent2.is_male
#             sex_multiplier = 0.5
#         end
#         return 1.0 - (sex_multiplier * abs(agent1.age - agent2.age) / 45)
#     end
# end

# -------------------------------------------------------------

# Создание графа Барабаши-Альберта
# На вход подаются группа с набором агентов (group) и число минимальных связей, которые должен иметь агент (m)
function generate_barabasi_albert_network(agents::Vector{Agent}, agent_ids::Vector{Int}, m::Int, rng::MersenneTwister)
    if length(agent_ids) < m
        m = length(agent_ids)
    end
    # Связный граф с m вершинами
    for i = 1:m
        for j = (i + 1):m
            push!(agents[agent_ids[i]].activity_conn_ids, agent_ids[j])
            push!(agents[agent_ids[j]].activity_conn_ids, agent_ids[i])
        end
    end
    # Сумма связей всех вершин
    degree_sum = m * (m - 1)
    # Добавление новых вершин
    for i = (m + 1):length(agent_ids)
        agent = agents[agent_ids[i]]
        degree_sum_temp = degree_sum
        for _ = 1:m
            cumulative = 0.0
            rand_num = rand(rng, Float64)
            for j = 1:(i - 1)
                if agent_ids[j] in agent.activity_conn_ids
                    continue
                end
                agent2 = agents[agent_ids[j]]
                cumulative += length(agent2.activity_conn_ids) / degree_sum_temp
                if rand_num < cumulative
                    degree_sum_temp -= length(agent2.activity_conn_ids)
                    push!(agent.activity_conn_ids, agent2.id)
                    push!(agent2.activity_conn_ids, agent.id)
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
