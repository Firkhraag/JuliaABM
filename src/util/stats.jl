function get_stats(
    # Агенты
    agents::Vector{Agent},
    # Школы
    schools::Vector{School},
    # Рабочие коллективы
    workplaces::Vector{Workplace}
)
    println("Stats...")

    # Количество агентов по возрастам
    age_nums = zeros(Int, 90)
    # Количество агентов по возрастным группам
    num_agents_age_groups = zeros(Int, 4)

    # Количество агентов по коллективам
    activity_nums = Int[0, 0, 0, 0, length(agents)]
    # Количество агентов по размеру домохозяйства
    household_nums = Int[0, 0, 0, 0, 0, 0]
    # Средний общий уровень иммуноглобулинов
    mean_ig_level = 0.0
    # Число инфицированных агентов
    num_of_infected = 0
    # Число инфицированных агентов по возрастным группам
    num_of_infected_age_groups = Int[0, 0, 0, 0]
    # Число агентов в резистентном состоянии
    num_of_immune = 0
    # Число изолированных агентов
    num_of_isolated = 0
    # Число агентов, сидящих на больничном по уходу за ребенком
    num_of_parent_leave = 0
    mean_num_of_kinder_conn = 0
    mean_num_of_activity_conn = 0
    mean_num_of_univer_conn = 0
    mean_num_of_univer_cross_conn = 0
    mean_num_of_work_conn = 0
    size_kinder_conn = 0
    size_activity_conn = 0
    size_univer_conn = 0
    size_work_conn = 0

    num_immunity = zeros(Int, num_viruses)
    # Число инфицированных агентов для различных вирусов
    num_infected = zeros(Int, num_viruses)

    kindergarten_contacts = zeros(Int, kindergarten_groups_size_4_5 + 1)
    school_contacts = zeros(Int, school_groups_size_15 + 1)
    college_contacts = zeros(Int, college_groups_size_1 + 1)
    work_contacts = zeros(Int, 1000)

    mean_num_students = 0.0
    for school in schools
        num_students = 0
        for groups in school.groups
            for group in groups
                for agent_id in group
                    num_students += 1
                end
            end
        end
        mean_num_students += num_students
    end

    println("Mean num of school students: $(mean_num_students / length(schools))")

    t1 = 0
    t2 = 0
    t3 = 0

    age_diff = 0
    age_diff_num = 0

    for agent in agents
        if agent.age < 3
            num_agents_age_groups[1] += 1
        elseif agent.age < 7
            num_agents_age_groups[2] += 1
        elseif agent.age < 15
            num_agents_age_groups[3] += 1
        else
            num_agents_age_groups[4] += 1
        end

        age_nums[agent.age + 1] += 1
    
        # Если агент посещает детский сад
        if agent.activity_type == 1
            activity_nums[1] += 1
            mean_num_of_kinder_conn += size(agent.activity_conn_ids, 1)
            size_kinder_conn += 1
            if agent.is_teacher
                t1 += 1
            end
        # Если агент посещает школу
        elseif agent.activity_type == 2
            activity_nums[2] += 1
            mean_num_of_activity_conn += size(agent.activity_conn_ids, 1)
            size_activity_conn += 1
            if agent.is_teacher
                t2 += 1
            end
        # Если агент посещает вуз
        elseif agent.activity_type == 3
            activity_nums[3] += 1
            mean_num_of_univer_conn += size(agent.activity_conn_ids, 1)
            mean_num_of_univer_cross_conn += size(agent.activity_cross_conn_ids, 1)
            size_univer_conn += 1
            if agent.is_teacher
                t3 += 1
            end
        # Если агент работает
        elseif agent.activity_type == 4
            activity_nums[4] += 1
            mean_num_of_work_conn += size(agent.activity_conn_ids, 1)
            size_work_conn += 1
        end

        household_nums[size(agent.household_conn_ids, 1)] += 1

        mean_ig_level += agent.ig_level

        if agent.virus_id != 0
            num_of_infected += 1
            if agent.age < 3
                num_of_infected_age_groups[1] += 1
            elseif agent.age < 7
                num_of_infected_age_groups[2] += 1
            elseif agent.age < 15
                num_of_infected_age_groups[3] += 1
            else
                num_of_infected_age_groups[4] += 1
            end
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

        if agent.supporter_id != 0
            age_diff += agents[agent.supporter_id].age - agent.age
            age_diff_num += 1
        end

        for i = 1:num_viruses
            if agent.immunity_susceptibility_levels[i] < 0.999
                num_immunity[i] += 1
            end
        end

        if agent.activity_type == 1
            kindergarten_contacts[length(agent.activity_conn_ids)] += 1
        elseif agent.activity_type == 2
            school_contacts[length(agent.activity_conn_ids)] += 1
        elseif agent.activity_type == 3
            college_contacts[length(agent.activity_conn_ids)] += 1
        elseif agent.activity_type == 4
            work_contacts[length(agent.activity_conn_ids) + 1] += 1
        end

    end
    for i = 1:6
        household_nums[i] /= i
    end

    # Число агентов в рабочих коллективах
    workplaces_num_people = Int[]
    for workplace in workplaces
        push!(workplaces_num_people, length(workplace.agent_ids))
    end

    # Количество агентов по возрастным группам
    # println("Age groups:")
    # for i = 0:17
    #     sum = 0
    #     sum += age_nums[5 * i + 1]
    #     sum += age_nums[5 * i + 2]
    #     sum += age_nums[5 * i + 3]
    #     sum += age_nums[5 * i + 4]
    #     sum += age_nums[5 * i + 5]
    #     println("$(5 * i): $(sum)")
    # end

    # Сохраняем результаты
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "kindergarten_contacts.csv"), kindergarten_contacts, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "school_contacts.csv"), school_contacts, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "college_contacts.csv"), college_contacts, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "work_contacts.csv"), work_contacts, ',')

    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "age_nums.csv"), age_nums, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "num_agents_age_groups.csv"), num_agents_age_groups, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "household_size_distribution.csv"), household_nums, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "activity_sizes.csv"), activity_nums, ',')
    writedlm(joinpath(@__DIR__, "..", "..", "input", "tables", "workplaces_num_people.csv"), workplaces_num_people, ',')

    # Выводим результаты
    println("Main age groups: $(num_agents_age_groups)")
    println("Teachers 1: $(t1)")
    println("Teachers 2: $(t2)")
    println("Teachers 3: $(t3)")
    println("Activities: $(activity_nums)")
    println("Households: $(household_nums)")
    println("Contacts: $(2 * (household_nums[2] + 3 * household_nums[3] + 6 * household_nums[4] + 10 * household_nums[5] + 15 * household_nums[6]))")
    println("Ig level: $(mean_ig_level / size(agents, 1))")
    println("Infected: $(num_of_infected)")
    println("Infected age groups: $(num_of_infected_age_groups)")
    println("Kinder conn: $(mean_num_of_kinder_conn / size_kinder_conn)")
    println("School conn: $(mean_num_of_activity_conn / size_activity_conn)")
    println("Univer conn: $(mean_num_of_univer_conn / size_univer_conn)")
    println("Univer cross conn: $(mean_num_of_univer_cross_conn / size_univer_conn)")
    println("Mean work conn: $(mean_num_of_work_conn / size_work_conn)")
    println("Mean num of people in firms: $(mean(workplaces_num_people))")
    println("Mean mother child age difference: $(age_diff / age_diff_num)")
    println("Initial immunity: $(num_immunity)")
    println("Initial infected: $(num_infected)")
end
