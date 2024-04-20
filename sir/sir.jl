using Distributions
using Random
using DataFrames
using StatsPlots
using LatinHypercubeSampling
using JLD
using CSV
using DelimitedFiles
using XGBoost
using Lux
using Zygote
using Optimisers

function log_g(x, mu, sigma)
    return -log(sqrt(2 * pi) * sigma) - 0.5 * ((x - mu) / sigma)^2
end

function f(x, mu, sigma)
    dist = Normal(mu, sigma)
    return cdf(dist, x + 0.5) - cdf(dist, x - 0.5)
end

# References
const S_ref = [9990, 9989, 9989, 9989, 9988, 9988, 9988, 9987, 9986, 9986, 9986, 9985, 9985, 9985, 9985, 9983, 9982, 9982, 9982, 9981, 9979, 9978, 9978, 9977, 9974, 9972, 9972, 9972, 9971, 9970, 9967, 9965, 9963, 9963, 9961, 9960, 9959, 9958, 9956, 9953, 9951, 9946, 9943, 9943, 9940, 9937, 9935, 9935, 9933, 9932, 9931, 9929, 9925, 9925, 9923, 9920, 9919, 9916, 9914, 9912, 9910, 9909, 9908, 9905, 9903, 9901, 9897, 9897, 9893, 9888, 9887, 9885, 9881, 9880, 9876, 9871, 9870, 9867, 9861, 9860, 9856, 9852, 9848, 9848, 9842, 9838, 9832, 9829, 9826, 9823, 9821, 9817, 9813, 9803, 9799, 9794, 9788, 9782, 9775, 9766, 9762, 9755, 9749, 9738, 9733, 9729, 9724, 9714, 9706, 9698, 9695, 9684, 9674, 9666, 9656, 9651, 9641, 9630, 9617, 9612, 9601, 9588, 9582, 9569, 9559, 9544, 9532, 9524, 9516, 9507, 9491, 9480, 9466, 9455, 9440, 9427, 9410, 9391, 9367, 9350, 9328, 9311, 9294, 9277, 9258, 9240, 9222, 9199, 9181, 9159, 9137, 9124, 9101, 9079, 9061, 9036, 9012, 8991, 8966, 8937, 8909, 8872, 8846, 8821, 8794, 8770, 8737, 8707, 8671, 8647, 8610, 8574, 8533, 8492, 8451, 8413, 8381, 8343, 8304, 8258, 8212, 8172, 8133, 8101, 8054, 8001, 7961, 7914, 7867, 7827, 7790, 7743, 7703, 7655, 7614, 7574, 7527, 7479, 7442, 7391, 7343, 7307, 7260, 7208, 7152, 7102, 7051, 7010, 6962, 6907, 6863, 6811, 6742, 6680, 6630, 6578, 6510, 6448, 6399, 6347, 6291, 6235, 6180, 6135, 6084, 6026, 5974, 5916, 5858, 5810, 5762, 5710, 5660, 5615, 5560, 5509, 5451, 5407, 5352, 5297, 5250, 5193, 5135, 5070, 5025, 4975, 4930, 4859, 4805, 4753, 4691, 4638, 4586, 4537, 4491, 4441, 4384, 4332, 4288, 4224, 4177, 4125, 4073, 4027, 3998, 3962, 3922, 3888, 3840, 3793, 3749, 3708, 3657, 3623, 3590, 3550, 3505, 3473, 3432, 3399, 3355, 3316, 3279, 3243, 3208, 3170, 3134, 3100, 3077, 3052, 3016, 2986, 2958, 2930, 2888, 2854, 2826, 2802, 2777, 2751, 2729, 2702, 2680, 2661, 2638, 2615, 2586, 2562, 2531, 2507, 2488, 2465, 2447, 2429, 2404, 2383, 2362, 2342, 2318, 2291, 2265, 2247, 2234, 2222, 2206, 2199, 2178, 2154, 2137, 2118, 2105, 2090, 2077, 2055, 2036, 2014, 2003, 1984, 1970, 1955, 1938, 1927, 1912, 1898, 1884, 1872, 1860, 1851, 1839, 1831, 1814, 1804, 1787, 1778, 1763, 1752, 1743, 1736, 1726, 1714, 1706, 1697, 1685, 1676, 1663, 1652, 1638, 1632, 1622, 1613, 1606, 1599, 1589, 1583, 1573, 1565, 1558, 1547, 1539, 1533, 1527, 1520, 1514, 1505, 1502, 1496, 1485, 1478, 1475, 1468, 1466, 1459, 1452, 1449, 1443, 1439, 1430, 1424, 1419, 1412, 1411]
const I_ref = [10, 11, 10, 9, 9, 9, 9, 10, 11, 11, 10, 11, 11, 11, 11, 13, 14, 14, 14, 15, 17, 18, 18, 19, 22, 24, 23, 23, 24, 25, 28, 27, 29, 29, 30, 31, 32, 33, 35, 36, 36, 40, 43, 43, 45, 47, 49, 49, 50, 51, 50, 51, 55, 54, 55, 56, 53, 55, 57, 58, 58, 58, 58, 58, 59, 59, 62, 60, 62, 66, 67, 67, 69, 69, 71, 74, 73, 75, 80, 80, 83, 87, 89, 89, 93, 95, 98, 99, 101, 100, 100, 102, 106, 114, 116, 121, 123, 127, 133, 137, 139, 143, 147, 158, 158, 157, 157, 161, 168, 172, 170, 176, 184, 188, 195, 195, 201, 209, 218, 220, 226, 237, 236, 246, 252, 259, 265, 268, 273, 279, 290, 295, 305, 305, 313, 321, 327, 340, 359, 370, 382, 392, 397, 404, 415, 430, 440, 451, 458, 468, 486, 490, 507, 524, 530, 547, 560, 568, 580, 603, 623, 651, 663, 671, 681, 689, 713, 732, 752, 759, 779, 803, 823, 843, 868, 896, 910, 932, 957, 979, 999, 1010, 1023, 1038, 1063, 1101, 1124, 1152, 1182, 1195, 1215, 1239, 1253, 1285, 1303, 1315, 1344, 1362, 1369, 1389, 1412, 1417, 1439, 1457, 1478, 1497, 1515, 1514, 1525, 1554, 1567, 1578, 1618, 1648, 1667, 1682, 1714, 1739, 1758, 1777, 1803, 1823, 1838, 1841, 1856, 1877, 1889, 1920, 1941, 1955, 1953, 1974, 1977, 1980, 1992, 2005, 2015, 2014, 2029, 2048, 2051, 2078, 2082, 2095, 2092, 2095, 2094, 2134, 2137, 2154, 2175, 2176, 2184, 2186, 2185, 2185, 2202, 2221, 2231, 2256, 2248, 2254, 2260, 2260, 2245, 2251, 2255, 2233, 2245, 2248, 2251, 2249, 2255, 2246, 2239, 2230, 2228, 2221, 2217, 2208, 2205, 2194, 2176, 2167, 2155, 2148, 2138, 2135, 2128, 2106, 2105, 2096, 2071, 2061, 2054, 2034, 2032, 2013, 1996, 1983, 1964, 1946, 1929, 1912, 1889, 1871, 1857, 1845, 1843, 1828, 1812, 1793, 1777, 1753, 1731, 1722, 1709, 1688, 1685, 1675, 1664, 1660, 1633, 1609, 1598, 1569, 1564, 1548, 1534, 1518, 1504, 1496, 1486, 1486, 1482, 1469, 1446, 1428, 1426, 1417, 1397, 1384, 1380, 1372, 1356, 1342, 1317, 1298, 1285, 1277, 1265, 1250, 1243, 1233, 1230, 1220, 1199, 1181, 1171, 1162, 1144, 1135, 1119, 1103, 1104, 1091, 1091, 1077, 1062, 1055, 1039, 1026, 1018, 1007, 997, 979, 965, 959, 944, 930, 907, 897, 882, 874, 859, 847, 843, 830, 813, 803, 791, 781, 767, 756, 748, 738, 724, 715, 707, 704, 684]
const R_ref = [0, 0, 1, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 8, 8, 8, 9, 9, 9, 9, 9, 11, 13, 14, 14, 14, 15, 16, 16, 16, 17, 17, 19, 20, 20, 21, 22, 24, 28, 29, 29, 30, 32, 33, 34, 37, 38, 40, 41, 43, 45, 46, 46, 48, 50, 51, 53, 55, 57, 58, 59, 60, 61, 61, 63, 63, 65, 67, 70, 72, 73, 77, 79, 81, 81, 83, 85, 85, 89, 91, 92, 97, 99, 102, 104, 104, 109, 114, 119, 125, 126, 130, 135, 140, 142, 146, 149, 154, 158, 161, 165, 168, 173, 175, 182, 185, 189, 197, 203, 208, 211, 214, 219, 225, 229, 240, 247, 252, 263, 269, 274, 280, 290, 297, 309, 319, 327, 330, 338, 350, 361, 373, 377, 386, 392, 397, 409, 417, 428, 441, 454, 460, 468, 477, 491, 508, 525, 541, 550, 561, 577, 594, 611, 623, 644, 665, 681, 691, 709, 725, 739, 763, 789, 818, 844, 861, 883, 898, 915, 934, 951, 978, 995, 1018, 1044, 1060, 1083, 1111, 1129, 1159, 1189, 1220, 1245, 1276, 1301, 1335, 1370, 1401, 1434, 1476, 1513, 1539, 1570, 1611, 1640, 1672, 1703, 1740, 1776, 1813, 1843, 1876, 1906, 1942, 1982, 2024, 2060, 2097, 2137, 2164, 2201, 2235, 2285, 2316, 2363, 2405, 2448, 2486, 2534, 2579, 2619, 2655, 2699, 2729, 2783, 2835, 2883, 2930, 2976, 3007, 3058, 3093, 3134, 3186, 3230, 3277, 3324, 3374, 3414, 3447, 3481, 3520, 3575, 3621, 3667, 3713, 3757, 3787, 3823, 3879, 3915, 3959, 4000, 4043, 4088, 4131, 4171, 4220, 4267, 4306, 4351, 4393, 4440, 4490, 4545, 4590, 4637, 4682, 4728, 4765, 4795, 4842, 4879, 4918, 4971, 5009, 5058, 5112, 5142, 5185, 5227, 5266, 5307, 5352, 5391, 5427, 5473, 5514, 5557, 5593, 5626, 5665, 5700, 5742, 5776, 5818, 5865, 5895, 5929, 5970, 5997, 6034, 6071, 6093, 6133, 6169, 6196, 6232, 6258, 6298, 6329, 6364, 6391, 6414, 6437, 6459, 6482, 6517, 6551, 6588, 6604, 6628, 6665, 6689, 6708, 6730, 6760, 6786, 6823, 6851, 6876, 6892, 6921, 6946, 6970, 6989, 7007, 7028, 7058, 7083, 7103, 7124, 7150, 7168, 7196, 7221, 7233, 7257, 7271, 7291, 7316, 7332, 7355, 7375, 7393, 7410, 7430, 7456, 7477, 7494, 7517, 7537, 7566, 7583, 7604, 7621, 7639, 7657, 7672, 7692, 7712, 7729, 7743, 7760, 7781, 7795, 7809, 7823, 7846, 7861, 7874, 7884, 7905]

@enum InfectionStatus Susceptible Infected Recovered

function susceptible(x)
    return count(i == Susceptible for i in x)
end
    
function infected(x)
    return count(i == Infected for i in x)
end

function recovered(x)
    return count(i == Recovered for i in x)
end

function sir_abm!(d_agents, agents, p, t)
    (β, c, γ, δt) = p
    N = length(agents)
    for i in 1:N
        d_agents[i] = agents[i]
    end
    for i in 1:length(agents)
        if agents[i] == Recovered
            continue
        elseif agents[i] == Susceptible
            ncontacts = rand(Poisson(c * δt))
            while ncontacts > 0
                j = sample(1:N)
                if j == i
                    continue
                end
                a = agents[j]
                if a == Infected && rand() < β
                    d_agents[i] = Infected
                    break
                end
                ncontacts -= 1
            end
        elseif rand() < γ
            d_agents[i] = Recovered
        end
    end
end

function sim!(agents_initial, nsteps, dt, p)
    agents = copy(agents_initial)
    d_agents = copy(agents_initial)
    t = 0.0
    ta = []
    Sa = []
    Ia = []
    Ra =[]
    push!(ta, t)
    push!(Sa, susceptible(agents))
    push!(Ia, infected(agents))
    push!(Ra, recovered(agents))
    for i in 1:nsteps
        sir_abm!(d_agents, agents, p, t)
        agents, d_agents = d_agents, agents
        t = t + dt
        push!(ta, t)
        push!(Sa, susceptible(agents))
        push!(Ia, infected(agents))
        push!(Ra, recovered(agents))
    end
    return DataFrame(t=ta, S=Sa, I=Ia, R=Ra)
end

function run_model(agents_initial, nsteps, δt, β, c, γ)
    p = [β, c, γ, δt]
    # Running the model
    df_abm = sim!(agents_initial, nsteps, δt, p)
    # println(df_abm.t)

    # println("S_ref = $(df_abm.S)")
    # println("I_ref = $(df_abm.I)")
    # println("R_ref = $(df_abm.R)")

    s = sum(abs.(df_abm.S - S_ref))
    s += sum(abs.(df_abm.I - I_ref))
    s += sum(abs.(df_abm.R - R_ref))

    pl = plot(
        df_abm.t,
        [df_abm.S df_abm.I df_abm.R],
        label=["S" "I" "R"],
        xlabel="Time",
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    savefig(pl, joinpath(@__DIR__, "sir.pdf"))
    
    nMAE = s / sum(S_ref + I_ref + R_ref)
    return nMAE

    # println(nMAE)
end

function run_model_metropolis(agents_initial, nsteps, δt, β, c, γ)
    p = [β, c, γ, δt]
    # Running the model
    df_abm = sim!(agents_initial, nsteps, δt, p)
    # println(df_abm.t)

    # println("S_ref = $(df_abm.S)")
    # println("I_ref = $(df_abm.I)")
    # println("R_ref = $(df_abm.R)")

    s = sum(abs.(df_abm.S - S_ref))
    s += sum(abs.(df_abm.I - I_ref))
    s += sum(abs.(df_abm.R - R_ref))
    
    nMAE = s / sum(S_ref + I_ref + R_ref)

    return df_abm.S, df_abm.I, df_abm.R, nMAE

    # println(nMAE)

    # pl = plot(
    #     df_abm.t,
    #     [df_abm.S df_abm.I df_abm.R],
    #     label=["S" "I" "R"],
    #     xlabel="Time",
    #     ylabel="Number of people",
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    # )
    # savefig(pl, joinpath(@__DIR__, "sir.pdf"))
end





function lhs_simulations(
    # Число прогонов модели
    num_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
)
    # Число параметров
    num_parameters = 4

    # Латинский гиперкуб
    latin_hypercube_plan, _ = LHCoptim(num_runs, num_parameters, 200)

    # Интервалы значений параметров
    points = scaleLHC(latin_hypercube_plan, [
        (0.02, 0.2), # β
        (5, 25), # c
        (0.01, 0.05), # γ
        (1, 50), # I0
    ])

    nMAE_min = 1.0e12

    for i = 1:num_runs
        println(i)

        β_parameter = points[i, 1]
        c_parameter = points[i, 2]
        γ_parameter = points[i, 3]
        I0_parameter = points[i, 4]

        # Reset
        for i in 1:length(agents)
            if i <= I0_parameter # I0
                agents[i] = Infected
            else
                agents[i] = Susceptible
            end
        end
        # Моделируем заболеваемость
        nMAE = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        if nMAE < nMAE_min
            nMAE_min = nMAE
            println("β_parameter = ", β_parameter)
            println("c_parameter = ", c_parameter)
            println("γ_parameter = ", γ_parameter)
            println("I0_parameter = ", I0_parameter)
        end
        save(joinpath(@__DIR__, "lhs", "results_$(i).jld"),
            "nMAE", nMAE,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)
    end
end

function mcmc_simulations_lhs(
    # Число прогонов модели
    num_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
)
    # Получаем значения параметров
    β_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_lhs", "1_array.csv"), ',', Float64, '\n'))
    β_parameter = β_parameter_array[end]

    c_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_lhs", "2_array.csv"), ',', Float64, '\n'))
    c_parameter = c_parameter_array[end]

    γ_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_lhs", "3_array.csv"), ',', Float64, '\n'))
    γ_parameter = γ_parameter_array[end]

    I0_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_lhs", "4_array.csv"), ',', Float64, '\n'))
    I0_parameter = I0_parameter_array[end]

    nMAE = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)
    # Reset
    for i in 1:length(agents)
        if i <= I0_parameter # I0
            agents[i] = Infected
        else
            agents[i] = Susceptible
        end
    end
    open(joinpath(@__DIR__, "mcmc_lhs.txt"), "a") do io
        println(io, nMAE)
    end

    # Число принятий новых значений параметров
    accept_num = 0
    # Число последовательных отказов
    local_rejected_num = 0

    β_parameter_delta = 0.1
    c_parameter_delta = 0.1
    γ_parameter_delta = 0.1
    I0_parameter_delta = 0.1

    nMAE_min = 99999.0
    nMAE_prev = nMAE
    nMAE_min = nMAE

    # (0.02, 0.2), # β
    # (5, 25), # c
    # (0.01, 0.05), # γ
    for n = 1:num_runs
        x = β_parameter_array[end]
        y = rand(Normal(log((x - 0.02) / (0.2 - x)), β_parameter_delta))
        β_parameter = (0.2 * exp(y) + 0.02) / (1 + exp(y))

        x = c_parameter_array[end]
        y = rand(Normal(log((x - 5) / (25 - x)), c_parameter_delta))
        c_parameter = (25 * exp(y) + 5) / (1 + exp(y))

        x = γ_parameter_array[end]
        y = rand(Normal(log((x - 0.01) / (0.05 - x)), γ_parameter_delta))
        γ_parameter = (0.05 * exp(y) + 0.01) / (1 + exp(y))

        x = I0_parameter_array[end]
        y = rand(Normal(log((x - 1) / (50 - x)), I0_parameter_delta))
        I0_parameter = (50 * exp(y) + 1) / (1 + exp(y))

        # Reset
        for i in 1:length(agents)
            if i <= I0_parameter # I0
                agents[i] = Infected
            else
                agents[i] = Susceptible
            end
        end
        nMAE = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "mcmc_lhs", "results_$(n).jld"),
            "nMAE", nMAE,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)

        open(joinpath(@__DIR__, "mcmc_lhs.txt"), "a") do io
            println(io, nMAE)
        end

        # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
        if nMAE < nMAE_prev || local_rejected_num >= 10
            if nMAE < nMAE_min
                nMAE_min = nMAE
                println("nMAE min = $(nMAE)")
                println("β_parameter = $(β_parameter)")
                println("c_parameter = $(c_parameter)")
                println("γ_parameter = $(γ_parameter)")
                println("I0_parameter = $(I0_parameter)")
            end
            push!(β_parameter_array, β_parameter)
            push!(c_parameter_array, c_parameter)
            push!(γ_parameter_array, γ_parameter)
            push!(I0_parameter_array, I0_parameter)

            nMAE_prev = nMAE

            # Увеличиваем число принятий новых параметров
            accept_num += 1
            # Число последовательных отказов приравниваем нулю
            local_rejected_num = 0
        else
            # Добавляем предыдущие значения параметров
            push!(β_parameter_array, β_parameter_array[end])
            push!(c_parameter_array, c_parameter_array[end])
            push!(γ_parameter_array, γ_parameter_array[end])
            push!(I0_parameter_array, I0_parameter_array[end])
            
            local_rejected_num += 1
        end

        # Раз в 2 шага
        if n % 2 == 0
            # Сохраняем значения параметров
            writedlm(joinpath(@__DIR__, "parameters_lhs", "1_parameter_array.csv"), β_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_lhs", "2_parameter_array.csv"), c_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_lhs", "3_parameter_array.csv"), γ_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_lhs", "4_parameter_array.csv"), I0_parameter_array, ',')
        end
    end
end

function mcmc_simulations(
    # Число прогонов модели
    num_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
)
    # Получаем значения параметров
    β_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters", "1_array.csv"), ',', Float64, '\n'))
    β_parameter = β_parameter_array[end]

    c_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters", "2_array.csv"), ',', Float64, '\n'))
    c_parameter = c_parameter_array[end]

    γ_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters", "3_array.csv"), ',', Float64, '\n'))
    γ_parameter = γ_parameter_array[end]

    I0_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters", "4_array.csv"), ',', Float64, '\n'))
    I0_parameter = I0_parameter_array[end]

    nMAE = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)
    # Reset
    for i in 1:length(agents)
        if i <= I0_parameter # I0
            agents[i] = Infected
        else
            agents[i] = Susceptible
        end
    end
    open(joinpath(@__DIR__, "mcmc.txt"), "a") do io
        println(io, nMAE)
    end

    # Число принятий новых значений параметров
    accept_num = 0
    # Число последовательных отказов
    local_rejected_num = 0

    β_parameter_delta = 0.1
    c_parameter_delta = 0.1
    γ_parameter_delta = 0.1
    I0_parameter_delta = 0.1

    nMAE_min = 99999.0
    nMAE_prev = nMAE
    nMAE_min = nMAE

    # (0.02, 0.2), # β
    # (5, 25), # c
    # (0.01, 0.05), # γ
    for n = 1:num_runs
        x = β_parameter_array[end]
        y = rand(Normal(log((x - 0.02) / (0.2 - x)), β_parameter_delta))
        β_parameter = (0.2 * exp(y) + 0.02) / (1 + exp(y))

        x = c_parameter_array[end]
        y = rand(Normal(log((x - 5) / (25 - x)), c_parameter_delta))
        c_parameter = (25 * exp(y) + 5) / (1 + exp(y))

        x = γ_parameter_array[end]
        y = rand(Normal(log((x - 0.01) / (0.05 - x)), γ_parameter_delta))
        γ_parameter = (0.05 * exp(y) + 0.01) / (1 + exp(y))

        x = I0_parameter_array[end]
        y = rand(Normal(log((x - 1) / (50 - x)), I0_parameter_delta))
        I0_parameter = (50 * exp(y) + 1) / (1 + exp(y))

        # Reset
        for i in 1:length(agents)
            if i <= I0_parameter # I0
                agents[i] = Infected
            else
                agents[i] = Susceptible
            end
        end
        nMAE = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "mcmc", "results_$(n).jld"),
            "nMAE", nMAE,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)

        open(joinpath(@__DIR__, "mcmc.txt"), "a") do io
            println(io, nMAE)
        end

        # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
        if nMAE < nMAE_prev || local_rejected_num >= 10
            if nMAE < nMAE_min
                nMAE_min = nMAE
                println("nMAE min = $(nMAE)")
                println("β_parameter = $(β_parameter)")
                println("c_parameter = $(c_parameter)")
                println("γ_parameter = $(γ_parameter)")
                println("I0_parameter = $(I0_parameter)")
            end
            push!(β_parameter_array, β_parameter)
            push!(c_parameter_array, c_parameter)
            push!(γ_parameter_array, γ_parameter)
            push!(I0_parameter_array, I0_parameter)

            nMAE_prev = nMAE

            # Увеличиваем число принятий новых параметров
            accept_num += 1
            # Число последовательных отказов приравниваем нулю
            local_rejected_num = 0
        else
            # Добавляем предыдущие значения параметров
            push!(β_parameter_array, β_parameter_array[end])
            push!(c_parameter_array, c_parameter_array[end])
            push!(γ_parameter_array, γ_parameter_array[end])
            push!(I0_parameter_array, I0_parameter_array[end])
            
            local_rejected_num += 1
        end

        # Раз в 2 шага
        if n % 2 == 0
            # Сохраняем значения параметров
            writedlm(joinpath(@__DIR__, "parameters", "1_parameter_array.csv"), β_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters", "2_parameter_array.csv"), c_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters", "3_parameter_array.csv"), γ_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters", "4_parameter_array.csv"), I0_parameter_array, ',')
        end
    end
end

function mcmc_simulations_metropolis(
    # Число прогонов модели
    num_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
)
    # Получаем значения параметров
    β_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_metropolis", "1_array.csv"), ',', Float64, '\n'))
    β_parameter = β_parameter_array[end]

    c_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_metropolis", "2_array.csv"), ',', Float64, '\n'))
    c_parameter = c_parameter_array[end]

    γ_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_metropolis", "3_array.csv"), ',', Float64, '\n'))
    γ_parameter = γ_parameter_array[end]

    I0_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_metropolis", "4_array.csv"), ',', Float64, '\n'))
    I0_parameter = I0_parameter_array[end]

    # Reset
    for i in 1:length(agents)
        if i <= I0_parameter # I0
            agents[i] = Infected
        else
            agents[i] = Susceptible
        end
    end
    S, I, R, nMAE = run_model_metropolis(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)
    open(joinpath(@__DIR__, "mcmc_metropolis.txt"), "a") do io
        println(io, nMAE)
    end

    prob_prev = zeros(Float64, length(S) + length(I) + length(R))
    for i = 1:length(S)
        prob_prev[i] = log_g(S[i], S_ref[i], sqrt(S_ref[i]))
    end
    for i = 1:length(I)
        prob_prev[i + length(S)] = log_g(I[i], I_ref[i], sqrt(I_ref[i]))
    end
    for i = 1:length(R)
        prob_prev[i + length(S) + length(I)] = log_g(R[i], R_ref[i], sqrt(R_ref[i]))
    end

    # Число принятий новых значений параметров
    accept_num = 0
    # Число последовательных отказов
    local_rejected_num = 0

    β_parameter_delta = 0.2
    c_parameter_delta = 0.2
    γ_parameter_delta = 0.2
    I0_parameter_delta = 0.2

    # (0.02, 0.2), # β
    # (5, 25), # c
    # (0.01, 0.05), # γ
    for n = 1:num_runs
        # β_parameter = rand(Normal(β_parameter_array[end], 0.05 * (0.2 - 0.02)))
        # if β_parameter < 0.02
        #     β_parameter = 0.02
        # end
        # if β_parameter > 0.2
        #     β_parameter = 0.2
        # end

        # c_parameter = rand(Normal(c_parameter_array[end], 0.05 * (25 - 5)))
        # if c_parameter < 5
        #     c_parameter = 5
        # end
        # if c_parameter > 25
        #     c_parameter = 25
        # end

        # γ_parameter = rand(Normal(γ_parameter_array[end], 0.05 * (0.05 - 0.01)))
        # if γ_parameter < 0.01
        #     γ_parameter = 0.01
        # end
        # if γ_parameter > 0.05
        #     γ_parameter = 0.05
        # end

        # I0_parameter = rand(Normal(I0_parameter_array[end], 0.05 * (0.05 - 0.01)))
        # if I0_parameter < 1
        #     I0_parameter = 1
        # end
        # if I0_parameter > 50
        #     I0_parameter = 50
        # end

        x = β_parameter_array[end]
        y = rand(Normal(log((x - 0.02) / (0.2 - x)), β_parameter_delta))
        β_parameter = (0.2 * exp(y) + 0.02) / (1 + exp(y))

        x = c_parameter_array[end]
        y = rand(Normal(log((x - 5) / (25 - x)), c_parameter_delta))
        c_parameter = (25 * exp(y) + 5) / (1 + exp(y))

        x = γ_parameter_array[end]
        y = rand(Normal(log((x - 0.01) / (0.05 - x)), γ_parameter_delta))
        γ_parameter = (0.05 * exp(y) + 0.01) / (1 + exp(y))

        x = I0_parameter_array[end]
        y = rand(Normal(log((x - 1) / (50 - x)), I0_parameter_delta))
        I0_parameter = (50 * exp(y) + 1) / (1 + exp(y))

        # Reset
        for i in 1:length(agents)
            if i <= I0_parameter # I0
                agents[i] = Infected
            else
                agents[i] = Susceptible
            end
        end
        S, I, R, nMAE = run_model_metropolis(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "mcmc_metropolis", "results_$(n).jld"),
            "nMAE", nMAE,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)

        open(joinpath(@__DIR__, "mcmc_metropolis.txt"), "a") do io
            println(io, nMAE)
        end

        prob = zeros(Float64, length(S) + length(I) + length(R))
        for i = 1:length(S)
            prob[i] = log_g(S[i], S_ref[i], sqrt(S_ref[i]))
        end
        for i = 1:length(I)
            prob[i + length(S)] = log_g(I[i], I_ref[i], sqrt(I_ref[i]))
        end
        for i = 1:length(R)
            prob[i + length(S) + length(I)] = log_g(R[i], R_ref[i], sqrt(R_ref[i]))
        end

        accept_prob = 0.0
        for i = 1:(3*length(S))
            accept_prob += prob[i] - prob_prev[i]
        end
        accept_prob_final = min(1.0, exp(accept_prob))

        if rand(Float64) < accept_prob_final || local_rejected_num >= 10
            push!(β_parameter_array, β_parameter)
            push!(c_parameter_array, c_parameter)
            push!(γ_parameter_array, γ_parameter)
            push!(I0_parameter_array, I0_parameter)

            prob_prev = copy(prob)

            # Увеличиваем число принятий новых параметров
            accept_num += 1
            # Число последовательных отказов приравниваем нулю
            local_rejected_num = 0
        else
            # Добавляем предыдущие значения параметров
            push!(β_parameter_array, β_parameter_array[end])
            push!(c_parameter_array, c_parameter_array[end])
            push!(γ_parameter_array, γ_parameter_array[end])
            push!(I0_parameter_array, I0_parameter_array[end])
            
            local_rejected_num += 1
        end

        # Раз в 2 шага
        if n % 2 == 0
            # Сохраняем значения параметров
            writedlm(joinpath(@__DIR__, "parameters_metropolis", "1_parameter_array.csv"), β_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_metropolis", "2_parameter_array.csv"), c_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_metropolis", "3_parameter_array.csv"), γ_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_metropolis", "4_parameter_array.csv"), I0_parameter_array, ',')
        end
    end
end

function mcmc_simulations_metropolis_lhs(
    # Число прогонов модели
    num_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
)
    # Получаем значения параметров
    β_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "1_array.csv"), ',', Float64, '\n'))
    β_parameter = β_parameter_array[end]

    c_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "2_array.csv"), ',', Float64, '\n'))
    c_parameter = c_parameter_array[end]

    γ_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "3_array.csv"), ',', Float64, '\n'))
    γ_parameter = γ_parameter_array[end]

    I0_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "4_array.csv"), ',', Float64, '\n'))
    I0_parameter = I0_parameter_array[end]

    # Reset
    for i in 1:length(agents)
        if i <= I0_parameter # I0
            agents[i] = Infected
        else
            agents[i] = Susceptible
        end
    end
    S, I, R, nMAE = run_model_metropolis(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)
    open(joinpath(@__DIR__, "mcmc_metropolis_lhs.txt"), "a") do io
        println(io, nMAE)
    end

    prob_prev = zeros(Float64, length(S) + length(I) + length(R))
    for i = 1:length(S)
        prob_prev[i] = log_g(S[i], S_ref[i], sqrt(S_ref[i]))
    end
    for i = 1:length(I)
        prob_prev[i + length(S)] = log_g(I[i], I_ref[i], sqrt(I_ref[i]))
    end
    for i = 1:length(R)
        prob_prev[i + length(S) + length(I)] = log_g(R[i], R_ref[i], sqrt(R_ref[i]))
    end

    # Число принятий новых значений параметров
    accept_num = 0
    # Число последовательных отказов
    local_rejected_num = 0

    β_parameter_delta = 0.2
    c_parameter_delta = 0.2
    γ_parameter_delta = 0.2
    I0_parameter_delta = 0.2

    # (0.02, 0.2), # β
    # (5, 25), # c
    # (0.01, 0.05), # γ
    for n = 1:num_runs
        # β_parameter = rand(Normal(β_parameter_array[end], 0.05 * (0.2 - 0.02)))
        # if β_parameter < 0.02
        #     β_parameter = 0.02
        # end
        # if β_parameter > 0.2
        #     β_parameter = 0.2
        # end

        # c_parameter = rand(Normal(c_parameter_array[end], 0.05 * (25 - 5)))
        # if c_parameter < 5
        #     c_parameter = 5
        # end
        # if c_parameter > 25
        #     c_parameter = 25
        # end

        # γ_parameter = rand(Normal(γ_parameter_array[end], 0.05 * (0.05 - 0.01)))
        # if γ_parameter < 0.01
        #     γ_parameter = 0.01
        # end
        # if γ_parameter > 0.05
        #     γ_parameter = 0.05
        # end

        # I0_parameter = rand(Normal(I0_parameter_array[end], 0.05 * (0.05 - 0.01)))
        # if I0_parameter < 1
        #     I0_parameter = 1
        # end
        # if I0_parameter > 50
        #     I0_parameter = 50
        # end

        x = β_parameter_array[end]
        y = rand(Normal(log((x - 0.02) / (0.2 - x)), β_parameter_delta))
        β_parameter = (0.2 * exp(y) + 0.02) / (1 + exp(y))

        x = c_parameter_array[end]
        y = rand(Normal(log((x - 5) / (25 - x)), c_parameter_delta))
        c_parameter = (25 * exp(y) + 5) / (1 + exp(y))

        x = γ_parameter_array[end]
        y = rand(Normal(log((x - 0.01) / (0.05 - x)), γ_parameter_delta))
        γ_parameter = (0.05 * exp(y) + 0.01) / (1 + exp(y))

        x = I0_parameter_array[end]
        y = rand(Normal(log((x - 1) / (50 - x)), I0_parameter_delta))
        I0_parameter = (50 * exp(y) + 1) / (1 + exp(y))

        # Reset
        for i in 1:length(agents)
            if i <= I0_parameter # I0
                agents[i] = Infected
            else
                agents[i] = Susceptible
            end
        end
        S, I, R, nMAE = run_model_metropolis(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "mcmc_metropolis_lhs", "results_$(n).jld"),
            "nMAE", nMAE,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)

        open(joinpath(@__DIR__, "mcmc_metropolis_lhs.txt"), "a") do io
            println(io, nMAE)
        end

        prob = zeros(Float64, length(S) + length(I) + length(R))
        for i = 1:length(S)
            prob[i] = log_g(S[i], S_ref[i], sqrt(S_ref[i]))
        end
        for i = 1:length(I)
            prob[i + length(S)] = log_g(I[i], I_ref[i], sqrt(I_ref[i]))
        end
        for i = 1:length(R)
            prob[i + length(S) + length(I)] = log_g(R[i], R_ref[i], sqrt(R_ref[i]))
        end

        accept_prob = 0.0
        for i = 1:(3*length(S))
            accept_prob += prob[i] - prob_prev[i]
        end
        accept_prob_final = min(1.0, exp(accept_prob))

        if rand(Float64) < accept_prob_final || local_rejected_num >= 10
            push!(β_parameter_array, β_parameter)
            push!(c_parameter_array, c_parameter)
            push!(γ_parameter_array, γ_parameter)
            push!(I0_parameter_array, I0_parameter)

            prob_prev = copy(prob)

            # Увеличиваем число принятий новых параметров
            accept_num += 1
            # Число последовательных отказов приравниваем нулю
            local_rejected_num = 0
        else
            # Добавляем предыдущие значения параметров
            push!(β_parameter_array, β_parameter_array[end])
            push!(c_parameter_array, c_parameter_array[end])
            push!(γ_parameter_array, γ_parameter_array[end])
            push!(I0_parameter_array, I0_parameter_array[end])
            
            local_rejected_num += 1
        end

        # Раз в 2 шага
        if n % 2 == 0
            # Сохраняем значения параметров
            writedlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "1_parameter_array.csv"), β_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "2_parameter_array.csv"), c_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "3_parameter_array.csv"), γ_parameter_array, ',')
            writedlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "4_parameter_array.csv"), I0_parameter_array, ',')
        end
    end
end

function run_swarm_model(
    num_swarm_model_runs,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
)
    num_particles = 20

    best_nMAE = 9999.0

    w = 0.5
    c1 = 1.0
    c2 = 1.0

    nMAE_particles = zeros(Float64, num_particles) .+ 9999.0

    β_parameter_particles = Array{Float64, 1}(undef, num_particles)
    c_parameter_particles = Array{Float64, 1}(undef, num_particles)
    γ_parameter_particles = Array{Float64, 1}(undef, num_particles)
    I0_parameter_particles = Array{Float64, 1}(undef, num_particles)

    β_parameter_particles_velocity = zeros(Float64, num_particles)
    c_parameter_particles_velocity = zeros(Float64, num_particles)
    γ_parameter_particles_velocity = zeros(Float64, num_particles)
    I0_parameter_particles_velocity = zeros(Float64, num_particles)

    β_parameter_particles_best = Array{Float64, 1}(undef, num_particles)
    c_parameter_particles_best = Array{Float64, 1}(undef, num_particles)
    γ_parameter_particles_best = Array{Float64, 1}(undef, num_particles)
    I0_parameter_particles_best = Array{Float64, 1}(undef, num_particles)

    β_parameter_best = 0.0
    c_parameter_best = 0.0
    γ_parameter_best = 0.0
    I0_parameter_best = 0.0

    velocity_particles = zeros(Float64, num_particles)

    num_parameters = 4

    for i = 1:num_particles
        nMAE_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["nMAE"]

        β_parameter_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["β_parameter"]
        c_parameter_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["c_parameter"]
        γ_parameter_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["γ_parameter"]
        I0_parameter_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["I0_parameter"]

        β_parameter_particles_best[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["β_parameter"]
        c_parameter_particles_best[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["c_parameter"]
        γ_parameter_particles_best[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["γ_parameter"]
        I0_parameter_particles_best[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["I0_parameter"]
    end

    k = argmin(nMAE_particles)
    β_parameter_best = β_parameter_particles[k]
    c_parameter_best = c_parameter_particles[k]
    γ_parameter_best = γ_parameter_particles[k]
    I0_parameter_best = I0_parameter_particles[k]

    # println(β_parameter_best)
    # println(c_parameter_best)
    # println(γ_parameter_best)
    # println(I0_parameter_best)
    # return

    # # Латинский гиперкуб
    # latin_hypercube_plan, _ = LHCoptim(num_particles, num_parameters, 200)

    # # Интервалы значений параметров
    # points = scaleLHC(latin_hypercube_plan, [
    #     (0.02, 0.2), # β
    #     (5, 25), # c
    #     (0.01, 0.05), # γ
    #     (1, 50), # I0
    # ])

    # for i = 1:num_particles
    #     β_parameter_particles_best[i] = points[i, 1]
    #     c_parameter_particles_best[i] = points[i, 2]
    #     γ_parameter_particles_best[i] = points[i, 3]
    #     I0_parameter_particles_best[i] = points[i, 4]

    #     β_parameter_particles[i] = points[i, 1]
    #     c_parameter_particles[i] = points[i, 2]
    #     γ_parameter_particles[i] = points[i, 3]
    #     I0_parameter_particles[i] = points[i, 4]

    #     # Reset
    #     for j in 1:length(agents)
    #         if j <= I0_parameter_particles_best[i] # I0
    #             agents[j] = Infected
    #         else
    #             agents[j] = Susceptible
    #         end
    #     end
    #     nMAE_particles[i] = run_model(agents, nsteps, δt, β_parameter_particles[i], c_parameter_particles_best[i], γ_parameter_particles_best[i])

    #     if nMAE_particles[i] < best_nMAE
    #         best_nMAE = nMAE_particles[i]

    #         β_parameter_best = points[i, 1]
    #         c_parameter_best = points[i, 2]
    #         γ_parameter_best = points[i, 3]
    #         I0_parameter_best = points[i, 4]
    #     end

    #     save(joinpath(@__DIR__, "swarm", "0", "results_$(i).jld"),
    #         "nMAE", nMAE_particles[i],
    #         "β_parameter", β_parameter_particles[i],
    #         "c_parameter", c_parameter_particles[i],
    #         "γ_parameter", γ_parameter_particles[i],
    #         "I0_parameter", I0_parameter_particles[i])
    # end

    

    for curr_run = 1:num_swarm_model_runs
        for i = 1:num_particles
            β_parameter_particles_velocity[i] = w * β_parameter_particles_velocity[i] + c1 * rand() * (β_parameter_particles_best[i] - β_parameter_particles[i]) + c2 * rand() * (β_parameter_best - β_parameter_particles[i])
            c_parameter_particles_velocity[i] = w * c_parameter_particles_velocity[i] + c1 * rand() * (c_parameter_particles_best[i] - c_parameter_particles[i]) + c2 * rand() * (c_parameter_best - c_parameter_particles[i])
            γ_parameter_particles_velocity[i] = w * γ_parameter_particles_velocity[i] + c1 * rand() * (γ_parameter_particles_best[i] - γ_parameter_particles[i]) + c2 * rand() * (γ_parameter_best - γ_parameter_particles[i])
            I0_parameter_particles_velocity[i] = w * I0_parameter_particles_velocity[i] + c1 * rand() * (I0_parameter_particles_best[i] - I0_parameter_particles[i]) + c2 * rand() * (I0_parameter_best - I0_parameter_particles[i])

            β_parameter_particles[i] += β_parameter_particles_velocity[i]
            c_parameter_particles[i] += c_parameter_particles_velocity[i]
            γ_parameter_particles[i] += γ_parameter_particles_velocity[i]
            I0_parameter_particles[i] += I0_parameter_particles_velocity[i]

            # (0.02, 0.2), # β
            # (5, 25), # c
            # (0.01, 0.05), # γ
            # Ограничения на область значений параметров
            if β_parameter_particles[i] < 0.02 || β_parameter_particles[i] > 0.2
                β_parameter_particles[i] = rand(Uniform(0.02, 0.2))
            end
            # Ограничения на область значений параметров
            if c_parameter_particles[i] < 5 || c_parameter_particles[i] > 25
                c_parameter_particles[i] = rand(Uniform(5, 25))
            end
            # Ограничения на область значений параметров
            if γ_parameter_particles[i] < 0.01 || γ_parameter_particles[i] > 0.05
                γ_parameter_particles[i] = rand(Uniform(0.01, 0.05))
            end
            # Ограничения на область значений параметров
            if I0_parameter_particles[i] < 1 || I0_parameter_particles[i] > 50
                I0_parameter_particles[i] = rand(Uniform(1, 50))
            end

            # Reset
            for j in 1:length(agents)
                if j <= I0_parameter_particles[i] # I0
                    agents[j] = Infected
                else
                    agents[j] = Susceptible
                end
            end
            nMAE = run_model(agents, nsteps, δt, β_parameter_particles[i], c_parameter_particles_best[i], γ_parameter_particles_best[i])

            save(joinpath(@__DIR__, "swarm", "$(i)", "results_$(curr_run).jld"),
                "nMAE", nMAE,
                "β_parameter", β_parameter_particles[i],
                "c_parameter", c_parameter_particles[i],
                "γ_parameter", γ_parameter_particles[i],
                "I0_parameter", I0_parameter_particles[i],
            )

            if nMAE < best_nMAE
                best_nMAE = nMAE

                β_parameter_best = β_parameter_particles[i]
                c_parameter_best = c_parameter_particles[i]
                γ_parameter_best = γ_parameter_particles[i]
                I0_parameter_best = I0_parameter_particles[i]

                println("Best!!!")
                println("nMAE_best = ", nMAE)
                println("β_parameter = ", β_parameter_best)
                println("c_parameter = ", c_parameter_best)
                println("γ_parameter = ", γ_parameter_best)
                println("I0_parameter = ", I0_parameter_best)
                println()
            end

            if nMAE < nMAE_particles[i]
                nMAE_particles[i] = nMAE

                β_parameter_particles_best[i] = β_parameter_particles[i]
                c_parameter_particles_best[i] = c_parameter_particles[i]
                γ_parameter_particles_best[i] = γ_parameter_particles[i]
                I0_parameter_particles_best[i] = I0_parameter_particles[i]

                println("Particle")
                println("nMAE_particle $(i) = ", nMAE)
                println("β_parameter = ", β_parameter_particles_best[i])
                println("c_parameter = ", c_parameter_particles_best[i])
                println("γ_parameter = ", γ_parameter_particles_best[i])
                println("I0_parameter = ", I0_parameter_particles_best[i])
                println()
            end
        end
    end
end

function run_surrogate_model(
    # Число прогонов модели
    num_runs_surrogate::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
)
    num_initial_runs = 20
    num_additional_runs = 0
    num_runs = num_initial_runs + num_additional_runs

    num_parameters = 4

    nMAE_arr = Array{Float64, 1}(undef, num_runs)
    β_parameter = Array{Float64, 1}(undef, num_runs)
    c_parameter = Array{Float64, 1}(undef, num_runs)
    γ_parameter = Array{Float64, 1}(undef, num_runs)
    I0_parameter = Array{Float64, 1}(undef, num_runs)

    for i = 1:num_initial_runs
        nMAE_arr[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["nMAE"]
        β_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["γ_parameter"]
        I0_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["I0_parameter"]
    end

    # for i = 1:num_additional_runs
    #     nMAE_arr[i + num_initial_runs] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["nMAE"]
    #     β_parameter[i + num_initial_runs] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["β_parameter"]
    # end

    min_i = 0
    min_nMAE = 9999.0

    # y = zeros(Float64, x, num_runs)
    # for i = 1:num_runs
    #     for j = 1:52
    #         y[j, i] = sum(abs.(incidence_arr[i][j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #     end
    #     nMAE = sum(y[:, i])
    #     if nMAE < min_nMAE
    #         min_i = i
    #         min_nMAE = nMAE
    #     end
    # end

    # XGBoost
    y = copy(nMAE_arr)
    min_i = argmin(nMAE_arr)
    # y = zeros(Float64, 400, num_runs)

    # X = zeros(Float64, 3, num_runs)
    # for i = 1:num_runs
    #     X[1, i] = β_parameter[i]
    #     X[2, i] = c_parameter[i]
    #     X[3, i] = γ_parameter[i]
    # end

    # XGBoost
    X = zeros(Float64, num_runs, num_parameters)
    for i = 1:num_runs
        X[i, 1] = β_parameter[i]
        X[i, 2] = c_parameter[i]
        X[i, 3] = γ_parameter[i]
        X[i, 4] = I0_parameter[i]
    end

    forest_num_rounds = 150
    forest_max_depth = 10
    η = 0.1

    # n_epochs = 10_000
    # rng = Xoshiro(42)
    # min_error = 99999.0
    # num_hidden_layers = 7
    # num_hidden_neurons = 15

    # lux_model = Chain(
    #     BatchNorm(3),
    #     Dense(3 => num_hidden_neurons, relu),
    #     [Dense(num_hidden_neurons => num_hidden_neurons, relu) for _ = 1:num_hidden_layers]...,
    #     Dense(num_hidden_neurons => num_years * 52),
    # )

    # rule = Optimisers.Adam()
    # error = 0.0

    par_vec = zeros(Float64, num_parameters)

    β_parameter_default = 0.0
    β_parameter_min = 0.0

    c_parameter_default = 0.0
    c_parameter_min = 0.0

    γ_parameter_default = 0.0
    γ_parameter_min = 0.0

    I0_parameter_default = 0.0
    I0_parameter_min = 0.0

    # XGBoost
    # bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror", η = η, watchlist=[])

    # params, lux_state = Lux.setup(rng, lux_model)

    # opt_state = Optimisers.setup(rule, params)  # optimiser state based on model parameters

    # # Train loop
    # for epoch = 1:n_epochs
    #     (loss, lux_state), back = Zygote.pullback(params, X) do p, x
    #         nMAE_model, st = Lux.apply(lux_model, x, p, lux_state)
    #         0.5 * mean((nMAE_model .- y).^2), st
    #     end
    #     ∇params, _ = back((one.(loss), nothing))  # gradient of only the loss, with respect to parameter tree

    #     opt_state, params = Optimisers.update!(opt_state, params, ∇params)

    #     if epoch % 2000 == 0
    #         println("Epoch: $(epoch), loss: $(loss)")
    #     end
    # end

    # for particle_number = 1:20
    #     for i = 1:42
    #         for k = 1:26
    #             par_vec[k] = 0.0
    #         end

    #         swarm_incidence = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"]
    #         swarm_nMAE = zeros(Float64, 52)
    #         for j = 1:52
    #             swarm_nMAE[j] = sum(abs.(swarm_incidence[j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #         end

    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["β_parameter"]
    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["c_parameter"]
    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["γ_parameter"]
    #         r = reshape(par_vec, :, 1)

    #         # nMAE, _ = Lux.apply(lux_model, r, params, opt_state)

    #         # real_nMAE = sum(abs.(load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    #         # error += abs(real_nMAE - nMAE[:][1])

    #         # y_predicted, _ = Lux.apply(lux_model, r, params, opt_state)
    #         # y_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         # y_model = vec(load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"])
    #         # error += sum(abs.(y_predicted - y_model)) / sum(y_model)

    #         nMAE_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         error += 0.5 * mean((nMAE_predicted .- swarm_nMAE).^2)
    #     end
    # end
    # error /= 840.0

    # println("Error: $(error)")
    # return

    β_parameter_delta = 0.1
    c_parameter_delta = 0.1
    γ_parameter_delta = 0.1
    I0_parameter_delta = 0.1

    for curr_run = 1:num_runs_surrogate
        # XGBoost
        bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror", η = η, watchlist=[])

        # # Train loop
        # params, lux_state = Lux.setup(rng, lux_model)
        # opt_state = Optimisers.setup(rule, params)  # optimiser state based on model parameters
        # # Train loop
        # for epoch = 1:n_epochs
        #     (loss, lux_state), back = Zygote.pullback(params, X) do p, x
        #         nMAE_model, st = Lux.apply(lux_model, x, p, lux_state)
        #         0.5 * mean((nMAE_model .- y).^2), st
        #     end
        #     ∇params, _ = back((one.(loss), nothing))  # gradient of only the loss, with respect to parameter tree

        #     opt_state, params = Optimisers.update!(opt_state, params, ∇params)

        #     if epoch % 2000 == 0
        #         println("Epoch: $(epoch), loss: $(loss)")
        #     end
        # end

        nMAE = 0.0
        nMAE_min = 99999.0
        nMAE_prev = 99999.0

        β_parameter_default = β_parameter[min_i]
        β_parameter_min = β_parameter[min_i]

        c_parameter_default = c_parameter[min_i]
        c_parameter_min = c_parameter[min_i]

        γ_parameter_default = γ_parameter[min_i]
        γ_parameter_min = γ_parameter[min_i]

        I0_parameter_default = I0_parameter[min_i]
        I0_parameter_min = I0_parameter[min_i]

        local_rejected_num = 0

        for n = 1:1000
            x_cand = β_parameter_default
            y_cand = rand(Normal(log((x_cand - 0.02) / (0.2 - x_cand)), β_parameter_delta))
            β_parameter_candidate = (0.2 * exp(y_cand) + 0.02) / (1 + exp(y_cand))

            x_cand = c_parameter_default
            y_cand = rand(Normal(log((x_cand - 5) / (25 - x_cand)), c_parameter_delta))
            c_parameter_candidate = (25 * exp(y_cand) + 5) / (1 + exp(y_cand))

            x_cand = γ_parameter_default
            y_cand = rand(Normal(log((x_cand - 0.01) / (0.05 - x_cand)), γ_parameter_delta))
            γ_parameter_candidate = (0.05 * exp(y_cand) + 0.01) / (1 + exp(y_cand))

            x_cand = I0_parameter_default
            y_cand = rand(Normal(log((x_cand - 1) / (50 - x_cand)), I0_parameter_delta))
            I0_parameter_candidate = (50 * exp(y_cand) + 1) / (1 + exp(y_cand))

            par_vec[1] = β_parameter_candidate
            par_vec[2] = c_parameter_candidate
            par_vec[3] = γ_parameter_candidate
            par_vec[4] = I0_parameter_candidate

            # NN
            # r = reshape(par_vec, :, 1)
            # XGBoost
            r = reshape(par_vec, 1, :)
    
            # nMAE_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
            # nMAE = sum(nMAE_predicted)

            # XGBoost
            nMAE = predict(bst, r)[1]

            # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
            if nMAE < nMAE_prev || local_rejected_num >= 10
                if nMAE < nMAE_min
                    nMAE_min = nMAE

                    β_parameter_min = β_parameter_candidate
                    c_parameter_min = c_parameter_candidate
                    γ_parameter_min = γ_parameter_candidate
                    I0_parameter_min = I0_parameter_candidate
                end
                β_parameter_default = β_parameter_candidate
                c_parameter_default = c_parameter_candidate
                γ_parameter_default = γ_parameter_candidate
                I0_parameter_default = I0_parameter_candidate

                nMAE_prev = nMAE

                # Число последовательных отказов приравниваем нулю
                local_rejected_num = 0
            else
                local_rejected_num += 1
            end
        end

        # Reset
        for i in 1:length(agents)
            if i <= I0_parameter_min # I0
                agents[i] = Infected
            else
                agents[i] = Susceptible
            end
        end
        nMAE = run_model(agents, nsteps, δt, β_parameter_min, c_parameter_min, γ_parameter_min)

        save(joinpath(@__DIR__, "surrogate", "results_$(curr_run).jld"),
            "nMAE", nMAE,
            "β_parameter", β_parameter_min,
            "c_parameter", c_parameter_min,
            "γ_parameter", γ_parameter_min,
            "I0_parameter", I0_parameter_min)

        println("Real nMAE: $(nMAE)")

        # y = cat(y, nMAE_arr, dims = 2)
        # X = cat(X, [β_parameter_min, c_parameter_min, γ_parameter_min], dims = 2)

        # XGBoost
        # y = vcat(y, nMAE)
        push!(y, nMAE)
        X = vcat(X, [β_parameter_min, c_parameter_min, γ_parameter_min, I0_parameter_min]')
    end
end

function run_surrogate_model_NN(
    # Число прогонов модели
    num_runs_surrogate::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
)
    num_initial_runs = 100
    num_additional_runs = 0
    num_runs = num_initial_runs + num_additional_runs

    num_parameters = 4

    nMAE_arr = Array{Float64, 1}(undef, num_runs)
    β_parameter = Array{Float64, 1}(undef, num_runs)
    c_parameter = Array{Float64, 1}(undef, num_runs)
    γ_parameter = Array{Float64, 1}(undef, num_runs)

    for i = 1:num_initial_runs
        nMAE_arr[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["nMAE"]
        β_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["γ_parameter"]
    end

    # for i = 1:num_additional_runs
    #     nMAE_arr[i + num_initial_runs] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["nMAE"]
    #     β_parameter[i + num_initial_runs] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["β_parameter"]
    # end

    min_i = 0
    min_nMAE = 9999.0

    y = copy(nMAE_arr)
    min_i = argmin(nMAE_arr)
    # y = zeros(Float64, x, num_runs)
    # for i = 1:num_runs
    #     for j = 1:52
    #         y[j, i] = sum(abs.(incidence_arr[i][j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #     end
    #     nMAE = sum(y[:, i])
    #     if nMAE < min_nMAE
    #         min_i = i
    #         min_nMAE = nMAE
    #     end
    # end

    X = zeros(Float64, 3, num_runs)
    for i = 1:num_runs
        X[1, i] = β_parameter[i]
        X[2, i] = c_parameter[i]
        X[3, i] = γ_parameter[i]
    end

    forest_num_rounds = 150
    forest_max_depth = 10
    η = 0.1

    n_epochs = 1_000
    rng = Xoshiro(42)
    min_error = 99999.0
    num_hidden_layers = 7
    num_hidden_neurons = 15

    lux_model = Chain(
        BatchNorm(3),
        Dense(3 => num_hidden_neurons, relu),
        [Dense(num_hidden_neurons => num_hidden_neurons, relu) for _ = 1:num_hidden_layers]...,
        Dense(num_hidden_neurons => 1),
    )

    rule = Optimisers.Adam()
    error = 0.0

    par_vec = zeros(Float64, 3)

    β_parameter_default = 0.0
    β_parameter_min = 0.0

    c_parameter_default = 0.0
    c_parameter_min = 0.0

    γ_parameter_default = 0.0
    γ_parameter_min = 0.0

    # XGBoost
    # bst = xgboost((X, y), num_round=forest_num_rounds, max_depth=forest_max_depth, objective="reg:squarederror", η = η, watchlist=[])

    # params, lux_state = Lux.setup(rng, lux_model)

    # opt_state = Optimisers.setup(rule, params)  # optimiser state based on model parameters

    # # Train loop
    # for epoch = 1:n_epochs
    #     (loss, lux_state), back = Zygote.pullback(params, X) do p, x
    #         nMAE_model, st = Lux.apply(lux_model, x, p, lux_state)
    #         0.5 * mean((nMAE_model .- y).^2), st
    #     end
    #     ∇params, _ = back((one.(loss), nothing))  # gradient of only the loss, with respect to parameter tree

    #     opt_state, params = Optimisers.update!(opt_state, params, ∇params)

    #     if epoch % 2000 == 0
    #         println("Epoch: $(epoch), loss: $(loss)")
    #     end
    # end

    # for particle_number = 1:20
    #     for i = 1:42
    #         for k = 1:26
    #             par_vec[k] = 0.0
    #         end

    #         swarm_incidence = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"]
    #         swarm_nMAE = zeros(Float64, 52)
    #         for j = 1:52
    #             swarm_nMAE[j] = sum(abs.(swarm_incidence[j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #         end

    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["β_parameter"]
    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["c_parameter"]
    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["γ_parameter"]
    #         r = reshape(par_vec, :, 1)

    #         # nMAE, _ = Lux.apply(lux_model, r, params, opt_state)

    #         # real_nMAE = sum(abs.(load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    #         # error += abs(real_nMAE - nMAE[:][1])

    #         # y_predicted, _ = Lux.apply(lux_model, r, params, opt_state)
    #         # y_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         # y_model = vec(load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"])
    #         # error += sum(abs.(y_predicted - y_model)) / sum(y_model)

    #         nMAE_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         error += 0.5 * mean((nMAE_predicted .- swarm_nMAE).^2)
    #     end
    # end
    # error /= 840.0

    # println("Error: $(error)")
    # return

    β_parameter_delta = 0.1
    c_parameter_delta = 0.1
    γ_parameter_delta = 0.1
    I0_parameter_delta = 0.1

    for curr_run = 1:num_runs_surrogate
        # Train loop
        params, lux_state = Lux.setup(rng, lux_model)
        opt_state = Optimisers.setup(rule, params)  # optimiser state based on model parameters
        # Train loop
        for epoch = 1:n_epochs
            (loss, lux_state), back = Zygote.pullback(params, X) do p, x
                nMAE_model, st = Lux.apply(lux_model, x, p, lux_state)
                0.5 * mean((nMAE_model .- y).^2), st
            end
            ∇params, _ = back((one.(loss), nothing))  # gradient of only the loss, with respect to parameter tree

            opt_state, params = Optimisers.update!(opt_state, params, ∇params)

            if epoch % 2000 == 0
                println("Epoch: $(epoch), loss: $(loss)")
            end
        end

        nMAE = 0.0
        nMAE_min = 99999.0
        nMAE_prev = 99999.0

        β_parameter_default = β_parameter[min_i]
        β_parameter_min = β_parameter[min_i]

        c_parameter_default = c_parameter[min_i]
        c_parameter_min = c_parameter[min_i]

        γ_parameter_default = γ_parameter[min_i]
        γ_parameter_min = γ_parameter[min_i]

        local_rejected_num = 0

        for n = 1:1000
            x_cand = β_parameter_default
            y_cand = rand(Normal(log((x_cand - 0.02) / (0.2 - x_cand)), β_parameter_delta))
            β_parameter_candidate = (0.2 * exp(y_cand) + 0.02) / (1 + exp(y_cand))

            x_cand = c_parameter_default
            y_cand = rand(Normal(log((x_cand - 5) / (25 - x_cand)), c_parameter_delta))
            c_parameter_candidate = (25 * exp(y_cand) + 5) / (1 + exp(y_cand))

            x_cand = γ_parameter_default
            y_cand = rand(Normal(log((x_cand - 0.01) / (0.05 - x_cand)), γ_parameter_delta))
            γ_parameter_candidate = (0.05 * exp(y_cand) + 0.01) / (1 + exp(y_cand))

            par_vec[1] = β_parameter_candidate
            par_vec[2] = c_parameter_candidate
            par_vec[3] = γ_parameter_candidate

            # NN
            r = reshape(par_vec, :, 1)
    
            nMAE, _ = Lux.apply(lux_model, r, params, lux_state)

            # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
            if nMAE[1][1] < nMAE_prev || local_rejected_num >= 10
                if nMAE[1][1] < nMAE_min
                    nMAE_min = nMAE[1][1]

                    β_parameter_min = β_parameter_candidate
                    c_parameter_min = c_parameter_candidate
                    γ_parameter_min = γ_parameter_candidate
                end
                β_parameter_default = β_parameter_candidate
                c_parameter_default = c_parameter_candidate
                γ_parameter_default = γ_parameter_candidate

                nMAE_prev = nMAE[1][1]

                # Число последовательных отказов приравниваем нулю
                local_rejected_num = 0
            else
                local_rejected_num += 1
            end
        end

        nMAE = run_model(agents, nsteps, δt, β_parameter_min, c_parameter_min, γ_parameter_min)
        # Reset
        for i in 1:length(agents)
            if i <= 10 # I0
                agents[i] = Infected
            else
                agents[i] = Susceptible
            end
        end

        save(joinpath(@__DIR__, "surrogate_NN", "results_$(curr_run).jld"),
            "nMAE", nMAE,
            "β_parameter", β_parameter_min,
            "c_parameter", c_parameter_min,
            "γ_parameter", γ_parameter_min,)

        println("Real nMAE: $(nMAE)")

        push!(y, nMAE)
        X = cat(X, [β_parameter_min, c_parameter_min, γ_parameter_min], dims = 2)
    end
end

function main()
    # Time domain
    δt = 0.1
    nsteps = 400
    tf = nsteps * δt
    tspan = (0.0, nsteps)
    t = 0:δt:tf

    # [0.02, 0.2]
    # [5, 25]
    # [0.01, 0.05]
    # β = 0.05 
    # c = 10.0
    # γ = 0.02

    # p = [β, c, γ, δt]

    # Начальные условия
    N = 10000
    # I0 = 10
    agents_initial = Array{InfectionStatus}(undef, N)
    # for i in 1:N
    #     if i <= I0
    #         s = Infected
    #     else
    #         s = Susceptible
    #     end
    #     agents_initial[i] = s
    # end


    # run_model(agents_initial, nsteps, δt, 0.05, 10.0, 0.02)

    # mcmc_simulations(500,agents_initial,nsteps,δt)
    # mcmc_simulations_metropolis(500,agents_initial,nsteps,δt)
    # run_swarm_model(25, agents_initial,nsteps,δt)
    # lhs_simulations(20,agents_initial,nsteps,δt)
    run_surrogate_model(500,agents_initial,nsteps,δt)
    # run_surrogate_model_NN(100,agents_initial,nsteps,δt)

    # mcmc_simulations_lhs(500,agents_initial,nsteps,δt)
    # mcmc_simulations_metropolis_lhs(500,agents_initial,nsteps,δt)
end

main()
