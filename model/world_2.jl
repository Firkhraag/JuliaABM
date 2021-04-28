module Model
    using CSV
    using DataFrames
    using Plots
    using MPI
    
    include("collective.jl")

    # DEBUG
    max_simulation_step = 10
    is_break = false

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

    district_df = CSV.read(
        joinpath(@__DIR__, "..", "tables", "districts.csv"), DataFrame, tasks=1)
    district_household_df = CSV.read(
        joinpath(@__DIR__, "..", "tables", "districts_households.csv"), DataFrame, tasks=1)
    etiologies = CSV.read(
        joinpath(@__DIR__, "..", "tables", "etiologies.csv"), DataFrame, tasks=1)
    temperature_df = CSV.read(
        joinpath(@__DIR__, "..", "tables", "temperature.csv"), DataFrame, tasks=1)
    processes_df = CSV.read(
        joinpath(@__DIR__, "..", "tables", "num_of_people_sort.csv"), DataFrame, tasks=1)

    MPI.Init()

    comm = MPI.COMM_WORLD
    comm_size = MPI.Comm_size(comm)
    comm_rank = MPI.Comm_rank(comm)

    district_nums = filter(x -> x["Process_$(comm_size)"] == comm_rank, processes_df)[:, "District"]

    # Набор агентов
    all_agents = Agent[]
    # Набор инфицированных агентов
    infected_agents = Agent[]

    function create_agent(
        household::Group,
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

    function create_spouse(household::Group, partner_age::Int)
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
            push!(adult.dependants, child)
            child.supporter = adult
            if child.age < 3 && child.social_status == 0
                adult.social_status == 0
            end
        end
    end

    function create_parents_with_children(
        household::Group,
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
        household::Group,
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
        household::Group,
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
            push!(all_agents, agent)
        end
    end

    function create_population(district_nums::Vector{Int})
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
        for index in district_nums

            index_for_1_people::Int = (index - 1) * 5 + 1
            index_for_2_people::Int = index_for_1_people + 1
            index_for_3_people::Int = index_for_2_people + 1
            index_for_4_people::Int = index_for_3_people + 1
            index_for_5_people::Int = index_for_4_people + 1
            for i in 1:district_df[index, "1P"]
                household = Group()
                agents = Agent[create_agent(household, index, index_for_1_people)]
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP2P0C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_2_people, 0, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP3P0C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_3_people, 0, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP3P1C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_3_people, 1, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP4P0C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_4_people, 0, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP4P1C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_4_people, 1, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP4P2C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_4_people, 2, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP5P0C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_5_people, 0, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP5P1C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_5_people, 1, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP5P2C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_5_people, 2, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP5P3C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_5_people, 3, 0, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP6P0C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_5_people, 0, 4, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP6P1C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_5_people, 1, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP6P2C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_5_people, 2, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "PWOP6P3C"]
                household = Group()
                agents = create_parents_with_children(household, index_for_5_people, 3, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "2PWOP4P0C"]
                household = Group()
                pair1 = create_parents_with_children(household, index_for_4_people, 0, 0, index)
                pair2 = create_parents_with_children(household, index_for_4_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "2PWOP5P0C"]
                household = Group()
                pair1 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "2PWOP5P1C"]
                household = Group()
                pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 0, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "2PWOP6P0C"]
                household = Group()
                pair1 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "2PWOP6P1C"]
                household = Group()
                pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 0, 1, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "2PWOP6P2C"]
                household = Group()
                pair1 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
                pair2 = create_parents_with_children(household, index_for_5_people, 1, 0, index)
                agents = vcat(pair1, pair2)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC2P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_2_people, 0, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC2P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_2_people, 1, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC3P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC3P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC3P2C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC3P2C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC4P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC4P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC4P2C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SMWC4P3C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 3, 0, index, false)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SFWC2P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_2_people, 0, 1, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SFWC2P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_2_people, 1, 0, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SFWC3P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SFWC3P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SFWC3P2C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 2, 0, index, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWP3P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWP3P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWP4P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWP4P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWP4P2C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end

            for i in 1:district_df[index, "SPWCWPWOP3P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 0, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWPWOP3P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_3_people, 1, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWPWOP4P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 0, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWPWOP4P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 1, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWPWOP4P2C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_4_people, 2, 1, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWPWOP5P0C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_5_people, 0, 4, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWPWOP5P1C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_5_people, 1, 3, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "SPWCWPWOP5P2C"]
                household = Group()
                agents = create_parent_with_children(household, index_for_5_people, 2, 2, index, nothing, true)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end

            for i in 1:district_df[index, "O2P0C"]
                household = Group()
                agents = create_others(household, index_for_2_people, 0, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O2P1C"]
                household = Group()
                agents = create_others(household, index_for_2_people, 1, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O3P0C"]
                household = Group()
                agents = create_others(household, index_for_3_people, 0, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O3P1C"]
                household = Group()
                agents = create_others(household, index_for_3_people, 1, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O3P2C"]
                household = Group()
                agents = create_others(household, index_for_3_people, 2, 1, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O4P0C"]
                household = Group()
                agents = create_others(household, index_for_4_people, 0, 4, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O4P1C"]
                household = Group()
                agents = create_others(household, index_for_4_people, 1, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O4P2C"]
                household = Group()
                agents = create_others(household, index_for_4_people, 2, 2, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O5P0C"]
                household = Group()
                agents = create_others(household, index_for_5_people, 0, 5, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O5P1C"]
                household = Group()
                agents = create_others(household, index_for_5_people, 1, 4, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end
            for i in 1:district_df[index, "O5P2C"]
                household = Group()
                agents = create_others(household, index_for_5_people, 2, 3, index)
                household.agents = agents
                add_agents_to_collectives(
                    agents, kindergarten, kindergarten_group_sizes,
                    school, school_group_sizes,
                    university, university_group_sizes,
                    workplace, workplace_group_sizes)
            end

            # DEBUG
            if is_break
                break
            end
        end
    end

    function update_infected_agent_state(agent::Agent)
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
            agent.days_infected,
            agent.infection_period,
            agent.incubation_period,
            agent.is_asymptomatic && agent.days_infected > 0,
            agent.virus.id)
    end

    function set_agent_infection(agent::Agent)
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
        agent.days_infected = 1 - incubation_period

        if rand(1:100) <= agent.virus.asymptomatic_probab
            # Асимптомный
            agent.is_asymptomatic = true
        end

        # Вирусная нагрузка
        agent.viral_load = find_agent_viral_load(
            agent.age,
            agent.days_infected,
            agent.infection_period,
            agent.incubation_period,
            agent.is_asymptomatic && agent.days_infected > 0,
            agent.virus.id)
    end

    function get_contact_duration(mean::Float64, sd::Float64)
        return rand(truncated(Normal(mean, sd), 0.0, Inf))
    end

    function make_contact(
        infected_agent::Agent,
        agent::Agent,
        contact_duration::Float64,
        current_temp::Float64,
        newly_infected_agents::Vector{Agent}
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

    function infect_randomly(agent::Agent, week_num::Int)
        rand_num = rand(Float64)
        if rand_num < etiologies[week_num, "FluA"]
            if agent.immunity_days["FluA"] == 0
                agent.virus = viruses["FluA"]
            end
        elseif rand_num < etiologies[week_num, "FluB"]
            if agent.immunity_days["FluB"] == 0
                agent.virus = viruses["FluB"]
            end
        elseif rand_num < etiologies[week_num, "RV"]
            if agent.immunity_days["RV"] == 0
                agent.virus = viruses["RV"]
            end
        elseif rand_num < etiologies[week_num, "RSV"]
            if agent.immunity_days["RSV"] == 0
                agent.virus = viruses["RSV"]
            end
        elseif rand_num < etiologies[week_num, "AdV"]
            if agent.immunity_days["AdV"] == 0
                agent.virus = viruses["AdV"]
            end
        elseif rand_num < etiologies[week_num, "PIV"]
            if agent.immunity_days["PIV"] == 0
                agent.virus = viruses["PIV"]
            end
        else
            if agent.immunity_days["CoV"] == 0
                agent.virus = viruses["CoV"]
            end
        end
    end

    function run_simulation()
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
        for step = 1:max_simulation_step
            if step == 10
                println("Step $(comm_rank)")
            end
            # Набор инфицированных агентов на данном шаге
            newly_infected_agents = Agent[]
            # Текущая нормализованная температура
            current_temp = (temperature_df[1, year_day] - min_temp) / max_min_temp

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

            for agent in all_infected_agents
                for agent2 in agent.household.agents
                    agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.social_status == 0
                    agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.social_status == 0
                    if is_holiday || (agent_at_home && agent2_at_home)
                        make_contact(agent, agent2, get_contact_duration(12.5, 5.5),
                            current_temp, newly_infected_agents)
                    elseif ((agent.social_status == 1 && !agent_at_home) ||
                        (agent2.social_status == 1 && !agent2_at_home)) && !is_kindergarten_holiday
                        make_contact(agent, agent2, get_contact_duration(5.0, 2.05),
                            current_temp, newly_infected_agents)
                    elseif ((agent.social_status == 4 && !agent_at_home) ||
                        (agent2.social_status == 4 && !agent2_at_home)) && !is_work_holiday
                        make_contact(agent, agent2, get_contact_duration(5.5, 2.25),
                            current_temp, newly_infected_agents)
                    elseif ((agent.social_status == 2 && !agent_at_home) ||
                        (agent2.social_status == 2 && !agent2_at_home)) && !is_school_holiday
                        make_contact(agent, agent2, get_contact_duration(6.0, 2.46),
                            current_temp, newly_infected_agents)
                    elseif ((agent.social_status == 3 && !agent_at_home) ||
                        (agent2.social_status == 3 && !agent2_at_home)) && !is_university_holiday
                        make_contact(agent, agent2, get_contact_duration(7.0, 3.69),
                            current_temp, newly_infected_agents)
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
                                    current_temp,
                                    newly_infected_agents)
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
                    if agent.age < 16
                        infect_randomly(agent, week_num)
                    else
                        infect_randomly(agent, week_num)
                    end
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
                    update_infected_agent_state(agent)

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

            Threads.@threads for agent in newly_infected_agents
                set_agent_infection(agent)
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

            all_infected_agents = vcat(all_infected_agents, newly_infected_agents)
            push!(daily_new_cases, size(newly_infected_agents, 1))
        end


        new_cases_data = MPI.Reduce(daily_new_cases, MPI.SUM, 0, comm)
        if comm_rank == 0
            daily_new_cases_plot = plot(1:max_simulation_step, new_cases_data, title = "Daily New Cases", lw = 3, legend = false)
            xlabel!("Day")
            ylabel!("Num of people")
            savefig(daily_new_cases_plot, joinpath(@__DIR__, "..", "output", "daily_new_cases.pdf"))
        end
    end

    println("Initialization $(comm_rank)")
    # @time create_population()
    @time create_population(district_nums)

    println(size(all_agents, 1))

    # println("Simulation $(comm_rank)")
    # @time run_simulation()
    # run_simulation()

    MPI.Barrier(comm)
end
