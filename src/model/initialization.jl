# Пол и возраст агента
function get_agent_sex_and_age(
    # Номер муниципалитета
    index::Int,
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people::Matrix{Float64},
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households::Matrix{Float64},
    # Индекс числа людей в домохозяйстве для таблицы district_people_households
    district_household_index::Int,
    # Генератор случайных чисел
    rng::MersenneTwister,
    # Пол, если нужен тольео возраст агента
    is_male::Union{Bool, Nothing} = nothing,
    # Является ли агент ребенком (до 18 лет)
    is_child::Bool = false,
)::Tuple{Bool, Int}
    # Случайное число для возраста
    age_rand_num = rand(rng, Float64)
    # Случайное число для пола
    sex_random_num = rand(rng, Float64)
    # Если ребенок
    if is_child
        # Случайное число для возрастной группы
        age_group_rand_num = rand(rng, Float64)
        # Возрастная группа 0-14 лет
        if age_group_rand_num < district_people_households[1, district_household_index]
            # 0-4 лет
            if age_rand_num < district_people[index, 20] * 0.95
                # Случайное число для возраста в группе
                sub_age_group_rand_num = rand(rng, Float64)
                if sub_age_group_rand_num < 0.22
                    return sex_random_num < district_people[index, 1], 4
                elseif sub_age_group_rand_num < 0.43
                    return sex_random_num < district_people[index, 1], 3
                elseif sub_age_group_rand_num < 0.63
                    return sex_random_num < district_people[index, 1], 2
                elseif sub_age_group_rand_num < 0.82
                    return sex_random_num < district_people[index, 1], 1
                else
                    return sex_random_num < district_people[index, 1], 0
                end
            # 5-9 лет
            elseif age_rand_num < district_people[index, 21]
                return sex_random_num < district_people[index, 2], rand(rng, 5:9)
            # 10–14 лет
            else
                # Случайное число для возраста в группе
                sub_age_group_rand_num = rand(rng, Float64)
                if sub_age_group_rand_num < 0.21
                    return sex_random_num < district_people[index, 1], 10
                elseif sub_age_group_rand_num < 0.41
                    return sex_random_num < district_people[index, 1], 11
                elseif sub_age_group_rand_num < 0.6
                    return sex_random_num < district_people[index, 1], 12
                elseif sub_age_group_rand_num < 0.79
                    return sex_random_num < district_people[index, 1], 13
                else
                    return sex_random_num < district_people[index, 1], 14
                end
            end
        # Возрастная группа 15-17 лет
        else
            # Случайное число для возраста в группе
            sub_age_group_rand_num = rand(rng, Float64)
            if sub_age_group_rand_num < 0.36
                return sex_random_num < district_people[index, 4], 17
            elseif sub_age_group_rand_num < 0.69
                return sex_random_num < district_people[index, 4], 16
            else
                return sex_random_num < district_people[index, 4], 15
            end
        end
    else
        # Случайное число для возрастной группы
        age_group_rand_num = rand(rng, Float64)
        # Возрастная группа 18-24 лет
        if age_group_rand_num < district_people_households[2, district_household_index] * 0.95
            # 18–19 лет
            if rand(rng, Float64) < 0.1
                # Если известен пол
                if is_male !== nothing
                    if rand(rng, Float64) < 0.66
                        return is_male, 19
                    else
                        return is_male, 18
                    end
                # Если пол неизвестен
                else
                    if rand(rng, Float64) < 0.66
                        return sex_random_num < district_people[index, 5], 19
                    else
                        return sex_random_num < district_people[index, 5], 18
                    end
                end
            # Возрастная группа 20-24 лет
            else
                # Случайное число для возраста в группе
                sub_age_group_rand_num = rand(rng, Float64)
                # Если пол известен
                if is_male !== nothing
                    if sub_age_group_rand_num < 0.24
                        return is_male, 24
                    elseif sub_age_group_rand_num < 0.46
                        return is_male, 23
                    elseif sub_age_group_rand_num < 0.66
                        return is_male, 22
                    elseif sub_age_group_rand_num < 0.84
                        return is_male, 21
                    else
                        return is_male, 20
                    end
                # Если пол неизвестен
                else
                    if sub_age_group_rand_num < 0.24
                        return sex_random_num < district_people[index, 5], 24
                    elseif sub_age_group_rand_num < 0.46
                        return sex_random_num < district_people[index, 5], 23
                    elseif sub_age_group_rand_num < 0.66
                        return sex_random_num < district_people[index, 5], 22
                    elseif sub_age_group_rand_num < 0.84
                        return sex_random_num < district_people[index, 5], 21
                    else
                        return sex_random_num < district_people[index, 5], 20
                    end
                end
            end
        # Возрастная группа 25-34 лет
        elseif age_group_rand_num < district_people_households[3, district_household_index]
            # 25-29 лет
            if age_rand_num < district_people[index, 22]
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 25:29)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 6], rand(rng, 25:29)
                end
            # 30-34 лет
            else
                if is_male !== nothing
                    return is_male, rand(rng, 30:34)
                else
                    # M30–34
                    return sex_random_num < district_people[index, 7], rand(rng, 30:34)
                end
            end
        # Возрастная группа 35-44 лет
        elseif age_group_rand_num < district_people_households[4, district_household_index]
            # 35-39 лет
            if age_rand_num < district_people[index, 23]
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 35:39)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 8], rand(rng, 35:39)
                end
            # 40-44 лет
            else
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 40:44)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 9], rand(rng, 40:44)
                end
            end
        # Возрастная группа 45-54 лет
        elseif age_group_rand_num < district_people_households[5, district_household_index]
            # 45-49 лет
            if age_rand_num < district_people[index, 24]
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 45:49)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 10], rand(rng, 45:49)
                end
            # 50-54 лет
            else
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 50:54)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 11], rand(rng, 50:54)
                end
            end
        # Возрастная группа 55-64 лет
        elseif age_group_rand_num < district_people_households[6, district_household_index]
            # 55-59 лет
            if age_rand_num < district_people[index, 25]
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 55:59)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 12], rand(rng, 55:59)
                end
            # 60-64 лет
            else
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 60:64)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 13], rand(rng, 60:64)
                end
            end
        # Возрастная группа 65+ лет
        else
            # 65-69 лет
            if age_rand_num < district_people[index, 26]
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 65:69)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 14], rand(rng, 65:69)
                end
            # 70-74 лет
            elseif age_rand_num < district_people[index, 27]
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 70:74)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 15], rand(rng, 70:74)
                end
            # 75-79 лет
            elseif age_rand_num < district_people[index, 28]
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 75:79)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 16], rand(rng, 75:79)
                end
            # 80-84 лет
            elseif age_rand_num < district_people[index, 29]
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 80:84)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 17], rand(rng, 80:84)
                end
            # 85-89 лет
            else
                # Если пол известен
                if is_male !== nothing
                    return is_male, rand(rng, 85:89)
                # Если пол неизвестен
                else
                    return sex_random_num < district_people[index, 18], rand(rng, 85:89)
                end
            end
        end
    end
end

# Нуждается ли ребенок в уходе за ним в случае болезни или из-за маленького возраста
function check_parent_leave(
    # В домохозяйстве нет агента, который бы мог побыть дома с ребенком
    no_one_at_home::Bool,
    # Агент-попечитель
    adult::Agent,
    # Агент-ребенок
    child::Agent
)
    # Для детей младше 12 лет
    if child.age < 12
        # Присваиваем попечителя агенту-ребенку
        child.supporter_id = adult.id
        # Присваиваем ребенка попечителю
        push!(adult.dependant_ids, child.id)
        # Если в домохозяйстве нет агента, который бы мог побыть дома с ребенком
        if no_one_at_home
            # Ребенок нуждается в уходе
            child.needs_supporter_care = true
            # Если ребенок младше 4 лет и не ходит в детский сад, то попечитель сидит дома с ребенком
            if child.age < 4 && child.activity_type == 0
                adult.activity_type = 0
            end
        end
    end
end

# Создание пары с детьми или без и прочих членов домохозяйства
function create_parents_with_children(
    # Id нового агента
    agent_id::Int,
    # Id домохозяйства
    household_id::Int,
    # Вирусы
    viruses::Vector{Virus},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам
    num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Id членов домохозяйства
    household_conn_ids::Vector{Int},
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people::Matrix{Float64},
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households::Matrix{Float64},
    # Индекс числа людей в домохозяйстве для таблицы district_people_households
    district_household_index::Int,
    # Число детей в домохозяйстве
    num_of_children::Int,
    # Число прочих людей в домохозяйстве
    num_of_other_people::Int,
    # Индекс муниципалитета
    index::Int,
    # Генератор случайных чисел
    rng::MersenneTwister,
    # Присутствуют не родственники
    with_others::Bool = false,
    # Присутствуют родители пары
    with_grandparent::Bool = false,
)::Vector{Agent}
    # Выбираем возраст для агента-женщины
    agent_female_sex, agent_female_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        rng, false)

    # Если есть неродственники
    if with_others
        # Если имеются дети младше 18 лет, то мать не может быть старше 55 лет, возраст 45-55 лет с вероятностью 40%,        если 2 ребенка, то старше 20 лет,                  если 3 ребенка, то старше 23 лет
        while ( (agent_female_age > 55 || (agent_female_age > 45 && rand(rng, Float64) > 0.4)) && num_of_children > 0 ) || ( num_of_children == 2 && agent_female_age < 21 ) || ( num_of_children == 3 && agent_female_age < 24 )
            agent_female_sex, agent_female_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, false)
        end
    # Если есть родитель одного из супругов
    elseif with_grandparent
        while ( (agent_female_age > 55 || (agent_female_age > 45 && rand(rng, Float64) > 0.4)) && num_of_children > 0 ) || agent_female_age > 65 || ( agent_female_age > 50 && rand(rng, Float64) > 0.25 ) || ( agent_female_age > 40 && rand(rng, Float64) > 0.35 ) || ( (agent_female_age < 34 || (agent_female_age == 34 && rand(rng, Float64) > 0.25)) && num_of_other_people > 1 ) || ( num_of_children == 2 && agent_female_age < 21 ) || ( num_of_children == 3 && agent_female_age < 24 )
            agent_female_sex, agent_female_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, false)
        end
    # Иначе
    else
        # Если имеются дети младше 18 лет, то мать не может быть старше 55 лет, возраст 45-55 лет с вероятностью 40%,
        while ( (agent_female_age > 55 || (agent_female_age > 45 && rand(rng, Float64) > 0.4)) && num_of_children > 0 ) || ( (agent_female_age < 34 || (agent_female_age == 34 && rand(rng, Float64) > 0.25)) && num_of_other_people > 0 ) || ( num_of_children == 2 && agent_female_age < 21 ) || ( num_of_children == 3 && agent_female_age < 24 )
            agent_female_sex, agent_female_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, false)
        end
    end

    # Создаем агента-женщину для пары
    agent_female = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, household_conn_ids, agent_female_sex, agent_female_age, rng)
    agent_id += 1

    # Выбираем возраст для агента-мужчины
    agent_male_sex, agent_male_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        rng, true)
    age_diff_rand_num = rand(rng, Float64)
    # Разница в возрасте между агентом-мужчиной и агентом-женщиной
    # Соответствие Age difference in heterosexual married couples, 2017 US Current Population Survey
    age_diff = abs(agent_male_age - agent_female_age)
    while age_diff > 15 || (age_diff > 10 && age_diff_rand_num > 0.06) || (age_diff > 5 && age_diff_rand_num > 0.14) || (age_diff > 3 && age_diff_rand_num > 0.162) || (age_diff > 1 && age_diff_rand_num > 0.265)
        agent_male_sex, agent_male_age = get_agent_sex_and_age(
            index, district_people,
            district_people_households, district_household_index,
            rng, true)
        age_diff_rand_num = rand(rng, Float64)
        age_diff = abs(agent_male_age - agent_female_age)
    end
    # Создаем агента-мужчину для пары
    agent_male = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, household_conn_ids, agent_male_sex, agent_male_age, rng)
    agent_id += 1

    if num_of_other_people == 0
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, child, child2, child3]
        end
        return Agent[agent_male, agent_female]
    elseif num_of_other_people == 1
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if with_others
            # Do nothing
        elseif with_grandparent
            age_diff_rand_num = agent_other_age > agent_female_age ? rand(rng, Float64) : 0
            age_diff = agent_other_age > agent_female_age ? abs(agent_other_age - agent_female_age - mean_child_mother_age_difference) : 13
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = agent_other_age > agent_female_age ? rand(rng, Float64) : 0
                age_diff = agent_other_age > agent_female_age ? abs(agent_other_age - agent_female_age - mean_child_mother_age_difference) : 13
            end
        else
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other_age - mean_child_mother_age_difference)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other]
    elseif num_of_other_people == 2
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if with_others
            # Do nothing
        elseif with_grandparent
            age_diff_rand_num = agent_other_age > agent_female_age ? rand(rng, Float64) : 0
            age_diff = agent_other_age > agent_female_age ? abs(agent_other_age - agent_female_age - mean_child_mother_age_difference) : 13
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = agent_other_age > agent_female_age ? rand(rng, Float64) : 0
                age_diff = agent_other_age > agent_female_age ? abs(agent_other_age - agent_female_age - mean_child_mother_age_difference) : 13
            end
        else
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other_age - mean_child_mother_age_difference)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other2_age - mean_child_mother_age_difference)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if with_others
            # Do nothing
        elseif with_grandparent
            age_diff_rand_num = agent_other_age > agent_female_age ? rand(rng, Float64) : 0
            age_diff = agent_other_age > agent_female_age ? abs(agent_other_age - agent_female_age - mean_child_mother_age_difference) : 13
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = agent_other_age > agent_female_age ? rand(rng, Float64) : 0
                age_diff = agent_other_age > agent_female_age ? abs(agent_other_age - agent_female_age - mean_child_mother_age_difference) : 13
            end
        else
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other_age - mean_child_mother_age_difference)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other2_age - mean_child_mother_age_difference)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index,
            rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other3_age - mean_child_mother_age_difference)
            end
        end
        agent_other3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other3_sex, agent_other3_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 || agent_other3.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3]
    else
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if with_others
            # Do nothing
        elseif with_grandparent
            age_diff_rand_num = agent_other_age > agent_female_age ? rand(rng, Float64) : 0
            age_diff = agent_other_age > agent_female_age ? abs(agent_other_age - agent_female_age - mean_child_mother_age_difference) : 13
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = agent_other_age > agent_female_age ? rand(rng, Float64) : 0
                age_diff = agent_other_age > agent_female_age ? abs(agent_other_age - agent_female_age - mean_child_mother_age_difference) : 13
            end
        else
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other_age - mean_child_mother_age_difference)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other2_age - mean_child_mother_age_difference)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other3_age - mean_child_mother_age_difference)
            end
        end
        agent_other3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other3_sex, agent_other3_age, rng)
        agent_id += 1
        agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - agent_other4_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - agent_other4_age - mean_child_mother_age_difference)
            end
        end
        agent_other4 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other4_sex, agent_other4_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 ||
                agent_other3.activity_type == 0 || agent_other4.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

# Создание двух пар с детьми или без и прочими членами домохозяйства
function create_two_pairs_with_children_with_others(
    # Id нового агента
    agent_id::Int,
    # Id домохозяйства
    household_id::Int,
    # Вирусы
    viruses::Vector{Virus},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам
    num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Id членов домохозяйства
    household_conn_ids::Vector{Int},
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people::Matrix{Float64},
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households::Matrix{Float64},
    # Индекс числа людей в домохозяйстве для таблицы district_people_households
    district_household_index::Int,
    # Число детей в домохозяйстве
    num_of_children::Int,
    # Число прочих людей в домохозяйстве
    num_of_other_people::Int,
    # Индекс муниципалитета
    index::Int,
    # Генератор случайных чисел
    rng::MersenneTwister,
)::Vector{Agent}
    agent_female_sex, agent_female_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        rng, false)

    while ( (agent_female_age > 55 || (agent_female_age > 45 && rand(rng, Float64) > 0.4)) && num_of_children > 0 ) || agent_female_age > 65 || ( agent_female_age > 50 && rand(rng, Float64) > 0.25 ) || ( agent_female_age > 40 && rand(rng, Float64) > 0.35 ) || ( (agent_female_age < 34 || (agent_female_age == 34 && rand(rng, Float64) > 0.25)) && num_of_other_people > 1 ) || ( num_of_children == 2 && agent_female_age < 21 ) || ( num_of_children == 3 && agent_female_age < 24 )
        agent_female_sex, agent_female_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, rng, false)
    end

    agent_female = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, household_conn_ids, agent_female_sex, agent_female_age, rng)

    agent_id += 1
    agent_male_sex, agent_male_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        rng, true)
    age_diff_rand_num = rand(rng, Float64)
    age_diff = abs(agent_male_age - agent_female_age)
    while age_diff > 15 || (age_diff > 10 && age_diff_rand_num > 0.06) || (age_diff > 5 && age_diff_rand_num > 0.14) || (age_diff > 3 && age_diff_rand_num > 0.162) || (age_diff > 1 && age_diff_rand_num > 0.265)
        agent_male_sex, agent_male_age = get_agent_sex_and_age(
            index, district_people,
            district_people_households, district_household_index,
            rng, true)
        age_diff_rand_num = rand(rng, Float64)
        age_diff = abs(agent_male_age - agent_female_age)
    end
    agent_male = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, household_conn_ids, agent_male_sex, agent_male_age, rng)
    agent_id += 1

    agent_female_old_sex, agent_female_old_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        rng, false)
    age_diff_rand_num = rand(rng, Float64)
    age_diff = abs(agent_female_old_age - agent_female_age - mean_child_mother_age_difference)
    while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
        agent_female_old_sex, agent_female_old_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, rng, false)
        age_diff_rand_num = rand(rng, Float64)
        age_diff = abs(agent_female_old_age - agent_female_age - mean_child_mother_age_difference)
    end
    agent_female_old = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_female_old_sex, agent_female_old_age, rng)

    agent_id += 1
    agent_male_old_sex, agent_male_old_age = get_agent_sex_and_age(
        index, district_people,
        district_people_households, district_household_index,
        rng, true)
    age_diff_rand_num = rand(rng, Float64)
    age_diff = abs(agent_male_old_age - agent_female_old_age)
    while age_diff > 15 || (age_diff > 10 && age_diff_rand_num > 0.06) || (age_diff > 5 && age_diff_rand_num > 0.14) || (age_diff > 3 && age_diff_rand_num > 0.162) || (age_diff > 1 && age_diff_rand_num > 0.265)
        agent_male_old_sex, agent_male_old_age = get_agent_sex_and_age(
            index, district_people,
            district_people_households, district_household_index,
            rng, true)
        age_diff_rand_num = rand(rng, Float64)
        age_diff = abs(agent_male_old_age - agent_female_old_age)
    end
    agent_male_old = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, household_conn_ids, agent_male_old_sex, agent_male_old_age, rng)
    agent_id += 1

    if num_of_other_people == 0
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_male_old, agent_female_old, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_male_old, agent_female_old]
    elseif num_of_other_people == 1
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other]
    else
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent_male.activity_type != 0 && agent_female.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent_female, child)
            if num_of_children == 1
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, agent_other2, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent_female, child2)
            if num_of_children == 2
                return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, agent_other2, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(agent_female_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent_female, child3)
            return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent_male, agent_female, agent_male_old, agent_female_old, agent_other, agent_other2]
    end
end

function create_parent_with_children(
    # Id агента
    agent_id::Int,
    # Id домохозяйства
    household_id::Int,
    # Вирусы
    viruses::Vector{Virus},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам
    num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Id агентов в домохозяйстве
    household_conn_ids::Vector{Int},
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people::Matrix{Float64},
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households::Matrix{Float64},
    # Индекс числа людей в домохозяйстве для таблицы district_people_households
    district_household_index::Int,
    # Число детей в домохозяйстве
    num_of_children::Int,
    # Число прочих людей в домохозяйстве
    num_of_other_people::Int,
    # Индекс муниципалитета
    index::Int,
    # Генератор случайных чисел
    rng::MersenneTwister,
    # Если родитель мужчина
    is_male_parent::Union{Bool, Nothing} = nothing,
    # С прочими агентами
    with_others::Bool = false,
    # С родителями родителя
    with_grandparent::Bool = false,
)::Vector{Agent}
    parent_sex, parent_age = get_agent_sex_and_age(
        index, district_people, district_people_households,
        district_household_index, rng, is_male_parent)

    if with_others
        while ( (parent_age > 55 || (parent_age > 45 && rand(rng, Float64) > 0.4)) && num_of_children > 0 ) || parent_age > 65 || ( parent_age > 50 && rand(rng, Float64) > 0.25 ) || ( parent_age > 40 && rand(rng, Float64) > 0.35 ) || ( num_of_children == 2 && parent_age < 21 ) || ( num_of_children == 3 && parent_age < 24 )
            parent_sex, parent_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, false)
        end
    elseif with_grandparent
        while ( (parent_age > 55 || (parent_age > 45 && rand(rng, Float64) > 0.4)) && num_of_children > 0 ) || parent_age > 65 || ( parent_age > 50 && rand(rng, Float64) > 0.25 ) || ( parent_age > 40 && rand(rng, Float64) > 0.35 ) || ( (parent_age < 34 || (parent_age == 34 && rand(rng, Float64) > 0.25)) && num_of_other_people > 1 ) || ( num_of_children == 2 && parent_age < 21 ) || ( num_of_children == 3 && parent_age < 24 )
            parent_sex, parent_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, false)
        end
    else
        while ( (parent_age > 55 || (parent_age > 45 && rand(rng, Float64) > 0.4)) && num_of_children > 0 ) || ( (parent_age < 34 || (parent_age == 34 && rand(rng, Float64) > 0.25)) && num_of_other_people > 0 ) || ( num_of_children == 2 && parent_age < 21 ) || ( num_of_children == 3 && parent_age < 24 )
            parent_sex, parent_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, false)
        end
    end

    parent = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, household_conn_ids, parent_sex, parent_age, rng)

    agent_id += 1
    if num_of_other_people == 0
        child_sex, child_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, rng, nothing, true)
        age_diff_rand_num = rand(rng, Float64)
        age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
        while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
        end
        child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
        agent_id += 1
        no_one_at_home = parent.activity_type != 0
        check_parent_leave(no_one_at_home, parent, child)
        if num_of_children == 1
            return Agent[parent, child]
        end
        child2_sex, child2_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            rng, nothing, true)
        age_diff_rand_num = rand(rng, Float64)
        age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
        while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
        end
        child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
        agent_id += 1
        check_parent_leave(no_one_at_home, parent, child2)
        if num_of_children == 2
            return Agent[parent, child, child2]
        end
        child3_sex, child3_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            rng, nothing, true)
        age_diff_rand_num = rand(rng, Float64)
        age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
        while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
        end
        child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
        check_parent_leave(no_one_at_home, parent, child3)
        return Agent[parent, child, child2, child3]
    elseif num_of_other_people == 1
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if with_others || with_grandparent
            age_diff_rand_num = agent_other_age > parent_age ? rand(rng, Float64) : 0
            age_diff = agent_other_age > parent_age ? abs(agent_other_age - parent_age - mean_child_mother_age_difference) : 13
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = agent_other_age > parent_age ? rand(rng, Float64) : 0
                age_diff = agent_other_age > parent_age ? abs(agent_other_age - parent_age - mean_child_mother_age_difference) : 13
            end
        else
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other_age - mean_child_mother_age_difference)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, child, child2, child3]
        end
        return Agent[parent, agent_other]
    elseif num_of_other_people == 2
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index,
            rng)
        if with_others || with_grandparent
            age_diff_rand_num = agent_other_age > parent_age ? rand(rng, Float64) : 0
            age_diff = agent_other_age > parent_age ? abs(agent_other_age - parent_age - mean_child_mother_age_difference) : 13
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = agent_other_age > parent_age ? rand(rng, Float64) : 0
                age_diff = agent_other_age > parent_age ? abs(agent_other_age - parent_age - mean_child_mother_age_difference) : 13
            end
        else
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other_age - mean_child_mother_age_difference)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other2_age - mean_child_mother_age_difference)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if with_others || with_grandparent
            age_diff_rand_num = agent_other_age > parent_age ? rand(rng, Float64) : 0
            age_diff = agent_other_age > parent_age ? abs(agent_other_age - parent_age - mean_child_mother_age_difference) : 13
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = agent_other_age > parent_age ? rand(rng, Float64) : 0
                age_diff = agent_other_age > parent_age ? abs(agent_other_age - parent_age - mean_child_mother_age_difference) : 13
            end
        else
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other_age - mean_child_mother_age_difference)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other2_age - mean_child_mother_age_difference)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other3_age - mean_child_mother_age_difference)
            end
        end
        agent_other3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other3_sex, agent_other3_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 || agent_other3.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, agent_other3, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3]
    else
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, rng)
        if with_others || with_grandparent
            age_diff_rand_num = agent_other_age > parent_age ? rand(rng, Float64) : 0
            age_diff = agent_other_age > parent_age ? abs(agent_other_age - parent_age - mean_child_mother_age_difference) : 13
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = agent_other_age > parent_age ? rand(rng, Float64) : 0
                age_diff = agent_other_age > parent_age ? abs(agent_other_age - parent_age - mean_child_mother_age_difference) : 13
            end
        else
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other_sex, agent_other_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other_age - mean_child_mother_age_difference)
            end
        end
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households, district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other2_age - mean_child_mother_age_difference)
            end
        end
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other3_age - mean_child_mother_age_difference)
            end
        end
        agent_other3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other3_sex, agent_other3_age, rng)
        agent_id += 1
        agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
            index, district_people, district_people_households,
            district_household_index, rng)
        if !with_others
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - agent_other4_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - agent_other4_age - mean_child_mother_age_difference)
            end
        end
        agent_other4 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other4_sex, agent_other4_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child_sex, child_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child_age - mean_child_mother_age_difference)
            end
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = parent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 ||
                agent_other3.activity_type == 0 || agent_other4.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, parent, child)
            if num_of_children == 1
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child2_sex, child2_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child2_age - mean_child_mother_age_difference)
            end
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, parent, child2)
            if num_of_children == 2
                return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            age_diff_rand_num = rand(rng, Float64)
            age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
            while age_diff > 12 || (age_diff > 10 && age_diff_rand_num > 0.01242) || (age_diff > 5 && age_diff_rand_num > 0.2113) || (age_diff > 3 && age_diff_rand_num > 0.45326) || (age_diff > 1 && age_diff_rand_num > 0.80258)
                child3_sex, child3_age = get_agent_sex_and_age(
                    index, district_people, district_people_households,
                    district_household_index, rng, nothing, true)
                age_diff_rand_num = rand(rng, Float64)
                age_diff = abs(parent_age - child3_age - mean_child_mother_age_difference)
            end
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, parent, child3)
            return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[parent, agent_other, agent_other2, agent_other3, agent_other4]
    end
end

# Создание агентов для прочих типов домохозяйств
function create_others(
    # Id агента
    agent_id::Int,
    # Id домохозяйства
    household_id::Int,
    # Вирусы
    viruses::Vector{Virus},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам
    num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    # Id агентов в домохозяйстве
    household_conn_ids::Vector{Int},
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people::Matrix{Float64},
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households::Matrix{Float64},
    # Индекс числа людей в домохозяйстве для таблицы district_people_households
    district_household_index::Int,
    # Число детей в домохозяйстве
    num_of_children::Int,
    # Число прочих людей в домохозяйстве
    num_of_other_people::Int,
    # Индекс муниципалитета
    index::Int,
    # Генератор случайных чисел
    rng::MersenneTwister,
)::Vector{Agent}
    agent_sex, agent_age = get_agent_sex_and_age(
        index, district_people, district_people_households, district_household_index, rng)
    agent = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
        isolation_probabilities_day_1, isolation_probabilities_day_2,
        isolation_probabilities_day_3, household_conn_ids, agent_sex, agent_age, rng)
    agent_id += 1
    if num_of_other_people == 0
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, child, child2, child3]
        end
        return Agent[agent]
    elseif num_of_other_people == 1
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, child, child2, child3]
        end
        return Agent[agent, agent_other]
    elseif num_of_other_people == 2
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2]
    elseif num_of_other_people == 3
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other3_sex, agent_other3_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 ||
                agent_other3.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, agent_other3, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3]
    elseif num_of_other_people == 4
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other3_sex, agent_other3_age, rng)
        agent_id += 1
        agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other4 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other4_sex, agent_other4_age, rng)
        agent_id += 1
        if num_of_children > 0
            child_sex, child_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child_sex, child_age, rng)
            agent_id += 1
            no_one_at_home = agent.activity_type != 0
            if agent_other.activity_type == 0 || agent_other2.activity_type == 0 ||
                agent_other3.activity_type == 0 || agent_other4.activity_type == 0
                no_one_at_home = false
            end
            check_parent_leave(no_one_at_home, agent, child)
            if num_of_children == 1
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child]
            end
            child2_sex, child2_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child2_sex, child2_age, rng)
            agent_id += 1
            check_parent_leave(no_one_at_home, agent, child2)
            if num_of_children == 2
                return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2]
            end
            child3_sex, child3_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                district_household_index, rng, nothing, true)
            child3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household_conn_ids, child3_sex, child3_age, rng)
            check_parent_leave(no_one_at_home, agent, child3)
            return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, child, child2, child3]
        end
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4]
    else
        agent_other_sex, agent_other_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other_sex, agent_other_age, rng)
        agent_id += 1
        agent_other2_sex, agent_other2_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other2 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other2_sex, agent_other2_age, rng)
        agent_id += 1
        agent_other3_sex, agent_other3_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other3 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other3_sex, agent_other3_age, rng)
        agent_id += 1
        agent_other4_sex, agent_other4_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other4 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other4_sex, agent_other4_age, rng)
        agent_id += 1
        agent_other5_sex, agent_other5_age = get_agent_sex_and_age(
            index, district_people, district_people_households, district_household_index, rng)
        agent_other5 = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
            isolation_probabilities_day_1, isolation_probabilities_day_2,
            isolation_probabilities_day_3, household_conn_ids, agent_other5_sex, agent_other5_age, rng)
        agent_id += 1
        return Agent[agent, agent_other, agent_other2, agent_other3, agent_other4, agent_other5]
    end
end

function create_population(
    # Id потока
    thread_id::Int,
    # Число потоков
    num_threads::Int,
    # Генератор случайных чисел для потоков
    thread_rng::Vector{MersenneTwister},
    # Id первого агента для потока
    start_agent_id::Int,
    # Агенты
    all_agents::Vector{Agent},
    # Домохозяйства
    households::Vector{Household},
    # Вирусы
    viruses::Vector{Virus},
    # Средняя заболеваемость по неделям, возрастным группам и вирусам
    num_all_infected_age_groups_viruses_mean::Array{Float64, 3},
    # Вероятности самоизоляции на 1-й, 2-й и 3-й дни болезни
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    start_household_id::Int,
    homes_coords_df::DataFrame,
    district_households::Matrix{Int},
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people::Matrix{Float64},
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households::Matrix{Float64},
)
    agent_id = start_agent_id
    household_id = start_household_id
    for index in district_nums[thread_id:num_threads:size(district_nums, 1)]
        index_for_1_people::Int = (index - 1) * 5 + 1
        index_for_2_people::Int = index_for_1_people + 1
        index_for_3_people::Int = index_for_2_people + 1
        index_for_4_people::Int = index_for_3_people + 1
        index_for_5_people::Int = index_for_4_people + 1

        homes_coords_district_df = homes_coords_df[homes_coords_df.dist .== index, :]

        for _ in 1:district_households[index, 1]
            # 1P - 1 взрослый человек
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                Int[agent_id], index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agent_sex, agent_age = get_agent_sex_and_age(
                index, district_people, district_people_households,
                index_for_1_people, thread_rng[thread_id])
            all_agents[agent_id] = Agent(agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, household.agent_ids, agent_sex, agent_age,
                thread_rng[thread_id])
            agent_id += 1
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 2]
            # PWOP2P0C - пара без детей (2 человека)
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 0, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 0, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 0, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 3]
            # PWOP3P0C - пара без детей (3 человека)
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 1, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 1, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 1, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 4]
            # PWOP3P1C - пара с 1 ребенком (3 человека)
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parents_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 5]
            # PWOP4P0C - пара без детей (4 человека)
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 2, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 2, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 2, index, thread_rng[thread_id], true)
            end 
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 6]
            # PWOP4P1C - пара с 1 ребенком (4 человека)
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 1, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 1, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 1, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 7]
            # PWOP4P2C - пара с 2 детьми
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parents_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 0, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 8]
            # PWOP5P0C - пара с 3 взрослыми
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 3, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 3, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 3, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 9]
            # PWOP5P1C - пара с 2 взрослыми и 1 ребенком
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 2, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 2, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 2, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 10]
            # PWOP5P2C - пара с 1 взрослым и 2 детьми
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 1, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 1, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 1, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 11]
            # PWOP5P3C - пара с 3 детьми
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parents_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 3, 0, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 12]
            # PWOP6P0C - пара с 4 взрослыми
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 4, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 4, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 0, 4, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 13]
            # PWOP6P1C - пара с 3 взрослыми и 1 ребенком
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 3, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 3, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 1, 3, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 14]
            # PWOP6P2C - пара с 2 взрослыми и 2 детьми
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 2, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 2, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 2, 2, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 15]
            # PWOP6P3C - пара с 1 взрослым и 3 детьми
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = Agent[]
            rand_num = rand(thread_rng[thread_id], Float64)
            if rand_num < 0.72
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 3, 1, index, thread_rng[thread_id])
            elseif rand_num < 0.81
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 3, 1, index, thread_rng[thread_id], false, true)
            else
                agents = create_parents_with_children(
                    agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                    isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                    district_people_households, index_for_2_people, 3, 1, index, thread_rng[thread_id], true)
            end
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 16]
            # 2PWOP4P0C - 2 пары
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 0, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 17]
            # 2PWOP5P0C - 2 пары с 1 взрослым
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 1, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 18]
            # 2PWOP5P1C - 2 пары с 1 ребенком
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 0, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 19]
            # 2PWOP6P0C - 2 пары с 2 взрослыми
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 2, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 20]
            # 2PWOP6P1C - 2 пары с 1 взрослым и 1 ребенком
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 1, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 21]
            # 2PWOP6P2C - 2 пары с 2 детьми
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_two_pairs_with_children_with_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 0, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 22]
            # SMWC2P0C - мать-одиночка со взрослым ребенком
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 23]
            # SMWC2P1C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 24]
            # SMWC3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 25]
            # SMWC3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 26]
            # SMWC3P2C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 27]
            # SMWC4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 28]
            # SMWC4P1C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 29]
            # SMWC4P2C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 30]
            # SMWC4P3C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 3, 0, index, thread_rng[thread_id], false)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 31]
            # SFWC2P0C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index, thread_rng[thread_id], true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 32]
            # SFWC2P1C
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index, thread_rng[thread_id], true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 33]
            # SFWC3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index, thread_rng[thread_id], true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 34]
            # SFWC3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index, thread_rng[thread_id], true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 35]
            # SFWC3P2C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index, thread_rng[thread_id], true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 36]
            # SPWCWP3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index, thread_rng[thread_id], false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 37]
            # SPWCWP3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index, thread_rng[thread_id], false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 38]
            # SPWCWP4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index, thread_rng[thread_id], false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 39]
            # SPWCWP4P1C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index, thread_rng[thread_id], false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 40]
            # SPWCWP4P2C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index, thread_rng[thread_id], false, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 41]
            # SPWCWPWOP3P0C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index, thread_rng[thread_id], true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 42]
            # SPWCWPWOP3P1C
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index, thread_rng[thread_id], true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 43]
            # SPWCWPWOP4P0C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index, thread_rng[thread_id], true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 44]
            # SPWCWPWOP4P1C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index, thread_rng[thread_id], true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 45]
            # SPWCWPWOP4P2C
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index, thread_rng[thread_id], true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 46]
            # SPWCWPWOP5P0C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index, thread_rng[thread_id], true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 47]
            # SPWCWPWOP5P1C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index, thread_rng[thread_id], true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 48]
            # SPWCWPWOP5P2C
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_parent_with_children(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index, thread_rng[thread_id], true, true)
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end

        for _ in 1:district_households[index, 49]
            # O2P0C - прочие домохозяйства без детей (2 человека)
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 0, 1, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 50]
            # O2P1C - прочие домохозяйства с 1 ребенком (2 человека)
            new_agent_id = agent_id + 1
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_2_people, 1, 0, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 51]
            # O3P0C - прочие домохозяйства без детей (3 человека)
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 0, 2, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 52]
            # O3P1C - прочие домохозяйства с 1 ребенком (3 человека)
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 1, 1, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 53]
            # O3P2C - прочие домохозяйства с 2 детьми (3 человека)
            new_agent_id = agent_id + 2
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_3_people, 2, 0, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 54]
            # O4P0C - прочие домохозяйства без детей (4 человека)
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 0, 3, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 55]
            # O4P1C - прочие домохозяйства с 1 ребенком (4 человека)
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 1, 2, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 56]
            # O4P2C - прочие домохозяйства с 2 детьми (4 человека)
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 2, 1, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 57]
            # O4P3C - прочие домохозяйства с 3 детьми (4 человека)
            new_agent_id = agent_id + 3
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_4_people, 3, 1, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 58]
            # O5P0C - прочие домохозяйства без детей (5 человек)
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 4, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 59]
            # O5P1C - прочие домохозяйства с 1 ребенком (5 человек)
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 3, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 60]
            # O5P2C - прочие домохозяйства с 2 детьми (5 человек)
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 2, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 61]
            # O5P3C - прочие домохозяйства с 3 детьми (5 человек)
            new_agent_id = agent_id + 4
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 3, 2, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 62]
            # O6P0C - прочие домохозяйства без детей (6 человек)
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 0, 5, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 63]
            # O6P1C - прочие домохозяйства с 1 ребенком (6 человек)
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 1, 4, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 64]
            # O6P2C - прочие домохозяйства с 2 детьми (6 человек)
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 2, 3, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
        for _ in 1:district_households[index, 65]
            # O6P3C - прочие домохозяйства с 3 детьми (6 человек)
            new_agent_id = agent_id + 5
            df_row = homes_coords_district_df[rand(1:size(homes_coords_district_df)[1]), :]
            household = Household(
                collect(Int, agent_id:new_agent_id), index, df_row.x, df_row.y, df_row.kinder, df_row.school,
                df_row.shop, df_row.restaurant, df_row.shop2, df_row.restaurant2)
            agents = create_others(
                agent_id, household_id, viruses, num_all_infected_age_groups_viruses_mean, isolation_probabilities_day_1,
                isolation_probabilities_day_2, isolation_probabilities_day_3, household.agent_ids, district_people,
                district_people_households, index_for_5_people, 3, 2, index, thread_rng[thread_id])
            agent_id = new_agent_id + 1
            for agent in agents
                all_agents[agent.id] = agent
            end
            households[household_id] = household
            household_id += 1
        end
    end
end
