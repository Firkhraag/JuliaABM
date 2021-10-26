function get_stats(agents::Vector{Agent})
    println("Stats...")
    age_groups_nums = zeros(Int, 90)

    age_groups_nums_1 = zeros(Int, 90)
    age_groups_nums_2 = zeros(Int, 90)
    age_groups_nums_3 = zeros(Int, 90)
    age_groups_nums_4 = zeros(Int, 90)
    age_groups_nums_5 = zeros(Int, 90)

    collective_nums = Int[0, 0, 0, 0]
    household_nums = Int[0, 0, 0, 0, 0, 0]
    mean_ig_level = 0.0
    num_of_infected = 0
    num_of_immune = 0
    num_of_isolated = 0
    num_of_parent_leave = 0
    mean_num_of_kinder_conn = 0
    mean_num_of_school_conn = 0
    mean_num_of_univer_conn = 0
    mean_num_of_univer_cross_conn = 0
    mean_num_of_work_conn = 0
    size_kinder_conn = 0
    size_school_conn = 0
    size_univer_conn = 0
    size_work_conn = 0

    mean_num_of_friend_conn = 0

    t1 = 0
    t2 = 0
    t3 = 0

    for agent in agents

        age_groups_nums[agent.age + 1] += 1
        
        if length(agent.household_conn_ids) == 1
            age_groups_nums_1[agent.age + 1] += 1
        elseif length(agent.household_conn_ids) == 2
            age_groups_nums_2[agent.age + 1] += 1
        elseif length(agent.household_conn_ids) == 3
            age_groups_nums_3[agent.age + 1] += 1
        elseif length(agent.household_conn_ids) == 4
            age_groups_nums_4[agent.age + 1] += 1
        elseif length(agent.household_conn_ids) == 5 || length(agent.household_conn_ids) == 6
            age_groups_nums_5[agent.age + 1] += 1
        end
    
        if agent.activity_type == 1
            collective_nums[1] += 1
            mean_num_of_kinder_conn += size(agent.school_conn_ids, 1)
            size_kinder_conn += 1
            if agent.is_teacher
                t1 += 1
            end
        elseif agent.activity_type == 2
            collective_nums[2] += 1
            mean_num_of_school_conn += size(agent.school_conn_ids, 1)
            size_school_conn += 1
            if agent.is_teacher
                t2 += 1
            end
        elseif agent.activity_type == 3
            collective_nums[3] += 1
            mean_num_of_univer_conn += size(agent.school_conn_ids, 1)
            mean_num_of_univer_cross_conn += size(agent.school_cross_conn_ids, 1)
            size_univer_conn += 1
            if agent.is_teacher
                t3 += 1
            end
        elseif agent.activity_type == 4
            collective_nums[4] += 1
            mean_num_of_work_conn += size(agent.workplace_conn_ids, 1)
            size_work_conn += 1
        end

        mean_num_of_friend_conn += length(agent.friend_conn_ids)

        household_nums[size(agent.household_conn_ids, 1)] += 1

        mean_ig_level += agent.ig_level

        if agent.virus_id != 0
            num_of_infected += 1
        end
        if agent.days_immune != 0
            num_of_immune += 1
        end
        if agent.is_isolated
            num_of_isolated += 1
        end
        if agent.on_parent_leave
            num_of_parent_leave += 1
        end
    end
    for i = 1:6
        household_nums[i] /= i
    end

    # println("Age groups:")
    # for i = 0:17
    #     sum = 0
    #     sum += age_groups_nums[5 * i + 1]
    #     sum += age_groups_nums[5 * i + 2]
    #     sum += age_groups_nums[5 * i + 3]
    #     sum += age_groups_nums[5 * i + 4]
    #     sum += age_groups_nums[5 * i + 5]
    #     println("$(5 * i): $(sum)")
    # end

    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums.csv"), age_groups_nums, ',')


    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_1.csv"), age_groups_nums_1, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2.csv"), age_groups_nums_2, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_3.csv"), age_groups_nums_3, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_4.csv"), age_groups_nums_4, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_5.csv"), age_groups_nums_5, ',')

    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age_distribution.csv"), age_groups_nums, ',')
    # writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "household_size_distribution.csv"), household_nums, ',')

    # println("Age groups:")
    # for i = 1:90
    #     println("$(i - 1): $(age_groups_nums[i])")
    # end

    # println("N1: $(n1)")
    # println("N2: $(n2)")

    println("Teachers 1: $(t1)")
    println("Teachers 2: $(t2)")
    println("Teachers 3: $(t3)")
    println("Collectives: $(collective_nums)")
    println("Households: $(household_nums)")
    println("Contacts: $(2 * (household_nums[2] + 3 * household_nums[3] + 6 * household_nums[4] + 10 * household_nums[5] + 15 * household_nums[6]))")
    println("Ig level: $(mean_ig_level / size(agents, 1))")
    println("Infected: $(num_of_infected)")
    println("Kinder conn: $(mean_num_of_kinder_conn / size_kinder_conn)")
    println("School conn: $(mean_num_of_school_conn / size_school_conn)")
    println("Univer conn: $(mean_num_of_univer_conn / size_univer_conn)")
    println("Univer cross conn: $(mean_num_of_univer_cross_conn / size_univer_conn)")
    println("Work conn: $(mean_num_of_work_conn / size_work_conn)")
    println("Friends conn: $(mean_num_of_friend_conn / num_agents)")
end
