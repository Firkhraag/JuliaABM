function get_stats(agents::Vector{Agent})
    println("Stats...")
    age_groups_nums = zeros(Int, 90)
    age_groups_nums_P1 = zeros(Int, 90)
    age_groups_nums_PWOP2P0C = zeros(Int, 90)
    age_groups_nums_PWOP3P0C = zeros(Int, 90)
    age_groups_nums_PWOP3P1C = zeros(Int, 90)
    age_groups_nums_PWOP4P0C = zeros(Int, 90)
    age_groups_nums_PWOP4P1C = zeros(Int, 90)
    age_groups_nums_PWOP4P2C = zeros(Int, 90)
    age_groups_nums_PWOP5P0C = zeros(Int, 90)
    age_groups_nums_PWOP5P1C = zeros(Int, 90)
    age_groups_nums_PWOP5P2C = zeros(Int, 90)
    age_groups_nums_PWOP5P3C = zeros(Int, 90)
    age_groups_nums_PWOP6P0C = zeros(Int, 90)
    age_groups_nums_PWOP6P1C = zeros(Int, 90)
    age_groups_nums_PWOP6P2C = zeros(Int, 90)
    age_groups_nums_PWOP6P3C = zeros(Int, 90)
    age_groups_nums_2PWOP4P0C = zeros(Int, 90)
    age_groups_nums_2PWOP5P0C = zeros(Int, 90)
    age_groups_nums_2PWOP5P1C = zeros(Int, 90)
    age_groups_nums_2PWOP6P0C = zeros(Int, 90)
    age_groups_nums_2PWOP6P1C = zeros(Int, 90)
    age_groups_nums_2PWOP6P2C = zeros(Int, 90)

    age_groups_nums_O2P0C = zeros(Int, 90)
    age_groups_nums_O2P1C = zeros(Int, 90)
    age_groups_nums_O3P0C = zeros(Int, 90)
    age_groups_nums_O3P1C = zeros(Int, 90)
    age_groups_nums_O3P2C = zeros(Int, 90)
    age_groups_nums_O4P0C = zeros(Int, 90)
    age_groups_nums_O4P1C = zeros(Int, 90)
    age_groups_nums_O4P2C = zeros(Int, 90)
    age_groups_nums_O5P0C = zeros(Int, 90)
    age_groups_nums_O5P1C = zeros(Int, 90)
    age_groups_nums_O5P2C = zeros(Int, 90)

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

    t1 = 0
    t2 = 0
    t3 = 0
    for agent in agents

        if agent.age >= 18 && agent.collective_id == 1
            t1 += 1
        elseif agent.age >= 20 && agent.collective_id == 2
            t2 += 1
        elseif agent.age >= 25 && agent.collective_id == 3
            t3 += 1
        end

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

        if agent.household_type == "1P"
            age_groups_nums_P1[agent.age + 1] += 1
        elseif agent.household_type == "PWOP2P0C"
            age_groups_nums_PWOP2P0C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP3P0C"
            age_groups_nums_PWOP3P0C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP3P1C"
            age_groups_nums_PWOP3P1C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP4P0C"
            age_groups_nums_PWOP4P0C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP4P1C"
            age_groups_nums_PWOP4P1C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP4P2C"
            age_groups_nums_PWOP4P2C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP5P0C"
            age_groups_nums_PWOP5P0C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP5P1C"
            age_groups_nums_PWOP5P1C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP5P2C"
            age_groups_nums_PWOP5P2C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP5P3C"
            age_groups_nums_PWOP5P3C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP6P0C"
            age_groups_nums_PWOP6P0C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP6P1C"
            age_groups_nums_PWOP6P1C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP6P2C"
            age_groups_nums_PWOP6P2C[agent.age + 1] += 1
        elseif agent.household_type == "PWOP6P3C"
            age_groups_nums_PWOP6P3C[agent.age + 1] += 1
        elseif agent.household_type == "2PWOP4P0C"
            age_groups_nums_2PWOP4P0C[agent.age + 1] += 1
        elseif agent.household_type == "2PWOP5P0C"
            age_groups_nums_2PWOP5P0C[agent.age + 1] += 1
        elseif agent.household_type == "2PWOP5P1C"
            age_groups_nums_2PWOP5P1C[agent.age + 1] += 1
        elseif agent.household_type == "2PWOP6P0C"
            age_groups_nums_2PWOP6P0C[agent.age + 1] += 1
        elseif agent.household_type == "2PWOP6P1C"
            age_groups_nums_2PWOP6P1C[agent.age + 1] += 1
        elseif agent.household_type == "2PWOP6P2C"
            age_groups_nums_2PWOP6P2C[agent.age + 1] += 1
        elseif agent.household_type == "O2P0C"
            age_groups_nums_O2P0C[agent.age + 1] += 1
        elseif agent.household_type == "O2P1C"
            age_groups_nums_O2P1C[agent.age + 1] += 1
        elseif agent.household_type == "O3P0C"
            age_groups_nums_O3P0C[agent.age + 1] += 1
        elseif agent.household_type == "O3P1C"
            age_groups_nums_O3P1C[agent.age + 1] += 1
        elseif agent.household_type == "O3P2C"
            age_groups_nums_O3P2C[agent.age + 1] += 1
        elseif agent.household_type == "O4P0C"
            age_groups_nums_O4P0C[agent.age + 1] += 1
        elseif agent.household_type == "O4P1C"
            age_groups_nums_O4P1C[agent.age + 1] += 1
        elseif agent.household_type == "O4P2C"
            age_groups_nums_O4P2C[agent.age + 1] += 1
        elseif agent.household_type == "O5P0C"
            age_groups_nums_O5P0C[agent.age + 1] += 1
        elseif agent.household_type == "O5P1C"
            age_groups_nums_O5P1C[agent.age + 1] += 1
        elseif agent.household_type == "O5P2C"
            age_groups_nums_O5P2C[agent.age + 1] += 1
        end

    
        if agent.collective_id == 1
            collective_nums[1] += 1
            mean_num_of_kinder_conn += size(agent.collective_conn_ids, 1)
            size_kinder_conn += 1
        elseif agent.collective_id == 2
            collective_nums[2] += 1
            mean_num_of_school_conn += size(agent.collective_conn_ids, 1)
            size_school_conn += 1
        elseif agent.collective_id == 3
            collective_nums[3] += 1
            mean_num_of_univer_conn += size(agent.collective_conn_ids, 1)
            mean_num_of_univer_cross_conn += size(agent.collective_cross_conn_ids, 1)
            size_univer_conn += 1
        elseif agent.collective_id == 4
            collective_nums[4] += 1
            mean_num_of_work_conn += size(agent.collective_conn_ids, 1)
            size_work_conn += 1
        end

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

    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_P1.csv"), age_groups_nums_P1, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP2P0C.csv"), age_groups_nums_PWOP2P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP3P0C.csv"), age_groups_nums_PWOP3P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP3P1C.csv"), age_groups_nums_PWOP3P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP4P0C.csv"), age_groups_nums_PWOP4P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP4P1C.csv"), age_groups_nums_PWOP4P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP4P2C.csv"), age_groups_nums_PWOP4P2C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP5P0C.csv"), age_groups_nums_PWOP5P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP5P1C.csv"), age_groups_nums_PWOP5P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP5P2C.csv"), age_groups_nums_PWOP5P2C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP5P3C.csv"), age_groups_nums_PWOP5P3C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP6P0C.csv"), age_groups_nums_PWOP6P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP6P1C.csv"), age_groups_nums_PWOP6P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP6P2C.csv"), age_groups_nums_PWOP6P2C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_PWOP6P3C.csv"), age_groups_nums_PWOP6P3C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP4P0C.csv"), age_groups_nums_2PWOP4P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP5P0C.csv"), age_groups_nums_2PWOP5P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP5P1C.csv"), age_groups_nums_2PWOP5P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP6P0C.csv"), age_groups_nums_2PWOP6P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP6P1C.csv"), age_groups_nums_2PWOP6P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_2PWOP6P2C.csv"), age_groups_nums_2PWOP6P2C, ',')

    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O2P0C.csv"), age_groups_nums_O2P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O2P1C.csv"), age_groups_nums_O2P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O3P0C.csv"), age_groups_nums_O3P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O3P1C.csv"), age_groups_nums_O3P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O3P2C.csv"), age_groups_nums_O3P2C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O4P0C.csv"), age_groups_nums_O4P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O4P1C.csv"), age_groups_nums_O4P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O4P2C.csv"), age_groups_nums_O4P2C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O5P0C.csv"), age_groups_nums_O5P0C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O5P1C.csv"), age_groups_nums_O5P1C, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age", "age_groups_nums_O5P2C.csv"), age_groups_nums_O5P2C, ',')


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
end
