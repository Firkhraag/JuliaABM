module Model
    using Plots
    using MPI
    
    include("collective.jl")

    function create_agent(
        viruses::Dict{String, Virus},
        viral_loads::Array{Float64, 4},
        household::Group,
        index::Int,
        districts_age_sex::Vector{Vector{Int}},
        district_households::Vector{Vector{Int}},
        district_household_index::Int,
        is_male::Union{Bool, Nothing} = nothing,
        is_child::Bool = false,
        parent_age::Union{Int, Nothing} = nothing,
        is_older::Bool = false,
        is_parent_of_parent::Bool = false
    ):: Agent
        age_rand_num = rand(1:100)
        sex_random_num = rand(1:100)
        if is_child
            if parent_age < 23
                # M0–4
                return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][1], rand(0:(parent_age - 18)))
            elseif parent_age < 28
                # T0-4_0–9
                if (age_rand_num <= districts_age_sex[index][19])
                    # M0–4
                    Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][1], rand(0:4))
                else
                    # M5–9
                    Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][2], rand(5:(parent_age - 18)))
                end
            elseif parent_age < 33
                # T0-4_0–14
                if (age_rand_num <= districts_age_sex[index][20])
                    # M0–4
                    Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][1], rand(0:4))
                # T0-9_0–14
                elseif (age_rand_num <= districts_age_sex[index][21])
                    # M5–9
                    Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][2], rand(5:9))
                else
                    # M10–14
                    Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][3], rand(10:(parent_age - 18)))
                end
            elseif parent_age < 35
                age_group_rand_num = rand(1:100)
                if age_group_rand_num <= district_households[1][district_household_index]
                    # T0-4_0–14
                    if (age_rand_num <= districts_age_sex[index][20])
                        # M0–4
                        Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][1], rand(0:4))
                    # T0-9_0–14
                    elseif (age_rand_num <= districts_age_sex[index][21])
                        # M5–9
                        Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][2], rand(5:9))
                    else
                        # M10–14
                        Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][3], rand(10:14))
                    end
                else
                    # M15–19
                    return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][4], rand(15:(parent_age - 18)))
                end
            else
                age_group_rand_num = rand(1:100)
                if age_group_rand_num <= district_households[1][district_household_index]
                    # T0-4_0–14
                    if (age_rand_num <= districts_age_sex[index][20])
                        # M0–4
                        Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][1], rand(0:4))
                    # T0-9_0–14
                    elseif (age_rand_num <= districts_age_sex[index][21])
                        # M5–9
                        Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][2], rand(5:9))
                    else
                        # M10–14
                        Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][3], rand(10:14))
                    end
                else
                    # M15–19
                    return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][4], rand(15:17))
                end
            end
        else
            age_group_rand_num = rand(1:100)
            if is_older
                age_group_rand_num = rand((district_households[3][district_household_index] + 1):100)
            elseif parent_age !== nothing
                if parent_age < 45
                    age_group_rand_num = 1
                elseif parent_age < 55
                    age_group_rand_num = rand(1:district_households[3][district_household_index])
                elseif parent_age < 65
                    age_group_rand_num = rand(1:district_households[4][district_household_index])
                else
                    age_group_rand_num = rand(1:district_households[5][district_household_index])
                end
            elseif is_parent_of_parent
                if parent_age < 25
                    age_group_rand_num = rand((district_households[3][district_household_index] + 1):100)
                elseif parent_age < 35
                    age_group_rand_num = rand((district_households[4][district_household_index] + 1):100)
                elseif parent_age < 45
                    age_group_rand_num = rand((district_households[5][district_household_index] + 1):100)
                else
                    age_group_rand_num = 100
                end
            end
            if age_group_rand_num <= district_households[2][district_household_index]
                if is_male !== nothing
                    return Agent(viruses, viral_loads, household, is_male, rand(18:24))
                else
                    # M20–24
                    return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][5], rand(18:24))
                end
            elseif age_group_rand_num <= district_households[3][district_household_index]
                # T25-29_25–34
                if age_rand_num <= districts_age_sex[index][22]
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(25:29))
                    else
                        # M25–29
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][6], rand(25:29))
                    end
                else
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(30:34))
                    else
                        # M30–34
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][7], rand(30:34))
                    end
                end
            elseif age_group_rand_num <= district_households[4][district_household_index]
                # T35-39_35–44
                if age_rand_num <= districts_age_sex[index][23]
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(35:39))
                    else
                        # M35–39
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][8], rand(35:39))
                    end
                else
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(40:44))
                    else
                        # M40–44
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][9], rand(40:44))
                    end
                end
            elseif age_group_rand_num <= district_households[5][district_household_index]
                # T45-49_45–54
                if age_rand_num <= districts_age_sex[index][24]
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(45:49))
                    else
                        # M45–49
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][10], rand(45:49))
                    end
                else
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(50:54))
                    else
                        # M50–54
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][11], rand(50:54))
                    end
                end
            elseif age_group_rand_num <= district_households[6][district_household_index]
                # T55-59_55–64
                if age_rand_num <= districts_age_sex[index][25]
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(55:59))
                    else
                        # M55–59
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][12], rand(55:59))
                    end
                else
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(60:64))
                    else
                        # M60–64
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][13], rand(60:64))
                    end
                end
            else
                # T65-69_65–89
                if age_rand_num <= districts_age_sex[index][26]
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(65:69))
                    else
                        # M65–69
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][14], rand(65:69))
                    end
                # T65-74_65–89
                elseif age_rand_num <= districts_age_sex[index][27]
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(70:74))
                    else
                        # M70–74
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][15], rand(70:74))
                    end
                # T65-79_65–89
                elseif age_rand_num <= districts_age_sex[index][28]
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(75:79))
                    else
                        # M75–79
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][16], rand(75:79))
                    end
                # T65-84_65–89
                elseif age_rand_num <= districts_age_sex[index][29]
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(80:84))
                    else
                        # M80–84
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][17], rand(80:84))
                    end
                else
                    if is_male !== nothing
                        return Agent(viruses, viral_loads, household, is_male, rand(85:89))
                    else
                        # M85–89
                        return Agent(viruses, viral_loads, household, sex_random_num <= districts_age_sex[index][18], rand(85:89))
                    end
                end
            end
        end
    end

    function create_spouse(
        viruses::Dict{String, Virus},
        viral_loads::Array{Float64, 4},
        household::Group,
        partner_age::Int
    )
        rand_num = rand(1:100)
        difference = 0
        if rand_num <= 3
            difference = rand(-20:-15)
        elseif rand_num <= 8
            difference = rand(-14:-10)
        elseif rand_num <= 20
            difference = rand(-9:-6)
        elseif rand_num <= 33
            difference = rand(-5:-4)
        elseif rand_num <= 53
            difference = rand(-3:-2)
        elseif rand_num <= 86
            difference = rand(-1:1)
        elseif rand_num <= 93
            difference = rand(2:3)
        elseif rand_num <= 96
            difference = rand(4:5)
        elseif rand_num <= 98
            difference = rand(6:9)
        else
            difference = rand(10:14)
        end

        spouse_age = partner_age + difference
        if spouse_age < 18
            spouse_age = 18
        elseif spouse_age > 89
            spouse_age = 89
        end
        return Agent(viruses, viral_loads, household, false, spouse_age)
    end

    function check_parent_leave(no_one_at_home::Bool, adult::Agent, child::Agent)
        if no_one_at_home && child.age < 14
            push!(adult.dependants, child)
            child.supporter = adult
            if child.age < 3 && child.social_status == 0
                adult.social_status == 0
            end
        end
    end

    function create_parents_with_children(
        viruses::Dict{String, Virus},
        viral_loads::Array{Float64, 4},
        household::Group,
        districts_age_sex::Vector{Vector{Int}},
        district_households::Vector{Vector{Int}},
        district_household_index::Int,
        num_of_children::Int,
        num_of_other_people::Int,
        index::Int
    )::Vector{Agent}
        agent_male = create_agent(
            viruses, viral_loads, household, index,
            districts_age_sex, district_households,
            district_household_index, true)
        agent_female = create_spouse(
            viruses, viral_loads, household, agent_male.age)
        if num_of_other_people == 0
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                no_one_at_home = agent_male.social_status != 0 && agent_female.social_status != 0
                check_parent_leave(no_one_at_home, agent_female, child)
                if num_of_children == 1
                    return Agent[agent_male, agent_female, child]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child2)
                if num_of_children == 2
                    return Agent[agent_male, agent_female, child, child2]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child3)
                return Agent[agent_male, agent_female, child, child2, child3]
            end
            return Agent[agent_male, agent_female]
        elseif num_of_other_people == 1
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                no_one_at_home = agent_male.social_status != 0 && agent_female.social_status != 0
                if agent_other.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, agent_female, child)
                if num_of_children == 1
                    return Agent[agent_male, agent_female, child, agent_other]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child2)
                if num_of_children == 2
                    return Agent[agent_male, agent_female, child, child2, agent_other]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child3)
                return Agent[agent_male, agent_female, child, child2, child3, agent_other]
            end
            return Agent[agent_male, agent_female, agent_other]
        elseif num_of_other_people == 2
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                no_one_at_home = agent_male.social_status != 0 && agent_female.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, agent_female, child)
                if num_of_children == 1
                    return Agent[agent_male, agent_female, child, agent_other, agent_other2]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child2)
                if num_of_children == 2
                    return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child3)
                return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2]
            end
            return Agent[agent_male, agent_female, agent_other, agent_other2]
        elseif num_of_other_people == 3
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other3 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                no_one_at_home = agent_male.social_status != 0 && agent_female.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0 || agent_other3.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, agent_female, child)
                if num_of_children == 1
                    return Agent[agent_male, agent_female, child, agent_other, agent_other2, agent_other3]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child2)
                if num_of_children == 2
                    return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2, agent_other3]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child3)
                return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2, agent_other3]
            end
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
        else
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other3 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other4 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                no_one_at_home = agent_male.social_status != 0 && agent_female.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0 ||
                    agent_other3.social_status == 0 || agent_other4.social_status
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, agent_female, child)
                if num_of_children == 1
                    return Agent[agent_male, agent_female, child, agent_other, agent_other2, agent_other3, agent_other4]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child2)
                if num_of_children == 2
                    return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, agent_female.age)
                check_parent_leave(no_one_at_home, agent_female, child3)
                return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
            end
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4]
        end
    end

    function create_parent_with_children(
        viruses::Dict{String, Virus},
        viral_loads::Array{Float64, 4},
        household::Group,
        districts_age_sex::Vector{Vector{Int}},
        district_households::Vector{Vector{Int}},
        district_household_index::Int,
        num_of_children::Int,
        num_of_other_people::Int,
        index::Int,
        is_male_parent::Union{Bool, Nothing},
        with_parent_of_parent::Bool = false
    )::Vector{Agent}
        parent = create_agent(
            viruses, viral_loads, household, index,
            districts_age_sex, district_households,
            district_household_index, is_male_parent,
            false, nothing, num_of_other_people > 0)
        if num_of_other_people == 0
            child = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing, true, parent.age)
            no_one_at_home = parent.social_status != 0
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, child]
            end
            child2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, child, child2]
            end
            child3 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, child, child2, child3]
        elseif num_of_other_people == 1
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing, false,
                parent.age, false, with_parent_of_parent)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                no_one_at_home = parent.social_status != 0
                if agent_other.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, parent, child)
                if num_of_children == 1
                    return Agent[parent, child, agent_other]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                check_parent_leave(no_one_at_home, parent, child2)
                if num_of_children == 2
                    return Agent[parent, child, child2, agent_other]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                check_parent_leave(no_one_at_home, parent, child3)
                return Agent[parent, child, child2, child3, agent_other]
            end
            return Agent[parent, agent_other]
        elseif num_of_other_people == 2
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing, false,
                parent.age, false, with_parent_of_parent)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing,
                false, parent.age)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                no_one_at_home = parent.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, parent, child)
                if num_of_children == 1
                    return Agent[parent, child, agent_other, agent_other2]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                check_parent_leave(no_one_at_home, parent, child2)
                if num_of_children == 2
                    return Agent[parent, child, child2, agent_other, agent_other2]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                check_parent_leave(no_one_at_home, parent, child3)
                return Agent[parent, child, child2, child3, agent_other, agent_other2]
            end
            return Agent[parent, agent_other, agent_other2]
        elseif num_of_other_people == 3
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing, false,
                parent.age, false, with_parent_of_parent)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing,
                false, parent.age)
            agent_other3 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing,
                false, parent.age)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                no_one_at_home = parent.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0 || agent_other3.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, parent, child)
                if num_of_children == 1
                    return Agent[parent, child, agent_other, agent_other2, agent_other3]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                check_parent_leave(no_one_at_home, parent, child2)
                if num_of_children == 2
                    return Agent[parent, child, child2, agent_other, agent_other2, agent_other3]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                check_parent_leave(no_one_at_home, parent, child3)
                return Agent[parent, child, child2, child3, agent_other, agent_other2, agent_other3]
            end
            return Agent[parent, agent_other, agent_other2, agent_other3]
        else
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing, false,
                parent.age, false, with_parent_of_parent)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing,
                false, parent.age)
            agent_other3 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing,
                false, parent.age)
            agent_other4 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households,
                district_household_index, nothing,
                false, parent.age)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                no_one_at_home = parent.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0 ||
                    agent_other3.social_status == 0 || agent_other4.social_status
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, parent, child)
                if num_of_children == 1
                    return Agent[parent, child, agent_other, agent_other2, agent_other3, agent_other4]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                check_parent_leave(no_one_at_home, parent, child2)
                if num_of_children == 2
                    return Agent[parent, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, parent.age)
                check_parent_leave(no_one_at_home, parent, child3)
                return Agent[parent, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
            end
            return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4]
        end
    end

    function create_others(
        viruses::Dict{String, Virus},
        viral_loads::Array{Float64, 4},
        household::Group,
        districts_age_sex::Vector{Vector{Int}},
        district_households::Vector{Vector{Int}},
        district_household_index::Int,
        num_of_children::Int,
        num_of_other_people::Int,
        index::Int
    )::Vector{Agent}
        agent = create_agent(
            viruses, viral_loads, household, index,
            districts_age_sex, district_households, district_household_index)
        if num_of_other_people == 0
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                no_one_at_home = agent.social_status != 0
                check_parent_leave(no_one_at_home, agent, child)
                if num_of_children == 1
                    return Agent[agent, child]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child2)
                if num_of_children == 2
                    return Agent[agent, child, child2]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child3)
                return Agent[agent, child, child2, child3]
            end
            return Agent[agent]
        elseif num_of_other_people == 1
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                no_one_at_home = agent.social_status != 0
                if agent_other.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, agent, child)
                if num_of_children == 1
                    return Agent[agent, child, agent_other]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child2)
                if num_of_children == 2
                    return Agent[agent, child, child2, agent_other]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child3)
                return Agent[agent, child, child2, child3, agent_other]
            end
            return Agent[agent, agent_other]
        elseif num_of_other_people == 2
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                no_one_at_home = agent.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, agent, child)
                if num_of_children == 1
                    return Agent[agent, child, agent_other, agent_other2]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child2)
                if num_of_children == 2
                    return Agent[agent, child, child2, agent_other, agent_other2]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child3)
                return Agent[agent, child, child2, child3, agent_other, agent_other2]
            end
            return Agent[agent, agent_other, agent_other2]
        elseif num_of_other_people == 3
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other3 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                no_one_at_home = agent.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0 ||
                    agent_other3.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, agent, child)
                if num_of_children == 1
                    return Agent[agent, child, agent_other, agent_other2, agent_other3]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child2)
                if num_of_children == 2
                    return Agent[agent, child, child2, agent_other, agent_other2, agent_other3]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child3)
                return Agent[agent, child, child2, child3, agent_other, agent_other2, agent_other3]
            end
            return Agent[agent, agent_other, agent_other2, agent_other3]
        else
            agent_other = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other2 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other3 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            agent_other4 = create_agent(
                viruses, viral_loads, household, index,
                districts_age_sex, district_households, district_household_index)
            if num_of_children > 0
                child = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                no_one_at_home = agent.social_status != 0
                if agent_other.social_status == 0 || agent_other2.social_status == 0 ||
                    agent_other3.social_status == 0 || agent_other4.social_status == 0
                    no_one_at_home = false
                end
                check_parent_leave(no_one_at_home, agent, child)
                if num_of_children == 1
                    return Agent[agent, child, agent_other, agent_other2, agent_other3, agent_other4]
                end
                child2 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child2)
                if num_of_children == 2
                    return Agent[agent, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
                end
                child3 = create_agent(
                    viruses, viral_loads, household, index,
                    districts_age_sex, district_households,
                    district_household_index, nothing, true, 35)
                check_parent_leave(no_one_at_home, agent, child3)
                return Agent[agent, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
            end
            return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
        end
    end

    function add_agent_to_group(
        agent::Agent,
        collective::Collective,
        group_num::Int,
        group_sizes::Vector{Int},
        get_group_size
    )
        if size(collective.groups[group_num], 1) == 0
            group = Group()
            push!(collective.groups[group_num], group)
            group.collective = collective
        end
        length = size(collective.groups[group_num], 1)
        last_group = collective.groups[group_num][length]
        if size(last_group.agents, 1) == group_sizes[group_num]
            last_group = Group()
            push!(collective.groups[group_num], last_group)
            last_group.collective = collective
            group_sizes[group_num] = get_group_size(group_num)
        end
        push!(last_group.agents, agent)
        agent.group = last_group
    end

    function add_agent_to_kindergarten(
        agent::Agent,
        kindergarten::Collective,
        group_sizes::Vector{Int}
    )
        group_num = 1
        if agent.age == 1
            group_num = 2
        elseif agent.age == 2
            group_num = rand(2:3)
        elseif agent.age == 3
            group_num = rand(3:4)
        elseif agent.age == 4
            group_num = rand(4:5)
        elseif agent.age == 5
            group_num = rand(5:6)
        elseif agent.age == 6
            group_num = 6
        end
        add_agent_to_group(agent, kindergarten, group_num, group_sizes, get_kindergarten_group_size)
    end

    function add_agent_to_school(
        agent::Agent,
        school::Collective,
        group_sizes::Vector{Int}
    )
        school_group_size = 25
        group_num = 1
        if agent.age == 8
            group_num = 2
        elseif agent.age == 9
            group_num = rand(2:3)
        elseif agent.age == 10
            group_num = rand(3:4)
        elseif agent.age == 11
            group_num = rand(4:5)
        elseif agent.age == 12
            group_num = rand(5:6)
        elseif agent.age == 13
            group_num = rand(6:7)
        elseif agent.age == 14
            group_num = rand(7:8)
        elseif agent.age == 15
            group_num = rand(8:9)
        elseif agent.age == 16
            group_num = rand(9:10)
        elseif agent.age == 17
            group_num = rand(10:11)
        elseif agent.age == 18
            group_num = 11
        end
        add_agent_to_group(agent, school, group_num, group_sizes, get_school_group_size)
    end

    function add_agent_to_university(
        agent::Agent,
        university::Collective,
        group_sizes::Vector{Int}
    )
        university_group_size = 12
        group_num = 1
        if agent.age == 19
            group_num = rand(1:2)
        elseif agent.age == 20
            group_num = rand(2:3)
        elseif agent.age == 21
            group_num = rand(3:4)
        elseif agent.age == 22
            group_num = rand(4:5)
        elseif agent.age == 23
            group_num = rand(5:6)
        elseif agent.age == 24
            group_num = 6
        end
        add_agent_to_group(agent, university, group_num, group_sizes, get_university_group_size)
    end

    function add_agent_to_workplace(
        agent::Agent,
        workplace::Collective,
        group_sizes::Vector{Int}
    )
        workplace_group_size = 8
        add_agent_to_group(agent, workplace, 1, group_sizes, get_workplace_group_size)
    end

    function add_agents_to_collectives(
        all_agents::Vector{Agent},
        infected_agents::Vector{Agent},
        agents::Vector{Agent},
        kindergarten::Collective,
        kindergarten_group_sizes::Vector{Int},
        school::Collective,
        school_group_sizes::Vector{Int},
        university::Collective,
        university_group_sizes::Vector{Int},
        workplace::Collective,
        workplace_group_sizes::Vector{Int}
    )
        for agent in agents
            if agent.virus !== nothing
                push!(infected_agents, agent)
            end
            if agent.social_status == 1
                add_agent_to_kindergarten(agent, kindergarten, kindergarten_group_sizes)
            elseif agent.social_status == 2
                add_agent_to_school(agent, school, school_group_sizes)
            elseif agent.social_status == 3
                add_agent_to_university(agent, university, university_group_sizes)
            elseif agent.social_status == 4
                add_agent_to_workplace(agent, workplace, workplace_group_sizes)
            end
        end
        append!(all_agents, agents)
    end

    function create_population(
        viruses::Dict{String, Virus},
        viral_loads::Array{Float64, 4},
        comm_rank::Int,
        comm_size::Int,
        all_agents::Vector{Agent},
        infected_agents::Vector{Agent}
    )
        districts = [10702 4300 8419 1540 2016 1253 712 372 475 355 98 88 81 123 96 277 139 243 65 117 103 2941 773 591 137 189 13 17 13 20 542 257 125 28 53 546 784 50 60 117 580 216 210 256 47 47 53 55 3481 647 956 309 103 177 240 74 39 77 64;
            8912 4549 2359 2351 1114 1018 1292 201 326 308 149 40 69 115 92 150 102 201 56 76 115 1618 533 217 76 126 8 5 9 18 334 164 41 13 45 305 450 31 25 86 241 138 115 159 36 29 23 25 1531 70 297 30 4 129 94 11 38 29 36;
            9525 6484 6101 1720 1772 1541 862 255 526 433 123 50 125 188 143 251 128 225 65 96 138 3329 832 468 131 209 24 10 15 22 746 277 125 30 51 601 825 59 57 150 858 337 290 336 88 68 101 84 4007 226 1097 232 28 304 251 46 92 110 82;
            19995 4299 3393 1753 1446 1230 886 219 397 311 174 43 78 126 102 197 91 184 45 74 117 2589 920 336 147 248 14 23 11 28 615 282 94 20 62 369 698 49 37 139 444 273 184 197 50 43 34 37 2778 146 739 77 23 319 143 23 88 57 34;
            7094 3533 3625 2568 1532 1596 979 250 464 502 153 61 111 127 111 173 139 203 69 120 108 2487 975 347 133 270 12 22 17 26 508 259 69 28 75 500 872 70 64 151 428 288 188 294 77 40 52 48 2098 143 499 114 23 144 186 40 49 60 70;
            12148 6715 9465 2498 2287 1545 1211 416 539 431 159 71 117 184 146 189 167 248 93 112 113 4054 1012 1250 147 234 27 16 19 27 788 302 199 36 73 504 728 73 42 134 589 302 208 274 83 52 47 74 3312 142 553 113 12 177 192 36 45 52 58;
            12016 2985 2204 1581 1008 985 891 192 358 320 141 78 109 160 156 122 73 152 143 87 107 2101 746 241 107 178 16 14 22 20 452 239 49 19 56 313 593 38 29 125 325 211 164 217 61 51 37 62 2600 300 694 269 58 307 240 87 93 90 63;
            8028 3496 3046 1579 1717 1117 931 419 415 430 134 155 119 162 157 204 166 246 137 134 159 1982 368 313 92 125 25 5 12 13 478 91 90 19 25 379 395 53 39 98 411 127 214 178 43 48 41 31 2065 77 514 49 11 267 93 11 89 49 33;
            9658 3061 2217 941 1030 628 426 255 249 183 74 66 64 83 65 190 160 128 81 66 74 1142 472 117 62 83 16 3 6 15 283 132 27 7 23 221 268 29 22 49 238 74 131 121 35 52 27 28 1939 163 559 59 31 304 54 33 33 25 15;
            6410 3485 3591 2044 1659 934 1462 230 345 253 121 42 72 110 84 258 152 191 49 95 111 1686 467 293 76 107 27 5 4 16 312 94 69 8 31 216 335 29 19 64 296 92 93 108 24 21 17 17 1795 139 391 92 35 101 85 23 37 25 31;
            14126 6236 4977 2970 2222 2152 1573 325 681 569 221 63 149 209 194 250 111 323 84 143 163 3412 1291 483 190 369 20 17 32 39 707 407 93 28 98 587 1020 59 72 224 644 373 265 385 108 74 76 83 4195 439 962 281 98 264 292 98 142 106 81;
            12663 5303 3352 3393 1409 1630 1431 230 549 520 259 59 123 231 207 258 118 266 74 141 154 2785 1530 309 207 473 16 13 26 83 522 679 70 42 172 423 990 41 58 223 457 334 181 306 116 61 55 61 3052 677 745 402 164 234 307 148 107 129 124;
            21922 5024 2876 3879 1264 1597 1172 209 500 382 184 38 92 163 149 145 82 234 55 107 127 2289 2158 268 140 240 15 18 15 28 398 280 48 11 66 371 762 45 43 117 372 355 180 256 63 46 53 66 2405 126 628 123 18 225 182 33 72 64 57;
            7795 2584 3070 1181 1249 691 671 88 217 232 112 20 27 74 48 112 40 90 20 37 34 1227 629 305 97 217 15 6 8 30 239 141 82 19 40 197 319 29 21 80 225 101 77 101 28 23 16 21 1423 163 338 73 22 141 96 32 30 27 30;
            19413 6005 4367 2855 2004 1670 1799 274 542 474 295 35 93 182 218 207 94 293 64 161 180 2651 1050 376 139 296 23 15 24 37 494 233 75 29 69 372 723 43 30 151 351 211 172 192 66 35 37 50 2575 234 674 212 60 204 223 86 55 65 77;
            14188 4822 4036 2195 1671 1416 1245 389 656 501 294 65 106 169 169 156 264 360 91 157 166 2557 1095 348 152 238 21 14 9 42 598 322 77 30 92 319 599 38 34 116 350 198 140 165 55 49 49 49 2215 209 596 200 42 261 236 69 121 104 58;
            28487 2823 2270 1299 1061 859 663 221 340 228 111 54 87 113 82 92 48 137 37 85 71 1605 575 219 79 149 11 7 7 14 325 200 50 11 26 237 412 23 17 63 415 199 171 213 42 51 47 22 2111 133 730 111 20 399 156 32 67 64 26;
            8985 4738 3507 2450 1821 1863 1189 330 563 592 203 75 238 219 203 307 191 466 178 274 276 2361 811 265 120 204 9 12 16 26 441 239 58 24 61 435 684 66 51 172 346 266 200 269 77 38 52 56 2301 164 504 157 26 183 163 47 80 64 67;
            9280 3371 2549 1576 1006 897 771 208 273 221 139 70 77 85 112 107 79 149 59 55 92 1895 688 212 108 178 14 14 10 33 426 270 62 26 74 257 378 33 31 95 291 195 156 192 59 32 39 39 2203 151 440 70 18 198 98 19 43 25 23;
            14097 2789 1900 1597 812 963 853 152 244 251 134 17 40 100 93 86 51 125 39 85 81 1722 554 182 100 151 9 12 8 13 330 133 34 22 40 249 402 22 26 71 297 159 133 156 30 40 34 33 2695 404 574 131 118 220 108 42 58 27 35;
            6761 2836 2192 1334 1021 937 616 198 313 254 98 84 85 113 87 124 96 143 60 74 75 1860 617 255 88 159 9 9 3 23 413 223 46 23 67 303 546 34 36 97 232 170 119 148 39 39 38 34 1682 96 354 68 20 119 114 21 33 38 38;
            6948 3353 3225 2044 1653 1724 1113 380 666 579 196 67 137 222 166 232 163 372 116 191 225 2215 764 362 148 217 22 13 16 27 370 233 83 24 67 368 649 38 40 153 408 215 178 240 81 56 60 61 1506 85 331 62 16 98 143 26 29 71 72;
            10314 4510 3866 1959 1953 1291 985 353 400 339 135 101 107 131 109 220 130 237 101 125 131 2859 553 382 89 142 26 10 7 16 610 107 86 18 19 409 467 62 40 87 520 191 317 238 65 67 58 59 2528 92 820 107 14 521 145 28 103 52 36;
            7211 2077 1727 1182 869 884 617 132 327 263 65 92 103 113 75 80 45 149 29 75 118 1391 423 185 74 97 11 2 6 7 199 80 27 8 14 213 342 17 25 52 255 150 134 174 51 31 59 43 4271 533 2146 516 94 1259 398 171 454 203 144;
            6814 2995 2793 2013 1467 1550 1147 190 408 427 136 18 66 154 117 173 104 288 52 159 152 1842 707 311 112 197 18 18 18 26 369 204 57 20 42 260 517 44 33 109 312 190 128 172 46 24 23 31 1231 69 222 31 9 75 141 17 12 42 42;
            11125 4062 3015 2183 1307 1318 1196 253 454 398 205 84 106 148 171 134 91 181 103 124 140 2666 1142 286 140 294 18 15 16 29 511 416 56 54 89 394 723 31 55 120 388 264 206 251 81 50 56 73 2326 145 478 138 20 160 151 38 36 67 48;
            10798 2627 1618 1172 568 542 454 116 178 159 79 30 30 54 60 86 42 80 52 60 74 1073 438 119 53 113 6 4 3 11 288 154 49 17 52 168 281 23 12 56 177 110 73 86 32 18 13 21 1476 108 364 78 15 80 77 35 24 30 20;
            7672 2264 1668 1022 757 650 436 201 226 176 73 69 79 77 83 133 61 93 65 70 74 1039 441 146 62 161 9 4 9 17 241 156 52 26 67 188 329 25 19 93 202 159 118 132 56 41 31 32 1740 147 738 158 45 304 114 35 187 44 37;
            11564 3246 2346 1884 1088 1126 1206 221 395 420 197 54 89 140 159 163 134 305 131 169 262 1649 531 237 84 128 13 6 12 10 272 119 34 15 35 276 371 30 39 85 206 94 100 99 28 22 28 26 1652 85 470 133 29 327 144 54 77 57 40;
            11673 4350 2746 2221 993 1092 1316 142 236 325 194 37 48 102 81 114 72 141 40 55 98 2199 954 231 130 276 8 16 21 46 458 302 41 18 69 345 577 31 30 111 271 163 107 113 44 20 16 34 1727 108 267 58 20 71 83 17 17 24 22;
            24489 2987 1842 1599 698 650 763 145 223 307 113 25 45 75 77 68 67 230 37 85 152 1704 620 166 75 128 8 4 8 20 280 208 40 21 40 245 382 20 29 81 161 116 67 94 26 10 15 19 1590 156 461 92 23 224 84 22 94 32 34;
            3789 2944 2210 1996 762 907 719 103 288 237 76 10 47 109 62 113 51 213 36 116 132 1355 548 209 66 132 12 8 5 11 255 169 37 18 39 212 419 17 26 77 207 122 57 105 26 3 17 21 912 52 144 26 4 27 73 6 9 33 28;
            11462 3516 3213 1318 1462 1176 698 293 412 279 85 59 92 144 85 128 113 221 82 96 116 2332 723 269 94 176 10 15 6 15 535 303 69 27 64 353 590 42 36 112 376 189 143 179 33 39 29 27 2114 109 415 75 20 156 137 23 65 46 44;
            19887 4679 4578 2469 2544 2106 1421 553 1024 669 187 184 292 475 295 194 136 387 190 289 311 3344 1276 573 198 346 47 15 24 50 648 396 130 40 124 530 1152 67 69 215 668 413 367 500 108 104 145 153 2722 212 835 187 31 459 342 53 191 115 128;
            7407 2189 2259 1337 1099 981 672 243 431 300 109 152 159 199 180 173 131 242 184 163 206 988 426 184 61 137 9 13 5 18 224 145 64 19 38 155 324 17 23 71 272 187 148 188 60 42 32 28 1097 89 310 55 16 98 95 23 37 40 51;
            6648 2404 2037 1265 849 1052 643 107 392 281 73 7 63 106 77 118 63 242 38 121 159 1254 412 194 80 98 12 6 7 11 159 74 18 5 15 184 386 22 26 73 196 101 82 117 26 12 20 22 2356 708 765 483 171 283 335 143 132 121 93;
            13253 3387 2939 1075 1302 782 553 178 299 159 73 68 71 73 63 44 32 76 41 47 50 2824 1445 362 150 323 22 13 13 37 655 751 92 43 143 285 561 24 33 93 316 152 132 153 36 33 26 34 2065 148 347 81 15 142 123 24 37 43 37;
            2903 794 855 357 363 330 194 78 143 106 29 27 44 63 54 41 24 40 27 40 33 752 256 87 32 53 3 5 2 3 198 94 17 7 13 137 216 13 12 44 170 109 101 94 30 25 27 17 911 44 201 33 4 67 56 13 30 37 18;
            8755 2228 3028 1263 783 723 477 142 218 210 72 36 36 79 77 82 65 123 81 85 99 1688 568 377 106 194 9 8 9 15 338 218 94 15 57 416 452 36 21 81 310 164 73 106 30 15 15 19 1477 55 555 29 12 205 98 15 226 38 39;
            4315 2829 1979 1520 734 779 697 145 203 252 105 38 32 56 50 134 81 201 55 84 122 1197 384 152 67 84 2 1 6 11 236 77 18 10 18 249 332 13 13 51 231 152 68 80 21 21 22 19 1898 126 446 87 19 110 100 27 52 54 26;
            11973 6680 6301 3145 3319 2485 1733 620 1016 742 243 184 256 368 214 437 275 588 171 313 369 4074 931 700 172 228 43 15 9 25 719 181 111 22 35 570 924 82 64 171 775 297 429 435 83 80 101 106 3164 287 1026 259 23 569 461 138 223 308 182;
            3887 1555 1291 875 647 581 499 97 148 134 45 34 35 67 51 81 47 90 36 28 43 940 406 124 55 100 10 5 7 13 198 153 23 10 35 150 262 25 17 55 159 120 77 81 30 12 27 15 908 41 192 38 4 71 49 10 12 17 17;
            10389 2588 1710 1524 630 729 698 82 203 192 110 18 31 68 71 54 39 85 36 37 54 1452 727 152 83 196 7 5 6 20 305 197 31 15 36 194 322 8 27 55 228 183 71 136 29 17 30 20 1540 91 339 84 11 198 91 25 37 29 25;
            8685 4184 3568 3394 1945 1963 2174 463 639 727 321 71 140 210 194 344 264 484 165 218 361 2505 931 345 149 262 18 13 24 39 399 280 60 21 60 404 681 52 49 136 414 239 213 261 90 48 58 60 2296 195 557 206 65 204 236 69 77 74 68;
            7314 5010 2937 1611 1212 1085 834 143 359 267 94 40 72 107 102 127 41 105 25 74 73 2194 942 313 111 216 17 12 18 23 529 329 61 29 77 309 668 23 44 111 426 240 153 222 76 25 48 49 2462 144 511 98 12 123 149 26 36 46 51;
            7878 3589 2768 2296 1411 1508 1886 355 521 468 323 74 109 155 155 303 317 453 163 195 236 1648 605 255 106 159 26 9 14 28 215 101 36 8 32 271 490 71 37 103 258 145 111 157 53 27 30 32 1525 139 559 156 57 110 132 30 70 52 61;
            4364 2164 1816 991 1010 749 565 201 277 228 103 65 88 108 97 140 97 158 87 78 109 1265 433 186 69 113 11 16 8 20 255 177 47 11 22 253 328 41 34 81 265 118 152 127 29 25 29 30 1293 86 332 61 9 115 75 23 29 17 20;
            16741 6638 4242 2886 1783 2083 1442 538 777 806 304 201 296 465 401 301 319 717 708 786 1088 3222 1143 374 163 312 18 23 20 39 484 231 68 34 50 538 859 54 80 170 425 230 161 221 80 31 57 55 2207 109 413 39 10 94 151 31 57 54 65;
            6721 4680 4983 2276 2893 2335 1414 671 998 759 255 214 238 443 330 399 260 600 204 332 419 2799 897 488 152 296 48 15 15 31 603 271 99 39 66 449 1060 82 69 238 584 294 338 365 94 97 75 81 2110 134 600 91 27 349 294 42 168 76 109;
            15399 5201 4656 3172 2386 2360 1757 2196 808 909 272 84 163 284 208 500 371 345 109 143 196 3618 1527 480 200 453 20 9 35 66 802 567 86 46 141 600 1200 70 97 281 734 588 365 530 244 112 79 116 3568 675 827 360 200 762 388 254 97 105 109;
            10385 4369 3375 2242 1564 1421 1240 314 516 489 264 85 129 205 238 222 199 386 204 225 269 2676 878 311 120 255 15 9 18 41 627 321 49 28 87 407 664 43 36 126 360 174 147 175 63 36 42 47 2630 124 457 67 10 148 106 18 73 45 35;
            12027 4372 3683 1872 1784 1390 1074 318 499 358 165 88 143 169 144 154 102 199 84 126 136 2559 900 357 140 268 15 27 14 29 514 282 80 33 68 355 778 35 32 120 519 255 225 289 73 60 52 71 2777 171 783 91 22 247 149 31 82 48 60;
            7723 4166 3346 2246 1837 1542 1527 482 571 570 312 78 92 142 249 331 333 690 184 232 326 2108 726 286 128 222 14 8 14 44 391 187 56 22 41 402 522 63 48 110 272 150 132 135 50 60 24 27 1827 132 350 52 10 152 80 15 84 17 25;
            3267 1458 975 973 418 343 426 98 90 85 61 19 17 24 27 89 33 101 34 39 45 444 197 83 34 64 8 4 6 7 104 27 21 4 7 97 132 16 4 18 79 49 24 18 12 2 8 7 481 25 115 13 3 35 18 4 6 8 13;
            43891 10413 7675 3128 3638 2714 1685 506 991 619 204 106 207 318 208 539 278 388 97 202 197 4573 1978 682 337 501 41 29 34 54 1186 781 161 71 171 732 1296 87 78 220 972 456 428 493 138 89 113 90 6097 365 1203 196 39 326 307 57 68 89 93;
            4937 947 819 492 407 440 282 73 184 119 42 30 32 83 46 63 34 94 24 39 55 557 205 104 33 52 6 8 5 4 104 44 20 10 11 96 179 8 13 31 140 88 82 83 23 16 23 16 860 41 299 23 4 124 52 8 104 14 10;
            13265 4202 3742 2347 1873 1646 1125 394 557 438 161 177 173 213 155 182 110 233 76 110 125 2812 966 341 163 277 11 7 12 33 536 391 58 34 85 394 841 61 53 176 844 481 620 590 152 149 131 94 5800 547 2603 294 128 1755 284 60 465 105 56;
            8842 2710 2478 1250 1519 1042 704 262 314 212 84 137 114 141 80 137 89 116 70 87 98 1648 766 279 94 237 22 9 19 35 439 368 78 24 94 259 541 35 36 123 305 204 234 199 86 58 62 40 2320 217 788 205 85 488 204 106 384 117 89;
            19188 5716 5328 3516 2407 2381 1978 456 837 628 296 85 193 352 264 227 129 373 104 233 262 4055 1854 623 263 481 29 23 33 66 821 668 124 44 125 602 1299 61 63 226 699 416 275 426 123 65 95 103 3598 247 915 211 49 420 351 99 166 122 100;
            17559 7174 8317 5446 4703 4104 3472 762 1585 1115 617 131 373 642 497 408 297 798 225 595 558 5038 2822 1089 380 907 94 56 57 151 930 805 217 68 264 577 1704 107 88 330 866 632 364 508 183 93 101 105 4538 508 1392 448 184 531 615 167 137 220 206;
            7563 1252 1338 705 639 553 375 151 213 141 57 27 69 81 53 95 54 82 52 57 76 895 392 139 57 109 9 8 7 13 251 142 31 14 39 156 299 20 20 57 200 121 115 111 33 19 20 27 1141 73 318 61 14 101 66 16 33 35 31;
            6417 3062 2613 1576 1272 1157 730 262 513 329 109 140 169 215 116 158 127 235 126 189 167 2045 650 280 102 117 18 7 12 10 341 184 62 11 34 307 479 36 28 78 393 192 206 210 51 41 76 48 1928 123 612 152 25 342 205 59 119 107 65;
            10123 4003 3715 2234 1669 1655 857 289 489 360 86 42 79 141 97 340 178 288 60 116 114 2276 1043 337 125 243 22 8 13 23 627 377 109 29 91 514 924 58 50 150 537 272 200 237 65 43 41 34 2777 254 749 204 32 243 199 54 54 78 79;
            5898 2743 3060 1497 1996 1520 787 411 627 376 120 149 219 265 177 191 134 189 163 179 169 2126 709 317 126 164 19 16 19 19 488 279 80 35 75 365 639 52 32 152 570 346 386 390 104 107 99 86 2793 159 1110 268 37 561 355 102 137 155 89;
            6284 1836 2113 981 1392 923 528 246 386 214 85 87 119 188 120 97 57 89 95 103 92 1786 733 276 128 183 31 17 19 18 408 317 77 34 73 277 550 47 31 93 370 213 280 265 77 52 74 73 2013 156 535 169 24 346 284 55 50 80 69;
            23069 3172 2451 1259 1292 1004 641 283 401 292 139 151 179 256 199 126 90 159 73 81 96 1614 617 200 78 163 20 12 3 19 501 310 78 21 62 311 485 27 46 106 465 298 334 341 92 120 124 94 3205 480 988 293 105 528 248 91 269 100 55;
            7662 2763 2368 941 991 870 522 247 333 253 121 46 84 113 117 83 74 136 45 61 93 1704 450 216 91 149 6 10 9 18 452 187 43 24 59 323 383 35 36 82 379 191 186 164 56 72 59 35 2626 209 760 127 61 384 96 38 219 25 32;
            12830 3654 3458 1959 1668 1587 942 355 523 408 124 104 168 205 145 204 95 202 71 117 111 2063 882 259 120 200 5 9 11 26 436 333 50 25 53 390 728 38 55 136 764 433 410 492 105 99 122 85 5051 489 1562 343 82 823 315 95 143 127 73;
            26506 6786 4820 2831 2071 1840 1519 352 626 561 210 51 116 225 176 230 165 284 89 161 192 3292 1169 433 148 266 27 13 31 40 831 329 122 43 80 579 888 66 68 171 543 275 264 284 75 68 39 55 3879 237 880 129 36 393 197 45 110 63 55;
            6290 1995 1719 1043 785 886 534 157 333 295 121 44 74 120 173 91 58 178 56 94 146 1634 577 189 74 134 7 11 9 28 336 196 29 19 52 223 452 20 17 73 286 170 112 151 36 25 26 30 1938 139 365 67 20 92 92 38 38 34 39;
            6868 2691 2935 1137 1566 1010 631 300 360 255 103 130 109 121 137 180 86 84 102 71 92 2290 705 332 109 245 42 17 14 43 555 331 99 45 105 417 680 67 53 148 381 221 244 238 64 62 50 54 2257 176 621 184 50 315 228 69 109 54 50;
            14145 2988 2453 1690 1168 918 1060 259 248 240 181 80 92 91 96 116 82 120 69 66 53 1406 594 183 96 150 9 7 9 17 256 140 61 25 45 241 412 25 29 59 260 145 127 142 55 35 29 41 2052 238 580 141 63 183 115 52 135 60 41;
            7703 4509 4507 1967 2137 1953 1187 388 753 525 172 99 182 267 179 266 209 397 135 197 268 2712 815 401 151 217 23 15 20 36 539 250 79 34 64 520 889 82 70 167 622 282 332 335 79 94 85 72 2894 143 805 138 23 388 231 72 84 99 95;
            18180 4796 3507 2174 1473 1362 1226 301 353 339 176 74 57 112 99 275 146 308 79 111 159 2047 937 263 137 241 14 10 14 20 415 245 74 12 51 342 549 44 38 122 285 151 93 126 27 23 17 14 2426 172 570 150 37 231 241 84 79 109 81;
            13299 6070 6547 2927 3432 3038 1664 658 1137 939 295 136 290 425 263 588 391 790 269 383 470 3394 1056 605 182 295 31 20 16 43 655 368 115 33 90 639 1258 83 95 236 733 338 386 395 95 97 105 105 3017 224 994 234 44 411 442 94 98 175 147;
            11192 5093 4138 2818 2189 2172 1833 552 778 716 308 269 250 403 272 351 220 548 374 469 623 2716 1180 438 161 336 33 29 15 57 471 331 73 17 76 351 833 48 62 164 412 306 217 285 81 93 71 58 2304 166 693 95 16 469 194 38 307 74 70;
            7247 2417 2562 1522 1611 1548 980 320 633 503 177 81 151 212 147 190 163 376 166 255 220 1821 650 355 122 177 23 14 15 30 289 147 59 29 45 333 647 36 82 127 316 225 180 221 57 39 50 48 1415 103 298 63 10 140 185 18 31 65 49;
            3546 2341 3266 1486 2463 1544 728 872 775 488 113 377 314 360 190 381 401 471 335 437 364 1110 426 284 77 136 28 13 10 9 279 116 72 22 16 229 431 54 24 79 462 192 333 248 55 123 75 47 1883 56 794 47 17 409 142 18 119 60 51;
            7058 3024 3042 1368 1607 1304 721 281 522 347 102 72 149 179 151 99 96 180 73 107 126 2550 917 393 148 277 20 17 18 42 520 378 75 36 104 440 849 53 34 181 639 335 281 357 107 71 66 68 2449 162 623 133 32 210 227 50 67 72 78;
            5203 1814 1479 898 738 699 461 144 259 235 89 32 82 116 136 69 64 104 54 84 76 960 409 125 62 125 14 9 5 21 192 125 30 17 41 193 289 27 27 78 219 162 98 118 47 40 24 32 1007 110 364 95 29 150 108 32 25 23 22;
            4225 3309 4282 2066 3052 2116 1034 717 1076 712 157 286 376 470 251 535 520 701 388 469 467 1948 628 404 130 208 32 11 18 21 383 234 87 32 68 392 823 61 46 201 575 238 354 400 90 128 121 99 1649 116 520 81 32 248 264 36 73 106 104;
            7899 2562 3214 940 2161 856 492 407 409 209 61 173 160 180 109 223 137 189 108 147 115 1605 424 363 87 107 24 5 8 8 380 156 84 14 26 235 331 37 15 51 416 136 237 172 33 68 29 45 1559 60 445 62 13 174 107 21 64 36 31;
            7196 2722 2686 1430 1291 1155 791 237 384 352 88 60 89 124 88 104 94 200 50 123 118 2211 849 334 125 211 20 23 22 24 441 293 75 27 80 395 747 43 46 131 358 187 150 206 42 30 30 39 1777 110 292 55 15 81 155 19 25 57 47;
            4894 3263 3825 1949 2483 1884 1099 624 754 606 165 249 218 371 183 414 321 493 325 353 392 1757 591 327 121 186 23 16 16 36 411 214 68 24 67 575 761 90 58 189 514 239 284 338 89 100 78 83 1998 131 623 101 23 333 248 31 138 104 74;
            6986 3154 2578 1848 1717 1155 967 476 394 392 177 102 94 109 121 203 240 296 121 130 149 1735 675 246 80 197 14 9 10 20 301 166 44 14 43 258 437 44 32 98 265 149 132 134 33 27 18 35 1303 62 270 30 7 88 91 11 33 28 26;
            5499 3257 2803 1485 1359 1211 785 314 483 342 96 128 158 176 95 111 54 212 56 104 143 2008 548 273 101 129 16 9 7 15 254 110 42 6 27 283 538 27 36 117 355 164 359 256 43 165 75 67 2827 122 3782 112 20 2934 196 27 2973 112 56;
            7434 3446 3549 3600 1799 1571 743 302 688 353 94 116 214 225 131 132 92 264 71 145 189 2209 615 384 110 127 27 8 10 14 346 163 72 16 40 296 677 31 40 105 687 205 270 312 52 65 93 74 3269 110 13911 201 22 732 224 41 189 82 68;
            23255 7743 4587 1767 1524 1287 731 253 400 336 100 52 83 123 92 186 101 221 53 111 119 2990 2571 388 125 155 17 12 15 18 670 345 87 20 36 526 715 48 45 133 484 373 213 236 65 50 55 43 3710 138 981 83 13 267 178 36 102 83 67;
            10495 3086 2988 1230 1282 1242 670 885 1188 415 105 54 113 1149 153 114 115 234 66 123 151 1944 745 470 153 150 14 14 9 22 350 165 51 22 36 352 860 28 34 116 495 203 290 246 47 36 84 49 2837 90 4498 79 7 185 182 31 44 205 65;
            5055 3350 3680 2199 2223 2464 1353 526 832 746 201 98 197 249 200 471 251 625 139 259 309 1830 768 298 128 253 20 15 16 26 354 207 73 19 60 432 800 80 71 221 466 257 255 291 96 66 76 58 1952 146 502 94 47 209 191 33 72 59 63;
            12857 4036 6556 2984 1902 1805 979 259 663 452 139 107 123 206 186 190 123 316 69 169 166 3038 1166 670 244 852 26 7 12 46 665 410 156 32 153 656 1751 59 70 194 683 320 209 308 98 50 75 69 2851 176 2356 98 20 332 229 39 142 95 70;
            3140 1305 1145 384 558 409 190 133 173 110 31 51 50 55 47 72 68 76 43 51 40 574 175 70 25 44 3 2 8 15 210 89 20 4 20 107 144 8 8 23 126 49 52 48 13 7 9 8 764 69 164 17 6 33 21 6 5 6 7;
            10483 4519 4155 2319 1909 1435 1132 405 548 417 191 87 109 172 149 202 141 260 96 147 186 2497 904 377 167 250 25 14 12 26 582 265 107 30 67 465 636 66 52 121 445 218 278 238 63 67 45 64 2350 123 603 108 24 298 144 23 208 79 43;
            3807 1876 1568 846 782 614 446 144 178 163 72 30 41 69 64 130 76 125 53 53 73 1005 259 127 41 62 12 4 8 11 190 82 32 12 19 186 211 20 17 50 179 84 86 54 23 19 10 11 1184 54 350 35 2 94 54 9 31 10 11;
            11161 6300 4713 4263 1272 1263 957 225 419 319 512 38 78 147 113 133 99 195 50 81 96 2127 663 299 113 196 17 14 11 27 404 268 45 22 50 338 602 41 47 102 377 216 142 213 48 28 39 41 2062 82 484 63 14 145 148 14 30 53 45;
            16234 8401 7826 2324 1961 1899 1218 322 650 559 174 43 134 188 156 241 120 358 87 143 236 4745 1180 687 181 287 46 16 17 33 1001 377 142 34 74 700 1127 68 97 179 706 301 246 324 78 54 64 68 5001 384 1209 387 74 317 340 102 103 109 94;
            5106 1743 1653 924 906 668 444 247 321 236 91 129 126 197 156 90 79 127 76 129 156 1162 455 185 70 126 9 9 10 15 228 114 32 17 37 189 324 22 20 48 298 132 152 170 46 66 56 61 1186 91 338 64 10 112 102 18 74 48 33;
            6521 1648 1338 860 773 561 504 211 253 192 119 88 86 105 95 64 75 182 76 110 83 900 254 144 45 94 11 9 4 17 212 94 25 11 16 150 161 24 16 40 170 80 91 78 25 27 25 21 892 54 282 60 4 138 62 15 77 17 19;
            3549 1249 1195 643 603 510 316 133 202 152 62 23 44 65 55 90 56 129 44 72 92 829 273 137 50 79 7 3 7 11 167 112 24 10 25 159 296 13 20 59 168 106 85 87 28 16 16 13 728 38 183 19 7 73 59 12 11 22 18;
            7505 2946 2025 906 1008 669 541 256 259 192 76 101 85 75 98 155 93 132 85 92 98 1569 358 177 59 97 10 2 5 21 378 89 52 16 26 220 276 23 22 52 260 89 135 90 25 47 24 19 1407 45 269 35 5 121 77 10 80 27 17;
            9413 5139 3906 1300 1259 924 565 224 287 211 95 70 60 92 69 219 140 171 89 66 65 2146 578 221 93 118 7 7 15 14 513 167 72 24 34 375 436 49 21 73 370 149 167 136 35 47 23 35 2964 98 729 88 14 203 126 27 75 47 34;
            12293 5056 4213 2123 2203 1712 1126 610 720 509 244 263 238 254 244 329 269 269 168 211 171 2795 930 330 141 248 24 15 12 40 611 319 89 43 87 405 654 58 34 105 547 293 272 262 90 80 73 64 3333 166 743 109 10 278 143 35 97 72 50;
            5798 2189 1852 1525 811 950 704 136 276 292 111 32 58 92 110 141 90 178 46 76 122 1247 548 171 72 170 6 2 5 20 209 130 24 9 33 226 361 21 25 79 182 123 85 109 45 9 19 19 1487 136 339 129 23 128 115 43 44 39 39;
            4970 2254 2412 890 1489 725 442 249 258 179 72 72 52 68 62 210 200 115 102 54 54 1471 458 217 85 107 9 9 6 21 306 146 45 18 35 220 310 44 23 55 257 114 168 116 33 34 31 22 1373 58 261 38 8 104 82 7 40 26 20;
            10507 4951 4339 2363 2281 1762 1283 552 594 556 196 134 151 215 157 305 233 388 155 196 223 2704 935 368 178 273 34 17 18 27 548 306 74 35 54 476 752 99 62 176 498 241 249 233 62 63 51 48 2441 119 461 57 28 232 141 28 34 67 42;
            7073 3126 2324 1350 992 913 1310 297 424 414 176 90 141 190 244 131 169 305 185 307 343 1667 563 189 93 159 16 7 17 28 348 147 37 15 36 255 379 34 37 105 222 109 97 101 37 35 29 25 1343 63 246 26 12 76 67 9 19 24 26;
            5139 2625 1959 1666 771 828 1001 114 238 274 215 33 70 109 138 88 72 170 74 99 146 1341 586 164 70 157 8 6 10 12 230 127 35 18 36 198 316 24 25 63 182 112 62 73 22 17 13 20 970 50 266 43 10 80 58 5 16 18 28]
        
        districts_age_sex = [[52,51,52,50,50,50,48,48,44,46,46,45,38,38,36,32,29,22,51,34,67,55,44,54,47,26,63,81,94],
            [50,52,51,49,50,46,49,48,50,47,47,43,43,39,35,31,25,25,51,36,70,52,53,50,52,22,54,73,89],
            [51,51,50,50,49,47,48,49,47,48,48,41,38,39,36,32,27,20,53,36,68,51,50,54,46,25,60,79,92],
            [52,51,51,54,53,52,51,49,49,48,45,45,42,39,36,31,27,20,51,35,68,51,52,48,50,21,52,72,89],
            [51,50,48,48,48,45,46,45,46,45,45,42,40,37,35,29,29,23,48,33,69,52,50,51,51,22,57,76,92],
            [50,50,50,49,48,48,47,47,44,43,46,44,42,37,33,30,27,22,52,36,69,56,46,50,55,22,55,75,92],
            [52,50,51,49,49,46,48,48,48,47,44,41,41,37,34,33,27,23,52,36,69,51,51,49,51,20,53,74,91],
            [53,54,56,54,54,50,51,49,49,49,46,45,42,40,37,33,29,25,51,33,66,53,50,51,52,22,55,74,90],
            [52,50,50,51,51,51,57,59,56,52,50,46,45,43,41,37,31,25,51,34,67,48,53,52,51,23,54,73,89],
            [52,49,49,58,60,49,49,51,51,45,40,42,45,47,42,34,29,24,49,33,67,51,64,38,55,28,60,77,91],
            [51,52,54,50,51,48,50,48,48,47,45,44,43,41,34,30,27,21,52,36,69,51,54,48,53,21,53,72,89],
            [52,51,51,50,50,53,53,56,54,52,49,41,42,39,32,27,27,17,48,32,67,52,53,53,53,21,55,76,93],
            [50,53,52,56,60,53,55,54,58,55,50,44,42,41,35,29,27,17,51,36,70,49,49,58,52,27,60,78,93],
            [51,52,50,51,46,48,49,47,44,47,52,43,40,41,35,30,29,25,52,35,67,57,45,58,54,20,51,71,89],
            [52,51,51,55,53,50,50,49,51,47,44,43,42,41,38,33,30,23,52,37,71,55,55,45,54,23,56,74,90],
            [51,51,52,48,50,48,48,48,49,48,45,45,43,41,39,37,31,28,53,37,69,50,52,48,51,23,57,76,91],
            [51,50,51,48,51,58,62,63,62,59,51,46,42,39,35,29,28,19,52,36,69,52,52,56,56,22,54,74,91],
            [51,49,49,50,50,50,51,50,52,48,46,43,42,38,35,31,30,28,52,35,68,51,51,50,52,20,51,71,89],
            [51,52,51,55,51,50,50,48,49,48,46,43,41,39,37,33,30,26,53,37,69,53,53,49,50,21,52,71,87],
            [51,53,52,52,50,47,47,49,48,43,46,48,43,39,35,32,25,18,52,37,70,50,50,52,54,27,62,81,94],
            [49,48,51,49,50,47,48,47,48,47,45,43,40,40,36,31,29,23,52,36,69,52,52,51,48,24,56,74,89],
            [50,52,52,47,48,49,49,47,48,47,45,41,40,38,35,31,26,18,51,34,67,50,53,50,49,26,62,80,93],
            [52,52,52,53,53,50,50,50,50,48,46,44,41,36,34,30,29,21,52,35,67,51,50,51,52,21,54,73,90],
            [51,51,51,51,51,53,48,48,54,53,44,41,39,37,31,27,26,18,53,37,70,46,56,53,55,22,56,77,93],
            [50,52,54,49,49,49,50,50,47,46,45,43,41,38,33,29,25,20,50,35,70,53,51,50,57,23,57,77,92],
            [53,53,52,51,50,47,48,49,48,48,46,43,41,38,33,30,27,21,52,36,69,51,51,50,52,21,54,73,90],
            [52,54,52,55,55,49,50,51,51,49,48,43,42,42,37,37,32,29,51,35,69,55,53,51,51,20,52,72,88],
            [52,52,54,53,54,47,48,50,48,48,48,45,42,41,38,37,33,28,51,34,66,47,53,50,47,21,51,70,86],
            [52,52,53,46,49,49,48,48,49,46,46,44,40,40,37,32,27,23,49,33,67,53,52,49,51,21,55,75,91],
            [50,51,53,51,51,46,46,46,48,49,47,42,39,36,35,34,32,26,49,34,69,49,49,55,51,21,56,76,92],
            [52,52,54,46,52,60,61,62,61,59,52,46,39,39,34,31,26,22,51,35,68,51,53,53,51,22,54,72,88],
            [52,52,52,56,51,48,49,48,48,48,46,40,43,41,34,32,26,19,49,33,68,46,55,49,51,25,60,79,93],
            [53,51,55,60,55,51,51,50,51,48,45,43,41,40,36,33,29,24,52,34,66,50,54,47,54,21,54,73,90],
            [51,52,54,51,54,52,53,51,52,50,44,40,42,40,34,30,25,18,49,34,68,48,56,50,51,28,61,78,92],
            [51,53,55,51,52,49,51,50,51,48,47,45,46,42,40,40,36,32,53,36,68,51,52,50,52,23,56,75,90],
            [50,49,52,53,53,52,54,55,58,55,48,42,42,42,36,31,23,17,53,38,71,46,55,53,50,29,63,80,94],
            [51,52,51,50,52,48,49,48,47,47,44,42,38,40,35,33,29,24,52,35,68,50,52,50,51,22,56,75,90],
            [52,51,52,49,51,47,46,49,50,47,45,46,44,43,34,33,33,24,53,37,71,52,53,47,53,19,48,67,87],
            [51,52,52,53,53,51,52,54,50,47,46,44,40,38,35,34,27,19,52,37,71,50,53,51,53,21,55,76,91],
            [51,51,50,48,45,48,51,51,49,49,47,40,41,42,36,31,27,26,45,30,67,50,55,51,49,27,60,78,91],
            [51,52,52,51,52,51,53,52,51,49,46,41,41,41,37,32,28,20,50,34,68,49,56,49,51,28,63,80,93],
            [50,50,51,51,51,48,48,49,50,48,48,43,40,38,36,34,30,22,51,36,71,51,51,52,52,20,53,73,89],
            [49,48,46,54,47,44,48,49,51,48,47,44,40,38,33,29,24,20,51,36,71,52,55,50,55,21,55,76,92],
            [48,48,48,47,47,46,47,49,49,47,46,43,40,38,33,31,28,22,46,30,65,50,53,52,53,24,59,78,93],
            [52,53,53,50,50,50,51,50,48,46,44,42,42,41,35,33,29,25,50,35,70,53,53,50,52,24,59,77,91],
            [48,47,48,47,48,46,50,50,49,49,45,42,40,38,36,34,28,19,47,30,64,50,51,52,49,27,63,80,93],
            [49,50,47,51,53,47,47,49,47,46,45,42,42,41,36,31,29,21,51,33,65,51,53,48,55,22,55,74,91],
            [53,52,52,49,52,48,48,48,48,48,46,43,42,39,36,33,32,24,50,33,67,50,50,52,51,23,59,78,93],
            [53,52,53,51,56,52,52,53,54,50,44,42,44,44,39,35,30,25,52,36,69,46,58,47,52,30,62,79,92],
            [51,50,52,51,49,49,49,51,52,50,47,42,42,38,34,31,29,24,50,33,67,51,53,48,57,21,53,73,90],
            [50,51,51,52,50,50,51,50,52,48,46,44,41,40,36,31,30,25,49,34,69,50,52,48,53,22,53,72,88],
            [51,52,52,51,55,53,52,51,50,49,46,44,42,40,34,30,28,21,52,36,69,53,54,47,56,20,52,73,91],
            [50,50,46,48,52,46,47,46,47,47,46,45,43,40,37,39,32,29,47,31,65,52,49,50,52,21,51,71,88],
            [48,48,46,49,44,47,53,52,49,48,46,43,44,40,38,41,31,29,53,37,70,53,53,51,51,23,54,73,89],
            [52,51,51,48,51,49,47,48,48,48,48,46,45,43,42,32,25,21,52,35,68,54,47,50,52,27,68,83,94],
            [55,51,50,52,51,51,58,61,62,56,50,49,45,43,37,29,27,20,51,35,69,44,57,47,59,21,52,70,89],
            [49,48,48,50,50,47,49,49,50,49,41,44,40,35,31,27,23,18,52,36,69,50,54,41,58,20,54,74,91],
            [52,52,50,65,64,49,50,49,49,47,45,43,43,43,37,31,30,25,52,36,69,50,53,48,53,25,58,75,90],
            [52,50,51,54,53,47,48,49,47,45,44,41,42,38,33,28,25,19,51,35,69,50,55,49,56,26,59,76,92],
            [52,51,52,51,51,48,48,48,46,44,43,41,42,41,32,27,24,19,51,36,70,52,55,46,58,27,60,78,92],
            [51,52,52,51,53,49,53,53,52,52,49,44,44,39,34,28,29,21,51,35,68,48,52,52,54,22,54,74,91],
            [53,51,51,51,51,48,49,49,49,46,45,43,41,40,37,33,29,24,52,35,67,53,51,50,51,23,54,72,89],
            [52,51,53,51,47,46,48,47,47,47,45,39,45,44,37,34,31,23,45,30,66,51,51,50,52,24,57,77,92],
            [53,52,53,51,50,49,48,48,47,47,46,43,41,39,35,32,30,23,53,36,68,52,50,51,52,22,55,74,91],
            [52,51,52,51,53,50,48,49,48,46,45,42,40,40,34,30,26,22,52,36,69,52,51,46,53,23,55,73,89],
            [52,52,50,46,49,48,47,49,48,49,46,44,44,43,38,35,30,27,51,34,67,52,51,50,52,25,56,74,89],
            [53,54,54,55,51,53,51,51,51,44,50,46,43,52,37,33,30,25,53,37,69,54,48,48,50,24,54,73,89],
            [51,52,52,52,55,52,53,53,53,49,47,44,40,38,33,28,26,19,52,36,70,51,53,50,53,23,58,77,93],
            [55,54,53,52,54,51,51,56,56,55,53,48,43,39,38,36,32,25,52,35,68,51,49,49,54,21,57,77,92],
            [51,51,53,51,49,49,51,50,48,47,44,43,40,37,33,27,24,16,52,37,70,52,53,49,56,23,55,74,91],
            [47,48,48,46,49,47,47,48,46,45,43,42,42,40,38,36,30,26,50,34,68,51,51,47,50,22,53,71,87],
            [52,51,51,49,46,46,46,48,48,46,46,44,43,39,37,33,29,27,50,34,67,50,54,50,52,22,53,72,88],
            [50,51,52,49,51,49,46,48,50,47,44,42,42,44,39,35,30,23,50,34,68,42,55,51,44,31,65,80,92],
            [51,51,53,49,49,50,50,51,50,47,47,42,43,41,37,33,30,28,49,33,67,47,55,50,53,21,54,73,90],
            [52,51,51,50,50,48,48,49,50,46,43,41,41,43,40,36,30,22,51,35,68,45,57,48,49,27,62,80,93],
            [52,52,52,51,51,50,53,53,52,47,45,42,41,40,36,32,27,20,49,33,67,48,56,50,53,26,60,79,93],
            [52,49,51,49,52,50,51,51,49,48,46,40,39,39,34,30,26,17,49,32,65,51,51,53,49,25,61,80,94],
            [52,52,51,50,50,48,50,50,49,46,44,44,46,47,40,32,28,26,54,39,72,54,55,44,60,25,58,76,92],
            [50,49,50,49,50,47,47,46,46,44,41,41,39,40,33,27,24,18,53,37,70,53,53,47,52,24,56,74,90],
            [50,49,51,50,48,47,48,47,46,46,45,42,42,43,35,33,28,22,51,35,68,51,53,49,50,23,56,75,92],
            [53,54,53,50,49,46,50,51,49,47,44,42,43,43,37,35,30,21,51,35,68,49,58,47,52,28,61,78,92],
            [49,50,51,52,52,48,50,50,47,43,45,45,43,41,35,34,30,22,55,40,72,57,55,44,60,23,56,74,90],
            [52,53,53,53,51,49,49,48,48,46,43,42,39,37,34,29,25,18,53,37,70,52,51,49,53,23,57,76,91],
            [50,51,51,52,50,48,49,49,49,47,45,43,43,40,37,33,30,25,50,33,66,49,51,50,53,23,58,77,93],
            [51,49,53,49,50,48,47,46,46,47,46,42,40,38,35,32,26,21,51,34,67,53,52,53,52,23,58,77,93],
            [50,52,51,45,41,42,41,48,48,45,45,40,39,44,44,40,33,33,52,36,69,50,57,48,50,28,60,78,91],
            [52,51,52,39,39,47,45,52,49,46,46,51,40,42,37,35,30,22,50,32,63,51,52,49,58,26,59,78,93],
            [53,53,52,49,49,47,50,49,45,48,46,45,42,39,34,28,25,20,53,37,70,50,50,55,53,21,54,75,91],
            [50,39,47,48,51,43,41,46,47,47,42,33,34,37,36,32,28,23,40,26,66,45,59,49,54,25,60,78,92],
            [46,45,44,44,46,47,46,48,48,47,45,41,40,40,36,32,31,24,47,31,66,53,51,48,50,26,63,81,94],
            [54,55,49,49,49,52,55,52,46,43,41,43,42,36,32,27,19,19,47,33,70,51,54,45,47,24,59,77,94],
            [53,53,52,49,51,51,50,50,51,50,50,50,44,44,41,41,34,33,50,35,69,52,48,50,54,23,49,67,84],
            [53,53,55,52,52,49,49,48,47,46,46,44,43,41,36,36,29,23,50,33,65,52,51,49,50,24,58,77,91],
            [53,53,54,48,48,49,50,48,49,47,47,42,41,40,37,33,27,22,52,36,68,53,52,50,49,25,57,73,88],
            [51,48,50,53,53,50,50,52,51,48,48,41,43,50,42,28,25,19,54,39,72,56,52,57,33,38,68,82,94],
            [51,53,51,50,47,46,47,47,46,46,45,41,39,38,35,31,27,22,51,35,69,53,47,52,51,24,59,78,92],
            [51,48,48,44,47,44,46,47,46,44,43,42,42,41,35,29,28,20,50,34,68,51,52,49,52,24,55,73,88],
            [48,52,51,50,50,49,49,47,47,45,45,42,43,41,37,34,31,25,46,30,64,50,52,50,53,23,54,72,88],
            [51,52,52,48,47,48,49,48,48,46,47,41,43,35,35,34,29,20,51,35,68,52,52,50,54,21,54,75,91],
            [52,49,50,49,50,47,49,48,48,47,45,43,42,40,36,33,29,25,48,31,64,49,51,47,49,22,54,73,89],
            [50,51,50,49,47,49,50,47,47,48,47,44,41,38,36,34,33,30,52,36,69,51,47,53,51,21,54,74,90],
            [52,53,52,51,52,50,49,49,48,48,47,46,43,41,37,36,31,28,54,37,69,53,50,49,54,22,51,70,88],
            [49,49,54,52,49,49,48,50,47,47,45,42,41,38,36,30,27,21,52,36,70,52,52,52,51,22,55,75,91],
            [51,50,54,52,51,50,47,46,46,45,46,46,41,40,38,35,32,24,50,33,66,54,47,50,51,20,50,69,85],
            [52,51,51,52,51,47,48,47,48,46,45,43,42,40,37,32,29,22,52,35,68,52,52,48,51,23,56,75,90],
            [48,49,48,53,54,45,45,50,47,46,44,42,42,42,37,37,32,27,44,27,61,48,53,48,50,23,54,74,90],
            [52,51,52,50,52,47,46,47,49,45,45,43,40,41,37,31,28,22,56,41,73,54,54,50,52,24,57,74,89]]
        
        district_households = [[74,70,80,82,88,8,75,84,87,85,78,74,80,83,87,4,76,80,84,86,68,77,84,85,88,23,73,82,84,88,54,77,84,86,89,7,74,83,82,83,9,74,78,81,89,61,80,87,90,92,71,78,83,85,88,55,77,84,85,87,71,82,82,84,87,3,74,81,83,87,4,75,84,87,90,10,79,83,85,87,59,78,83,84,89,73,75,81,83,88,15,76,83,83,87,76,80,86,85,89,77,78,83,85,87,11,75,81,83,86,31,70,82,83,86,60,73,81,82,88,25,77,83,84,88,44,78,83,85,87,16,79,84,87,87,19,77,82,83,85,4,71,82,83,86,29,78,84,86,87,4,76,83,85,89,30,77,80,86,87,15,77,82,84,86,30,77,82,85,88,16,77,84,85,88,78,82,84,83,88,61,82,81,84,88,16,74,84,83,88,5,79,84,87,89,50,77,85,87,89,59,77,82,83,88,61,79,83,85,86,5,81,86,86,87,58,75,84,85,86,49,78,83,86,88,5,67,79,83,85,50,74,83,85,87,4,74,82,83,87,50,76,83,85,88,43,80,84,84,87,45,76,83,86,87,61,77,83,85,88,25,76,81,83,88,14,81,87,88,88,25,76,80,82,87,24,71,85,86,88,74,80,84,85,87,49,82,84,85,83,59,80,82,85,88,37,80,83,84,89,76,79,83,84,88,64,73,80,82,86,49,78,83,83,86,61,73,79,80,85,39,76,83,84,87,10,80,84,85,88,55,79,82,83,82,35,79,83,85,88,3,73,82,83,88,65,78,83,85,87,47,79,84,85,86,6,78,84,86,82,70,76,80,84,87,49,80,84,86,88,32,75,81,83,87,45,77,83,84,87,11,71,79,81,86,17,77,82,84,90,56,78,82,84,88,33,78,82,84,86,63,74,81,83,87,9,72,82,85,90,50,76,82,83,89,45,76,81,82,85,20,78,85,84,86,28,74,80,84,88,38,74,87,84,89,39,71,80,82,87,57,79,81,84,93,50,78,81,82,87,41,76,85,84,87,25,79,81,83,86,23,76,81,82,84,6,75,84,83,86,6,74,86,84,90,55,74,80,84,89,39,76,81,83,86,41,71,81,82,84,5,74,81,83,84,50,75,82,84,83,22,68,79,83,86,57,75,81,83,87,33,80,85,88,90,29,71,80,80,87,57,75,82,83,86,12,77,82,89,86,11,76,85,86,88],
            [4,10,15,15,14,23,14,13,14,16,5,9,14,15,13,40,9,12,13,14,4,9,12,14,13,5,9,15,15,14,6,9,12,15,13,13,10,14,16,16,19,10,12,12,7,4,7,9,10,9,6,9,12,14,12,6,11,11,14,10,9,11,14,15,14,25,10,18,20,12,33,11,13,14,12,26,9,12,13,13,3,9,12,14,12,5,9,12,13,12,20,10,12,15,15,2,7,11,14,14,4,9,13,15,14,18,10,13,15,13,9,9,13,15,14,3,8,10,11,7,6,11,14,17,15,7,9,13,14,15,27,11,13,14,15,44,13,15,16,22,36,12,16,20,16,6,8,13,14,14,24,10,15,16,16,5,9,12,13,11,8,8,11,13,14,15,8,11,13,12,24,11,12,14,13,4,7,11,14,9,3,8,12,15,12,7,7,10,13,12,11,10,14,15,12,4,11,13,12,7,5,8,12,14,11,5,10,13,13,14,16,12,12,14,15,5,9,12,14,11,6,12,13,15,13,7,11,17,15,13,22,9,13,13,14,26,9,12,14,13,4,8,10,12,14,8,8,12,13,14,4,9,11,14,13,8,11,12,16,14,7,8,12,15,17,7,9,12,13,14,13,8,12,15,14,6,8,11,12,10,5,8,11,11,11,18,11,13,14,27,8,10,13,15,14,6,10,14,16,15,6,10,12,14,12,5,10,13,14,12,6,8,11,12,12,4,10,13,16,14,6,10,13,16,14,40,9,12,13,13,5,8,11,14,22,9,9,12,14,13,25,10,12,16,10,5,8,12,14,13,4,8,11,13,15,23,12,12,14,18,5,8,10,13,11,6,8,12,14,13,7,7,11,13,12,5,10,13,15,13,17,10,13,16,14,4,9,12,14,12,5,9,12,14,13,12,10,14,17,15,5,9,11,13,12,27,10,14,16,14,4,9,12,15,13,4,8,11,13,14,6,9,13,17,16,5,9,11,15,15,5,9,15,15,13,7,9,16,16,14,8,8,13,13,8,4,9,12,13,11,10,9,13,14,11,6,8,12,13,13,9,10,14,17,20,11,12,16,15,16,8,6,16,14,13,4,9,15,14,13,15,10,13,14,15,7,9,13,15,14,18,10,14,16,17,3,6,11,14,15,6,8,14,15,13,6,9,12,14,14,4,10,13,14,13,4,7,12,15,13,5,9,12,15,14,11,8,11,13,13,7,10,14,16,15],
            [11,22,32,33,34,35,32,38,38,39,16,27,31,34,34,50,25,33,34,38,14,25,34,35,36,15,26,34,37,38,19,25,34,37,38,25,28,35,38,38,31,24,31,32,34,19,25,35,39,40,19,25,33,36,39,19,28,35,38,40,31,27,36,36,38,35,26,37,41,36,46,30,35,38,39,38,23,32,33,36,42,26,33,36,37,17,25,33,34,35,33,27,33,36,37,8,20,32,36,38,14,24,32,34,36,28,25,34,36,37,21,26,34,37,38,20,29,36,39,45,17,28,38,41,44,19,26,34,36,38,41,28,35,36,38,53,33,36,39,42,46,27,38,42,39,19,22,34,35,35,46,25,36,38,39,17,27,36,37,38,22,23,31,35,40,38,25,33,36,40,37,28,34,36,36,15,22,32,35,38,17,23,31,35,35,19,22,30,35,37,24,27,37,38,45,13,26,36,35,31,18,24,33,37,40,17,26,35,35,36,39,32,37,38,49,16,25,37,38,35,22,37,36,39,42,17,26,39,39,36,31,25,32,35,37,36,24,33,35,35,15,25,33,35,41,17,24,32,34,37,18,25,32,37,38,24,27,34,38,39,17,22,32,35,38,33,28,41,39,37,26,22,30,35,37,27,28,36,38,39,18,24,32,32,34,35,28,33,35,48,29,29,36,39,40,20,30,37,40,45,32,28,34,36,36,17,26,33,35,33,24,25,32,33,35,16,25,32,35,36,17,27,33,36,36,53,24,31,33,35,20,22,28,33,42,26,25,32,35,39,39,25,32,36,29,18,26,33,37,42,15,22,31,34,39,47,29,33,34,40,17,22,29,33,37,32,25,34,38,38,26,21,31,35,37,18,27,36,41,41,33,24,32,36,36,19,31,38,40,42,15,25,31,34,37,24,25,34,39,38,17,26,33,36,39,38,27,36,40,41,15,25,32,37,38,14,22,31,34,37,22,25,36,39,40,14,23,31,39,38,16,25,37,38,39,27,32,34,37,38,28,25,41,36,39,14,24,32,34,35,22,25,37,36,44,21,24,30,31,32,22,27,34,37,40,25,31,37,37,40,19,16,38,35,37,14,25,33,35,38,26,26,32,36,38,28,25,34,36,37,26,27,33,36,41,15,21,30,34,36,18,24,31,34,34,19,25,32,35,36,16,27,37,37,40,14,20,30,33,35,18,25,33,35,37,22,22,31,37,35,19,27,36,39,39],
            [20,36,51,54,54,46,47,57,60,58,29,44,52,57,56,58,40,51,54,57,24,39,54,56,54,25,39,51,56,54,30,38,51,57,56,37,42,53,57,57,42,37,48,51,63,33,36,53,58,57,31,38,51,56,57,32,41,54,58,66,55,43,60,58,60,44,39,55,59,58,56,41,52,58,57,50,36,50,54,54,72,40,51,56,56,27,37,52,54,55,43,40,51,57,57,18,33,51,57,55,26,38,51,54,55,38,39,55,58,56,34,40,53,57,57,38,50,61,64,76,31,41,56,61,60,31,40,54,58,57,51,42,54,56,55,61,48,56,58,59,54,39,57,62,59,33,37,55,60,58,65,37,56,62,61,29,43,57,60,58,37,36,48,53,57,53,40,53,58,60,49,42,53,56,53,28,36,52,58,67,33,38,49,55,56,31,36,46,53,55,39,42,56,59,68,23,37,55,57,58,31,38,52,57,62,30,40,54,56,58,58,45,56,60,70,28,39,58,61,58,33,51,54,58,62,30,39,60,64,59,40,38,50,54,56,44,38,53,57,54,26,38,51,55,63,37,38,51,53,51,32,39,51,57,59,37,39,51,57,55,28,34,51,56,55,50,40,59,60,55,43,38,49,54,54,47,45,56,59,63,34,38,51,51,54,48,43,51,53,63,45,43,55,60,58,33,44,55,59,60,62,44,53,56,56,29,40,52,54,50,39,40,51,52,53,29,39,50,53,53,29,41,50,53,53,63,39,48,52,52,36,37,44,51,57,42,39,49,54,61,55,38,51,57,56,31,40,52,58,64,28,35,48,52,58,64,42,51,57,59,28,36,49,55,59,56,38,53,59,56,44,34,50,55,57,32,42,56,62,62,48,40,53,59,56,32,45,54,55,55,25,39,49,53,54,34,38,51,57,56,29,40,52,55,57,48,39,48,52,53,26,38,51,56,55,26,36,49,53,55,34,39,56,60,59,24,36,51,58,57,28,40,60,57,58,46,51,53,56,57,44,40,65,56,64,25,39,51,55,53,35,41,56,57,69,37,39,47,49,49,36,41,52,56,58,37,46,54,58,58,33,25,58,56,58,26,41,53,57,57,39,41,51,54,55,49,39,53,57,59,36,41,52,55,58,28,35,49,54,55,32,40,51,53,53,33,39,50,54,53,28,42,57,58,59,28,33,49,51,51,31,39,51,54,55,33,34,49,60,54,30,40,55,61,58],
            [34,53,76,74,71,58,64,76,79,75,44,61,73,75,71,68,57,71,73,73,38,57,74,75,71,41,59,79,78,72,45,56,72,76,72,52,60,73,77,74,55,54,68,70,80,47,51,72,75,72,45,55,72,75,74,49,60,74,78,83,74,62,78,78,76,57,58,83,85,81,67,57,72,77,73,61,52,70,73,71,88,60,74,78,76,41,54,71,73,71,55,55,70,76,74,47,57,75,79,76,41,55,70,73,71,51,56,75,78,74,48,57,73,77,74,53,66,79,81,86,49,61,79,83,79,46,59,74,78,76,60,58,73,75,71,69,61,72,73,73,63,55,76,80,75,48,54,75,78,75,78,53,74,79,77,45,60,78,77,73,54,54,68,72,73,68,55,70,74,74,62,58,72,75,70,45,53,71,75,85,54,56,70,75,75,48,54,66,72,72,54,59,77,78,83,34,50,73,76,79,46,55,72,76,78,45,57,74,76,75,69,62,76,79,84,43,57,77,81,76,49,67,73,77,78,43,55,78,82,76,53,56,70,73,73,55,55,73,76,71,41,53,68,71,78,58,56,71,71,71,49,57,71,77,77,54,58,73,78,73,42,50,71,76,72,63,55,75,78,74,64,58,70,75,73,66,63,75,76,78,56,61,75,76,78,63,61,70,73,78,62,62,76,80,75,51,64,78,81,79,79,63,74,76,75,46,59,73,74,67,56,58,70,72,71,48,59,71,73,72,47,60,72,74,72,75,57,68,72,70,52,54,64,70,77,60,59,70,74,79,68,55,71,76,80,49,58,74,78,83,44,52,66,71,73,73,59,71,76,75,40,50,65,71,74,70,55,73,79,75,59,50,68,72,72,49,59,75,80,77,62,59,73,80,73,51,65,76,76,74,39,57,70,73,72,48,55,69,75,73,45,57,70,73,72,64,62,75,78,74,41,56,71,76,73,41,53,68,71,71,47,57,76,82,77,38,52,70,73,71,44,59,82,78,76,62,68,77,77,74,58,57,81,75,77,40,56,70,74,71,50,59,76,76,81,56,57,68,69,66,51,58,72,76,73,49,60,72,76,74,45,37,76,76,75,42,59,76,76,73,53,59,71,73,72,66,55,72,75,76,50,60,73,74,75,41,49,68,72,71,47,57,72,73,71,48,56,71,74,71,43,58,75,77,75,46,49,71,73,69,47,56,71,73,72,47,50,69,77,71,43,56,75,80,76],
            [54,70,88,86,84,72,80,88,90,88,62,78,86,88,85,79,75,86,87,87,56,73,87,87,85,60,77,92,90,86,62,73,85,88,86,68,77,87,89,86,69,72,84,83,89,69,76,91,92,91,62,74,87,89,88,67,77,87,91,92,84,79,88,89,89,70,76,92,94,92,78,76,88,90,88,74,72,86,87,86,92,78,88,91,90,57,71,84,85,84,69,72,84,88,87,69,76,88,90,89,60,72,84,86,85,69,76,89,90,88,64,74,86,89,87,69,81,90,91,94,67,78,91,93,92,64,76,87,89,88,70,73,85,86,84,78,75,85,85,85,74,73,88,90,89,64,70,86,88,86,86,72,87,89,90,65,81,92,91,90,71,74,84,87,88,81,78,87,89,90,74,77,86,89,85,68,78,89,90,95,71,74,86,88,87,67,70,81,85,86,69,76,89,89,93,54,71,87,88,90,66,77,88,90,92,62,74,87,88,87,79,78,88,89,92,62,75,89,91,90,67,82,88,90,91,63,75,90,92,89,70,75,85,87,89,69,72,87,88,85,63,77,87,88,93,73,75,87,87,85,67,75,85,89,89,70,76,88,90,86,59,68,85,88,85,74,72,86,89,86,80,77,85,88,87,83,82,90,91,92,72,78,88,88,90,79,79,86,87,90,77,81,91,93,90,72,85,93,93,93,88,80,87,88,89,65,77,87,87,82,74,76,84,87,86,68,76,85,86,86,68,78,87,88,86,85,76,84,86,85,67,71,81,84,86,75,76,85,87,90,77,71,84,87,91,67,75,87,90,94,64,71,83,85,86,83,77,85,88,86,58,70,82,85,89,80,74,87,91,89,75,74,86,88,89,67,79,89,92,90,76,77,87,91,86,72,84,92,90,89,59,76,87,88,88,66,73,84,88,87,67,79,88,89,89,78,80,90,91,89,60,74,86,89,87,59,72,82,85,86,64,75,89,92,89,60,75,86,86,84,64,80,92,92,91,75,80,89,89,87,71,74,91,89,92,59,75,84,87,86,67,77,88,89,92,73,75,83,84,81,68,75,86,88,86,65,76,86,88,87,63,63,90,89,87,61,76,89,88,88,69,77,86,88,86,79,74,86,88,89,66,77,86,87,88,60,69,84,86,85,64,72,84,85,84,65,74,86,87,85,60,75,88,88,88,64,66,85,86,83,65,75,86,86,87,63,68,84,88,85,62,77,89,91,89]]

        # processes = [60, 55, 75, 50, 41, 59, 96,
        #     34, 48, 69, 87, 11, 6, 57, 76, 91,
        #     49, 88, 81, 15, 12, 102, 3, 44, 1,
        #     73, 68, 105, 86, 13, 84, 89, 16, 90,
        #     18, 93, 95, 51, 74, 52, 66, 4, 63, 53,
        #     23, 64, 78, 26, 5, 22, 46, 79, 17, 8,
        #     77, 33, 7, 101, 58, 30, 45, 71, 29,
        #     62, 24, 37, 31, 25, 72, 85, 10, 2, 83,
        #     82, 106, 20, 19, 65, 67, 36, 35, 21,
        #     39, 9, 14, 70, 43, 100, 103, 28, 104,
        #     107, 32, 40, 97, 47, 27, 80, 98, 61,
        #     94, 42, 99, 56, 92, 54, 38]

        # processes = [60, 55, 75, 50, 41, 59,
        #     96, 34, 48, 69, 87, 11,
        #     6, 57, 76, 91, 49, 88,
        #     81, 15, 12, 102, 3, 44,
        #     1, 73, 68, 105, 86, 13,
        #     84, 89, 16, 90, 18, 93,
        #     95, 51, 74, 52, 66, 4,
        #     63, 53, 23, 64, 78, 26,
        #     5, 22, 46, 79, 17, 8,
        #     77, 33, 7, 101, 58, 30,
        #     45, 71, 29, 62, 24, 37,
        #     31, 25, 72, 85, 10, 2, 83,
        #     82, 106, 20, 19, 65, 67,
        #     36, 35, 21, 39, 9, 14,
        #     70, 43, 100, 103, 28, 104,
        #     107, 32, 40, 97, 47, 27,
        #     80, 98, 61, 94, 42, 99,
        #     56, 92, 54, 38]

        processes = [60, 55, 75, 50, 41, 59,
            11, 87, 69, 48, 34, 96,
            6, 57, 76, 91, 49, 88,
            44, 3, 102, 12, 15, 81,
            1, 73, 68, 105, 86, 13,
            93, 18, 90, 16, 89, 84,
            95, 51, 74, 52, 66, 4,
            26, 78, 64, 23, 53, 63,
            5, 22, 46, 79, 17, 8,
            30, 58, 101, 7, 33, 77,
            45, 71, 29, 62, 24, 37,
            83, 2, 10, 85, 72, 25, 31,
            82, 106, 20, 19, 65, 67,
            14, 9, 39, 21, 35, 36,
            70, 43, 100, 103, 28, 104,
            27, 47, 97, 40, 32, 107,
            80, 98, 61, 94, 42, 99,
            38, 54, 92, 56]
        
        kindergarten = Collective(5.88, 2.52, fill(Group[], 6))
        kindergarten_group_sizes = Int[
            get_kindergarten_group_size(1),
            get_kindergarten_group_size(2),
            get_kindergarten_group_size(3),
            get_kindergarten_group_size(4),
            get_kindergarten_group_size(5),
            get_kindergarten_group_size(6)]

        school = Collective(4.783, 2.67, fill(Group[], 11))
        school_group_sizes = Int[
            get_school_group_size(1),
            get_school_group_size(2),
            get_school_group_size(3),
            get_school_group_size(4),
            get_school_group_size(5),
            get_school_group_size(6),
            get_school_group_size(7),
            get_school_group_size(8),
            get_school_group_size(9),
            get_school_group_size(10),
            get_school_group_size(11)]

        university = Collective(2.1, 3.0, fill(Group[], 6))
        university_group_sizes = Int[
            get_university_group_size(1),
            get_university_group_size(2),
            get_university_group_size(3),
            get_university_group_size(4),
            get_university_group_size(5),
            get_university_group_size(6)]

        workplace = Collective(3.0, 3.0, fill(Group[], 1))
        workplace_group_sizes = Int[get_workplace_group_size(1)]

        for index in processes[(comm_rank + 1):comm_size:107]
            index_for_1_people::Int = (index - 1) * 5 + 1
            index_for_2_people::Int = index_for_1_people + 1
            index_for_3_people::Int = index_for_2_people + 1
            index_for_4_people::Int = index_for_3_people + 1
            index_for_5_people::Int = index_for_4_people + 1
            for i in 1:districts[index, 1]
                # 1P
                household = Group()
                agents = Agent[create_agent(viruses, viral_loads, household, index, districts_age_sex, district_households, index_for_1_people)]
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 2]
                # PWOP2P0C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_2_people, 0, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 3]
                # PWOP3P0C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 0, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 4]
                # PWOP3P1C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 1, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 5]
                # PWOP4P0C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 0, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 6]
                # PWOP4P1C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 1, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 7]
                # PWOP4P2C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 2, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 8]
                # PWOP5P0C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 9]
                # PWOP5P1C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 1, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 10]
                # PWOP5P2C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 2, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 11]
                # PWOP5P3C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 3, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 12]
                # PWOP6P0C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 4, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 13]
                # PWOP6P1C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 1, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 14]
                # PWOP6P2C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 2, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 15]
                # PWOP6P3C
                household = Group()
                agents = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 3, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 16]
                # 2PWOP4P0C
                household = Group()
                pair1 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 0, 0, index)
                pair2 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 17]
                # 2PWOP5P0C
                household = Group()
                pair1 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 1, index)
                pair2 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 18]
                # 2PWOP5P1C
                household = Group()
                pair1 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 19]
                # 2PWOP6P0C
                household = Group()
                pair1 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 1, index)
                pair2 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 1, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 20]
                # 2PWOP6P1C
                household = Group()
                pair1 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 1, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 21]
                # 2PWOP6P2C
                household = Group()
                pair1 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 1, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 22]
                # SMWC2P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_2_people, 0, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 23]
                # SMWC2P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_2_people, 1, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 24]
                # SMWC3P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 0, 2, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 25]
                # SMWC3P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 1, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 26]
                # SMWC3P2C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 2, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 27]
                # SMWC4P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 0, 3, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 28]
                # SMWC4P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 1, 2, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 29]
                # SMWC4P2C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 2, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 30]
                # SMWC4P3C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 3, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 31]
                # SFWC2P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_2_people, 0, 1, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 32]
                # SFWC2P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_2_people, 1, 0, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 33]
                # SFWC3P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 0, 2, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 34]
                # SFWC3P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 1, 1, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 35]
                # SFWC3P2C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 2, 0, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 36]
                # SPWCWP3P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 0, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 37]
                # SPWCWP3P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 1, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 38]
                # SPWCWP4P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 0, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 39]
                # SPWCWP4P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 1, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 40]
                # SPWCWP4P2C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 2, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end

            for i in 1:districts[index, 41]
                # SPWCWPWOP3P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 0, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 42]
                # SPWCWPWOP3P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 1, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 43]
                # SPWCWPWOP4P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 0, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 44]
                # SPWCWPWOP4P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 1, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 45]
                # SPWCWPWOP4P2C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 2, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 46]
                # SPWCWPWOP5P0C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 4, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 47]
                # SPWCWPWOP5P1C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 1, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 48]
                # SPWCWPWOP5P2C
                household = Group()
                agents = create_parent_with_children(viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 2, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end

            for i in 1:districts[index, 49]
                # O2P0C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_2_people, 0, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 50]
                # O2P1C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_2_people, 1, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 51]
                # O3P0C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 0, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 52]
                # O3P1C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 1, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 53]
                # O3P2C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_3_people, 2, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 54]
                # O4P0C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 0, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 55]
                # O4P1C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 1, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 56]
                # O4P2C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_4_people, 2, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 57]
                # O5P0C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 0, 4, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 58]
                # O5P1C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 1, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:districts[index, 59]
                # O5P2C
                household = Group()
                agents = create_others(
                    viruses, viral_loads, household, districts_age_sex, district_households, index_for_5_people, 2, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    all_agents, infected_agents,
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
        end
    end

    function update_infected_agent_state(
        viral_loads::Array{Float64, 4},
        agent::Agent,
    )
        if !agent.is_asymptomatic && !agent.is_isolated && agent.social_status != 0 && !agent.on_parent_leave
            # Самоизоляция
            rand_num = rand(1:1000)
            if agent.days_infected == agent.incubation_period + 1
                if agent.age < 8
                    if rand_num < 305
                        agent.is_isolated = true
                    end
                elseif agent.age < 18
                    if rand_num < 204
                        agent.is_isolated = true
                    end
                else
                    if rand_num < 101
                        agent.is_isolated = true
                    end
                end
            elseif agent.days_infected == agent.incubation_period + 2
                if agent.age < 8
                    if rand_num < 576
                        agent.is_isolated = true
                    end
                elseif agent.age < 18
                    if rand_num < 499
                        agent.is_isolated = true
                    end
                else
                    if rand_num < 334
                        agent.is_isolated = true
                    end
                end
            elseif agent.days_infected == agent.incubation_period + 3
                if agent.age < 8
                    if rand_num < 325
                        agent.is_isolated = true
                    end
                elseif agent.age < 18
                    if rand_num < 376
                        agent.is_isolated = true
                    end
                else
                    if rand_num < 168
                        agent.is_isolated = true
                    end
                end
            end
        end
        
        # Вирусная нагрузка
        agent.viral_load = find_agent_viral_load(
            agent.age,
            viral_loads[agent.virus.id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
            agent.is_asymptomatic && agent.days_infected > 0)
    end

    function set_agent_infection(
        viral_loads::Array{Float64, 4},
        agent::Agent
    )
        # Инкубационный период
        agent.incubation_period = get_period_from_erlang(
            agent.virus.mean_incubation_period,
            agent.virus.incubation_period_variance,
            agent.virus.min_incubation_period,
            agent.virus.max_incubation_period)
        # Период болезни
        if agent.age < 16
            agent.infection_period = get_period_from_erlang(
                agent.virus.mean_infection_period_child,
                agent.virus.infection_period_variance_child,
                agent.virus.min_infection_period_child,
                agent.virus.max_infection_period_child)
        else
            agent.infection_period = get_period_from_erlang(
                agent.virus.mean_infection_period_adult,
                agent.virus.infection_period_variance_adult,
                agent.virus.min_infection_period_adult,
                agent.virus.max_infection_period_adult)
        end

        # Дней с момента инфицирования
        agent.days_infected = 1 - agent.incubation_period

        if rand(1:100) <= agent.virus.asymptomatic_probab
            # Асимптомный
            agent.is_asymptomatic = true
        end

        # Вирусная нагрузка
        agent.viral_load = find_agent_viral_load(
            agent.age,
            viral_loads[agent.virus.id, agent.incubation_period, agent.infection_period - 1, agent.days_infected + 7],
            agent.is_asymptomatic && agent.days_infected > 0)
    end

    function get_contact_duration(mean::Float64, sd::Float64)
        return rand(truncated(Normal(mean, sd), 0.0, Inf))
    end

    function make_contact(
        infected_agent::Agent,
        agent::Agent,
        contact_duration::Float64,
        current_temp::Float64,
        newly_infected_agents::Vector{Agent},
        duration_parameter::Float64,
        temperature_parameters::Dict{String, Float64},
        susceptibility_parameters::Dict{String, Float64}
    )
        # Проверка восприимчивости агента к вирусу
        if agent.virus !== nothing || agent.days_immune > 0 || agent.immunity_days[infected_agent.virus.name] > 0
            return
        end
        # Влияние продолжительности контакта на вероятность инфицирования
        duration_influence = 1 / (1 + exp(-contact_duration + duration_parameter))
                
        # Влияние температуры воздуха на вероятность инфицирования
        temperature_influence = temperature_parameters[infected_agent.virus.name] * current_temp + 1.0

        # Влияние восприимчивости агента на вероятность инфицирования
        susceptibility_influence = 2 / (1 + exp(susceptibility_parameters[infected_agent.virus.name] * agent.ig_level))

        # Влияние силы инфекции на вероятность инфицирования
        infectivity_influence = infected_agent.viral_load / 12.0

        # Вероятность инфицирования
        infection_probability = infectivity_influence * susceptibility_influence *
            temperature_influence * duration_influence

        if rand(Float64) < infection_probability
            agent.virus = infected_agent.virus
            push!(newly_infected_agents, agent)
        end
    end

    function infect_randomly(
        viruses::Dict{String, Virus},
        agent::Agent,
        week_num::Int,
        etiologies::Vector{Vector{Float64}}
    )
        # Check age
        rand_num = rand(Float64)
        if rand_num < etiologies[week_num][1]
            if agent.immunity_days["FluA"] == 0
                agent.virus = viruses["FluA"]
            end
        elseif rand_num < etiologies[week_num][2]
            if agent.immunity_days["FluB"] == 0
                agent.virus = viruses["FluB"]
            end
        elseif rand_num < etiologies[week_num][3]
            if agent.immunity_days["RV"] == 0
                agent.virus = viruses["RV"]
            end
        elseif rand_num < etiologies[week_num][4]
            if agent.immunity_days["RSV"] == 0
                agent.virus = viruses["RSV"]
            end
        elseif rand_num < etiologies[week_num][5]
            if agent.immunity_days["AdV"] == 0
                agent.virus = viruses["AdV"]
            end
        elseif rand_num < etiologies[week_num][6]
            if agent.immunity_days["PIV"] == 0
                agent.virus = viruses["PIV"]
            end
        else
            if agent.immunity_days["CoV"] == 0
                agent.virus = viruses["CoV"]
            end
        end
    end

    function run_simulation(
        viruses::Dict{String, Virus},
        viral_loads::Array{Float64, 4},
        comm_rank::Int,
        comm::MPI.Comm,
        all_agents::Vector{Agent},
        infected_agents::Vector{Agent}
    )
        # Параметры
        duration_parameter = 7.05
        temperature_parameters = Dict(
            "FluA" => -0.8,
            "FluB" => -0.8,
            "RV" => -0.05,
            "RSV" => -0.64,
            "AdV" => -0.2,
            "PIV" => -0.05,
            "CoV" => -0.8)
        susceptibility_parameters = Dict(
            "FluA" => 2.61,
            "FluB" => 2.61,
            "RV" => 3.17,
            "RSV" => 5.11,
            "AdV" => 4.69,
            "PIV" => 3.89,
            "CoV" => 3.77)
        immunity_durations = Dict(
            "FluA" => 366,
            "FluB" => 366,
            "RV" => 60,
            "RSV" => 60,
            "AdV" => 366,
            "PIV" => 366,
            "CoV" => 366)

        # Температура воздуха, начиная с 1 января
        temperature = [-5.8, -5.9, -5.9, -5.9,
            -6.0, -6.0, -6.1, -6.1, -6.2, -6.2, -6.2, -6.3,
            -6.3, -6.4, -6.5, -6.5, -6.6, -6.6, -6.7, -6.7,
            -6.8, -6.8, -6.9, -6.9, -7.0, -7.0, -7.0, -7.1, -7.1,
            -7.1, -7.1, -7.2, -7.2, -7.2, -7.2, -7.2, -7.2, -7.1,
            -7.1, -7.1, -7.0, -7.0, -6.9, -6.8, -6.8, -6.7, -6.6,
            -6.5, -6.4, -6.3, -6.1, -6.0, -5.9, -5.7, -5.6, -5.4,
            -5.2, -5.0, -4.8, -4.7, -4.5, -4.2, -4.0, -3.8,
            -3.6, -3.4, -3.1, -2.9, -2.7, -2.4, -2.2, -1.9, -1.7,
            -1.4, -1.2, -0.9, -0.6, -0.4, -0.1, 0.2, 0.4,
            0.7, 1.0, 1.2, 1.5, 1.8, 2.0, 2.3, 2.5, 2.8,
            3.1, 3.3, 3.6, 3.9, 4.1, 4.4, 4.6, 4.9, 5.1,
            5.4, 5.6, 5.9, 6.1, 6.4, 6.6, 6.9, 7.1, 7.4,
            7.6, 7.8, 8.1, 8.3, 8.5, 8.8, 9.0, 9.2, 9.4,
            9.7, 9.9, 10.1, 10.3, 10.5, 10.7, 11.0, 11.2,
            11.4, 11.6, 11.8, 12.0, 12.1, 12.3, 12.5, 12.7,
            12.9, 13.1, 13.2, 13.4, 13.6, 13.7, 13.9, 14.0,
            14.2, 14.3, 14.5, 14.6, 14.8, 14.9, 15.0, 15.2,
            15.3, 15.4, 15.5, 15.6, 15.8, 15.9, 16.0, 16.1,
            16.2, 16.3, 16.4, 16.5, 16.6, 16.7, 16.8, 16.9,
            17.0, 17.1, 17.2, 17.2, 17.3, 17.4, 17.5, 17.6,
            17.7, 17.8, 17.9, 17.9, 18.0, 18.1, 18.2, 18.3,
            18.4, 18.4, 18.5, 18.6, 18.7, 18.7, 18.8, 18.9,
            18.9, 19.0, 19.1, 19.1, 19.2, 19.2, 19.3, 19.3,
            19.3, 19.4, 19.4, 19.4, 19.4, 19.4, 19.4, 19.4,
            19.4, 19.4, 19.3, 19.3, 19.3, 19.2, 19.1, 19.1,
            19.0, 18.9, 18.8, 18.7, 18.6, 18.5, 18.4, 18.3,
            18.2, 18.0, 17.9, 17.7, 17.6, 17.4, 17.2, 17.1,
            16.9, 16.7, 16.5, 16.3, 16.1, 15.9, 15.7, 15.5,
            15.3, 15.1, 14.9, 14.7, 14.5, 14.3, 14.1, 13.9,
            13.7, 13.5, 13.3, 13.1, 12.8, 12.6, 12.4, 12.2,
            12.1, 11.9, 11.7, 11.5, 11.3, 11.1, 10.9, 10.7,
            10.6, 10.4, 10.2, 10.0, 9.9, 9.7, 9.5, 9.4,
            9.2, 9.0, 8.9, 8.7, 8.5, 8.3, 8.2, 8.0,
            7.8, 7.7, 7.5, 7.3, 7.1, 6.9, 6.8, 6.6,
            6.4, 6.2, 6.0, 5.8, 5.6, 5.4, 5.2, 4.9,
            4.7, 4.5, 4.3, 4.0, 3.8, 3.6, 3.3, 3.1,
            2.9, 2.6, 2.4, 2.1, 1.9, 1.6, 1.4, 1.1,
            0.9, 0.7, 0.4, 0.2, -0.1, -0.3, -0.5, -0.8,
            -1.0, -1.2, -1.5, -1.7, -1.9, -2.1, -2.3, -2.5,
            -2.7, -2.9, -3.0, -3.2, -3.4, -3.5, -3.7, -3.8,
            -4.0, -4.1, -4.2, -4.3, -4.4, -4.5, -4.6, -4.7,
            -4.8, -4.9, -5.0, -5.0, -5.1, -5.2, -5.2, -5.3,
            -5.3, -5.4, -5.4, -5.4, -5.5, -5.5, -5.5, -5.6,
            -5.6, -5.6, -5.7, -5.7, -5.7, -5.7, -5.8, -5.8]

        # Вероятность случайного инфицирования [номер недели, вирус]
        etiologies = [[0.00980294117647054,0.00490147058823527,0.499999999999999,0.588235294117646,0.823529411764704,0.985294117647056],
            [0.00784235294117644,0.00392117647058822,0.494117647058823,0.529411764705882,0.811764705882352,0.976470588235293],
            [0.00724565217391304,0.00362282608695652,0.499999999999999,0.554347826086956,0.771739130434782,0.956521739130434],
            [0.00748988764044939,0.00374494382022469,0.539325842696629,0.584269662921348,0.831460674157303,0.988764044943819],
            [0.00529047619047619,0.00264523809523809,0.603174603174603,0.626984126984127,0.785714285714285,0.968253968253967],
            [0.00432857142857143,0.00216428571428571,0.655844155844155,0.688311688311688,0.805194805194804,0.987012987012985],
            [0.00383103448275861,0.00191551724137931,0.706896551724138,0.741379310344827,0.827586206896551,0.994252873563217],
            [0.00368287292817679,0.00184143646408839,0.685082872928176,0.718232044198894,0.823204419889501,0.988950276243092],
            [0.00310046511627907,0.00155023255813953,0.627906976744186,0.646511627906976,0.753488372093022,0.981395348837208],
            [0.00362282608695652,0.00181141304347826,0.684782608695652,0.717391304347826,0.79891304347826,0.989130434782607],
            [0.003471875,0.0017359375,0.671874999999999,0.697916666666666,0.802083333333332,0.994791666666665],
            [0.00336666666666667,0.00168333333333333,0.6010101010101,0.63131313131313,0.782828282828281,0.974747474747472],
            [0.00314433962264151,0.00157216981132075,0.622641509433961,0.65566037735849,0.787735849056603,0.96698113207547],
            [0.00296266666666666,0.00148133333333333,0.555555555555555,0.577777777777778,0.742222222222222,0.982222222222222],
            [0.00352698412698413,0.00176349206349206,0.481481481481481,0.523809523809524,0.73015873015873,0.973544973544973],
            [0.003333,0.0016665,0.505,0.59,0.79,0.965],
            [0.00288571428571428,0.00144285714285714,0.489177489177488,0.606060606060604,0.744588744588742,0.965367965367962],
            [0.0264523809523809,0.0132261904761904,0.547619047619047,0.634920634920634,0.793650793650792,0.980158730158728],
            [0.06666,0.03333,0.5,0.608,0.776,0.976],
            [0.093740625,0.0468703125,0.45703125,0.61328125,0.82421875,0.94140625],
            [0.183805147058823,0.0919025735294117,0.485294117647058,0.602941176470587,0.768382352941175,0.952205882352939],
            [0.155828571428571,0.0779142857142855,0.46103896103896,0.629870129870128,0.831168831168829,0.961038961038958],
            [0.312138095238095,0.156069047619048,0.642857142857142,0.793650793650792,0.857142857142855,0.992063492063489],
            [0.3333,0.16665,0.653846153846153,0.776923076923076,0.826923076923076,0.973076923076922],
            [0.360324324324324,0.180162162162162,0.702702702702702,0.805405405405404,0.889189189189188,0.975675675675674],
            [0.347791304347826,0.173895652173913,0.695652173913042,0.808695652173911,0.895652173913041,0.967391304347824],
            [0.311719424460431,0.155859712230216,0.640287769784172,0.802158273381294,0.874100719424459,0.964028776978416],
            [0.313251879699248,0.156625939849624,0.639097744360902,0.774436090225563,0.887218045112781,0.964285714285713],
            [0.303690205011389,0.151845102505695,0.612756264236901,0.749430523917994,0.890660592255123,0.943052391799542],
            [0.291050704225352,0.145525352112676,0.605633802816901,0.814084507042253,0.907042253521126,0.957746478873239],
            [0.249975,0.1249875,0.576086956521739,0.869565217391304,0.945652173913043,0.975543478260869],
            [0.166188365650969,0.0830941828254845,0.470914127423821,0.858725761772851,0.941828254847643,0.977839335180053],
            [0.130498412698412,0.0652492063492061,0.423280423280422,0.846560846560845,0.936507936507935,0.984126984126983],
            [0.10330350877193,0.0516517543859649,0.444444444444444,0.7953216374269,0.888888888888888,0.947368421052631],
            [0.0973928571428571,0.0486964285714285,0.405844155844155,0.788961038961038,0.889610389610388,0.935064935064933],
            [0.0902964143426293,0.0451482071713146,0.434262948207171,0.824701195219123,0.872509960159362,0.940239043824701],
            [0.0939299999999994,0.0469649999999997,0.422727272727271,0.786363636363634,0.863636363636361,0.945454545454543],
            [0.087369902912621,0.0436849514563105,0.441747572815533,0.757281553398057,0.849514563106795,0.95145631067961],
            [0.06666,0.03333,0.41578947368421,0.773684210526315,0.884210526315788,0.973684210526314],
            [0.0617222222222222,0.0308611111111111,0.401234567901234,0.808641975308641,0.932098765432097,0.981481481481479],
            [0.0563323943661972,0.0281661971830986,0.422535211267605,0.788732394366196,0.90845070422535,0.992957746478871],
            [0.03749625,0.018748125,0.43125,0.7,0.85,0.96875],
            [0.00404,0.00202,0.424242424242424,0.709090909090908,0.860606060606059,0.957575757575756],
            [0.00524881889763779,0.0026244094488189,0.32283464566929,0.661417322834644,0.80314960629921,0.937007874015745],
            [0.0053758064516129,0.00268790322580645,0.387096774193548,0.693548387096773,0.846774193548385,0.975806451612901],
            [0.006666,0.003333,0.39,0.7,0.82,0.98],
            [0.00812926829268292,0.00406463414634146,0.463414634146341,0.695121951219511,0.817073170731706,0.987804878048779],
            [0.00843797468354426,0.00421898734177213,0.50632911392405,0.594936708860759,0.734177215189872,0.987341772151897],
            [0.0102553846153846,0.00512769230769228,0.369230769230768,0.461538461538461,0.784615384615384,0.984615384615384],
            [0.00938873239436618,0.00469436619718309,0.436619718309859,0.507042253521126,0.830985915492957,0.985915492957745],
            [0.0101,0.00504999999999998,0.424242424242424,0.484848484848485,0.833333333333333,0.984848484848484],
            [0.00994925373134324,0.00497462686567162,0.492537313432835,0.567164179104477,0.850746268656715,0.98507462686567]]

        # Минимальная температура воздуха
        min_temp = -7.2
        # Max - Min температура
        max_min_temp = 26.6

        # День месяца
        day = 1
        # Месяц
        month = 8
        # День недели
        week_day = 1
        # День в году
        year_day = 213
        # Номер недели
        week_num = 1

        # Инфицированные агенты
        all_infected_agents = copy(infected_agents)
        # Резистентные агенты
        all_recovered_agents = Agent[]

        daily_new_cases = Int[]
        # DEBUG
        for step = 1:1
            # Набор инфицированных агентов на данном шаге
            newly_infected_agents = Agent[]
            # Текущая нормализованная температура
            current_temp = (temperature[year_day] - min_temp) / max_min_temp

            # Выходные, праздники
            is_holiday = false
            if (week_day == 7)
                is_holiday = true
            elseif (month == 1 && (day == 1 || day == 2 || day == 3 || day == 7))
                is_holiday = true
            elseif (month == 5 && (day == 1 || day == 9))
                is_holiday = true
            elseif (month == 2 && day == 23)
                is_holiday = true
            elseif (month == 3 && day == 8)
                is_holiday = true
            elseif (month == 6 && day == 12)
                is_holiday = true
            end

            is_work_holiday = false
            if (week_day == 6)
                is_work_holiday = true
            end

            is_kindergarten_holiday = is_work_holiday
            if (month == 7 || month == 8)
                is_kindergarten_holiday = true
            end

            # Каникулы
            # Летние - 01.06.yyyy - 31.08.yyyy
            # Осенние - 05.11.yyyy - 11.11.yyyy
            # Зимние - 28.12.yyyy - 09.03.yyyy
            # Весенние - 22.03.yyyy - 31.03.yyyy
            is_school_holiday = false
            if (month == 6 || month == 7 || month == 8)
                is_school_holiday = true
            elseif (month == 11 && (day >= 5 && day <= 11))
                is_school_holiday = true
            elseif (month == 12 && (day >= 28 && day <= 31))
                is_school_holiday = true
            elseif (month == 1 && (day >= 1 && day <= 9))
                is_school_holiday = true
            elseif (month == 3 && (day >= 22 && day <= 31))
                is_school_holiday = true
            end

            is_university_holiday = false
            if (month == 7 || month == 8)
                is_university_holiday = true
            elseif (month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27)
                is_university_holiday = true
            elseif (month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27)
                is_university_holiday = true
            elseif ((month == 2) && (day >= 1 && day <= 10))
                is_university_holiday = true
            elseif (month == 12 && (day >= 22 && day <= 31))
                is_university_holiday = true
            end
            
            # for agent in all_infected_agents
            for agent in all_infected_agents
                for agent2 in agent.household.agents
                    agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.social_status == 0
                    agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.social_status == 0
                    if is_holiday || (agent_at_home && agent2_at_home)
                        make_contact(agent, agent2, get_contact_duration(12.5, 5.5),
                            current_temp, newly_infected_agents,
                            duration_parameter, temperature_parameters, susceptibility_parameters)
                    elseif ((agent.social_status == 1 && !agent_at_home) ||
                        (agent2.social_status == 1 && !agent2_at_home)) && !is_kindergarten_holiday
                        make_contact(agent, agent2, get_contact_duration(5.0, 2.05),
                            current_temp, newly_infected_agents,
                            duration_parameter, temperature_parameters, susceptibility_parameters)
                    elseif ((agent.social_status == 4 && !agent_at_home) ||
                        (agent2.social_status == 4 && !agent2_at_home)) && !is_work_holiday
                        make_contact(agent, agent2, get_contact_duration(5.5, 2.25),
                            current_temp, newly_infected_agents,
                            duration_parameter, temperature_parameters, susceptibility_parameters)
                    elseif ((agent.social_status == 2 && !agent_at_home) ||
                        (agent2.social_status == 2 && !agent2_at_home)) && !is_school_holiday
                        make_contact(agent, agent2, get_contact_duration(6.0, 2.46),
                            current_temp, newly_infected_agents,
                            duration_parameter, temperature_parameters, susceptibility_parameters)
                    elseif ((agent.social_status == 3 && !agent_at_home) ||
                        (agent2.social_status == 3 && !agent2_at_home)) && !is_university_holiday
                        make_contact(agent, agent2, get_contact_duration(7.0, 3.69),
                            current_temp, newly_infected_agents,
                            duration_parameter, temperature_parameters, susceptibility_parameters)
                    end
                end
                if !is_holiday && agent.group !== nothing && !agent.is_isolated && !agent.on_parent_leave
                    group = agent.group
                    if (agent.social_status == 1 && !is_kindergarten_holiday) ||
                        (agent.social_status == 2 && !is_school_holiday) ||
                        (agent.social_status == 3 && !is_university_holiday) ||
                        (agent.social_status == 4 && !is_work_holiday)
                        for agent2 in group.agents
                            if !agent2.is_isolated && !agent2.on_parent_leave
                                make_contact(
                                    agent,
                                    agent2,
                                    get_contact_duration(
                                        group.collective.mean_time_spent,
                                        group.collective.time_spent_sd),
                                    current_temp, newly_infected_agents,
                                    duration_parameter, temperature_parameters, susceptibility_parameters)
                            end
                        end
                    end
                end
            end

            # Обновление состояния восприимчивых агентов
            for i = 1:1000
                length = size(all_agents, 1)
                rand_num = rand(1:length)
                agent = all_agents[rand_num]
                if agent.virus === nothing && agent.days_immune == 0
                    infect_randomly(viruses, agent, week_num, etiologies)
                end
            end

            # Обновление состояния выздоровевших агентов
            i = size(all_recovered_agents, 1)
            while i > 0
                agent = all_recovered_agents[i]
                if agent.days_immune != 0
                    if agent.days_immune == 14
                        # Переход из резистентного состояния в восприимчивое
                        agent.days_immune = 0
                    else
                        agent.days_immune += 1
                    end
                end
                immunity_found = false
                for (virus, immunity_days) in agent.immunity_days
                    if immunity_days > 0
                        if immunity_days == immunity_durations[virus]
                            agent.immunity_days[virus] = 0
                        else
                            agent.immunity_days[virus] += 1
                            immunity_found = true
                        end
                    end
                end
                if !immunity_found
                    deleteat!(all_recovered_agents, i)
                end
                i -= 1
            end

            # Обновление состояния инфицированных агентов
            i = size(all_infected_agents, 1)
            while i > 0
                agent = all_infected_agents[i]
                if agent.days_infected == agent.infection_period
                    agent.immunity_days[agent.virus.name] = 1
                    agent.days_immune = 1
                    agent.virus = nothing
                    deleteat!(all_infected_agents, i)

                    if agent.supporter !== nothing
                        is_support_still_needed = false
                        for dependant in agent.supporter.dependants
                            if dependant.virus !== nothing && (dependant.social_status == 0 || dependant.is_isolated)
                                is_support_still_needed = true
                            end
                        end
                        if !is_support_still_needed
                            agent.supporter.on_parent_leave = false
                        end
                    end
                else
                    agent.days_infected += 1
                    update_infected_agent_state(viral_loads, agent)

                    if agent.supporter !== nothing && !agent.is_asymptomatic
                        if agent.days_infected > 0
                            if agent.is_isolated || agent.social_status == 0
                                agent.supporter.on_parent_leave = true
                            end
                        end
                    end
                    
                end

                #         agent.isStayingHomeWhenInfected = agent.findIfShouldStayAtHome()
                #         if (agent.isStayingHomeWhenInfected) {
                #             // Выявление
                #             newCasesDayStats[1] += 1
                #             when (agent.age) {
                #                 in (0..2) -> {
                #                     ageGroupsWeekStats[ageGroupsWeekStats.size - 1][0] += 1
                #                     ageGroupsDayStats[0] += 1
                #                 }
                #                 in (3..6) -> {
                #                     ageGroupsWeekStats[ageGroupsWeekStats.size - 1][1] += 1
                #                     ageGroupsDayStats[1] += 1
                #                 }
                #                 in (7..14) -> {
                #                     ageGroupsWeekStats[ageGroupsWeekStats.size - 1][2] += 1
                #                     ageGroupsDayStats[2] += 1
                #                 }
                #                 else -> {
                #                     ageGroupsWeekStats[ageGroupsWeekStats.size - 1][3] += 1
                #                     ageGroupsDayStats[3] += 1
                #                 }
                #             }

                #             when (agent.infectionType) {
                #                 "fluA" -> etiologyDayStats[0] += 1
                #                 "fluB" -> etiologyDayStats[1] += 1
                #                 "RV" -> etiologyDayStats[2] += 1
                #                 "RSV" -> etiologyDayStats[3] += 1
                #                 "AdV" -> etiologyDayStats[4] += 1
                #                 "PIV" -> etiologyDayStats[5] += 1
                #                 "CoV" -> etiologyDayStats[6] += 1
                #             }

                i -= 1
            end

            # for agent in newly_infected_agents
            #     println(agent.age)
            #     set_agent_infection(agent)
            # end
            # exit(0)

            for agent in newly_infected_agents
                set_agent_infection(viral_loads, agent)
            end

            # Обновление даты
            if week_day == 7
                week_day = 1
                if week_num == 52
                    week_num = 1
                else
                    week_num += 1
                end
            else
                week_day += 1
            end

            if year_day == 365
                year_day == 1
            else
                year_day += 1
            end

            if (month in Int[1, 3, 5, 7, 8, 10] && day == 31) ||
                (month in Int[4, 6, 9, 11] && day == 30) ||
                (month == 2 && day == 28)
                day = 1
                month += 1
                println("New month")
            elseif (month == 12 && day == 31)
                day = 1
                month = 1
                println("New month")
            else
                day += 1
            end

            append!(all_infected_agents, newly_infected_agents)
            push!(daily_new_cases, size(newly_infected_agents, 1))
        end

        new_cases_data = MPI.Reduce(daily_new_cases, MPI.SUM, 0, comm)
        # if comm_rank == 0
        #     daily_new_cases_plot = plot(1:1, new_cases_data, title = "Daily New Cases", lw = 3, legend = false)
        #     xlabel!("Day")
        #     ylabel!("Num of people")
        #     savefig(daily_new_cases_plot, joinpath(@__DIR__, "..", "output", "daily_new_cases.pdf"))
        # end
    end

    function main()
        MPI.Init()

        comm = MPI.COMM_WORLD
        comm_size = MPI.Comm_size(comm)
        comm_rank = MPI.Comm_rank(comm)

        if comm_rank == 0
            println("Initialization...")
        end
        
        # Вирусы
        viruses = Dict(
            "FluA" => Virus(1, "FluA", 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 16),
            "FluB" => Virus(2, "FluB", 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 16),
            "RV" => Virus(3, "RV", 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 30),
            "RSV" => Virus(4, "RSV", 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 30),
            "AdV" => Virus(5, "AdV", 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 30),
            "PIV" => Virus(6, "PIV", 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 30),
            "CoV" => Virus(7, "CoV", 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 30)
        )

        viral_loads = Array{Float64,4}(undef, 7, 7, 13, 21)

        for days_infected in -6:14
            days_infected_index = days_infected + 7
            for infection_period in 2:14
                infection_period_index = infection_period - 1
                for incubation_period in 1:7
                    min_days_infected = 1 - incubation_period
                    mean_viral_loads = [4.6, 4.7, 3.5, 6.0, 4.1, 4.7, 4.93]
                    for i in 1:7
                        if (days_infected >= min_days_infected) && (days_infected <= infection_period)
                            viral_loads[i, incubation_period, infection_period_index, days_infected_index] = get_viral_load(
                                days_infected, incubation_period, infection_period, mean_viral_loads[i])
                        end
                    end
                end
            end
        end

        # Набор агентов
        all_agents = Agent[]
        # Набор инфицированных агентов
        infected_agents = Agent[]

        @time create_population(viruses, viral_loads, comm_rank, comm_size, all_agents, infected_agents)
        # create_population(viruses, viral_loads, comm_rank, comm_size)

        MPI.Barrier(comm)
    
        if comm_rank == 0
            println("Simulation...")
        end
        @time run_simulation(viruses, viral_loads, comm_rank, comm, all_agents, infected_agents)
        # run_simulation()
    
        # MPI.Barrier(comm)
    end

    main()
end