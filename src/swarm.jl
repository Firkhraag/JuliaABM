using Base.Threads
using DelimitedFiles
using Statistics
using LatinHypercubeSampling
using CSV
using JLD
using DataFrames
using Distributions

# Модель на сервере
include("../server/lib/data/etiology.jl")
include("../server/lib/data/incidence.jl")

include("../server/lib/global/variables.jl")

include("../server/lib/model/virus.jl")
include("../server/lib/model/agent.jl")
include("../server/lib/model/household.jl")
include("../server/lib/model/workplace.jl")
include("../server/lib/model/school.jl")
include("../server/lib/model/initialization.jl")
include("../server/lib/model/connections.jl")
include("../server/lib/model/contacts.jl")

include("../server/lib/util/moving_avg.jl")
include("../server/lib/util/stats.jl")
include("../server/lib/util/reset.jl")

# Локальная модель
include("model/simulation.jl")

function arg_n_smallest_values(A::AbstractArray{T,N}, n::Integer) where {T,N}
    perm = sortperm(vec(A))
    ci = CartesianIndices(A)
    return ci[perm[1:n]]
end

function run_swarm_model()
    println("Initialization...")

    # Номер запуска модели
    run_num = 0
    is_rt_run = true
    try
        run_num = parse(Int64, ARGS[1])
    catch
        run_num = 0
    end

    # Число моделируемых лет
    num_years = 1
    # Среднее по num_years
    is_one_mean_year_modeled = true

    # Число потоков
    num_threads = nthreads()

    # Вероятности изолироваться при болезни на 1-й, 2-й и 3-й дни
    isolation_probabilities_day_1 = [0.406, 0.305, 0.204, 0.101]
    isolation_probabilities_day_2 = [0.669, 0.576, 0.499, 0.334]
    isolation_probabilities_day_3 = [0.45, 0.325, 0.376, 0.168]
    # Продолжительность резистентного состояния
    recovered_duration_mean = 6.0
    recovered_duration_sd = 2.0
    # Продолжительности контактов в домохозяйствах
    # Укороченные для различных коллективов и полная: детсад, школа, вуз, работа, полный контакт
    mean_household_contact_durations = [6.5, 5.8, 9.0, 4.5, 12.0]
    household_contact_duration_sds = [2.2, 2.0, 3.0, 1.5, 4.0]
    # Продолжительности контактов в прочих коллективах: детсад, школа, вуз, работа, вуз (между группами)
    other_contact_duration_shapes = [2.5, 1.78, 2.0, 1.81, 1.2]
    other_contact_duration_scales = [1.6, 1.95, 1.07, 1.7, 1.07]
    # Минимальный размер рабочего коллектива
    firm_min_size = 1
    # Максимальный размер рабочего коллектива
    firm_max_size = 1000
    # Параметр предпочтительного присоединения графа Барабаши-Альберт для рабочих коллективов
    work_num_barabasi_albert_attachments = 5
    # Параметр предпочтительного присоединения графа Барабаши-Альберт для школ
    school_num_barabasi_albert_attachments = 10

    # Набор вирусов
    # shape = mean * mean / variance
    # scale = variance / mean
    viruses = Virus[
        # Flu A
        Virus(round(Int, 1.4 * 1.4 / 0.67), 0.67 / 1.4,   round(Int, 4.8 * 4.8 / 2.04), 2.04 / 4.8,    round(Int, 8.0 * 8.0 / 3.4), 3.4 / 8.0,      3.53, 2.63, 1.8,    0.38, 0.47, 0.57,   1.0, 0.33),
        # Flu B
        Virus(round(Int, 0.6 * 0.6 / 0.19), 0.19 / 0.6,   round(Int, 3.7 * 3.7 / 3.0), 3.0 / 3.7,      round(Int, 6.1 * 6.1 / 4.8), 4.8 / 6.1,      3.53, 2.63, 1.8,    0.38, 0.47, 0.57,   1.0, 0.33),
        # RV
        Virus(round(Int, 1.9 * 1.9 / 1.11), 1.11 / 1.9,   round(Int, 10.1 * 10.1 / 7.0), 7.0 / 10.1,   round(Int, 11.4 * 11.4 / 7.7), 7.7 / 11.4,   3.5, 2.6, 1.8,      0.19, 0.24, 0.29,   1.0, 0.33),
        # RSV
        Virus(round(Int, 4.4 * 4.4 / 1.0), 1.0 / 4.4,     round(Int, 6.5 * 6.5 / 2.7), 2.7 / 6.5,      round(Int, 6.7 * 6.7 / 2.8), 2.8 / 6.7,      6.0, 4.5, 3.0,      0.24, 0.3, 0.36,    1.0, 0.33),
        # AdV
        Virus(round(Int, 5.6 * 5.6 / 1.3), 1.3 / 5.6,     round(Int, 8.0 * 8.0 / 5.6), 5.6 / 8.0,      round(Int, 9.0 * 9.0 / 6.3), 6.3 / 9.0,      4.1, 3.1, 2.1,      0.15, 0.19, 0.23,   1.0, 0.33),
        # PIV
        Virus(round(Int, 2.6 * 2.6 / 0.85), 0.85 / 2.6,   round(Int, 7.0 * 7.0 / 2.9), 2.9 / 7.0,      round(Int, 8.0 * 8.0 / 3.4), 3.4 / 8.0,      4.8, 3.6, 2.4,      0.16, 0.2, 0.24,    1.0, 0.33),
        # CoV
        Virus(round(Int, 3.2 * 3.2 / 0.44), 0.44 / 3.2,   round(Int, 6.5 * 6.5 / 4.5), 4.5 / 6.5,      round(Int, 7.5 * 7.5 / 5.2), 5.2 / 7.5,      4.9, 3.7, 2.5,      0.21, 0.26, 0.32,   1.0, 0.33)]

    # Число домохозяйств каждого типа по муниципалитетам
    district_households = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_households.csv"))))
    # Число людей в каждой возрастной группе по муниципалитетам
    district_people = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_people.csv"))))
    # Число людей в домохозяйствах по муниципалитетам
    district_people_households = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "district_people_households.csv"))))
    # Распределение вирусов в течение года
    etiology = get_etiology()
    # Температура воздуха, начиная с 1 января
    temperature = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "temperature.csv"))))[1, :]

    # Набор агентов
    agents = Array{Agent, 1}(undef, num_agents)

    # Генератор случайных чисел для потоков
    thread_rng = [MersenneTwister(i + run_num * num_threads) for i = 1:num_threads]

    # Координаты домов
    homes_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "homes.csv")))
    # Массив для хранения домохозяйств
    households = Array{Household, 1}(undef, num_households)

    # Координаты детских садов
    kindergarten_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "kindergartens.csv")))
    # Массив для хранения детских садов
    kindergartens = Array{School, 1}(undef, num_kindergartens)
    for i in 1:size(kindergarten_coords_df, 1)
        kindergartens[i] = School(
            1,
            kindergarten_coords_df[i, :dist],
            kindergarten_coords_df[i, :x],
            kindergarten_coords_df[i, :y],
        )
    end

    # Координаты школ
    school_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "schools.csv")))
    # Массив для хранения школ
    schools = Array{School, 1}(undef, num_schools)
    for i in 1:size(school_coords_df, 1)
        schools[i] = School(
            2,
            school_coords_df[i, :dist],
            school_coords_df[i, :x],
            school_coords_df[i, :y],
        )
    end

    # Координаты вузов
    college_coords_df = DataFrame(CSV.File(joinpath(@__DIR__, "..", "input", "tables", "space", "colleges.csv")))
    # Массив для хранения институтов
    colleges = Array{School, 1}(undef, num_colleges)
    for i in 1:size(college_coords_df, 1)
        colleges[i] = School(
            3,
            college_coords_df[i, :dist],
            college_coords_df[i, :x],
            college_coords_df[i, :y],
        )
    end

    # Массив для хранения фирм
    workplaces = Workplace[]

    # Заболеваемость различными вирусами в разных возрастных группах за рассматриваемые года
    num_infected_age_groups_viruses = get_incidence(etiology, is_one_mean_year_modeled, flu_starting_index, true)
    # Заболеваемость различными вирусами в разных возрастных группах за предыдущий год
    num_infected_age_groups_viruses_prev = get_incidence(etiology, false, 1, false)

    for virus_id in eachindex(viruses)
        num_infected_age_groups_viruses_prev[:, virus_id, 1] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[1]) * (1 - isolation_probabilities_day_2[1]) * (1 - isolation_probabilities_day_3[1]))
        num_infected_age_groups_viruses_prev[:, virus_id, 2] ./= viruses[virus_id].symptomatic_probability_child * (1 - (1 - isolation_probabilities_day_1[2]) * (1 - isolation_probabilities_day_2[2]) * (1 - isolation_probabilities_day_3[2]))
        num_infected_age_groups_viruses_prev[:, virus_id, 3] ./= viruses[virus_id].symptomatic_probability_teenager * (1 - (1 - isolation_probabilities_day_1[3]) * (1 - isolation_probabilities_day_2[3]) * (1 - isolation_probabilities_day_3[3]))
        num_infected_age_groups_viruses_prev[:, virus_id, 4] ./= viruses[virus_id].symptomatic_probability_adult * (1 - (1 - isolation_probabilities_day_1[4]) * (1 - isolation_probabilities_day_2[4]) * (1 - isolation_probabilities_day_3[4]))
    end

    # Создание популяции
    @time @threads for thread_id in 1:num_threads
        create_population(
            thread_id, num_threads, thread_rng, start_agent_ids[thread_id],
            agents, households, viruses, num_infected_age_groups_viruses_prev, isolation_probabilities_day_1,
            isolation_probabilities_day_2, isolation_probabilities_day_3, start_household_ids[thread_id],
            homes_coords_df, district_households, district_people, district_people_households)
    end

    # Установление связей между агентами
    @time set_connections(
        agents, households, kindergartens, schools, colleges,
        workplaces, thread_rng, num_threads, homes_coords_df,
        firm_min_size, firm_max_size, work_num_barabasi_albert_attachments,
        school_num_barabasi_albert_attachments)

    println("Simulation")

    num_swarm_model_runs = 25
    num_particles = 10

    w = 0.5
    w_min = 0.4
    w_max = 0.9
    c1 = 2.0
    c2 = 2.0

    num_years = 1
    num_parameters = 26
    num_viruses = 7

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, num_particles)
    best_error = 9.0e11
    error_particles = zeros(Float64, num_particles) .+ 9999999.0

    duration_parameter_particles = Array{Float64, 1}(undef, num_particles)
    susceptibility_parameters_particles = Array{Vector{Float64}, 1}(undef, num_particles)
    temperature_parameters_particles = Array{Vector{Float64}, 1}(undef, num_particles)
    mean_immunity_durations_particles = Array{Vector{Float64}, 1}(undef, num_particles)
    random_infection_probabilities_particles = Array{Vector{Float64}, 1}(undef, num_particles)

    duration_parameter_particles_velocity = zeros(Float64, num_particles)
    susceptibility_parameters_particles_velocity = zeros(Float64, num_particles, num_viruses)
    temperature_parameters_particles_velocity = zeros(Float64, num_particles, num_viruses)
    mean_immunity_durations_particles_velocity = zeros(Float64, num_particles, num_viruses)
    random_infection_probabilities_particles_velocity = zeros(Float64, num_particles, 4)

    duration_parameter_particles_best = Array{Float64, 1}(undef, num_particles)
    susceptibility_parameters_particles_best = Array{Vector{Float64}, 1}(undef, num_particles)
    temperature_parameters_particles_best = Array{Vector{Float64}, 1}(undef, num_particles)
    mean_immunity_durations_particles_best = Array{Vector{Float64}, 1}(undef, num_particles)
    random_infection_probabilities_particles_best = Array{Vector{Float64}, 1}(undef, num_particles)

    duration_parameter_best = 0.0
    susceptibility_parameters_best = zeros(Float64, num_viruses)
    temperature_parameters_best = zeros(Float64, num_viruses)
    mean_immunity_durations_best = zeros(Float64, num_viruses)
    random_infection_probabilities_best = zeros(Float64, 4)

    velocity_particles = zeros(Float64, num_particles)

    # В случае, если значения загружаются из таблицы
    points = Matrix(DataFrame(CSV.File(joinpath(@__DIR__, "..", "output", "tables", "swarm", "parameters_swarm.csv"), header = false)))

    # Латинский гиперкуб
    latin_hypercube_plan, _ = LHCoptim(num_particles, num_parameters, 500)

    # Интервалы значений параметров
    # points = scaleLHC(latin_hypercube_plan, [
    #     (0.1, 1.0), # duration_parameter
    #     (1.0, 7.0), # susceptibility_parameters
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (1.0, 7.0),
    #     (-1.0, -0.01), # temperature_parameters
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (-1.0, -0.01),
    #     (30, 365), # mean_immunity_durations
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (30, 365),
    #     (0.0008, 0.0012), # random_infection_probabilities
    #     (0.0005, 0.001),
    #     (0.0002, 0.0005),
    #     (0.000005, 0.00001),
    # ])
    # writedlm(joinpath(@__DIR__, "..", "output", "tables", "swarm", "parameters_swarm.csv"), points, ',')

    for i = 1:num_particles
        duration_parameter_particles_best[i] = points[i, 1]
        susceptibility_parameters_particles_best[i] = copy(points[i, 2:8])
        temperature_parameters_particles_best[i] = copy(points[i, 9:15])
        mean_immunity_durations_particles_best[i] = copy(points[i, 16:22])
        for k = 1:length(viruses)
            viruses[k].mean_immunity_duration = points[i, 15 + k]
            viruses[k].immunity_duration_sd = points[i, 15 + k] * 0.33
        end
        random_infection_probabilities_particles_best[i] = copy(points[i, 23:26])

        duration_parameter_particles[i] = points[i, 1]
        susceptibility_parameters_particles[i] = copy(points[i, 2:8])
        temperature_parameters_particles[i] = copy(points[i, 9:15])
        mean_immunity_durations_particles[i] = copy(points[i, 16:22])
        random_infection_probabilities_particles[i] = copy(points[i, 23:26])

        # Сбрасываем состояние синтетической популяции до начального
        @threads for thread_id in 1:num_threads
            reset_agent_states(
                agents,
                start_agent_ids[thread_id],
                end_agent_ids[thread_id],
                viruses,
                num_infected_age_groups_viruses_prev,
                isolation_probabilities_day_1,
                isolation_probabilities_day_2,
                isolation_probabilities_day_3,
                thread_rng[thread_id],
            )
        end

        # Если уже посчитано
        for i = 1:num_particles
            incidence_arr[i] = load(joinpath(@__DIR__, "..", "output", "tables", "swarm", "0", "results_$(i).jld"))["observed_cases"]
        end

        # Если не посчитано
        # @time incidence_arr[i], activities_infections, rt, num_schools_closed = run_simulation(
        #     num_threads, thread_rng, agents, viruses, households, schools, duration_parameter_particles_best[i],
        #     susceptibility_parameters_particles_best[i], temperature_parameters_particles_best[i], temperature,
        #     mean_household_contact_durations, household_contact_duration_sds,
        #     other_contact_duration_shapes, other_contact_duration_scales,
        #     isolation_probabilities_day_1, isolation_probabilities_day_2,
        #     isolation_probabilities_day_3, random_infection_probabilities_particles_best[i],
        #     recovered_duration_mean, recovered_duration_sd, num_years, false)

        error_particles[i] = sum((incidence_arr[i] - num_infected_age_groups_viruses).^2)
        if error_particles[i] < best_error
            best_error = error_particles[i]

            duration_parameter_best = points[i, 1]
            susceptibility_parameters_best = copy(points[i, 2:8])
            temperature_parameters_best = copy(points[i, 9:15])
            mean_immunity_durations_best = copy(points[i, 16:22])
            random_infection_probabilities_best = copy(points[i, 23:26])
        end

        # Если не посчитано
        # save(joinpath(@__DIR__, "..", "output", "tables", "swarm", "0", "results_$(i).jld"),
        #     "observed_cases", incidence_arr[i],
        #     "duration_parameter", duration_parameter_particles_best[i],
        #     "susceptibility_parameters", susceptibility_parameters_particles_best[i],
        #     "temperature_parameters", temperature_parameters_particles_best[i],
        #     "mean_immunity_durations", mean_immunity_durations_particles_best[i],
        #     "random_infection_probabilities", random_infection_probabilities_particles_best[i])
    end

    for curr_run = 1:num_swarm_model_runs
        w = (num_swarm_model_runs - curr_run) / num_swarm_model_runs * (w_max - w_min) + w_min
        for i = 1:num_particles
            duration_parameter_particles_velocity[i] = w * duration_parameter_particles_velocity[i] + c1 * rand(thread_rng[1], Float64) * (duration_parameter_particles_best[i] - duration_parameter_particles[i]) + c2 * rand(thread_rng[1], Float64) * (duration_parameter_best - duration_parameter_particles[i])
            for j = 1:num_viruses
                susceptibility_parameters_particles_velocity[i, j] = w * susceptibility_parameters_particles_velocity[i, j] +  c1 * rand(thread_rng[1], Float64) * (susceptibility_parameters_particles_best[i][j] - susceptibility_parameters_particles[i][j]) + c2 * rand(thread_rng[1], Float64) * (susceptibility_parameters_best[j] - susceptibility_parameters_particles[i][j])
                temperature_parameters_particles_velocity[i, j] =  w * temperature_parameters_particles_velocity[i, j] + c1 * rand(thread_rng[1], Float64) * (temperature_parameters_particles_best[i][j] - temperature_parameters_particles[i][j]) + c2 * rand(thread_rng[1], Float64) * (temperature_parameters_best[j] - temperature_parameters_particles[i][j])
                mean_immunity_durations_particles_velocity[i, j] = w * mean_immunity_durations_particles_velocity[i, j] + c1 * rand(thread_rng[1], Float64) * (mean_immunity_durations_particles_best[i][j] - mean_immunity_durations_particles[i][j]) + c2 * rand(thread_rng[1], Float64) * (mean_immunity_durations_best[j] - mean_immunity_durations_particles[i][j])
            end
            for j = 1:4
                random_infection_probabilities_particles_velocity[i, j] = w * random_infection_probabilities_particles_velocity[i, j] + c1 * rand(thread_rng[1], Float64) * (random_infection_probabilities_particles_best[i][j] - random_infection_probabilities_particles[i][j]) + c2 * rand(thread_rng[1], Float64) * (random_infection_probabilities_best[j] - random_infection_probabilities_particles[i][j])
            end

            duration_parameter_particles[i] += duration_parameter_particles_velocity[i]
            for j = 1:num_viruses
                susceptibility_parameters_particles[i][j] += susceptibility_parameters_particles_velocity[i, j]
                temperature_parameters_particles[i][j] += temperature_parameters_particles_velocity[i, j]
                mean_immunity_durations_particles[i][j] += mean_immunity_durations_particles_velocity[i, j]
            end
            for j = 1:4
                random_infection_probabilities_particles[i][j] += random_infection_probabilities_particles_velocity[i, j]
            end

            # Ограничения на область значений параметров
            if duration_parameter_particles[i] < 0.1 || duration_parameter_particles[i] > 1
                duration_parameter_particles[i] = rand(Uniform(0.1, 1.0))
            end
            for j = 1:num_viruses
                if susceptibility_parameters_particles[i][j] < 1 || susceptibility_parameters_particles[i][j] > 7
                    susceptibility_parameters_particles[i][j] = rand(Uniform(1.0, 7.0))
                end
                if temperature_parameters_particles[i][j] < -1 || temperature_parameters_particles[i][j] > -0.01
                    temperature_parameters_particles[i][j] = rand(Uniform(-1.0, -0.01))
                end
                if mean_immunity_durations_particles[i][j] < 30 || mean_immunity_durations_particles[i][j] > 365
                    mean_immunity_durations_particles[i][j] = rand(Uniform(30.0, 365.0))
                end
                viruses[j].mean_immunity_duration = mean_immunity_durations_particles[i][j]
                viruses[j].immunity_duration_sd = mean_immunity_durations_particles[i][j] * 0.33
            end
            if random_infection_probabilities_particles[i][1] < 0.0008 || random_infection_probabilities_particles[i][1] > 0.0012
                random_infection_probabilities_particles[i][1] = rand(Uniform(0.0008, 0.0012))
            end
            if random_infection_probabilities_particles[i][2] < 0.0005 || random_infection_probabilities_particles[i][2] > 0.001
                random_infection_probabilities_particles[i][2] = rand(Uniform(0.0005, 0.001))
            end
            if random_infection_probabilities_particles[i][3] < 0.0002 || random_infection_probabilities_particles[i][3] > 0.0005
                random_infection_probabilities_particles[i][3] = rand(Uniform(0.0002, 0.0005))
            end
            if random_infection_probabilities_particles[i][4] < 0.000005 || random_infection_probabilities_particles[i][4] > 0.00001
                random_infection_probabilities_particles[i][4] = rand(Uniform(0.000005, 0.00001))
            end

            # Сбрасываем состояние синтетической популяции до начального
            @threads for thread_id in 1:num_threads
                reset_agent_states(
                    agents,
                    start_agent_ids[thread_id],
                    end_agent_ids[thread_id],
                    viruses,
                    num_infected_age_groups_viruses_prev,
                    isolation_probabilities_day_1,
                    isolation_probabilities_day_2,
                    isolation_probabilities_day_3,
                    thread_rng[thread_id],
                )
            end

            # Моделируем заболеваемость
            @time observed_num_infected_age_groups_viruses, activities_infections, rt, num_schools_closed = run_simulation(
                num_threads, thread_rng, agents, viruses, households, schools, duration_parameter_particles[i],
                susceptibility_parameters_particles[i], temperature_parameters_particles[i], temperature,
                mean_household_contact_durations, household_contact_duration_sds,
                other_contact_duration_shapes, other_contact_duration_scales,
                isolation_probabilities_day_1, isolation_probabilities_day_2,
                isolation_probabilities_day_3, random_infection_probabilities_particles[i],
                recovered_duration_mean, recovered_duration_sd, num_years, false)

            # Функция потерь
            error = 0.0
            # Если рассматривается 1 год
            if is_one_mean_year_modeled
                observed_num_infected_age_groups_viruses_mean = observed_num_infected_age_groups_viruses[1:52, :, :]
                for i = 2:num_years
                    for j = 1:52
                        observed_num_infected_age_groups_viruses_mean[j, :, :] += observed_num_infected_age_groups_viruses[(i - 1) * 52 + j, :, :]
                    end
                end
                observed_num_infected_age_groups_viruses_mean ./= num_years
                error = sum((observed_num_infected_age_groups_viruses_mean - num_infected_age_groups_viruses).^2)
            else
                error = sum(abs.(observed_num_infected_age_groups_viruses - num_infected_age_groups_viruses).^2)
            end

            save(joinpath(@__DIR__, "..", "output", "tables", "swarm", "$(i)", "results_$(curr_run).jld"),
                "observed_cases", observed_num_infected_age_groups_viruses,
                "duration_parameter", duration_parameter_particles[i],
                "susceptibility_parameters", susceptibility_parameters_particles[i],
                "temperature_parameters", temperature_parameters_particles[i],
                "mean_immunity_durations", mean_immunity_durations_particles[i],
                "random_infection_probabilities", random_infection_probabilities_particles[i],
                "duration_parameter_velocity", duration_parameter_particles_velocity[i],
                "susceptibility_parameters_velocity", susceptibility_parameters_particles_velocity[i, :],
                "temperature_parameters_velocity", temperature_parameters_particles_velocity[i, :],
                "mean_immunity_durations_velocity", mean_immunity_durations_particles_velocity[i, :],
                "random_infection_probabilities_velocity", random_infection_probabilities_particles_velocity[i, :],)

            if error < best_error
                best_error = error

                duration_parameter_best = duration_parameter_particles[i]
                susceptibility_parameters_best = copy(susceptibility_parameters_particles[i])
                temperature_parameters_best = copy(temperature_parameters_particles[i])
                random_infection_probabilities_best = copy(random_infection_probabilities_particles[i])
                mean_immunity_durations_best = copy(mean_immunity_durations_particles[i])

                println("Best!!!")
                println("error_best = ", error)
                println("duration_parameter = ", duration_parameter_best)
                println("susceptibility_parameters = ", susceptibility_parameters_best)
                println("temperature_parameters = ", temperature_parameters_best)
                println("mean_immunity_durations = ", mean_immunity_durations_best)
                println("random_infection_probabilities = ", random_infection_probabilities_best)
                println()
            end

            if error < error_particles[i]
                error_particles[i] = error

                duration_parameter_particles_best[i] = duration_parameter_particles[i]
                susceptibility_parameters_particles_best[i] = copy(susceptibility_parameters_particles[i])
                temperature_parameters_particles_best[i] = copy(temperature_parameters_particles[i])
                random_infection_probabilities_particles_best[i] = copy(random_infection_probabilities_particles[i])
                mean_immunity_durations_particles_best[i] = copy(mean_immunity_durations_particles[i])

                println("Particle")
                println("error_particle $(i) = ", error)
                println("duration_parameter = ", duration_parameter_particles_best[i])
                println("susceptibility_parameters = ", susceptibility_parameters_particles_best[i])
                println("temperature_parameters = ", temperature_parameters_particles_best[i])
                println("mean_immunity_durations = ", mean_immunity_durations_particles_best[i])
                println("random_infection_probabilities = ", random_infection_probabilities_particles_best[i])
                println()
            end
        end
    end
end

run_swarm_model()
