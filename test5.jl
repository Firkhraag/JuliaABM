# using Random

# function sample_from_zipf_distribution(s::Float64, N::Int)
#     cumulative = 0.0
#     rand_num = rand(Float64)
#     num = 0
#     multiplier = 1 / sum((1:N).^(-s))
#     for i = 1:N
#         cumulative += i^(-s) * multiplier
#         println(i^(-s) * multiplier)
#         # if rand_num < cumulative
#         #     return i
#         # end
#     end
#     return N
# end

# sample_from_zipf_distribution(1.065, 100)

a = zeros(Float64, 2, 3, 4)
# println(a[2][3][4])
println(a[2, 3, 4])

# @time for i = 1:1000 sample_from_zipf_distribution(1.065, 2000) end
# @time for i = 1:1000 rand(1:2000) end

# struct Agent
#     id::Int
#     work_conn_ids::Vector{Int}

#     function Agent(id::Int, work_conn_ids::Vector{Int})
#         new(id, work_conn_ids)
#     end
# end

# struct Group
#     agent_ids::Vector{Int}

#     function Group(agent_ids::Vector{Int})
#         new(agent_ids)
#     end
# end


# all_agents = Agent[Agent(1, Int[]), Agent(2, Int[]), Agent(3, Int[]), Agent(4, Int[]), Agent(5, Int[]), Agent(6, Int[]), Agent(7, Int[])]
# group = Group(Int[1, 2, 3, 4, 5, 6, 7])

# # Создание графа Барабаши-Альберта
# # На вход подаются группа с набором агентов (group) и число минимальных связей, которые должен иметь агент (m)
# function generate_barabasi_albert_network(all_agents::Vector{Agent}, group::Group, m::Int)
#     # Связный граф с m вершинами
#     for i = 1:m
#         for j = 1:m
#             if i != j
#                 push!(all_agents[group.agent_ids[i]].work_conn_ids, all_agents[group.agent_ids[j]].id)
#             end
#         end
#     end
#     # Сумма связей всех вершин
#     degree_sum = m * (m - 1)
#     # Добавление новых вершин
#     for i = (m + 1):size(group.agent_ids, 1)
#         println("I: $i")
#         agent = all_agents[group.agent_ids[i]]
#         degree_sum_temp = degree_sum
#         for k = 1:m
#             println("K: $k")
#             println("degree_sum_temp: $degree_sum_temp")
#             cumulative = 0.0
#             rand_num = rand(Float64)
#             for j = 1:(i-1)
#                 println("J: $j")
#                 if j in agent.work_conn_ids
#                     continue
#                 end
#                 agent2 = all_agents[group.agent_ids[j]]
#                 cumulative += size(agent2.work_conn_ids, 1) / degree_sum_temp
#                 println(cumulative)
#                 if rand_num < cumulative
#                     degree_sum_temp -= size(agent2.work_conn_ids, 1)
#                     push!(agent.work_conn_ids, agent2.id)
#                     push!(agent2.work_conn_ids, agent.id)
#                     break
#                 end
#             end
#         end
#         degree_sum += 2m

#         # added_conn = 0
#         # # Новая вершина должна иметь m связей
#         # while (added_conn < m)
#         #     for j = 1:i
#         #         agent2 = all_agents[group.agent_ids[j]]
#         #         p = size(agent2.work_conn_ids, 1) / degree_sum
#         #         if rand(Float64) < p
#         #             push!(agent.work_conn_ids, agent2.id)
#         #             push!(agent2.work_conn_ids, agent.id)
#         #             added_conn += 1
#         #             if added_conn == m
#         #                 break
#         #             end
#         #         end
#         #     end
#         # end
#         # degree_sum += m
#     end
# end

# generate_barabasi_albert_network(all_agents, group, 3)
# for a in all_agents
#     println(size(a.work_conn_ids, 1))
# end



# struct Group
#     c::Int
#     function Group(c::Int)
#         new(c)
#     end
# end

# groups = Group[]

# struct T1
#     a::Int
#     tt1::Vector{T1}

#     function T1(a::Int)
#         new(a, T1[])
#     end
# end

# function main1()

#     arr = T1[]

#     for i = 1:10000
#         t = T1(i)
#         if i > 1
#             for j = 1:(i - 1)
#                 push!(t.tt1, arr[j])
#             end
#         end
#         push!(arr, t)
#     end

# end

# struct T2
#     id::Int
#     a::Int
#     tt1::Vector{Int}
#     group::Group

#     function T2(a::Int, group::Group)
#         new(a, a, Int[], group)
#     end
# end

# struct T22
#     id::Int
#     a::Int
#     tt1::Vector{Int}
#     group_id::Int

#     function T22(a::Int, group_id::Int)
#         new(a, a, Int[], group_id)
#     end
# end

# function main2()

#     arr = T2[]

#     for i = 1:10000
#         t = T2(i, Group(i))
#         if i > 1
#             for j = 1:(i - 1)
#                 push!(t.tt1, arr[j].id)
#             end
#         end
#         push!(arr, t)
#     end

# end

# function main22()

#     arr = T22[]

#     k = 1
#     for i = 1:10000
#         g = Group(k)
#         k += 1
#         push!(groups, g)
#         t = T22(i, g.c)
#         if i > 1
#             for j = 1:(i - 1)
#                 push!(t.tt1, arr[j].id)
#             end
#         end
#         push!(arr, t)
#     end

# end

# @time main2()
# @time main22()
