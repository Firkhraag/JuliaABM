function make_contact_r0(
    num_people_infected::Vector{Int},
    infected_agent_ids::Vector{Int},
    viruses::Vector{Virus},
    infected_agent::Agent,
    susceptible_agent::Agent,
    contact_duration::Float64,
    current_step::Int,
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temperature_parameters::Vector{Float64},
    current_temp::Float64,
    rng::MersenneTwister,
)
    # Влияние продолжительности контакта на вероятность инфицирования
    duration_influence = 1 / (1 + exp(-contact_duration + duration_parameter))
            
    # Влияние температуры воздуха на вероятность инфицирования
    temperature_influence = temperature_parameters[infected_agent.virus_id] * current_temp + 1.0

    # Влияние восприимчивости агента на вероятность инфицирования
    susceptibility_influence = 2 / (1 + exp(susceptibility_parameters[infected_agent.virus_id] * susceptible_agent.ig_level))

    # Влияние силы инфекции на вероятность инфицирования
    infectivity_influence = 0.0
    if infected_agent.age < 3
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_toddler,
            infected_agent.is_asymptomatic)
    elseif infected_agent.age < 16
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_child,
            infected_agent.is_asymptomatic)
    else
        infectivity_influence = get_infectivity(
            infected_agent.days_infected,
            infected_agent.incubation_period,
            infected_agent.infection_period,
            viruses[infected_agent.virus_id].mean_viral_load_adult,
            infected_agent.is_asymptomatic)
    end

    # Вероятность инфицирования
    infection_probability = infectivity_influence * susceptibility_influence *
        temperature_influence * duration_influence

    if rand(rng, Float64) < infection_probability
        num_people_infected[1] += 1
        push!(infected_agent_ids, susceptible_agent.id)
    end
end

function simulate_contacts_r0(
    infected_agent_id::Int,
    agents::Vector{Agent},
    households::Vector{Household},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temperature_parameters::Vector{Float64},
    random_infection_probabilities::Vector{Float64},
    viruses::Vector{Virus},
    is_kindergarten_holiday::Bool,
    is_school_holiday::Bool,
    is_college_holiday::Bool,
    is_work_holiday::Bool,
    current_step::Int,
    current_temp::Float64,
    num_people_infected::Vector{Int},
    infected_agent_ids::Vector{Int},
    rng::MersenneTwister,
)
    agent = agents[infected_agent_id]
    for agent2_id in agent.household_conn_ids
        agent2 = agents[agent2_id]
        if !(agent2.id in infected_agent_ids)
            dur = 0.0
            if (agent.is_isolated || agent.quarantine_period > 0 || agent.on_parent_leave || agent.activity_type == 0 ||
                (agent.activity_type == 4 && is_work_holiday) || (agent.activity_type == 3 && is_college_holiday) ||
                (agent.activity_type == 2 && is_school_holiday) || (agent.activity_type == 1 && is_kindergarten_holiday)) &&
                (agent2.is_isolated || agent2.quarantine_period > 0 || agent2.on_parent_leave || agent2.activity_type == 0 ||
                (agent2.activity_type == 4 && is_work_holiday) || (agent2.activity_type == 3 && is_college_holiday) ||
                (agent2.activity_type == 2 && is_school_holiday) || (agent2.activity_type == 1 && is_kindergarten_holiday))

                dur = get_contact_duration_normal(mean_household_contact_durations[5], household_contact_duration_sds[5], rng)
            elseif ((agent.activity_type == 4 && !(agent.is_isolated || agent.on_parent_leave)) ||
                (agent2.activity_type == 4 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_work_holiday

                dur = get_contact_duration_normal(mean_household_contact_durations[4], household_contact_duration_sds[4], rng)
            elseif ((agent.activity_type == 2 && !(agent.is_isolated || agent.on_parent_leave || agent.quarantine_period > 0)) ||
                (agent2.activity_type == 2 && !(agent2.is_isolated || agent2.on_parent_leave || agent2.quarantine_period > 0))) && !is_school_holiday

                dur = get_contact_duration_normal(mean_household_contact_durations[2], household_contact_duration_sds[2], rng)
            elseif ((agent.activity_type == 1 && !(agent.is_isolated || agent.on_parent_leave)) ||
                (agent2.activity_type == 1 && !(agent2.is_isolated || agent2.on_parent_leave))) && !is_kindergarten_holiday
                
                dur = get_contact_duration_normal(mean_household_contact_durations[1], household_contact_duration_sds[1], rng)
            else
                dur = get_contact_duration_normal(mean_household_contact_durations[3], household_contact_duration_sds[3], rng)
            end

            if dur > 0.01
                make_contact_r0(num_people_infected, infected_agent_ids,
                    viruses, agent, agent2, dur, current_step, duration_parameter,
                    susceptibility_parameters, temperature_parameters,
                    current_temp, rng)
            end
        end
    end
    if agent.attendance && !agent.is_isolated &&
        ((agent.activity_type == 1 && !is_kindergarten_holiday) ||
            (agent.activity_type == 2 && !is_school_holiday) ||
            (agent.activity_type == 3 && !is_college_holiday) ||
            (agent.activity_type == 4 && !is_work_holiday))
        for agent2_id in agent.activity_conn_ids
            agent2 = agents[agent2_id]
            if !(agent2.id in infected_agent_ids) && agent2.attendance
                dur = 0.0
                if agent.activity_type == 1
                    dur = get_contact_duration_gamma(other_contact_duration_shapes[1], other_contact_duration_scales[1], rng)
                elseif agent.activity_type == 2
                    dur = get_contact_duration_gamma(other_contact_duration_shapes[2], other_contact_duration_scales[2], rng)
                elseif agent.activity_type == 3
                    dur = get_contact_duration_gamma(other_contact_duration_shapes[3], other_contact_duration_scales[3], rng)
                else
                    dur = get_contact_duration_gamma(other_contact_duration_shapes[4], other_contact_duration_scales[4], rng)
                end

                if dur > 0.01
                    make_contact_r0(num_people_infected, infected_agent_ids,
                        viruses, agent, agent2, dur, current_step, duration_parameter,
                        susceptibility_parameters, temperature_parameters,
                        current_temp, rng)
                end
            end
        end

        if agent.activity_type == 3
            for agent2_id in agent.activity_cross_conn_ids
                agent2 = agents[agent2_id]
                if !(agent2.id in infected_agent_ids) && rand(rng, Float64) < 0.25
                    dur = get_contact_duration_gamma(other_contact_duration_shapes[5], other_contact_duration_scales[5], rng)
                    make_contact_r0(num_people_infected, infected_agent_ids,
                        viruses, agent, agent2, dur, current_step, duration_parameter,
                        susceptibility_parameters, temperature_parameters,
                        current_temp, rng)
                end
            end
        end
    end
end

function update_agent_states_r0(
    infected_agent_id::Int,
    agents::Vector{Agent},
    rng::MersenneTwister,
)::Bool
    agent = agents[infected_agent_id]
    if agent.days_infected == agent.infection_period
        agent.virus_id = 0
        agent.is_isolated = false
        return false
    else
        agent.days_infected += 1
        if !agent.is_asymptomatic && !agent.is_isolated
            if agent.days_infected == 1
                rand_num = rand(rng, Float64)
                if agent.age < 8
                    if rand_num < 0.305
                        agent.is_isolated = true
                    end
                elseif agent.age < 18
                    if rand_num < 0.204
                        agent.is_isolated = true
                    end
                else
                    if rand_num < 0.101
                        agent.is_isolated = true
                    end
                end
            elseif agent.days_infected == 2
                rand_num = rand(rng, Float64)
                if agent.age < 8
                    if rand_num < 0.576
                        agent.is_isolated = true
                    end
                elseif agent.age < 18
                    if rand_num < 0.499
                        agent.is_isolated = true
                    end
                else
                    if rand_num < 0.334
                        agent.is_isolated = true
                    end
                end
            elseif agent.days_infected == 3
                rand_num = rand(rng, Float64)
                if agent.age < 8
                    if rand_num < 0.325
                        agent.is_isolated = true
                    end
                elseif agent.age < 18
                    if rand_num < 0.376
                        agent.is_isolated = true
                    end
                else
                    if rand_num < 0.168
                        agent.is_isolated = true
                    end
                end
            end
        end
        
        agent.attendance = true
        if agent.activity_type == 3 && !agent.is_teacher && rand(rng, Float64) < skip_college_probability
            agent.attendance = false
        end
        return true
    end
end

# Without parent leave to be truly parallel
function run_simulation_r0(
    month_num::Int,
    infected_agent_id::Int,
    agents::Vector{Agent},
    viruses::Vector{Virus},
    households::Vector{Household},
    schools::Vector{School},
    duration_parameter::Float64,
    susceptibility_parameters::Vector{Float64},
    temperature_parameters::Vector{Float64},
    temperature::Vector{Float64},
    mean_household_contact_durations::Vector{Float64},
    household_contact_duration_sds::Vector{Float64},
    other_contact_duration_shapes::Vector{Float64},
    other_contact_duration_scales::Vector{Float64},
    isolation_probabilities_day_1::Vector{Float64},
    isolation_probabilities_day_2::Vector{Float64},
    isolation_probabilities_day_3::Vector{Float64},
    random_infection_probabilities::Vector{Float64},
    recovered_duration_mean::Float64,
    recovered_duration_sd::Float64,
    rng::MersenneTwister,
)::Int
    # Месяц
    month = month_num

    infected_agent_ids = Int[]

    # Минимальная температура воздуха
    min_temp = -7.2
    # Max - Min температура
    max_min_temp = 26.6

    current_step = 1
    year_day = 212
    if month == 9
        current_step = 31
        year_day = 243
    elseif month == 10
        current_step = 61
        year_day = 273
    elseif month == 11
        current_step = 92
        year_day = 304
    elseif month == 12
        current_step = 122
        year_day = 334
    elseif month == 1
        current_step = 153
        year_day = 365
    elseif month == 2
        current_step = 184
        year_day = 31
    elseif month == 3
        current_step = 212
        year_day = 59
    elseif month == 4
        current_step = 243
        year_day = 90
    elseif month == 5
        current_step = 273
        year_day = 120
    elseif month == 6
        current_step = 304
        year_day = 151
    elseif month == 7
        current_step = 334
        year_day = 181
    end


    # День месяца
    day = 1
    if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12
        day = rand(rng, 1:31)
    elseif month == 4 || month == 6 || month == 9 || month == 11
        day = rand(rng, 1:30)
    else
        day = rand(rng, 1:28)
    end

    current_step += day

    # День недели
    week_day = rand(rng, 1:7)

    agent_infected = true
    num_people_infected = zeros(Int, 1)

    while(agent_infected)
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
        # Зимние - 28.12.yyyy - 09.01.yyyy
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

        is_college_holiday = is_holiday
        if month == 7 || month == 8
            is_college_holiday = true
        elseif month == 1 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_college_holiday = true
        elseif month == 6 && day != 11 && day != 15 && day != 19 && day != 23 && day != 27
            is_college_holiday = true
        elseif month == 2 && (day >= 1 && day <= 10)
            is_college_holiday = true
        elseif month == 12 && (day >= 22 && day <= 31)
            is_college_holiday = true
        end

        simulate_contacts_r0(
            infected_agent_id,
            agents,
            households,
            mean_household_contact_durations,
            household_contact_duration_sds,
            other_contact_duration_shapes,
            other_contact_duration_scales,
            duration_parameter,
            susceptibility_parameters,
            temperature_parameters,
            random_infection_probabilities,
            viruses,
            is_kindergarten_holiday,
            is_school_holiday,
            is_college_holiday,
            is_work_holiday,
            current_step,
            (temperature[year_day] - min_temp) / max_min_temp,
            num_people_infected,
            infected_agent_ids,
            rng,
        )
        
        agent_infected = update_agent_states_r0(
            infected_agent_id,
            agents,
            rng,
        )

        # Обновление даты
        if week_day == 7
            week_day = 1
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

    return num_people_infected[1]
end