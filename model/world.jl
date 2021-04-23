module Model
    using CSV
    using DataFrames

    include("entities.jl")

    # Температура воздуха, начиная с 1 января
    temp = [-5.8, -5.9, -5.9, -5.9,
        -6.0, -6.0, -6.1, -6.1, -6.2, -6.2, -6.2, -6.3,
        -6.3, -6.4, -6.5, -6.5, -6.6, -6.6, -6.7, -6.7,
        -6.8, -6.8, -6.9, -6.9, -7.0, -7.0, -7.0, -7.1, -7.1,
        -7.1, -7.1, -7.2, -7.2, -7.2, -7.2, -7.2, -7.2, -7.1,
        -7.1, -7.1, -7.0, -7.0, -6.9, -6.8, -6.8, -6.7, -6.6,
        -6.5, -6.4, -6.3, -6.1, -6.0, -5.9, -5.7, -5.6, -5.4,
        -5.2, -5.0, -4.8, -4.7, -4.7, -4.5, -4.2, -4.0, -3.8,
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
    year_day = 211
    # Номер недели
    week_num = 0
    # Шаг модели
    step = 0

    # agents::Vector{10000000}

    # current_kindergarten = Collective(1, 1)
    # current_school = Collective(1, 1)
    # current_university = Collective(1, 1)
    # current_workplace = Collective(1, 1)

    # Набор id инфицированных агентов
    infected_agents = Set()

    district_df = CSV.read(
        joinpath(@__DIR__, "..", "tables", "districts.csv"), DataFrame, tasks=1)
    district_household_df = CSV.read(
        joinpath(@__DIR__, "..", "tables", "districts_households.csv"), DataFrame, tasks=1)


    function create_agent(
        household::Collective,
        index::Int,
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
                return Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:(parent_age - 18)))
            elseif parent_age < 28
                if (age_rand_num <= district_df[index, "T0-4_0–9"])
                    Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:4))
                else
                    Agent(household, sex_random_num <= district_df[index, "M5–9"], rand(5:(parent_age - 18)))
                end
            elseif parent_age < 33
                if (age_rand_num <= district_df[index, "T0-4_0–14"])
                    Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:4))
                elseif (age_rand_num <= district_df[index, "T0-9_0–14"])
                    Agent(household, sex_random_num <= district_df[index, "M5–9"], rand(5:9))
                else
                    Agent(household, sex_random_num <= district_df[index, "M10–14"], rand(10:(parent_age - 18)))
                end
            elseif parent_age < 35
                age_group_rand_num = rand(1:100)
                if age_group_rand_num <= district_household_df[1, district_household_index]
                    if (age_rand_num <= district_df[index, "T0-4_0–14"])
                        Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:4))
                    elseif (age_rand_num <= district_df[index, "T0-9_0–14"])
                        Agent(household, sex_random_num <= district_df[index, "M5–9"], rand(5:9))
                    else
                        Agent(household, sex_random_num <= district_df[index, "M10–14"], rand(10:14))
                    end
                else
                    return Agent(household, sex_random_num <= district_df[index, "M15–19"], rand(15:(parent_age - 18)))
                end
            else
                age_group_rand_num = rand(1:100)
                if age_group_rand_num <= district_household_df[1, district_household_index]
                    if (age_rand_num <= district_df[index, "T0-4_0–14"])
                        Agent(household, sex_random_num <= district_df[index, "M0–4"], rand(0:4))
                    elseif (age_rand_num <= district_df[index, "T0-9_0–14"])
                        Agent(household, sex_random_num <= district_df[index, "M5–9"], rand(5:9))
                    else
                        Agent(household, sex_random_num <= district_df[index, "M10–14"], rand(10:14))
                    end
                else
                    return Agent(household, sex_random_num <= district_df[index, "M15–19"], rand(15:17))
                end
            end
        else
            age_group_rand_num = rand(1:100)
            if is_older
                age_group_rand_num = rand((district_household_df[3, district_household_index] + 1):100)
            elseif parent_age !== nothing
                if parent_age < 45
                    age_group_rand_num = 1
                elseif parent_age < 55
                    age_group_rand_num = rand(1:district_household_df[3, district_household_index])
                elseif parent_age < 65
                    age_group_rand_num = rand(1:district_household_df[4, district_household_index])
                else
                    age_group_rand_num = rand(1:district_household_df[5, district_household_index])
                end
            elseif is_parent_of_parent
                if parent_age < 25
                    age_group_rand_num = rand((district_household_df[3, district_household_index] + 1):100)
                elseif parent_age < 35
                    age_group_rand_num = rand((district_household_df[4, district_household_index] + 1):100)
                elseif parent_age < 45
                    age_group_rand_num = rand((district_household_df[5, district_household_index] + 1):100)
                else
                    age_group_rand_num = 100
                end
            end
            if age_group_rand_num <= district_household_df[2, district_household_index]
                if is_male !== nothing
                    return Agent(household, is_male, rand(18:24))
                else
                    return Agent(household, sex_random_num <= district_df[index, "M20–24"], rand(18:24))
                end
            elseif age_group_rand_num <= district_household_df[3, district_household_index]
                if age_rand_num <= district_df[index, "T25-29_25–34"]
                    if is_male !== nothing
                        return Agent(household, is_male, rand(25:29))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M25–29"], rand(25:29))
                    end
                else
                    if is_male !== nothing
                        return Agent(household, is_male, rand(30:34))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M30–34"], rand(30:34))
                    end
                end
            elseif age_group_rand_num <= district_household_df[4, district_household_index]
                if age_rand_num <= district_df[index, "T35-39_35–44"]
                    if is_male !== nothing
                        return Agent(household, is_male, rand(35:39))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M35–39"], rand(35:39))
                    end
                else
                    if is_male !== nothing
                        return Agent(household, is_male, rand(40:44))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M40–44"], rand(40:44))
                    end
                end
            elseif age_group_rand_num <= district_household_df[5, district_household_index]
                if age_rand_num <= district_df[index, "T45-49_45–54"]
                    if is_male !== nothing
                        return Agent(household, is_male, rand(45:49))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M45–49"], rand(45:49))
                    end
                else
                    if is_male !== nothing
                        return Agent(household, is_male, rand(50:54))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M50–54"], rand(50:54))
                    end
                end
            elseif age_group_rand_num <= district_household_df[6, district_household_index]
                if age_rand_num <= district_df[index, "T55-59_55–64"]
                    if is_male !== nothing
                        return Agent(household, is_male, rand(55:59))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M55–59"], rand(55:59))
                    end
                else
                    if is_male !== nothing
                        return Agent(household, is_male, rand(60:64))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M60–64"], rand(60:64))
                    end
                end
            else
                if age_rand_num <= district_df[index, "T65-69_65–89"]
                    if is_male !== nothing
                        return Agent(household, is_male, rand(65:69))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M65–69"], rand(65:69))
                    end
                elseif age_rand_num <= district_df[index, "T65-74_65–89"]
                    if is_male !== nothing
                        return Agent(household, is_male, rand(70:74))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M70–74"], rand(70:74))
                    end
                elseif age_rand_num <= district_df[index, "T65-79_65–89"]
                    if is_male !== nothing
                        return Agent(household, is_male, rand(75:79))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M75–79"], rand(75:79))
                    end
                elseif age_rand_num <= district_df[index, "T65-84_65–89"]
                    if is_male !== nothing
                        return Agent(household, is_male, rand(80:84))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M80–84"], rand(80:84))
                    end
                else
                    if is_male !== nothing
                        return Agent(household, is_male, rand(85:89))
                    else
                        return Agent(household, sex_random_num <= district_df[index, "M85–89"], rand(85:89))
                    end
                end
            end
        end
    end

    function create_spouse(household::Collective, partner_age::Int)
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
        return Agent(household, false, spouse_age)
    end

    function check_parent_leave(no_one_at_home::Bool, adult::Agent, child::Agent)
        if no_one_at_home && child.age < 14
            adult.need_parent_leave = true
            if child.age < 3 && child.social_status == 0
                adult.social_status == 0
            end
        end
    end

    function create_parents_with_children(
        household::Collective,
        district_household_index::Int,
        num_of_children::Int,
        num_of_other_people::Int,
        index::Int
    )::Vector{Agent}
        agent_male = create_agent(household, index, district_household_index, true)
        agent_female = create_spouse(household, agent_male.age)
        agent_other::Union{Agent, Nothing} = nothing
        agent_other2::Union{Agent, Nothing} = nothing
        agent_other3::Union{Agent, Nothing} = nothing
        agent_other4::Union{Agent, Nothing} = nothing
        if num_of_other_people > 0
            agent_other = create_agent(household, index, district_household_index)
            if num_of_other_people > 1
                agent_other2 = create_agent(household, index, district_household_index)
                if num_of_other_people > 2
                    agent_other3 = create_agent(household, index, district_household_index)
                    if num_of_other_people > 3
                        agent_other4 = create_agent(household, index, district_household_index)
                    end
                end
            end
        end
        if num_of_children > 0
            child = create_agent(household, index, district_household_index, nothing, true, agent_female.age)
            no_one_at_home = agent_male.social_status != 0 && agent_female.social_status != 0
            if agent_other !== nothing && agent_other.social_status == 0
                no_one_at_home = false
            elseif agent_other2 !== nothing && agent_other2.social_status == 0
                no_one_at_home = false
            elseif agent_other3 !== nothing && agent_other3.social_status == 0
                no_one_at_home = false
            elseif agent_other4 !== nothing && agent_other4.social_status == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                if agent_other4 !== nothing
                    return Agent[agent_male, agent_female, child, agent_other, agent_other2, agent_other3, agent_other4]
                elseif agent_other3 !== nothing
                    return Agent[agent_male, agent_female, child, agent_other, agent_other2, agent_other3]
                elseif agent_other2 !== nothing
                    return Agent[agent_male, agent_female, child, agent_other, agent_other2]
                elseif agent_other !== nothing
                    return Agent[agent_male, agent_female, child, agent_other]
                end
                return Agent[agent_male, agent_female, child]
            end

            child2 = create_agent(household, index, district_household_index, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                if agent_other4 !== nothing
                    return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
                elseif agent_other3 !== nothing
                    return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2, agent_other3]
                elseif agent_other2 !== nothing
                    return Agent[agent_male, agent_female, child, child2, agent_other, agent_other2]
                elseif agent_other !== nothing
                    return Agent[agent_male, agent_female, child, child2, agent_other]
                end
                return Agent[agent_male, agent_female, child, child2]
            end

            child3 = create_agent(household, index, district_household_index, nothing, true, agent_female.age)
            check_parent_leave(no_one_at_home, agent_female, child3)
            if agent_other4 !== nothing
                return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[agent_male, agent_female, child, child2, child3, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[agent_male, agent_female, child, child2, child3, agent_other]
            end
            return Agent[agent_male, agent_female, child, child2, child3]
        end
        if agent_other4 !== nothing
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4]
        elseif agent_other3 !== nothing
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
        elseif agent_other2 !== nothing
            return Agent[agent_male, agent_female, agent_other, agent_other2]
        elseif agent_other !== nothing
            return Agent[agent_male, agent_female, agent_other]
        end
        return Agent[agent_male, agent_female]
    end

    function create_parent_with_children(
        household::Collective,
        district_household_index::Int,
        num_of_children::Int,
        num_of_other_people::Int,
        index::Int,
        is_male_parent::Union{Bool, Nothing},
        with_parent_of_parent::Bool = false
    )::Vector{Agent}
        parent = create_agent(household, index, district_household_index, is_male_parent, false, nothing, num_of_other_people > 0)
        agent_other::Union{Agent, Nothing} = nothing
        agent_other2::Union{Agent, Nothing} = nothing
        agent_other3::Union{Agent, Nothing} = nothing
        agent_other4::Union{Agent, Nothing} = nothing
        if num_of_other_people > 0
            if with_parent_of_parent
                agent_other = create_agent(household, index, district_household_index, nothing, false, parent.age, false, true)
            else
                agent_other = create_agent(household, index, district_household_index, nothing, false, parent.age)
            end
            if num_of_other_people > 1
                agent_other2 = create_agent(household, index, district_household_index, nothing, false, parent.age)
                if num_of_other_people > 2
                    agent_other3 = create_agent(household, index, district_household_index, nothing, false, parent.age)
                    if num_of_other_people > 3
                        agent_other4 = create_agent(household, index, district_household_index, nothing, false, parent.age)
                    end
                end
            end
        end
        if num_of_children > 0
            child = create_agent(household, index, district_household_index, nothing, true, parent.age)
            no_one_at_home = parent.social_status != 0
            if agent_other !== nothing && agent_other.social_status == 0
                no_one_at_home = false
            elseif agent_other2 !== nothing && agent_other2.social_status == 0
                no_one_at_home = false
            elseif agent_other3 !== nothing && agent_other3.social_status == 0
                no_one_at_home = false
            elseif agent_other4 !== nothing && agent_other4.social_status == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                if agent_other4 !== nothing
                    return Agent[parent, child, agent_other, agent_other2, agent_other3, agent_other4]
                elseif agent_other3 !== nothing
                    return Agent[parent, child, agent_other, agent_other2, agent_other3]
                elseif agent_other2 !== nothing
                    return Agent[parent, child, agent_other, agent_other2]
                elseif agent_other !== nothing
                    return Agent[parent, child, agent_other]
                end
                return Agent[parent, child]
            end

            child2 = create_agent(household, index, district_household_index, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                if agent_other4 !== nothing
                    return Agent[parent, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
                elseif agent_other3 !== nothing
                    return Agent[parent, child, child2, agent_other, agent_other2, agent_other3]
                elseif agent_other2 !== nothing
                    return Agent[parent, child, child2, agent_other, agent_other2]
                elseif agent_other !== nothing
                    return Agent[parent, child, child2, agent_other]
                end
                return Agent[parent, child, child2]
            end

            child3 = create_agent(household, index, district_household_index, nothing, true, parent.age)
            check_parent_leave(no_one_at_home, parent, child3)
            if agent_other4 !== nothing
                return Agent[parent, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[parent, child, child2, child3, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[parent, child, child2, child3, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[parent, child, child2, child3, agent_other]
            end
            return Agent[parent, child, child2, child3]
        end
        if agent_other4 !== nothing
            return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4]
        elseif agent_other3 !== nothing
            return Agent[parent, agent_other, agent_other2, agent_other3]
        elseif agent_other2 !== nothing
            return Agent[parent, agent_other, agent_other2]
        elseif agent_other !== nothing
            return Agent[parent, agent_other]
        end
    end

    function create_others(
        household::Collective,
        district_household_index::Int,
        num_of_children::Int,
        num_of_other_people::Int,
        index::Int
    )::Vector{Agent}
        agent = create_agent(household, index, district_household_index)
        agent_other::Union{Agent, Nothing} = nothing
        agent_other2::Union{Agent, Nothing} = nothing
        agent_other3::Union{Agent, Nothing} = nothing
        agent_other4::Union{Agent, Nothing} = nothing
        if num_of_other_people > 1
            agent_other = create_agent(household, index, district_household_index)
            if num_of_other_people > 2
                agent_other2 = create_agent(household, index, district_household_index)
                if num_of_other_people > 3
                    agent_other3 = create_agent(household, index, district_household_index)
                    if num_of_other_people > 4
                        agent_other4 = create_agent(household, index, district_household_index)
                    end
                end
            end
        end
        if num_of_children > 0
            child = create_agent(household, index, district_household_index, nothing, true, 35)
            no_one_at_home = agent.social_status != 0
            if agent_other !== nothing && agent_other.social_status == 0
                no_one_at_home = false
            elseif agent_other2 !== nothing && agent_other2.social_status == 0
                no_one_at_home = false
            elseif agent_other3 !== nothing && agent_other3.social_status == 0
                no_one_at_home = false
            elseif agent_other4 !== nothing && agent_other4.social_status == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                if agent_other4 !== nothing
                    return Agent[agent, child, agent_other, agent_other2, agent_other3, agent_other4]
                elseif agent_other3 !== nothing
                    return Agent[agent, child, agent_other, agent_other2, agent_other3]
                elseif agent_other2 !== nothing
                    return Agent[agent, child, agent_other, agent_other2]
                elseif agent_other !== nothing
                    return Agent[agent, child, agent_other]
                end
                return Agent[agent, child]
            end

            child2 = create_agent(household, index, district_household_index, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                if agent_other4 !== nothing
                    return Agent[agent, child, child2, agent_other, agent_other2, agent_other3, agent_other4]
                elseif agent_other3 !== nothing
                    return Agent[agent, child, child2, agent_other, agent_other2, agent_other3]
                elseif agent_other2 !== nothing
                    return Agent[agent, child, child2, agent_other, agent_other2]
                elseif agent_other !== nothing
                    return Agent[agent, child, child2, agent_other]
                end
                return Agent[agent, child, child2]
            end

            child3 = create_agent(household, index, district_household_index, nothing, true, 35)
            check_parent_leave(no_one_at_home, agent, child3)
            if agent_other4 !== nothing
                return Agent[agent, child, child2, child3, agent_other, agent_other2, agent_other3, agent_other4]
            elseif agent_other3 !== nothing
                return Agent[agent, child, child2, child3, agent_other, agent_other2, agent_other3]
            elseif agent_other2 !== nothing
                return Agent[agent, child, child2, child3, agent_other, agent_other2]
            elseif agent_other !== nothing
                return Agent[agent, child, child2, child3, agent_other]
            end
            return Agent[agent, child, child2, child3]
        end
        if agent_other4 !== nothing
            return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
        elseif agent_other3 !== nothing
            return Agent[agent, agent_other, agent_other2, agent_other3]
        elseif agent_other2 !== nothing
            return Agent[agent, agent_other, agent_other2]
        elseif agent_other !== nothing
            return Agent[agent, agent_other]
        end
    end

    function add_agents_to_kindergarten(agents::Vector{Agent}, kindergarten_group::Collective)
        # Should lock threads
        for agent in agents
            if agent.social_status == 1
                push!(kindergarten_group.agents, agent)



        #         // Выбор группы по возрасту
        # val groupNum = when (agent.age) {
        #     0 -> 0
        #     1 -> 1
        #     2 -> if ((0..1).random() == 0) 1 else 2
        #     3 -> if ((0..1).random() == 0) 2 else 3
        #     4 -> if ((0..1).random() == 0) 3 else 4
        #     5 -> if ((0..1).random() == 0) 4 else 5
        #     6 -> 5
        #     else -> error("Wrong age")
        # }
        # // Добавление группы, если отсутствует
        # if (groupsByAge[groupNum].size == 0) {
        #     groupsByAge[groupNum].add(Group())
        # }
        # // Группа заполнена
        # if (groupsByAge[groupNum][groupsByAge[groupNum].size - 1].agents.size == currentGroupSize[groupNum]) {
        #     groupsByAge[groupNum].add(Group())
        #     currentGroupSize[groupNum] = findNumberOfPeople(groupNum)
        # }
        # // Добавление агента в последнюю добавленную группу
        # groupsByAge[groupNum][groupsByAge[groupNum].size - 1].addAgent(agent)



            end
        end
        # agents.forEach { agent ->
        #     when (agent.activityStatus) {
        #         1 -> kindergarten.addAgent(agent)
        #         2 -> school.addAgent(agent)
        #         3 -> university.addAgent(agent)
        #         4 -> workplace.addAgent(agent)
        #     }
        #     // Добавление в домохозяйство
        #     household.addAgent(agent)
        # }
        # // Добавление нового домохозяйства в массив домохозяйств
        # households.add(household)
    end

    function add_agents_to_collectives(agents::Vector{Agent})
        # Should lock threads
        for agent in agents
            if agent.virus !== nothing
                l = ReentrantLock()
                lock(l)
                try
                    push!(infected_agents, 1)
                finally
                    unlock(l)
                end
            end
            if agent.social_status == 1
                
            elseif agent.social_status == 2

            elseif agent.social_status == 3

            elseif agent.social_status == 4

            end
        end
        # agents.forEach { agent ->
        #     when (agent.activityStatus) {
        #         1 -> kindergarten.addAgent(agent)
        #         2 -> school.addAgent(agent)
        #         3 -> university.addAgent(agent)
        #         4 -> workplace.addAgent(agent)
        #     }
        #     // Добавление в домохозяйство
        #     household.addAgent(agent)
        # }
        # // Добавление нового домохозяйства в массив домохозяйств
        # households.add(household)
    end

    function create_population()
        progress_counter = Threads.Atomic{Int}(0)
        Threads.@threads for index = 1:107
            current_kindergarten_group = Collective(5.88, 2.52)
            # println(index)
            index_for_1_people::Int = (index - 1) * 5 + 1
            index_for_2_people::Int = index_for_1_people + 1
            index_for_3_people::Int = index_for_2_people + 1
            index_for_4_people::Int = index_for_3_people + 1
            index_for_5_people::Int = index_for_4_people + 1
            for i in 1:district_df[index, "1P"]
                household = Collective(12.4, 5.13)
                agents = Agent[create_agent(household, index, index_for_1_people)]
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP2P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_2_people, 0, 0, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP3P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_3_people, 0, 1, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP3P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_3_people, 1, 0, index)
                household.agents = agents
                add_agents_to_kindergarten(agents, current_kindergarten_group)
                
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP4P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_4_people, 0, 2, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP4P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_4_people, 1, 1, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP4P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_4_people, 2, 0, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP5P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_5_people, 0, 3, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP5P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_5_people, 1, 2, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP5P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_5_people, 2, 1, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP5P3C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_5_people, 3, 0, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP6P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_5_people, 0, 4, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP6P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_5_people, 1, 3, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP6P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_5_people, 2, 2, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "PWOP6P3C"]
                household = Collective(12.4, 5.13)
                agents = create_parents_with_children(household, index_for_5_people, 3, 1, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "2PWOP4P0C"]
                household = Collective(12.4, 5.13)
                pair1 = create_parents_with_children(household, index_for_4_people, 0, 0, index)
                pair2 = create_parents_with_children(household, index_for_4_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "2PWOP5P0C"]
                household = Collective(12.4, 5.13)
                pair1 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "2PWOP5P1C"]
                household = Collective(12.4, 5.13)
                pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "2PWOP6P0C"]
                household = Collective(12.4, 5.13)
                pair1 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "2PWOP6P1C"]
                household = Collective(12.4, 5.13)
                pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "2PWOP6P2C"]
                household = Collective(12.4, 5.13)
                pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC2P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_2_people, 0, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC2P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_2_people, 1, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC3P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC3P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC3P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC3P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC4P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC4P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC4P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SMWC4P3C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 3, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SFWC2P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_2_people, 0, 1, index, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SFWC2P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_2_people, 1, 0, index, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SFWC3P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SFWC3P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SFWC3P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWP3P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWP3P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWP4P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWP4P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWP4P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end

            for i in 1:district_df[index, "SPWCWPWOP3P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWPWOP3P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWPWOP4P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWPWOP4P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWPWOP4P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWPWOP5P0C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_5_people, 0, 4, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWPWOP5P1C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_5_people, 1, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "SPWCWPWOP5P2C"]
                household = Collective(12.4, 5.13)
                agents = create_parent_with_children(household, index_for_5_people, 2, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(agents)
            end

            for i in 1:district_df[index, "O2P0C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_2_people, 0, 2, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O2P1C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_2_people, 1, 1, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O3P0C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_3_people, 0, 3, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O3P1C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_3_people, 1, 2, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O3P2C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_3_people, 2, 1, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O4P0C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_4_people, 0, 4, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O4P1C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_4_people, 1, 3, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O4P2C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_4_people, 2, 2, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O5P0C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_5_people, 0, 5, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O5P1C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_5_people, 1, 4, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            for i in 1:district_df[index, "O5P2C"]
                household = Collective(12.4, 5.13)
                agents = create_others(household, index_for_5_people, 2, 3, index)
                household.agents = agents
                add_agents_to_collectives(agents)
            end
            break
        end
    end

    @time create_population()
    println(length(infected_agents))
end


# // Взрослый
# // Случайное число для возрастной группы
# val ageGroupRandomNum = if (isOld != null) {
#     if (isOld) {
#         // Взрослый в возрасте
#         // 45+
#         (district_household_df[12, "$(index)_$(size_of_household)"] + 1..100).random()
#     } else {
#         // Более молодой взрослый
#         // 18-54
#         (1..district_household_df[13, "$(index)_$(size_of_household)"]).random()
#     }
# } else {
#     (1..100).random()
# }
