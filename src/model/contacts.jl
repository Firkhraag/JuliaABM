function simulate_contacts_evaluation(
    thread_id::Int,
    rng::MersenneTwister,
    start_agent_id::Int,
    end_agent_id::Int,
    agents::Vector{Agent},
    is_holiday::Bool,
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_university_holiday::Bool,
    is_work_holiday::Bool,
    week_num::Int,
    current_step::Int,
    contact_matrix_by_age_threads::Array{Float64, 3},
    contact_duration_matrix_by_age_threads::Array{Float64, 3},
    contact_matrix_by_age_household_threads::Array{Float64, 3},
    contact_matrix_by_age_kindergarten_threads::Array{Float64, 3},
    contact_matrix_by_age_school_threads::Array{Float64, 3},
    contact_matrix_by_age_university_threads::Array{Float64, 3},
    contact_matrix_by_age_workplace_threads::Array{Float64, 3},
    contact_duration_matrix_by_age_household_threads::Array{Float64, 3},
    contact_duration_matrix_by_age_kindergarten_threads::Array{Float64, 3},
    contact_duration_matrix_by_age_school_threads::Array{Float64, 3},
    contact_duration_matrix_by_age_university_threads::Array{Float64, 3},
    contact_duration_matrix_by_age_workplace_threads::Array{Float64, 3}
)
    for agent_id = start_agent_id:end_agent_id
        agent = agents[agent_id]
        for agent2_id in agent.household_conn_ids
            agent2 = agents[agent2_id]

            if agent2.id != agent.id
                agent_at_home = agent.is_isolated || agent.on_parent_leave || agent.activity_type == 0 ||
                    (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_university_holiday) ||
                    (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)
                agent2_at_home = agent2.is_isolated || agent2.on_parent_leave || agent2.activity_type == 0 ||
                    (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_university_holiday) ||
                    (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday)

                dur = 0.0
                if is_holiday || (agent_at_home && agent2_at_home)

                    dur = get_contact_duration_normal(12.0, 4.0, rng)
                elseif ((agent.activity_type == 4 && !agent_at_home) ||
                    (agent2.activity_type == 4 && !agent2_at_home)) && !is_work_holiday

                    dur = get_contact_duration_normal(4.5, 1.5, rng)
                elseif ((agent.activity_type == 2 && !agent_at_home) ||
                    (agent2.activity_type == 2 && !agent2_at_home)) && !is_school_holiday

                    dur = get_contact_duration_normal(5.8, 2.0, rng)
                elseif ((agent.activity_type == 1 && !agent_at_home) ||
                    (agent2.activity_type == 1 && !agent2_at_home)) && !is_kindergarten_holiday

                    dur = get_contact_duration_normal(6.5, 2.2, rng)
                elseif ((agent.activity_type == 3 && !agent_at_home) ||
                    (agent2.activity_type == 3 && !agent2_at_home)) && !is_university_holiday

                    dur = get_contact_duration_normal(9.0, 3.0, rng)
                else
                    println("Error")
                end
                if dur > 0.1
                    contact_duration_matrix_by_age_household_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    contact_matrix_by_age_household_threads[thread_id, agent.age + 1, agent2.age + 1] += 1

                    contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                    contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                end
            end
        end

        if agent.activity_type == 1 && agent.attendance
            for agent2_id in agent.school_conn_ids
                agent2 = agents[agent2_id]
                if agent2.id != agent.id && agent2.attendance
                    dur = get_contact_duration_gamma(kindergarten_time_spent_shape, kindergarten_time_spent_scale, rng)
                    if dur > 0.1
                        contact_duration_matrix_by_age_kindergarten_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_kindergarten_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    end
                end
            end
        elseif agent.activity_type == 2 && agent.attendance
            for agent2_id in agent.school_conn_ids
                agent2 = agents[agent2_id]
                if agent2.id != agent.id && agent2.attendance
                    dur = get_contact_duration_gamma(school_time_spent_shape, school_time_spent_scale, rng)
                    if dur > 0.1
                        contact_duration_matrix_by_age_school_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_school_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    end
                end
            end
        elseif agent.activity_type == 3 && agent.attendance
            for agent2_id in agent.school_conn_ids
                agent2 = agents[agent2_id]
                if agent2.id != agent.id && agent2.attendance
                    dur = get_contact_duration_gamma(university_time_spent_shape, university_time_spent_scale, rng)
                    if dur > 0.1
                        contact_duration_matrix_by_age_university_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_university_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    end
                end
            end
            for agent2_id in agent.school_cross_conn_ids
                agent2 = agents[agent2_id]
                if agent2.id != agent.id && agent2.attendance && !agent2.is_teacher && rand(rng, Float64) < 0.5
                    dur = get_contact_duration_gamma(1.2, 1.07, rng)
                    if dur > 0.1
                        contact_duration_matrix_by_age_university_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_university_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    end
                end
            end
        elseif agent.activity_type == 4
            for agent2_id in agent.workplace_conn_ids
                agent2 = agents[agent2_id]
                if agent2.id != agent.id && agent2.attendance
                    dur = get_contact_duration_gamma(workplace_time_spent_shape, workplace_time_spent_scale, rng)
                    if dur > 0.1
                        contact_duration_matrix_by_age_workplace_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_workplace_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                        contact_duration_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += dur
                        contact_matrix_by_age_threads[thread_id, agent.age + 1, agent2.age + 1] += 1
                    end
                end
            end
        end
    end
end

function run_simulation_evaluation(
    num_threads::Int,
    thread_rng::Vector{MersenneTwister},
    start_agent_ids::Vector{Int},
    end_agent_ids::Vector{Int},
    agents::Vector{Agent},
)
    # День месяца
    day = 1
    # Месяц
    month = 9
    # month = 8

    # День недели
    week_day = 1
    # week_day = 7

    # Номер недели
    week_num = 1

    contact_matrix_by_age_threads = zeros(Float64, num_threads, 90, 90)
    contact_duration_matrix_by_age_threads = zeros(Float64, num_threads, 90, 90)

    contact_matrix_by_age_household_threads = zeros(Float64, num_threads, 90, 90)
    contact_matrix_by_age_kindergarten_threads = zeros(Float64, num_threads, 90, 90)
    contact_matrix_by_age_school_threads = zeros(Float64, num_threads, 90, 90)
    contact_matrix_by_age_university_threads = zeros(Float64, num_threads, 90, 90)
    contact_matrix_by_age_workplace_threads = zeros(Float64, num_threads, 90, 90)

    contact_duration_matrix_by_age_household_threads = zeros(Float64, num_threads, 90, 90)
    contact_duration_matrix_by_age_kindergarten_threads = zeros(Float64, num_threads, 90, 90)
    contact_duration_matrix_by_age_school_threads = zeros(Float64, num_threads, 90, 90)
    contact_duration_matrix_by_age_university_threads = zeros(Float64, num_threads, 90, 90)
    contact_duration_matrix_by_age_workplace_threads = zeros(Float64, num_threads, 90, 90)

    days_run = 1
    for current_step = 1:days_run
        # Выходные, праздники
        is_holiday = false
        if week_day == 7
            is_holiday = true
        elseif month == 1 && (day == 1 || day == 2 || day == 3 || day == 7)
            is_holiday = true
        elseif month == 5 && (day == 1 || day == 9)
            is_holiday = true
        elseif month == 2 && day == 23
            is_holiday = true
        elseif month == 3 && day == 8
            is_holiday = true
        elseif month == 6 && day == 12
            is_holiday = true
        end

        is_work_holiday = is_holiday
        if week_day == 6
            is_work_holiday = true
        end

        is_kindergarten_holiday = is_work_holiday
        if month == 7 || month == 8
            is_kindergarten_holiday = true
        end

        # Каникулы
        # Летние - 01.06.yyyy - 31.08.yyyy
        # Осенние - 05.11.yyyy - 11.11.yyyy
        # Зимние - 28.12.yyyy - 09.03.yyyy
        # Весенние - 22.03.yyyy - 31.03.yyyy
        is_school_holiday = is_holiday
        if month == 6 || month == 7 || month == 8
            is_school_holiday = true
        elseif month == 11 && day >= 5 && day <= 11
            is_school_holiday = true
        elseif month == 12 && day >= 28 && day <= 31
            is_school_holiday = true
        elseif month == 1 && day >= 1 && day <= 9
            is_school_holiday = true
        elseif month == 3 && day >= 22 && day <= 31
            is_school_holiday = true
        end

        is_university_holiday = is_holiday
        if month == 7 || month == 8
            is_university_holiday = true
        elseif month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_university_holiday = true
        elseif month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_university_holiday = true
        elseif month == 2 && (day >= 1 && day <= 10)
            is_university_holiday = true
        elseif month == 12 && (day >= 22 && day <= 31)
            is_university_holiday = true
        end

        @threads for thread_id in 1:num_threads
            simulate_contacts_evaluation(
                thread_id,
                thread_rng[thread_id],
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                agents,
                is_holiday,
                is_kindergarten_holiday,
                is_school_holiday,
                is_university_holiday,
                is_work_holiday,
                week_num,
                current_step,
                contact_matrix_by_age_threads,
                contact_duration_matrix_by_age_threads,
                contact_matrix_by_age_household_threads,
                contact_matrix_by_age_kindergarten_threads,
                contact_matrix_by_age_school_threads,
                contact_matrix_by_age_university_threads,
                contact_matrix_by_age_workplace_threads,
                contact_duration_matrix_by_age_household_threads,
                contact_duration_matrix_by_age_kindergarten_threads,
                contact_duration_matrix_by_age_school_threads,
                contact_duration_matrix_by_age_university_threads,
                contact_duration_matrix_by_age_workplace_threads,
            )
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

        if ((month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10) && day == 31) ||
            ((month == 4 || month == 6 || month == 9 || month == 11) && day == 30) ||
            (month == 2 && day == 28)
            day = 1
            month += 1
        elseif (month == 12 && day == 31)
            day = 1
            month = 1
        else
            day += 1
        end
    end

    contact_matrix_by_age = sum(contact_matrix_by_age_threads, dims=1)[1, :, :]

    contact_matrix_by_age_household = sum(contact_matrix_by_age_household_threads, dims=1)[1, :, :]
    contact_matrix_by_age_kindergarten = sum(contact_matrix_by_age_kindergarten_threads, dims=1)[1, :, :]
    contact_matrix_by_age_school = sum(contact_matrix_by_age_school_threads, dims=1)[1, :, :]
    contact_matrix_by_age_university = sum(contact_matrix_by_age_university_threads, dims=1)[1, :, :]
    contact_matrix_by_age_workplace = sum(contact_matrix_by_age_workplace_threads, dims=1)[1, :, :]

    println(sum(contact_matrix_by_age))

    println(sum(contact_matrix_by_age_household))
    println(sum(contact_matrix_by_age_kindergarten))
    println(sum(contact_matrix_by_age_school))
    println(sum(contact_matrix_by_age_university))
    println(sum(contact_matrix_by_age_workplace))

    contact_duration_matrix_by_age = sum(contact_duration_matrix_by_age_threads, dims=1)[1, :, :]
    contact_duration_matrix_by_age ./= contact_matrix_by_age

    contact_duration_matrix_by_age_household = sum(contact_duration_matrix_by_age_household_threads, dims=1)[1, :, :]
    contact_duration_matrix_by_age_household ./= contact_matrix_by_age_household

    contact_duration_matrix_by_age_kindergarten = sum(contact_duration_matrix_by_age_kindergarten_threads, dims=1)[1, :, :]
    for i = 1:90
        for j = 1:90
            if contact_matrix_by_age_kindergarten[i, j] > 0.001
                contact_duration_matrix_by_age_kindergarten[i, j] /= contact_matrix_by_age_kindergarten[i, j]
            else
                contact_duration_matrix_by_age_kindergarten[i, j] = 0.0
            end
        end
    end

    contact_duration_matrix_by_age_school = sum(contact_duration_matrix_by_age_school_threads, dims=1)[1, :, :]
    for i = 1:90
        for j = 1:90
            if contact_matrix_by_age_school[i, j] > 0.001
                contact_duration_matrix_by_age_school[i, j] /= contact_matrix_by_age_school[i, j]
            else
                contact_duration_matrix_by_age_school[i, j] = 0.0
            end
        end
    end

    contact_duration_matrix_by_age_university = sum(contact_duration_matrix_by_age_university_threads, dims=1)[1, :, :]
    for i = 1:90
        for j = 1:90
            if contact_matrix_by_age_university[i, j] > 0.001
                contact_duration_matrix_by_age_university[i, j] /= contact_matrix_by_age_university[i, j]
            else
                contact_duration_matrix_by_age_university[i, j] = 0.0
            end
        end
    end

    contact_duration_matrix_by_age_workplace = sum(contact_duration_matrix_by_age_workplace_threads, dims=1)[1, :, :]
    for i = 1:90
        for j = 1:90
            if contact_matrix_by_age_workplace[i, j] > 0.001
                contact_duration_matrix_by_age_workplace[i, j] /= contact_matrix_by_age_workplace[i, j]
            else
                contact_duration_matrix_by_age_workplace[i, j] = 0.0
            end
        end
    end

    if month == 8
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_weekday_summer.csv"), contact_matrix_by_age, ',')
    elseif week_day == 1
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_sunday.csv"), contact_matrix_by_age, ',')
    else
        writedlm(
            joinpath(@__DIR__, "..", "..", "output", "tables", "contact_counts_weekday.csv"), contact_matrix_by_age, ',')
    end

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations.csv"), contact_duration_matrix_by_age, ',')

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations_household.csv"), contact_duration_matrix_by_age_household, ',')

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations_kindergarten.csv"), contact_duration_matrix_by_age_kindergarten, ',')

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations_school.csv"), contact_duration_matrix_by_age_school, ',')

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations_university.csv"), contact_duration_matrix_by_age_university, ',')

    writedlm(
        joinpath(@__DIR__, "..", "..", "output", "tables", "contact_durations_workplace.csv"), contact_duration_matrix_by_age_workplace, ',')
end
