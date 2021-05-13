# @everywhere x = 1234

# x0 = 567

# @everywhere function showid()
#     println(myid())
# end

# @everywhere showid()

# println(nprocs())
# println(nworkers())
# workers()

# t = rmprocs(2, 3, waitfor=0)
# wait(t)

# @spawnat 2 println(myid())
# fetch(@spawnat 2 4)

# @spawn (x.^2, myid())
# @spawnat 2 (x.^2, myid())

# n = 10_000
# A = randn(n, n)

# # Copy A
# @time fetch(@spawnat :any sum(A.^2))
# # Copy n
# @time fetch(@spawnat :any sum(randn(n, n).^2))

# @everywhere println(x)


# @everywhere include
# @everywhere using

# varinfo()
# fetch(@spawnat 3 varinfo())

# @everywhere function points_inside_circle(n)
#     n_in = 0
#     for i = 1:n
#         x, y = rand(), rand()
#         n_in += (x*x + y*y) <= 1
#     end
#     return n_in
# end

# function pi_p(n)
#     p = nworkers()
#     # n_in = sum(pmap(x->points_inside_circle(x), [n/p for i=1:p]))
#     n_in = @distributed (+) for i=1:p
#         points_inside_circle(n/p)
#     end
#     return 4 * n_in / n
# end

# println(pi_p(10_000))

using Distributed
using DelimitedFiles
using Distributions
using Random

@everywhere include("src/model/agent.jl")
@everywhere include("src/model/collective.jl")
@everywhere include("src/data/temperature.jl")

@everywhere function initialization(worker_id::Int, num_of_workers::Int)
    println("Initialization...")
    
    # Вирусы
    viruses = Virus[
        Virus(1, 1.4, 0.09, 1, 7, 4.8, 1.12, 3, 12, 8.8, 3.748, 4, 14, 4.6, 0.16),
        Virus(2, 1.0, 0.0484, 1, 7, 3.7, 0.66, 3, 12, 7.8, 2.94, 4, 14, 4.7, 0.16),
        Virus(3, 1.9, 0.175, 1, 7, 10.1, 4.93, 3, 12, 11.4, 6.25, 4, 14, 3.5, 0.3),
        Virus(4, 4.4, 0.937, 1, 7, 7.4, 2.66, 3, 12, 9.3, 4.0, 4, 14, 6.0, 0.3),
        Virus(5, 5.6, 1.51, 1, 7, 8.0, 3.1, 3, 12, 9.0, 3.92, 4, 14, 4.1, 0.3),
        Virus(6, 2.6, 0.327, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.7, 0.3),
        Virus(7, 3.2, 0.496, 1, 7, 7.0, 2.37, 3, 12, 8.0, 3.1, 4, 14, 4.93, 0.3)]

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

    # Коллективы
    collectives = Collective[
        Collective(1, 5.88, 2.52, [[Int[]], [Int[]], [Int[]], [Int[]], [Int[]], [Int[]]]),
        Collective(2, 4.783, 2.67, [[Int[]], [Int[]], [Int[]], [Int[]], [Int[]], [Int[]],
            [Int[]], [Int[]], [Int[]], [Int[]], [Int[]]]),
        Collective(3, 2.1, 3.0, [[Int[]], [Int[]], [Int[]], [Int[]], [Int[]], [Int[]]]),
        Collective(4, 3.0, 3.0, [[Int[]]])]

    # Параметры
    duration_parameter = 7.05
    temperature_parameters = Float64[-0.8, -0.8, -0.05, -0.64, -0.2, -0.05, -0.8]   
    # temperature_parameters = Float64[-0.8, -0.8, -0.1, -0.64, -0.2, -0.1, -0.8]   
    susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]
    # susceptibility_parameters = Float64[2.1, 2.1, 3.77, 4.89, 4.69, 3.89, 3.77]
    immunity_durations = Int[366, 366, 60, 60, 90, 90, 366]

    # Температура воздуха, начиная с 1 января
    temperature = get_air_temperature()

    # Минимальная температура воздуха
    min_temp = -7.2
    # Max - Min температура
    max_min_temp = 26.6

    temp_influences = Array{Float64,2}(undef, 7, 365)
    year_day = 213
    for step in 1:365
        current_temp = (temperature[year_day] - min_temp) / max_min_temp
        for v in 1:7
            temp_influences[v, step] = temperature_parameters[v] * current_temp + 1.0
        end
        if year_day == 365
            year_day = 1
        else
            year_day += 1
        end
    end

    # Набор агентов
    all_agents = Agent[]

    # for i = worker_id:num_of_workers:100000
    #     println(i)
    #     # push!(all_agents, Agent(i, viruses, viral_loads, [1, 2], true, 44))
    # end
    for i = 1:10
        println(i)
    end
    println(worker_id)
end

num_of_workers = nworkers()
@spawnat 2 initialization(1, num_of_workers)
@spawnat 3 initialization(2, num_of_workers)
@spawnat 4 initialization(3, num_of_workers)
