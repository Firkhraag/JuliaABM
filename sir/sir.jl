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

default(legendfontsize = 11, guidefont = (12, :black), tickfont = (11, :black))

function arg_n_smallest_values(A::AbstractArray{T,N}, n::Integer) where {T,N}
    perm = sortperm(vec(A))
    ci = CartesianIndices(A)
    return ci[perm[1:n]]
end

function log_g(x, mu, sigma)
    return -log(sqrt(2 * pi) * sigma) - 0.5 * ((x - mu) / sigma)^2
end

function f(x, mu, sigma)
    dist = Normal(mu, sigma)
    return cdf(dist, x + 0.5) - cdf(dist, x - 0.5)
end

# References
const S_ref = Any[99975, 99971, 99971, 99969, 99968, 99966, 99964, 99961, 99959, 99953, 99951, 99951, 99948, 99946, 99946, 99946, 99942, 99939, 99937, 99934, 99934, 99931, 99930, 99928, 99924, 99924, 99923, 99914, 99911, 99906, 99904, 99901, 99899, 99895, 99893, 99886, 99883, 99878, 99875, 99868, 99865, 99861, 99854, 99851, 99844, 99839, 99833, 99828, 99822, 99819, 99816, 99811, 99803, 99790, 99785, 99774, 99765, 99756, 99744, 99737, 99726, 99719, 99711, 99700, 99688, 99680, 99672, 99653, 99641, 99628, 99618, 99607, 99591, 99583, 99569, 99561, 99550, 99533, 99517, 99496, 99484, 99469, 99456, 99431, 99412, 99395, 99380, 99357, 99333, 99307, 99289, 99261, 99238, 99219, 99200, 99182, 99163, 99137, 99115, 99096, 99072, 99046, 99015, 98980, 98951, 98916, 98887, 98849, 98808, 98784, 98742, 98705, 98659, 98622, 98578, 98530, 98493, 98455, 98409, 98367, 98314, 98262, 98215, 98169, 98114, 98037, 97970, 97918, 97848, 97782, 97706, 97642, 97584, 97521, 97451, 97386, 97311, 97239, 97140, 97051, 96954, 96868, 96777, 96701, 96611, 96501, 96381, 96260, 96158, 96051, 95924, 95806, 95698, 95579, 95443, 95321, 95178, 95054, 94921, 94781, 94632, 94483, 94329, 94154, 93997, 93837, 93662, 93489, 93296, 93113, 92915, 92729, 92541, 92310, 92095, 91872, 91630, 91387, 91138, 90908, 90635, 90356, 90096, 89814, 89568, 89303, 88994, 88689, 88395, 88095, 87804, 87482, 87167, 86871, 86553, 86208, 85865, 85524, 85123, 84770, 84422, 84058, 83683, 83289, 82879, 82497, 82071, 81629, 81195, 80754, 80297, 79878, 79417, 78971, 78519, 78056, 77553, 77060, 76556, 76050, 75497, 74986, 74485, 73936, 73403, 72890, 72346, 71828, 71251, 70722, 70145, 69577, 69058, 68518, 67983, 67400, 66815, 66236, 65684, 65124, 64519, 63971, 63375, 62801, 62240, 61631, 61030, 60439, 59833, 59253, 58707, 58102, 57540, 56989, 56409, 55808, 55237, 54659, 54043, 53449, 52908, 52332, 51752, 51172, 50633, 50055, 49531, 48941, 48411, 47834, 47255, 46722, 46201, 45633, 45157, 44667, 44126, 43616, 43122, 42581, 42083, 41570, 41133, 40633, 40152, 39646, 39193, 38695, 38245, 37765, 37309, 36870, 36449, 36005, 35574, 35185, 34791, 34399, 33986, 33571, 33200, 32821, 32420, 32037, 31658, 31357, 31005, 30639, 30289, 29980, 29659, 29344, 29002, 28716, 28381, 28065, 27789, 27493, 27205, 26908, 26644, 26378, 26100, 25804, 25554, 25330, 25054, 24799, 24531, 24297, 24086, 23853, 23595, 23369, 23145, 22897, 22693, 22482, 22271, 22083, 21844, 21626, 21449, 21250, 21065, 20884, 20699, 20534, 20344, 20184, 20023, 19876, 19716, 19557, 19419, 19259, 19119, 18996, 18875, 18729, 18595, 18459, 18307, 18161, 18040, 17898, 17762, 17637, 17520, 17416, 17289, 17183, 17057, 16942, 16838, 16740, 16628, 16529, 16423, 16320, 16220, 16130, 16031, 15955, 15852, 15773, 15683, 15600, 15514, 15447, 15357, 15271, 15195, 15124, 15045, 14964, 14892, 14813, 14742, 14684, 14626]
const I_ref = Any[25, 25, 25, 26, 25, 27, 29, 32, 34, 40, 41, 41, 43, 45, 44, 43, 44, 45, 44, 46, 46, 48, 49, 49, 51, 51, 51, 60, 62, 67, 68, 69, 70, 73, 72, 78, 81, 86, 86, 92, 91, 95, 102, 104, 108, 111, 117, 120, 125, 125, 125, 129, 135, 147, 149, 157, 160, 162, 173, 175, 182, 185, 191, 199, 205, 210, 212, 231, 239, 243, 246, 247, 259, 258, 267, 271, 274, 282, 293, 309, 316, 325, 335, 354, 361, 369, 375, 390, 405, 422, 431, 448, 465, 471, 479, 484, 490, 509, 524, 532, 546, 567, 584, 604, 623, 651, 668, 698, 725, 731, 760, 778, 808, 822, 858, 894, 917, 936, 970, 982, 1014, 1045, 1073, 1109, 1146, 1196, 1236, 1264, 1315, 1355, 1412, 1446, 1474, 1507, 1554, 1588, 1631, 1666, 1739, 1793, 1858, 1905, 1963, 2003, 2053, 2121, 2197, 2272, 2332, 2388, 2467, 2537, 2595, 2660, 2751, 2817, 2895, 2954, 3036, 3114, 3194, 3268, 3369, 3481, 3575, 3661, 3771, 3855, 3966, 4060, 4173, 4268, 4375, 4524, 4641, 4782, 4944, 5086, 5247, 5375, 5547, 5715, 5858, 6030, 6135, 6299, 6477, 6651, 6827, 6988, 7148, 7328, 7488, 7635, 7799, 8003, 8200, 8385, 8609, 8785, 8956, 9152, 9348, 9545, 9771, 9944, 10179, 10423, 10657, 10879, 11142, 11323, 11554, 11776, 12008, 12207, 12455, 12695, 12930, 13156, 13435, 13662, 13890, 14156, 14402, 14637, 14888, 15118, 15384, 15618, 15851, 16122, 16324, 16554, 16742, 17014, 17244, 17445, 17666, 17883, 18122, 18280, 18507, 18697, 18899, 19162, 19392, 19609, 19786, 19951, 20119, 20310, 20459, 20633, 20804, 20999, 21152, 21299, 21497, 21669, 21805, 21930, 22068, 22210, 22314, 22440, 22520, 22624, 22697, 22881, 22951, 23009, 23082, 23217, 23203, 23246, 23313, 23385, 23426, 23531, 23530, 23577, 23554, 23570, 23580, 23636, 23629, 23639, 23615, 23607, 23615, 23604, 23531, 23486, 23437, 23394, 23292, 23231, 23196, 23129, 22998, 22917, 22832, 22771, 22680, 22571, 22457, 22366, 22282, 22133, 22026, 21919, 21849, 21697, 21554, 21442, 21294, 21209, 21086, 20963, 20819, 20673, 20547, 20458, 20299, 20102, 20007, 19870, 19714, 19521, 19352, 19187, 19034, 18856, 18691, 18601, 18408, 18246, 18097, 17940, 17794, 17665, 17499, 17335, 17197, 17039, 16876, 16710, 16578, 16406, 16253, 16061, 15874, 15710, 15557, 15377, 15239, 15071, 14904, 14796, 14639, 14489, 14339, 14208, 14051, 13902, 13795, 13638, 13493, 13337, 13214, 13038, 12895, 12779, 12651, 12493, 12361, 12201, 12089, 11957, 11821, 11675, 11545, 11382, 11251, 11090, 10979, 10835, 10703, 10546, 10428, 10285, 10166, 10035, 9909, 9785, 9661, 9547, 9429, 9281, 9146]
const R_ref = Any[0, 4, 4, 5, 7, 7, 7, 7, 7, 7, 8, 8, 9, 9, 10, 11, 14, 16, 19, 20, 20, 21, 21, 23, 25, 25, 26, 26, 27, 27, 28, 30, 31, 32, 35, 36, 36, 36, 39, 40, 44, 44, 44, 45, 48, 50, 50, 52, 53, 56, 59, 60, 62, 63, 66, 69, 75, 82, 83, 88, 92, 96, 98, 101, 107, 110, 116, 116, 120, 129, 136, 146, 150, 159, 164, 168, 176, 185, 190, 195, 200, 206, 209, 215, 227, 236, 245, 253, 262, 271, 280, 291, 297, 310, 321, 334, 347, 354, 361, 372, 382, 387, 401, 416, 426, 433, 445, 453, 467, 485, 498, 517, 533, 556, 564, 576, 590, 609, 621, 651, 672, 693, 712, 722, 740, 767, 794, 818, 837, 863, 882, 912, 942, 972, 995, 1026, 1058, 1095, 1121, 1156, 1188, 1227, 1260, 1296, 1336, 1378, 1422, 1468, 1510, 1561, 1609, 1657, 1707, 1761, 1806, 1862, 1927, 1992, 2043, 2105, 2174, 2249, 2302, 2365, 2428, 2502, 2567, 2656, 2738, 2827, 2912, 3003, 3084, 3166, 3264, 3346, 3426, 3527, 3615, 3717, 3818, 3929, 4046, 4156, 4297, 4398, 4529, 4660, 4778, 4917, 5048, 5190, 5345, 5494, 5648, 5789, 5935, 6091, 6268, 6445, 6622, 6790, 6969, 7166, 7350, 7559, 7750, 7948, 8148, 8367, 8561, 8799, 9029, 9253, 9473, 9737, 9992, 10245, 10514, 10794, 11068, 11352, 11625, 11908, 12195, 12473, 12766, 13054, 13365, 13660, 14004, 14301, 14618, 14928, 15275, 15586, 15941, 16319, 16650, 16993, 17359, 17749, 18118, 18502, 18861, 19207, 19578, 19952, 20381, 20796, 21174, 21588, 22001, 22378, 22787, 23193, 23611, 24042, 24460, 24882, 25287, 25738, 26180, 26618, 27053, 27505, 27949, 28435, 28892, 29285, 29794, 30269, 30717, 31150, 31640, 32087, 32561, 32999, 33452, 33888, 34387, 34853, 35313, 35797, 36268, 36718, 37178, 37666, 38140, 38628, 39076, 39526, 40020, 40509, 40989, 41421, 41917, 42370, 42818, 43300, 43802, 44262, 44748, 45192, 45662, 46072, 46538, 46995, 47429, 47887, 48315, 48737, 49149, 49587, 50065, 50493, 50917, 51298, 51709, 52129, 52537, 52949, 53353, 53738, 54147, 54568, 54939, 55331, 55755, 56182, 56562, 56960, 57371, 57775, 58164, 58502, 58899, 59272, 59632, 59977, 60362, 60709, 61052, 61415, 61738, 62077, 62425, 62756, 63078, 63410, 63724, 64063, 64410, 64733, 65024, 65364, 65642, 65933, 66221, 66475, 66766, 67052, 67354, 67631, 67909, 68200, 68443, 68725, 68987, 69247, 69497, 69779, 70048, 70279, 70511, 70767, 71011, 71270, 71488, 71723, 71959, 72195, 72424, 72663, 72897, 73137, 73338, 73565, 73783, 74007, 74215, 74444, 74639, 74841, 75046, 75251, 75447, 75640, 75829, 76035, 76228]

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

function run_model_plot(agents_initial, nsteps, δt)
    num_runs = 10
    # Best
    β, c, γ, I0 = 0.02914546000421925, 16.99835897540075, 0.019603036841374714, 40.011319044945466
    # # Median
    # β, c, γ, I0 = 0.0320317798685097, 15.222030086565974, 0.01947785846755082, 48.01541900675947

    df_abm_arr_S = []
    df_abm_arr_I = []
    df_abm_arr_R = []
    df_abm_t = []
    df_abm_S = zeros(Float64, 401)
    df_abm_I = zeros(Float64, 401)
    df_abm_R = zeros(Float64, 401)
    for i = 1:num_runs
        # Reset
        for i in 1:length(agents_initial)
            if i <= I0 # I0
                agents_initial[i] = Infected
            else
                agents_initial[i] = Susceptible
            end
        end
        p = [β, c, γ, δt]
        df_abm_temp = sim!(agents_initial, nsteps, δt, p)
        push!(df_abm_arr_S, df_abm_temp.S)
        push!(df_abm_arr_I, df_abm_temp.I)
        push!(df_abm_arr_R, df_abm_temp.R)
        if i == num_runs
            df_abm_t = df_abm_temp.t
        end
    end
    for i = 1:length(df_abm_S)
        for j = 1:num_runs
            df_abm_S[i] += df_abm_arr_S[j][i]
        end
        df_abm_S[i] /= num_runs
    end
    for i = 1:length(df_abm_I)
        for j = 1:num_runs
            df_abm_I[i] += df_abm_arr_I[j][i]
        end
        df_abm_I[i] /= num_runs
    end
    for i = 1:length(df_abm_R)
        for j = 1:num_runs
            df_abm_R[i] += df_abm_arr_R[j][i]
        end
        df_abm_R[i] /= num_runs
    end

    pl1 = plot(
        df_abm_t,
        df_abm_S,
        label="MCMC LHS",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.267, 0.467, 0.667),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    pl2 = plot(
        df_abm_t,
        df_abm_I,
        xlabel="Day",
        label="MCMC LHS",
        lw = 1.5,
        color = RGB(0.267, 0.467, 0.667),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    pl3 = plot(
        df_abm_t,
        df_abm_R,
        xlabel="Day",
        label="MCMC LHS",
        lw = 1.5,
        color = RGB(0.267, 0.467, 0.667),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    # Best
    β, c, γ, I0 = 0.06308478645916318, 8.620302179936914, 0.02120364824191881, 13.030465864640968
    # # Median
    # β, c, γ, I0 = 0.07447012760371949, 9.231202825682047, 0.03140516369043498, 19.43276986123847

    df_abm_arr_S = []
    df_abm_arr_I = []
    df_abm_arr_R = []
    df_abm_t = []
    df_abm_S = zeros(Float64, 401)
    df_abm_I = zeros(Float64, 401)
    df_abm_R = zeros(Float64, 401)

    for i = 1:num_runs
        # Reset
        for i in 1:length(agents_initial)
            if i <= I0 # I0
                agents_initial[i] = Infected
            else
                agents_initial[i] = Susceptible
            end
        end
        p = [β, c, γ, δt]
        df_abm_temp = sim!(agents_initial, nsteps, δt, p)
        push!(df_abm_arr_S, df_abm_temp.S)
        push!(df_abm_arr_I, df_abm_temp.I)
        push!(df_abm_arr_R, df_abm_temp.R)
        if i == num_runs
            df_abm_t = df_abm_temp.t
        end
    end

    for i = 1:length(df_abm_S)
        for j = 1:num_runs
            df_abm_S[i] += df_abm_arr_S[j][i]
        end
        df_abm_S[i] /= num_runs
    end
    for i = 1:length(df_abm_I)
        for j = 1:num_runs
            df_abm_I[i] += df_abm_arr_I[j][i]
        end
        df_abm_I[i] /= num_runs
    end
    for i = 1:length(df_abm_R)
        for j = 1:num_runs
            df_abm_R[i] += df_abm_arr_R[j][i]
        end
        df_abm_R[i] /= num_runs
    end

    plot!(
        pl1,
        df_abm_t,
        df_abm_S,
        label="MCMC manual",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.933, 0.4, 0.467),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl2,
        df_abm_t,
        df_abm_I,
        xlabel="Day",
        label="MCMC manual",
        lw = 1.5,
        color = RGB(0.933, 0.4, 0.467),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl3,
        df_abm_t,
        df_abm_R,
        xlabel="Day",
        label="MCMC manual",
        lw = 1.5,
        color = RGB(0.933, 0.4, 0.467),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    # savefig(pl1, joinpath(@__DIR__, "sir_S.pdf"))
    # savefig(pl2, joinpath(@__DIR__, "sir_I.pdf"))
    # savefig(pl3, joinpath(@__DIR__, "sir_R.pdf"))
    # return

    # β, c, γ, I0 = 0.08442353592331978, 5.0, 0.016001790923900215, 30.31581156584824

    # # Reset
    # for i in 1:length(agents_initial)
    #     if i <= I0 # I0
    #         agents_initial[i] = Infected
    #     else
    #         agents_initial[i] = Susceptible
    #     end
    # end
    # p = [β, c, γ, δt]
    # df_abm = sim!(agents_initial, nsteps, δt, p)

    # plot!(
    #     df_abm_t,
    #     df_abm_S,
    #     label="MA LHS",
    #     xlabel="Day",
    #     lw = 1.5,
    #     color = RGB(0.133, 0.533, 0.2),
    #     ylabel="Number of agents",
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    # )
    # plot!(
    #     df_abm_t,
    #     df_abm_I,
    #     xlabel="Day",
    #     label = false,
    #     lw = 1.5,
    #     color = RGB(0.133, 0.533, 0.2),
    #     ylabel="Number of agents",
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    # )
    # plot!(
    #     df_abm_t,
    #     df_abm_R,
    #     xlabel="Day",
    #     label = false,
    #     lw = 1.5,
    #     color = RGB(0.133, 0.533, 0.2),
    #     ylabel="Number of agents",
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    # )

    # β, c, γ, I0 = 0.06976332393517669, 7.3440641320089055, 0.027419841333460867, 28.988843268269655

    # # Reset
    # for i in 1:length(agents_initial)
    #     if i <= I0 # I0
    #         agents_initial[i] = Infected
    #     else
    #         agents_initial[i] = Susceptible
    #     end
    # end
    # p = [β, c, γ, δt]
    # df_abm = sim!(agents_initial, nsteps, δt, p)

    # plot!(
    #     df_abm_t,
    #     df_abm_S,
    #     label="MA manual",
    #     xlabel="Day",
    #     lw = 1.5,
    #     color = RGB(0.667, 0.2, 0.467),
    #     ylabel="Number of agents",
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    # )
    # plot!(
    #     df_abm_t,
    #     df_abm_I,
    #     xlabel="Day",
    #     label = false,
    #     lw = 1.5,
    #     color = RGB(0.667, 0.2, 0.467),
    #     ylabel="Number of agents",
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    # )
    # plot!(
    #     df_abm_t,
    #     df_abm_R,
    #     xlabel="Day",
    #     label = false,
    #     lw = 1.5,
    #     color = RGB(0.667, 0.2, 0.467),
    #     ylabel="Number of agents",
    #     foreground_color_legend = nothing,
    #     background_color_legend = nothing,
    # )

    # Best
    β, c, γ, I0 = 0.020680567299059184, 24.96253908208722, 0.020729138990765946, 24.014891329173516
    # # Median
    # β, c, γ, I0 = 0.03927349878742921, 21.66574708234853, 0.04699396824842727, 3.310893118869288

    df_abm_arr_S = []
    df_abm_arr_I = []
    df_abm_arr_R = []
    df_abm_t = []
    df_abm_S = zeros(Float64, 401)
    df_abm_I = zeros(Float64, 401)
    df_abm_R = zeros(Float64, 401)

    for i = 1:num_runs
        # Reset
        for i in 1:length(agents_initial)
            if i <= I0 # I0
                agents_initial[i] = Infected
            else
                agents_initial[i] = Susceptible
            end
        end
        p = [β, c, γ, δt]
        df_abm_temp = sim!(agents_initial, nsteps, δt, p)
        push!(df_abm_arr_S, df_abm_temp.S)
        push!(df_abm_arr_I, df_abm_temp.I)
        push!(df_abm_arr_R, df_abm_temp.R)
        if i == num_runs
            df_abm_t = df_abm_temp.t
        end
    end

    for i = 1:length(df_abm_S)
        for j = 1:num_runs
            df_abm_S[i] += df_abm_arr_S[j][i]
        end
        df_abm_S[i] /= num_runs
    end
    for i = 1:length(df_abm_I)
        for j = 1:num_runs
            df_abm_I[i] += df_abm_arr_I[j][i]
        end
        df_abm_I[i] /= num_runs
    end
    for i = 1:length(df_abm_R)
        for j = 1:num_runs
            df_abm_R[i] += df_abm_arr_R[j][i]
        end
        df_abm_R[i] /= num_runs
    end

    plot!(
        pl1,
        df_abm_t,
        df_abm_S,
        label="SM",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.133, 0.533, 0.2),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl2,
        df_abm_t,
        df_abm_I,
        label="SM",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.133, 0.533, 0.2),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl3,
        df_abm_t,
        df_abm_R,
        label="SM",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.133, 0.533, 0.2),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    # Best
    β, c, γ, I0 = 0.043145839036186344, 12.061908252437279, 0.0209793523053137, 25.39745553515337
    # # Median
    # β, c, γ, I0 = 0.02566264894291515, 18.4744858309475, 0.01868922377633394, 35.04930705707181

    df_abm_arr_S = []
    df_abm_arr_I = []
    df_abm_arr_R = []
    df_abm_t = []
    df_abm_S = zeros(Float64, 401)
    df_abm_I = zeros(Float64, 401)
    df_abm_R = zeros(Float64, 401)

    for i = 1:num_runs
        # Reset
        for i in 1:length(agents_initial)
            if i <= I0 # I0
                agents_initial[i] = Infected
            else
                agents_initial[i] = Susceptible
            end
        end
        p = [β, c, γ, δt]
        df_abm_temp = sim!(agents_initial, nsteps, δt, p)
        push!(df_abm_arr_S, df_abm_temp.S)
        push!(df_abm_arr_I, df_abm_temp.I)
        push!(df_abm_arr_R, df_abm_temp.R)
        if i == num_runs
            df_abm_t = df_abm_temp.t
        end
    end

    for i = 1:length(df_abm_S)
        for j = 1:num_runs
            df_abm_S[i] += df_abm_arr_S[j][i]
        end
        df_abm_S[i] /= num_runs
    end
    for i = 1:length(df_abm_I)
        for j = 1:num_runs
            df_abm_I[i] += df_abm_arr_I[j][i]
        end
        df_abm_I[i] /= num_runs
    end
    for i = 1:length(df_abm_R)
        for j = 1:num_runs
            df_abm_R[i] += df_abm_arr_R[j][i]
        end
        df_abm_R[i] /= num_runs
    end

    plot!(
        pl1,
        df_abm_t,
        df_abm_S,
        label="PSO",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.667, 0.2, 0.467),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl2,
        df_abm_t,
        df_abm_I,
        label="PSO",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.667, 0.2, 0.467),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl3,
        df_abm_t,
        df_abm_R,
        label="PSO",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.667, 0.2, 0.467),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    # Best
    β, c, γ, I0 = 0.04000000000000001, 11.3822576069654, 0.018210965408549492, 46.57974385928745
    # # Median
    # β, c, γ, I0 = 0.029279761612317372, 19.2731042457002, 0.01941136446065339, 8.97178358572054

    df_abm_arr_S = []
    df_abm_arr_I = []
    df_abm_arr_R = []
    df_abm_t = []
    df_abm_S = zeros(Float64, 401)
    df_abm_I = zeros(Float64, 401)
    df_abm_R = zeros(Float64, 401)

    for i = 1:num_runs
        # Reset
        for i in 1:length(agents_initial)
            if i <= I0 # I0
                agents_initial[i] = Infected
            else
                agents_initial[i] = Susceptible
            end
        end
        p = [β, c, γ, δt]
        df_abm_temp = sim!(agents_initial, nsteps, δt, p)
        push!(df_abm_arr_S, df_abm_temp.S)
        push!(df_abm_arr_I, df_abm_temp.I)
        push!(df_abm_arr_R, df_abm_temp.R)
        if i == num_runs
            df_abm_t = df_abm_temp.t
        end
    end

    for i = 1:length(df_abm_S)
        for j = 1:num_runs
            df_abm_S[i] += df_abm_arr_S[j][i]
        end
        df_abm_S[i] /= num_runs
    end
    for i = 1:length(df_abm_I)
        for j = 1:num_runs
            df_abm_I[i] += df_abm_arr_I[j][i]
        end
        df_abm_I[i] /= num_runs
    end
    for i = 1:length(df_abm_R)
        for j = 1:num_runs
            df_abm_R[i] += df_abm_arr_R[j][i]
        end
        df_abm_R[i] /= num_runs
    end

    plot!(
        pl1,
        df_abm_t,
        df_abm_S,
        label="GA",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.8, 0.733, 0.267),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl2,
        df_abm_t,
        df_abm_I,
        label="GA",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.8, 0.733, 0.267),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl3,
        df_abm_t,
        df_abm_R,
        label="GA",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.8, 0.733, 0.267),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    # Best
    β, c, γ, I0 = 0.033833576359600964, 15.777168861917703, 0.02136611083662048, 24.745999687704078
    # # Median
    # β, c, γ, I0 = 0.057412732095255534, 8.686077322261115, 0.017701428934867723, 30.0129764526302

    df_abm_arr_S = []
    df_abm_arr_I = []
    df_abm_arr_R = []
    df_abm_t = []
    df_abm_S = zeros(Float64, 401)
    df_abm_I = zeros(Float64, 401)
    df_abm_R = zeros(Float64, 401)

    for i = 1:num_runs
        # Reset
        for i in 1:length(agents_initial)
            if i <= I0 # I0
                agents_initial[i] = Infected
            else
                agents_initial[i] = Susceptible
            end
        end
        p = [β, c, γ, δt]
        df_abm_temp = sim!(agents_initial, nsteps, δt, p)
        push!(df_abm_arr_S, df_abm_temp.S)
        push!(df_abm_arr_I, df_abm_temp.I)
        push!(df_abm_arr_R, df_abm_temp.R)
        if i == num_runs
            df_abm_t = df_abm_temp.t
        end
    end

    for i = 1:length(df_abm_S)
        for j = 1:num_runs
            df_abm_S[i] += df_abm_arr_S[j][i]
        end
        df_abm_S[i] /= num_runs
    end
    for i = 1:length(df_abm_I)
        for j = 1:num_runs
            df_abm_I[i] += df_abm_arr_I[j][i]
        end
        df_abm_I[i] /= num_runs
    end
    for i = 1:length(df_abm_R)
        for j = 1:num_runs
            df_abm_R[i] += df_abm_arr_R[j][i]
        end
        df_abm_R[i] /= num_runs
    end

    plot!(
        pl1,
        df_abm_t,
        df_abm_S,
        label="CGO",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.4, 0.8, 0.933),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl2,
        df_abm_t,
        df_abm_I,
        label="CGO",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.4, 0.8, 0.933),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl3,
        df_abm_t,
        df_abm_R,
        label="CGO",
        xlabel="Day",
        lw = 1.5,
        color = RGB(0.4, 0.8, 0.933),
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    # Ref
    plot!(
        pl1,
        df_abm_t,
        S_ref,
        label="Reference",
        lw = 2.0,
        color = :black,
        xlabel="Day",
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl2,
        df_abm_t,
        I_ref,
        label="Reference",
        lw = 2.0,
        color = :black,
        xlabel="Day",
        ylabel="Number of agents",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    plot!(
        pl3,
        df_abm_t,
        R_ref,
        label="Reference",
        lw = 2.0,
        color = :black,
        xlabel="Day",
        ylabel="Number of agents",
        legend = (0.13, 0.7),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )

    savefig(pl1, joinpath(@__DIR__, "sir_S_min.pdf"))
    savefig(pl2, joinpath(@__DIR__, "sir_I_min.pdf"))
    savefig(pl3, joinpath(@__DIR__, "sir_R_min.pdf"))

    # savefig(pl1, joinpath(@__DIR__, "sir_S_median.pdf"))
    # savefig(pl2, joinpath(@__DIR__, "sir_I_median.pdf"))
    # savefig(pl3, joinpath(@__DIR__, "sir_R_median.pdf"))
    
    error = sqrt(1 / 1200 * sum((df_abm_S - S_ref).^2) + 1 / 1200 * sum((df_abm_I - I_ref).^2) + 1 / 1200 * sum((df_abm_R - R_ref).^2))
    return error
end

function run_model(agents_initial, nsteps, δt, β, c, γ)
    p = [β, c, γ, δt]
    # Running the model
    df_abm = sim!(agents_initial, nsteps, δt, p)
    pl = plot(
        df_abm.t,
        # [df_abm.S df_abm.I df_abm.R],
        [S_ref I_ref R_ref],
        label=["S" "I" "R"],
        xlabel="Day",
        ylabel="Number of people",
        # xlabel="Время",
        # ylabel="Число агентов",
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    savefig(pl, joinpath(@__DIR__, "sir.pdf"))
    # println("S_ref = $(df_abm.S)")
    # println("I_ref = $(df_abm.I)")
    # println("R_ref = $(df_abm.R)")
    error = sqrt(1 / 1200 * sum((df_abm.S - S_ref).^2) + 1 / 1200 * sum((df_abm.I - I_ref).^2) + 1 / 1200 * sum((df_abm.R - R_ref).^2))
    return error
end

function run_model_series(agents_initial, nsteps, δt, β, c, γ)
    p = [β, c, γ, δt]
    # Running the model
    df_abm = sim!(agents_initial, nsteps, δt, p)
    res_arr = copy(df_abm.S[1:400])
    append!(res_arr, df_abm.I[1:400])
    append!(res_arr, df_abm.R[1:400])
    return res_arr
end

function run_model_metropolis(agents_initial, nsteps, δt, β, c, γ)
    p = [β, c, γ, δt]
    # Running the model
    df_abm = sim!(agents_initial, nsteps, δt, p)
    error = sqrt(1 / 1200 * sum((df_abm.S - S_ref).^2) + 1 / 1200 * sum((df_abm.I - I_ref).^2) + 1 / 1200 * sum((df_abm.R - R_ref).^2))
    return error

    # println(error)

    # pl = plot(
    #     df_abm.t,
    #     [df_abm.S df_abm.I df_abm.R],
    #     label=["S" "I" "R"],
    #     xlabel="Day",
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
    method_num,
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

    error_min = 1.0e12

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
        error = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        if error < error_min
            error_min = error
            println("β_parameter = ", β_parameter)
            println("c_parameter = ", c_parameter)
            println("γ_parameter = ", γ_parameter)
            println("I0_parameter = ", I0_parameter)
        end
        save(joinpath(@__DIR__, "lhs$(method_num)", "results_$(i).jld"),
            "error", error,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)
    end
end

function lhs_simulations_series(
    # Число прогонов модели
    num_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
    method_num,
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

    error_min = 1.0e12

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
        res_vec = run_model_series(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "lhs", "results_$(i).jld"),
            "result", res_vec,
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
    method_run,
)
    # Получаем значения параметров
    β_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_lhs$(method_run)", "1_array.csv"), ',', Float64, '\n'))
    β_parameter = β_parameter_array[end]

    c_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_lhs$(method_run)", "2_array.csv"), ',', Float64, '\n'))
    c_parameter = c_parameter_array[end]

    γ_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_lhs$(method_run)", "3_array.csv"), ',', Float64, '\n'))
    γ_parameter = γ_parameter_array[end]

    I0_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters_lhs$(method_run)", "4_array.csv"), ',', Float64, '\n'))
    I0_parameter = I0_parameter_array[end]

    # Reset
    for i in 1:length(agents)
        if i <= I0_parameter # I0
            agents[i] = Infected
        else
            agents[i] = Susceptible
        end
    end
    error = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)
    open(joinpath(@__DIR__, "mcmc_lhs$(method_run).txt"), "a") do io
        println(io, error)
    end

    # Число принятий новых значений параметров
    accept_num = 0
    # Число последовательных отказов
    local_rejected_num = 0

    β_parameter_delta = 0.1
    c_parameter_delta = 0.1
    γ_parameter_delta = 0.1
    I0_parameter_delta = 0.1

    error_min = 9.e12
    error_prev = error
    error_min = error

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
        error = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "mcmc_lhs$(method_run)", "results_$(n).jld"),
            "error", error,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)

        open(joinpath(@__DIR__, "mcmc_lhs$(method_run).txt"), "a") do io
            println(io, error)
        end

        # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
        if error < error_prev || local_rejected_num >= 10
            if error < error_min
                error_min = error
                println("error min = $(error)")
                println("β_parameter = $(β_parameter)")
                println("c_parameter = $(c_parameter)")
                println("γ_parameter = $(γ_parameter)")
                println("I0_parameter = $(I0_parameter)")
            end
            push!(β_parameter_array, β_parameter)
            push!(c_parameter_array, c_parameter)
            push!(γ_parameter_array, γ_parameter)
            push!(I0_parameter_array, I0_parameter)

            error_prev = error

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

        # Сохраняем значения параметров
        writedlm(joinpath(@__DIR__, "parameters_lhs$(method_run)", "1_parameter_array.csv"), β_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters_lhs$(method_run)", "2_parameter_array.csv"), c_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters_lhs$(method_run)", "3_parameter_array.csv"), γ_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters_lhs$(method_run)", "4_parameter_array.csv"), I0_parameter_array, ',')
    end
end

function mcmc_simulations(
    # Число прогонов модели
    num_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
    method_run,
)
    # Получаем значения параметров
    β_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters$(method_run)", "1_array.csv"), ',', Float64, '\n'))
    β_parameter = β_parameter_array[end]

    c_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters$(method_run)", "2_array.csv"), ',', Float64, '\n'))
    c_parameter = c_parameter_array[end]

    γ_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters$(method_run)", "3_array.csv"), ',', Float64, '\n'))
    γ_parameter = γ_parameter_array[end]

    I0_parameter_array = vec(readdlm(joinpath(@__DIR__, "parameters$(method_run)", "4_array.csv"), ',', Float64, '\n'))
    I0_parameter = I0_parameter_array[end]

    # Reset
    for i in 1:length(agents)
        if i <= I0_parameter # I0
            agents[i] = Infected
        else
            agents[i] = Susceptible
        end
    end
    error = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)
    open(joinpath(@__DIR__, "mcmc$(method_run).txt"), "a") do io
        println(io, error)
    end

    # Число принятий новых значений параметров
    accept_num = 0
    # Число последовательных отказов
    local_rejected_num = 0

    β_parameter_delta = 0.1
    c_parameter_delta = 0.1
    γ_parameter_delta = 0.1
    I0_parameter_delta = 0.1

    error_min = 9.e12
    error_prev = error
    error_min = error

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
        @time error = run_model(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "mcmc$(method_run)", "results_$(n).jld"),
            "error", error,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)

        open(joinpath(@__DIR__, "mcmc$(method_run).txt"), "a") do io
            println(io, error)
        end

        # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
        if error < error_prev || local_rejected_num >= 10
            if error < error_min
                error_min = error
                println("error min = $(error)")
                println("β_parameter = $(β_parameter)")
                println("c_parameter = $(c_parameter)")
                println("γ_parameter = $(γ_parameter)")
                println("I0_parameter = $(I0_parameter)")
            end
            push!(β_parameter_array, β_parameter)
            push!(c_parameter_array, c_parameter)
            push!(γ_parameter_array, γ_parameter)
            push!(I0_parameter_array, I0_parameter)

            error_prev = error

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

        # Сохраняем значения параметров
        writedlm(joinpath(@__DIR__, "parameters$(method_run)", "1_parameter_array.csv"), β_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters$(method_run)", "2_parameter_array.csv"), c_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters$(method_run)", "3_parameter_array.csv"), γ_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters$(method_run)", "4_parameter_array.csv"), I0_parameter_array, ',')
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
    S, I, R, error = run_model_metropolis(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)
    open(joinpath(@__DIR__, "mcmc_metropolis.txt"), "a") do io
        println(io, error)
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
        if abs(x - 0.02) < 0.00001
            x += 0.001
        elseif abs(x - 0.2) < 0.00001
            x -= 0.001
        end
        y = rand(Normal(log((x - 0.02) / (0.2 - x)), β_parameter_delta))
        β_parameter = (0.2 * exp(y) + 0.02) / (1 + exp(y))

        x = c_parameter_array[end]
        if abs(x - 5) < 0.00001
            x += 0.1
        elseif abs(x - 25) < 0.00001
            x -= 0.1
        end
        y = rand(Normal(log((x - 5) / (25 - x)), c_parameter_delta))
        c_parameter = (25 * exp(y) + 5) / (1 + exp(y))

        x = γ_parameter_array[end]
        if abs(x - 0.01) < 0.00001
            x += 0.001
        elseif abs(x - 0.05) < 0.00001
            x -= 0.001
        end
        y = rand(Normal(log((x - 0.01) / (0.05 - x)), γ_parameter_delta))
        γ_parameter = (0.05 * exp(y) + 0.01) / (1 + exp(y))

        x = I0_parameter_array[end]
        if abs(x - 1) < 0.00001
            x += 0.1
        elseif abs(x - 50) < 0.00001
            x -= 0.1
        end
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
        S, I, R, error = run_model_metropolis(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "mcmc_metropolis", "results_$(n).jld"),
            "error", error,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)

        open(joinpath(@__DIR__, "mcmc_metropolis.txt"), "a") do io
            println(io, error)
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
    S, I, R, error = run_model_metropolis(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)
    open(joinpath(@__DIR__, "mcmc_metropolis_lhs.txt"), "a") do io
        println(io, error)
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
        if abs(x - 0.02) < 0.00001
            x += 0.001
        elseif abs(x - 0.2) < 0.00001
            x -= 0.001
        end
        y = rand(Normal(log((x - 0.02) / (0.2 - x)), β_parameter_delta))
        β_parameter = (0.2 * exp(y) + 0.02) / (1 + exp(y))

        x = c_parameter_array[end]
        if abs(x - 5) < 0.00001
            x += 0.1
        elseif abs(x - 25) < 0.00001
            x -= 0.1
        end
        y = rand(Normal(log((x - 5) / (25 - x)), c_parameter_delta))
        c_parameter = (25 * exp(y) + 5) / (1 + exp(y))

        x = γ_parameter_array[end]
        if abs(x - 0.01) < 0.00001
            x += 0.001
        elseif abs(x - 0.05) < 0.00001
            x -= 0.001
        end
        y = rand(Normal(log((x - 0.01) / (0.05 - x)), γ_parameter_delta))
        γ_parameter = (0.05 * exp(y) + 0.01) / (1 + exp(y))

        x = I0_parameter_array[end]
        if abs(x - 1) < 0.00001
            x += 0.1
        elseif abs(x - 50) < 0.00001
            x -= 0.1
        end
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
        S, I, R, error = run_model_metropolis(agents, nsteps, δt, β_parameter, c_parameter, γ_parameter)

        save(joinpath(@__DIR__, "mcmc_metropolis_lhs", "results_$(n).jld"),
            "error", error,
            "β_parameter", β_parameter,
            "c_parameter", c_parameter,
            "γ_parameter", γ_parameter,
            "I0_parameter", I0_parameter)

        open(joinpath(@__DIR__, "mcmc_metropolis_lhs.txt"), "a") do io
            println(io, error)
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

        # Сохраняем значения параметров
        writedlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "1_parameter_array.csv"), β_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "2_parameter_array.csv"), c_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "3_parameter_array.csv"), γ_parameter_array, ',')
        writedlm(joinpath(@__DIR__, "parameters_metropolis_lhs", "4_parameter_array.csv"), I0_parameter_array, ',')
    end
end

function run_swarm_model(
    num_swarm_model_runs,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
    method_num,
)
    num_particles = 10

    best_error = 9.e12

    w = 0.5
    w_min = 0.4
    w_max = 0.9
    c1 = 2.0
    c2 = 2.0

    error_particles = zeros(Float64, num_particles) .+ 9.e12

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

    # for i = 1:num_particles
    #     error_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["error"]

    #     β_parameter_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["β_parameter"]
    #     c_parameter_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["c_parameter"]
    #     γ_parameter_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["γ_parameter"]
    #     I0_parameter_particles[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["I0_parameter"]

    #     β_parameter_particles_best[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["β_parameter"]
    #     c_parameter_particles_best[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["c_parameter"]
    #     γ_parameter_particles_best[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["γ_parameter"]
    #     I0_parameter_particles_best[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["I0_parameter"]
    # end

    k = argmin(error_particles)
    β_parameter_best = β_parameter_particles[k]
    c_parameter_best = c_parameter_particles[k]
    γ_parameter_best = γ_parameter_particles[k]
    I0_parameter_best = I0_parameter_particles[k]

    # println(β_parameter_best)
    # println(c_parameter_best)
    # println(γ_parameter_best)
    # println(I0_parameter_best)
    # return

    # Латинский гиперкуб
    latin_hypercube_plan, _ = LHCoptim(num_particles, num_parameters, 200)

    # Интервалы значений параметров
    points = scaleLHC(latin_hypercube_plan, [
        (0.02, 0.2), # β
        (5, 25), # c
        (0.01, 0.05), # γ
        (1, 50), # I0
    ])

    for i = 1:num_particles
        β_parameter_particles_best[i] = points[i, 1]
        c_parameter_particles_best[i] = points[i, 2]
        γ_parameter_particles_best[i] = points[i, 3]
        I0_parameter_particles_best[i] = points[i, 4]

        β_parameter_particles[i] = points[i, 1]
        c_parameter_particles[i] = points[i, 2]
        γ_parameter_particles[i] = points[i, 3]
        I0_parameter_particles[i] = points[i, 4]

        # Reset
        for j in 1:length(agents)
            if j <= I0_parameter_particles_best[i] # I0
                agents[j] = Infected
            else
                agents[j] = Susceptible
            end
        end
        error_particles[i] = run_model(agents, nsteps, δt, β_parameter_particles[i], c_parameter_particles_best[i], γ_parameter_particles_best[i])

        if error_particles[i] < best_error
            best_error = error_particles[i]

            β_parameter_best = points[i, 1]
            c_parameter_best = points[i, 2]
            γ_parameter_best = points[i, 3]
            I0_parameter_best = points[i, 4]
        end

        save(joinpath(@__DIR__, "swarm$(method_num)", "0", "results_$(i).jld"),
            "error", error_particles[i],
            "β_parameter", β_parameter_particles[i],
            "c_parameter", c_parameter_particles[i],
            "γ_parameter", γ_parameter_particles[i],
            "I0_parameter", I0_parameter_particles[i])
    end
    println(minimum(error_particles))

    for curr_run = 1:num_swarm_model_runs
        w = (num_swarm_model_runs - curr_run) / num_swarm_model_runs * (w_max - w_min) + w_min
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
            error = run_model(agents, nsteps, δt, β_parameter_particles[i], c_parameter_particles[i], γ_parameter_particles[i])

            save(joinpath(@__DIR__, "swarm$(method_num)", "$(i)", "results_$(curr_run).jld"),
                "error", error,
                "β_parameter", β_parameter_particles[i],
                "c_parameter", c_parameter_particles[i],
                "γ_parameter", γ_parameter_particles[i],
                "I0_parameter", I0_parameter_particles[i],
            )

            if error < best_error
                best_error = error

                β_parameter_best = β_parameter_particles[i]
                c_parameter_best = c_parameter_particles[i]
                γ_parameter_best = γ_parameter_particles[i]
                I0_parameter_best = I0_parameter_particles[i]

                println("Best!!!")
                println("error_best = ", error)
                println("β_parameter = ", β_parameter_best)
                println("c_parameter = ", c_parameter_best)
                println("γ_parameter = ", γ_parameter_best)
                println("I0_parameter = ", I0_parameter_best)
                println()
            end

            if error < error_particles[i]
                error_particles[i] = error

                β_parameter_particles_best[i] = β_parameter_particles[i]
                c_parameter_particles_best[i] = c_parameter_particles[i]
                γ_parameter_particles_best[i] = γ_parameter_particles[i]
                I0_parameter_particles_best[i] = I0_parameter_particles[i]

                println("Particle")
                println("error_particle $(i) = ", error)
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
    method_num,
)
    num_initial_runs = 10
    num_additional_runs = 0
    num_runs = num_initial_runs + num_additional_runs

    num_parameters = 4

    error_arr = Array{Float64, 1}(undef, num_runs)
    β_parameter = Array{Float64, 1}(undef, num_runs)
    c_parameter = Array{Float64, 1}(undef, num_runs)
    γ_parameter = Array{Float64, 1}(undef, num_runs)
    I0_parameter = Array{Float64, 1}(undef, num_runs)

    for i = 1:num_initial_runs
        error_arr[i] = load(joinpath(@__DIR__, "lhs$(method_num)", "results_$(i).jld"))["error"]
        β_parameter[i] = load(joinpath(@__DIR__, "lhs$(method_num)", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "lhs$(method_num)", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "lhs$(method_num)", "results_$(i).jld"))["γ_parameter"]
        I0_parameter[i] = load(joinpath(@__DIR__, "lhs$(method_num)", "results_$(i).jld"))["I0_parameter"]
    end

    # for i = 1:num_additional_runs
    #     error_arr[i + num_initial_runs] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["error"]
    #     β_parameter[i + num_initial_runs] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["β_parameter"]
    # end

    min_i = 0
    min_error = 9.e12

    # y = zeros(Float64, x, num_runs)
    # for i = 1:num_runs
    #     for j = 1:52
    #         y[j, i] = sum(abs.(incidence_arr[i][j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #     end
    #     error = sum(y[:, i])
    #     if error < min_error
    #         min_i = i
    #         min_error = error
    #     end
    # end

    # XGBoost
    y = copy(error_arr)
    min_i = argmin(error_arr)
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
    #         error_model, st = Lux.apply(lux_model, x, p, lux_state)
    #         0.5 * mean((error_model .- y).^2), st
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
    #         swarm_error = zeros(Float64, 52)
    #         for j = 1:52
    #             swarm_error[j] = sum(abs.(swarm_incidence[j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #         end

    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["β_parameter"]
    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["c_parameter"]
    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["γ_parameter"]
    #         r = reshape(par_vec, :, 1)

    #         # error, _ = Lux.apply(lux_model, r, params, opt_state)

    #         # real_error = sum(abs.(load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    #         # error += abs(real_error - error[:][1])

    #         # y_predicted, _ = Lux.apply(lux_model, r, params, opt_state)
    #         # y_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         # y_model = vec(load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"])
    #         # error += sum(abs.(y_predicted - y_model)) / sum(y_model)

    #         error_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         error += 0.5 * mean((error_predicted .- swarm_error).^2)
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
        #         error_model, st = Lux.apply(lux_model, x, p, lux_state)
        #         0.5 * mean((error_model .- y).^2), st
        #     end
        #     ∇params, _ = back((one.(loss), nothing))  # gradient of only the loss, with respect to parameter tree

        #     opt_state, params = Optimisers.update!(opt_state, params, ∇params)

        #     if epoch % 2000 == 0
        #         println("Epoch: $(epoch), loss: $(loss)")
        #     end
        # end

        error = 0.0
        error_min = 9.e12
        error_prev = 9.e12

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
            if abs(x_cand - 0.02) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 0.2) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 0.02) / (0.2 - x_cand)), β_parameter_delta))
            β_parameter_candidate = (0.2 * exp(y_cand) + 0.02) / (1 + exp(y_cand))

            x_cand = c_parameter_default
            if abs(x_cand - 5) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 25) < 0.00001
                x_cand -= 0.1
            end
            y_cand = rand(Normal(log((x_cand - 5) / (25 - x_cand)), c_parameter_delta))
            c_parameter_candidate = (25 * exp(y_cand) + 5) / (1 + exp(y_cand))

            x_cand = γ_parameter_default
            if abs(x_cand - 0.01) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 0.05) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 0.01) / (0.05 - x_cand)), γ_parameter_delta))
            γ_parameter_candidate = (0.05 * exp(y_cand) + 0.01) / (1 + exp(y_cand))

            x_cand = I0_parameter_default
            if abs(x_cand - 1) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 50) < 0.00001
                x_cand -= 0.1
            end
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
    
            # error_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
            # error = sum(error_predicted)

            # XGBoost
            error = predict(bst, r)[1]

            # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
            if error < error_prev || local_rejected_num >= 10
                if error < error_min
                    error_min = error

                    β_parameter_min = β_parameter_candidate
                    c_parameter_min = c_parameter_candidate
                    γ_parameter_min = γ_parameter_candidate
                    I0_parameter_min = I0_parameter_candidate
                end
                β_parameter_default = β_parameter_candidate
                c_parameter_default = c_parameter_candidate
                γ_parameter_default = γ_parameter_candidate
                I0_parameter_default = I0_parameter_candidate

                error_prev = error

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
        error = run_model(agents, nsteps, δt, β_parameter_min, c_parameter_min, γ_parameter_min)

        save(joinpath(@__DIR__, "surrogate$(method_num)", "results_$(curr_run).jld"),
            "error", error,
            "β_parameter", β_parameter_min,
            "c_parameter", c_parameter_min,
            "γ_parameter", γ_parameter_min,
            "I0_parameter", I0_parameter_min)

        println("Real error: $(error)")

        # y = cat(y, error_arr, dims = 2)
        # X = cat(X, [β_parameter_min, c_parameter_min, γ_parameter_min], dims = 2)

        # XGBoost
        # y = vcat(y, error)
        push!(y, error)
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

    error_arr = Array{Float64, 1}(undef, num_runs)
    β_parameter = Array{Float64, 1}(undef, num_runs)
    c_parameter = Array{Float64, 1}(undef, num_runs)
    γ_parameter = Array{Float64, 1}(undef, num_runs)

    for i = 1:num_initial_runs
        error_arr[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["error"]
        β_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["β_parameter"]
        c_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["c_parameter"]
        γ_parameter[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["γ_parameter"]
    end

    # for i = 1:num_additional_runs
    #     error_arr[i + num_initial_runs] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["error"]
    #     β_parameter[i + num_initial_runs] = load(joinpath(@__DIR__, "surrogate", "results_$(i).jld"))["β_parameter"]
    # end

    min_i = 0
    min_error = 9.e12

    y = copy(error_arr)
    min_i = argmin(error_arr)
    # y = zeros(Float64, x, num_runs)
    # for i = 1:num_runs
    #     for j = 1:52
    #         y[j, i] = sum(abs.(incidence_arr[i][j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #     end
    #     error = sum(y[:, i])
    #     if error < min_error
    #         min_i = i
    #         min_error = error
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
    min_error = 9.e12
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
    #         error_model, st = Lux.apply(lux_model, x, p, lux_state)
    #         0.5 * mean((error_model .- y).^2), st
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
    #         swarm_error = zeros(Float64, 52)
    #         for j = 1:52
    #             swarm_error[j] = sum(abs.(swarm_incidence[j, :, :] - num_infected_age_groups_viruses[j, :, :])) / sum(num_infected_age_groups_viruses[j, :, :])
    #         end

    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["β_parameter"]
    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["c_parameter"]
    #         par_vec[1] = load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["γ_parameter"]
    #         r = reshape(par_vec, :, 1)

    #         # error, _ = Lux.apply(lux_model, r, params, opt_state)

    #         # real_error = sum(abs.(load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"] - num_infected_age_groups_viruses)) / sum(num_infected_age_groups_viruses)
    #         # error += abs(real_error - error[:][1])

    #         # y_predicted, _ = Lux.apply(lux_model, r, params, opt_state)
    #         # y_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         # y_model = vec(load(joinpath(@__DIR__, "swarm", "$(particle_number)", "results_$(i).jld"))["observed_cases"])
    #         # error += sum(abs.(y_predicted - y_model)) / sum(y_model)

    #         error_predicted, _ = Lux.apply(lux_model, r, params, lux_state)
    #         error += 0.5 * mean((error_predicted .- swarm_error).^2)
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
                error_model, st = Lux.apply(lux_model, x, p, lux_state)
                0.5 * mean((error_model .- y).^2), st
            end
            ∇params, _ = back((one.(loss), nothing))  # gradient of only the loss, with respect to parameter tree

            opt_state, params = Optimisers.update!(opt_state, params, ∇params)

            if epoch % 2000 == 0
                println("Epoch: $(epoch), loss: $(loss)")
            end
        end

        error = 0.0
        error_min = 9.e12
        error_prev = 9.e12

        β_parameter_default = β_parameter[min_i]
        β_parameter_min = β_parameter[min_i]

        c_parameter_default = c_parameter[min_i]
        c_parameter_min = c_parameter[min_i]

        γ_parameter_default = γ_parameter[min_i]
        γ_parameter_min = γ_parameter[min_i]

        local_rejected_num = 0

        for n = 1:1000
            x_cand = β_parameter_default
            if abs(x_cand - 0.02) < 0.00001
                x_cand += 0.001
            elseif abs(x_cand - 0.2) < 0.00001
                x_cand -= 0.001
            end
            y_cand = rand(Normal(log((x_cand - 0.02) / (0.2 - x_cand)), β_parameter_delta))
            β_parameter_candidate = (0.2 * exp(y_cand) + 0.02) / (1 + exp(y_cand))

            x_cand = c_parameter_default
            if abs(x_cand - 5) < 0.00001
                x_cand += 0.1
            elseif abs(x_cand - 25) < 0.00001
                x_cand -= 0.1
            end
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
    
            error, _ = Lux.apply(lux_model, r, params, lux_state)

            # Если ошибка меньше ошибки на предыдущем шаге или число последовательных отказов больше 10
            if error[1][1] < error_prev || local_rejected_num >= 10
                if error[1][1] < error_min
                    error_min = error[1][1]

                    β_parameter_min = β_parameter_candidate
                    c_parameter_min = c_parameter_candidate
                    γ_parameter_min = γ_parameter_candidate
                end
                β_parameter_default = β_parameter_candidate
                c_parameter_default = c_parameter_candidate
                γ_parameter_default = γ_parameter_candidate

                error_prev = error[1][1]

                # Число последовательных отказов приравниваем нулю
                local_rejected_num = 0
            else
                local_rejected_num += 1
            end
        end

        # Reset
        for i in 1:length(agents)
            if i <= 10 # I0
                agents[i] = Infected
            else
                agents[i] = Susceptible
            end
        end
        error = run_model(agents, nsteps, δt, β_parameter_min, c_parameter_min, γ_parameter_min)

        save(joinpath(@__DIR__, "surrogate_NN", "results_$(curr_run).jld"),
            "error", error,
            "β_parameter", β_parameter_min,
            "c_parameter", c_parameter_min,
            "γ_parameter", γ_parameter_min,)

        println("Real error: $(error)")

        push!(y, error)
        X = cat(X, [β_parameter_min, c_parameter_min, γ_parameter_min], dims = 2)
    end
end

function selection(
    pop_size::Int,
    errors::Vector{Float64},
    num_parents::Int,
    k::Int = 2
)::Vector{Int}
    mating_pool_indicies = Int[]
    # Tournament selection
    for i = 1:num_parents
        tournament_indicies = rand(setdiff(vec(1:pop_size), mating_pool_indicies), k)
        pop_el_selected_num = tournament_indicies[1]
        for pop_el_num in tournament_indicies[2:end]
            if errors[pop_el_num] < errors[pop_el_selected_num]
                pop_el_selected_num = pop_el_num
            end
        end
        push!(mating_pool_indicies, pop_el_selected_num)
    end
    # Other - Proportional Roulette Wheel Selection
    return mating_pool_indicies
end

function crossover(
    p1_parameters,
    p2_parameters,
    cross_rate::Float64 = 0.8
)
    # One-point crossover
    if rand(Float64) < cross_rate
        split_pos = rand(1:(length(p1_parameters) - 1))
        c1_parameters = vcat(p1_parameters[1:split_pos], p2_parameters[(split_pos + 1):end])
        c2_parameters = vcat(p2_parameters[1:split_pos], p1_parameters[(split_pos + 1):end])
        return c1_parameters, c2_parameters
    end
    return p1_parameters, p2_parameters
end

function mutation(
    parameters,
    mut_rate::Float64 = 0.15,
    disturbance::Float64 = 0.33,
)
    if rand(Float64) < mut_rate
        parameters[1] += rand(Normal(0, disturbance * 0.18))
    end
    if rand(Float64) < mut_rate
        parameters[2] += rand(Normal(0, disturbance * 20))
    end
    if rand(Float64) < mut_rate
        parameters[3] += rand(Normal(0, disturbance * 0.04))
    end
    if rand(Float64) < mut_rate
        parameters[4] += rand(Normal(0, disturbance * 49))
    end
    # [0.02, 0.2]
    # [5, 25]
    # [0.01, 0.05]
    # [1, 50]
    if parameters[1] < 0.02 || parameters[1] > 0.2
        parameters[1] = rand(Uniform(0.02, 0.2))
    end
    if parameters[2] < 5 || parameters[2] > 25
        parameters[2] = rand(Uniform(5, 25))
    end
    if parameters[3] < 0.01 || parameters[3] > 0.05
        parameters[3] = rand(Uniform(0.01, 0.05))
    end
    if parameters[4] < 1 || parameters[4] > 50
        parameters[4] = rand(Uniform(1, 50))
    end
end

function genetic_algorithm(
    # Число прогонов модели
    num_ga_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
    method_num,
)
    population_size = 10
    num_parents = 5

    incidence_arr = Array{Array{Float64, 3}, 1}(undef, population_size)
    best_error = 9.0e12
    error_population = zeros(Float64, population_size) .+ 9.0e12
    error_population_children = zeros(Float64, population_size) .+ 9.0e12

    β_parameter_array = Array{Float64, 1}(undef, population_size)
    c_parameter_array = Array{Float64, 1}(undef, population_size)
    γ_parameter_array = Array{Float64, 1}(undef, population_size)
    I0_parameter_array = Array{Float64, 1}(undef, population_size)

    # Латинский гиперкуб
    latin_hypercube_plan, _ = LHCoptim(population_size, 4, 200)

    # Интервалы значений параметров
    points = scaleLHC(latin_hypercube_plan, [
        (0.02, 0.2), # β
        (5, 25), # c
        (0.01, 0.05), # γ
        (1, 50), # I0
    ])

    # for i = 1:population_size
    #     error_population[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["error"]
    #     β_parameter_array[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["β_parameter"]
    #     c_parameter_array[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["c_parameter"]
    #     γ_parameter_array[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["γ_parameter"]
    #     I0_parameter_array[i] = load(joinpath(@__DIR__, "lhs", "results_$(i).jld"))["I0_parameter"]
    # end

    β_parameter_array = points[:, 1]
    c_parameter_array = points[:, 2]
    γ_parameter_array = points[:, 3]
    I0_parameter_array = points[:, 4]

    for i = 1:population_size
        # Reset
        for j in 1:length(agents)
            if j <= I0_parameter_array[i] # I0
                agents[j] = Infected
            else
                agents[j] = Susceptible
            end
        end
        error_population[i] = run_model(agents, nsteps, δt, β_parameter_array[i], c_parameter_array[i], γ_parameter_array[i])

        save(joinpath(@__DIR__, "ga$(method_num)", "0", "results_$(i).jld"),
            "error", error_population[i],
            "β_parameter", β_parameter_array[i],
            "c_parameter", c_parameter_array[i],
            "γ_parameter", γ_parameter_array[i],
            "I0_parameter", I0_parameter_array[i])
    end
    println(minimum(error_population))

    β_parameter_children = zeros(Float64, population_size)
    c_parameter_children = zeros(Float64, population_size)
    γ_parameter_children = zeros(Float64, population_size)
    I0_parameter_children = zeros(Float64, population_size)

    for curr_run = 1:num_ga_runs
        children_k = 1
        println("curr_num = $(curr_run)")
        mating_pool_indicies = selection(population_size, error_population, num_parents)
        for i = 1:(population_size / 2)
            p1_mating_index = rand(mating_pool_indicies)
            p2_mating_index = rand(mating_pool_indicies)
            while p1_mating_index == p2_mating_index
                p2_mating_index = rand(mating_pool_indicies)
            end
            
            for c in crossover(
                [β_parameter_array[p1_mating_index], c_parameter_array[p1_mating_index], γ_parameter_array[p1_mating_index], I0_parameter_array[p1_mating_index]],
                [β_parameter_array[p2_mating_index], c_parameter_array[p2_mating_index], γ_parameter_array[p2_mating_index], I0_parameter_array[p2_mating_index]],
            )
                mutation(c)
                β_parameter_children[children_k] = c[1]
                c_parameter_children[children_k] = c[2]
                γ_parameter_children[children_k] = c[3]
                I0_parameter_children[children_k] = c[4]
                children_k += 1
            end
        end
        for i = 1:population_size
            # Reset
            for j in 1:length(agents)
                if j <= I0_parameter_children[i] # I0
                    agents[j] = Infected
                else
                    agents[j] = Susceptible
                end
            end
            error_population_children[i] = run_model(agents, nsteps, δt, β_parameter_children[i], c_parameter_children[i], γ_parameter_children[i])
        end
        # β_parameter_array = copy(β_parameter_children)
        # c_parameter_array = copy(c_parameter_children)
        # γ_parameter_array = copy(γ_parameter_children)
        # I0_parameter_array = copy(I0_parameter_children)
        # error_population = copy(error_population_children)

        args = [a[1] for a in arg_n_smallest_values(vcat(error_population, error_population_children), population_size)]

        β_parameter_concatenated = vcat(β_parameter_array, β_parameter_children)
        c_parameter_concatenated = vcat(c_parameter_array, c_parameter_children)
        γ_parameter_concatenated = vcat(γ_parameter_array, γ_parameter_children)
        I0_parameter_concatenated = vcat(I0_parameter_array, I0_parameter_children)
        error_population_concatenated = vcat(error_population, error_population_children)

        for i = 1:population_size
            β_parameter_array[i] = β_parameter_concatenated[args[i]]
            c_parameter_array[i] = c_parameter_concatenated[args[i]]
            γ_parameter_array[i] = γ_parameter_concatenated[args[i]]
            I0_parameter_array[i] = I0_parameter_concatenated[args[i]]
            error_population[i] = error_population_concatenated[args[i]]

            save(joinpath(@__DIR__, "ga$(method_num)", "$(curr_run)", "results_$(i).jld"),
                "error", error_population[i],
                "β_parameter", β_parameter_array[i],
                "c_parameter", c_parameter_array[i],
                "γ_parameter", γ_parameter_array[i],
                "I0_parameter", I0_parameter_array[i],
            )
        end
    end
end

function check_bounds(
    parameters::Vector{Float64},
)
    # Ограничения на область значений параметров
    # [0.02, 0.2]
    # [5, 25]
    # [0.01, 0.05]
    # [1, 50]
    if parameters[1] < 0.02 || parameters[1] > 0.2
        parameters[1] = rand(Uniform(0.02, 0.2))
    end
    if parameters[2] < 5 || parameters[2] > 25
        parameters[2] = rand(Uniform(5, 25))
    end
    if parameters[3] < 0.01 || parameters[3] > 0.05
        parameters[3] = rand(Uniform(0.01, 0.05))
    end
    if parameters[4] < 1 || parameters[4] > 50
        parameters[4] = rand(Uniform(1, 50))
    end
end

function run_cgo_model(
    # Число прогонов модели
    num_cgo_runs::Int,
    # Агенты
    agents::Vector{InfectionStatus},
    nsteps,
    δt,
    method_num,
)
    num_parameters = 26

    seeds_size = 10

    best_error = 9.0e12

    error_seeds_arr = Array{Float64, 1}(undef, seeds_size)
    β_parameter_seeds_array = Array{Float64, 1}(undef, seeds_size)
    c_parameter_seeds_array = Array{Float64, 1}(undef, seeds_size)
    γ_parameter_seeds_array = Array{Float64, 1}(undef, seeds_size)
    I0_parameter_seeds_array = Array{Float64, 1}(undef, seeds_size)

    error_offsprings_arr = Array{Float64, 2}(undef, seeds_size, 4)
    β_parameter_offsprings_array = Array{Float64, 2}(undef, seeds_size, 4)
    c_parameter_offsprings_array = Array{Float64, 2}(undef, seeds_size, 4)
    γ_parameter_offsprings_array = Array{Float64, 2}(undef, seeds_size, 4)
    I0_parameter_offsprings_array = Array{Float64, 2}(undef, seeds_size, 4)

    β_parameter_best = 0.0
    c_parameter_best = 0.0
    γ_parameter_best = 0.0
    I0_parameter_best = 0.0

    β_parameter_mean_group = 0.0
    c_parameter_mean_group = 0.0
    γ_parameter_mean_group = 0.0
    I0_parameter_mean_group = 0.0

    # Латинский гиперкуб
    latin_hypercube_plan, _ = LHCoptim(seeds_size, 4, 200)

    # Интервалы значений параметров
    points = scaleLHC(latin_hypercube_plan, [
        (0.02, 0.2), # β
        (5, 25), # c
        (0.01, 0.05), # γ
        (1, 50), # I0
    ])

    β_parameter_seeds_array = points[:, 1]
    c_parameter_seeds_array = points[:, 2]
    γ_parameter_seeds_array = points[:, 3]
    I0_parameter_seeds_array = points[:, 4]

    for i = 1:seeds_size
        # Reset
        for j in 1:length(agents)
            if j <= I0_parameter_seeds_array[i] # I0
                agents[j] = Infected
            else
                agents[j] = Susceptible
            end
        end
        error_seeds_arr[i] = run_model(agents, nsteps, δt, β_parameter_seeds_array[i], c_parameter_seeds_array[i], γ_parameter_seeds_array[i])

        if error_seeds_arr[i] < best_error
            β_parameter_best = β_parameter_seeds_array[i]
            c_parameter_best = c_parameter_seeds_array[i]
            γ_parameter_best = γ_parameter_seeds_array[i]
            I0_parameter_best = I0_parameter_seeds_array[i]
            best_error = error_seeds_arr[i]
        end

        save(joinpath(@__DIR__, "cgo$(method_num)", "0", "results_$(i).jld"),
            "error", error_seeds_arr[i],
            "β_parameter", β_parameter_seeds_array[i],
            "c_parameter", c_parameter_seeds_array[i],
            "γ_parameter", γ_parameter_seeds_array[i],
            "I0_parameter", I0_parameter_seeds_array[i])
    end

    for curr_run = 1:num_cgo_runs
        for seed = 1:seeds_size
            group_num = rand(1:seeds_size)
            el_nums = zeros(Int, group_num)
            for i = 1:group_num
                rand_num = rand(1:seeds_size)
                while rand_num in el_nums
                    rand_num = rand(1:seeds_size)
                end
                el_nums[i] = rand_num
            end

            β_parameter_mean_group = mean(β_parameter_seeds_array[el_nums])
            c_parameter_mean_group = mean(c_parameter_seeds_array[el_nums])
            γ_parameter_mean_group = mean(γ_parameter_seeds_array[el_nums])
            I0_parameter_mean_group = mean(I0_parameter_seeds_array[el_nums])

            # I = rand(0:1, 6)
            I = rand(1:2, 6)
            Ir = rand(0:1, 2)

            if I[1] == 0 && I[2] == 0
                I[rand(1:2)] = 1
            end
            if I[3] == 0 && I[4] == 0
                I[rand(3:4)] = 1
            end
            if I[5] == 0 && I[6] == 0
                I[rand(5:6)] = 1
            end

            alpha = Array{Vector{Float64}, 1}(undef, 4)
            # alpha[1] = rand(num_parameters)
            # alpha[2] = 2 * rand(num_parameters) .- 1
            # alpha[3] = Ir[1] .* rand(num_parameters) .+ 1
            # alpha[4] = (Ir[2] .* rand(num_parameters) .+ (1 - Ir[2]))
            alpha[1] = rand(num_parameters)
            alpha[2] = 2 * rand(num_parameters)
            alpha[3] = Ir[1] .* rand(num_parameters) .+ 1
            alpha[4] = (Ir[2] .* rand(num_parameters) .+ (1 - Ir[2]))

            ii = rand(1:4, 1, 3)
            selected_alpha = alpha[ii]

            β_parameter_offsprings_array[seed, 1] = β_parameter_seeds_array[seed] + selected_alpha[1][1] * (I[1] * β_parameter_best - I[2] * β_parameter_mean_group)
            c_parameter_offsprings_array[seed, 1] = c_parameter_seeds_array[seed] + selected_alpha[1][2] * (I[1] * c_parameter_best - I[2] * c_parameter_mean_group)
            γ_parameter_offsprings_array[seed, 1] = γ_parameter_seeds_array[seed] + selected_alpha[1][3] * (I[1] * γ_parameter_best - I[2] * γ_parameter_mean_group)
            I0_parameter_offsprings_array[seed, 1] = I0_parameter_seeds_array[seed] + selected_alpha[1][4] * (I[1] * I0_parameter_best - I[2] * I0_parameter_mean_group)

            c1 = [β_parameter_offsprings_array[seed, 1], c_parameter_offsprings_array[seed, 1], γ_parameter_offsprings_array[seed, 1], I0_parameter_offsprings_array[seed, 1]]
            check_bounds(c1)

            β_parameter_offsprings_array[seed, 1] = c1[1]
            c_parameter_offsprings_array[seed, 1] = c1[2]
            γ_parameter_offsprings_array[seed, 1] = c1[3]
            I0_parameter_offsprings_array[seed, 1] = c1[4]

            # Reset
            for j in 1:length(agents)
                if j <= c1[4] # I0
                    agents[j] = Infected
                else
                    agents[j] = Susceptible
                end
            end
            error_offsprings_arr[seed, 1] = run_model(agents, nsteps, δt, c1[1], c1[2], c1[3])

            β_parameter_offsprings_array[seed, 2] = β_parameter_best + selected_alpha[2][1] * (I[3] * β_parameter_mean_group - I[4] * β_parameter_seeds_array[seed])
            c_parameter_offsprings_array[seed, 2] = c_parameter_best + selected_alpha[2][2] * (I[3] * c_parameter_mean_group - I[4] * c_parameter_seeds_array[seed])
            γ_parameter_offsprings_array[seed, 2] = γ_parameter_best + selected_alpha[2][3] * (I[3] * γ_parameter_mean_group - I[4] * γ_parameter_seeds_array[seed])
            I0_parameter_offsprings_array[seed, 2] = I0_parameter_best + selected_alpha[2][4] * (I[3] * I0_parameter_mean_group - I[4] * I0_parameter_seeds_array[seed])

            # β_parameter_offsprings_array[seed, 2] = β_parameter_best + selected_alpha[2][1] * (I[3] * β_parameter_seeds_array[seed] - I[4] * β_parameter_mean_group)
            # c_parameter_offsprings_array[seed, 2] = c_parameter_best + selected_alpha[2][2] * (I[3] * c_parameter_seeds_array[seed] - I[4] * c_parameter_mean_group)
            # γ_parameter_offsprings_array[seed, 2] = γ_parameter_best + selected_alpha[2][3] * (I[3] * γ_parameter_seeds_array[seed] - I[4] * γ_parameter_mean_group)
            # I0_parameter_offsprings_array[seed, 2] = I0_parameter_best + selected_alpha[2][4] * (I[3] * I0_parameter_seeds_array[seed] - I[4] * I0_parameter_mean_group)

            c2 = [β_parameter_offsprings_array[seed, 2], c_parameter_offsprings_array[seed, 2], γ_parameter_offsprings_array[seed, 2], I0_parameter_offsprings_array[seed, 2]]
            check_bounds(c2)

            β_parameter_offsprings_array[seed, 2] = c2[1]
            c_parameter_offsprings_array[seed, 2] = c2[2]
            γ_parameter_offsprings_array[seed, 2] = c2[3]
            I0_parameter_offsprings_array[seed, 2] = c2[4]

            # Reset
            for j in 1:length(agents)
                if j <= c2[4] # I0
                    agents[j] = Infected
                else
                    agents[j] = Susceptible
                end
            end
            error_offsprings_arr[seed, 2] = run_model(agents, nsteps, δt, c2[1], c2[2], c2[3])

            β_parameter_offsprings_array[seed, 3] = β_parameter_mean_group + selected_alpha[3][1] * (I[5] * β_parameter_best - I[6] * β_parameter_seeds_array[seed])
            c_parameter_offsprings_array[seed, 3] = c_parameter_mean_group + selected_alpha[3][2] * (I[5] * c_parameter_best - I[6] * c_parameter_seeds_array[seed])
            γ_parameter_offsprings_array[seed, 3] = γ_parameter_mean_group + selected_alpha[3][3] * (I[5] * γ_parameter_best - I[6] * γ_parameter_seeds_array[seed])
            I0_parameter_offsprings_array[seed, 3] = I0_parameter_mean_group + selected_alpha[3][4] * (I[5] * I0_parameter_best - I[6] * I0_parameter_seeds_array[seed])

            # β_parameter_offsprings_array[seed, 3] = β_parameter_mean_group + selected_alpha[3][1] * (I[5] * β_parameter_seeds_array[seed] - I[6] * β_parameter_best)
            # c_parameter_offsprings_array[seed, 3] = c_parameter_mean_group + selected_alpha[3][2] * (I[5] * c_parameter_seeds_array[seed] - I[6] * c_parameter_best)
            # γ_parameter_offsprings_array[seed, 3] = γ_parameter_mean_group + selected_alpha[3][3] * (I[5] * γ_parameter_seeds_array[seed] - I[6] * γ_parameter_best)
            # I0_parameter_offsprings_array[seed, 3] = I0_parameter_mean_group + selected_alpha[3][4] * (I[5] * I0_parameter_seeds_array[seed] - I[6] * I0_parameter_best)

            c3 = [β_parameter_offsprings_array[seed, 3], c_parameter_offsprings_array[seed, 3], γ_parameter_offsprings_array[seed, 3], I0_parameter_offsprings_array[seed, 3]]
            check_bounds(c3)

            β_parameter_offsprings_array[seed, 3] = c3[1]
            c_parameter_offsprings_array[seed, 3] = c3[2]
            γ_parameter_offsprings_array[seed, 3] = c3[3]
            I0_parameter_offsprings_array[seed, 3] = c3[4]

            # Reset
            for j in 1:length(agents)
                if j <= c3[4] # I0
                    agents[j] = Infected
                else
                    agents[j] = Susceptible
                end
            end
            error_offsprings_arr[seed, 3] = run_model(agents, nsteps, δt, c3[1], c3[2], c3[3])


            # if rand() < 1 / 4
            #     β_parameter_offsprings_array[seed, 4] = rand(Uniform(0.02, 0.2))
            # end
            # if rand() < 1 / 4
            #     c_parameter_offsprings_array[seed, 4] = rand(Uniform(5, 25))
            # end
            # if rand() < 1 / 4
            #     γ_parameter_offsprings_array[seed, 4] = rand(Uniform(0.01, 0.05))
            # end
            # if rand() < 1 / 4
            #     I0_parameter_offsprings_array[seed, 4] = rand(Uniform(1, 50))
            # end

            β_parameter_offsprings_array[seed, 4] = β_parameter_seeds_array[seed]
            c_parameter_offsprings_array[seed, 4] = c_parameter_seeds_array[seed]
            γ_parameter_offsprings_array[seed, 4] = γ_parameter_seeds_array[seed]
            I0_parameter_offsprings_array[seed, 4] = I0_parameter_seeds_array[seed]

            mutation_params = rand(1:4, rand(1:4))
            if 1 in mutation_params
                β_parameter_offsprings_array[seed, 4] = rand(Uniform(0.02, 0.2))
            end
            if 2 in mutation_params
                c_parameter_offsprings_array[seed, 4] = rand(Uniform(5, 25))
            end
            if 3 in mutation_params
                γ_parameter_offsprings_array[seed, 4] = rand(Uniform(0.01, 0.05))
            end
            if 4 in mutation_params
                I0_parameter_offsprings_array[seed, 4] = rand(Uniform(1, 50))
            end

            # Reset
            for j in 1:length(agents)
                if j <= I0_parameter_offsprings_array[seed, 4] # I0
                    agents[j] = Infected
                else
                    agents[j] = Susceptible
                end
            end
            error_offsprings_arr[seed, 4] = run_model(agents, nsteps, δt, β_parameter_offsprings_array[seed, 4], c_parameter_offsprings_array[seed, 4], γ_parameter_offsprings_array[seed, 4])
        end

        args = [a[1] for a in arg_n_smallest_values(vcat(error_seeds_arr, error_offsprings_arr[:, 1], error_offsprings_arr[:, 2], error_offsprings_arr[:, 3], error_offsprings_arr[:, 4]), seeds_size)]

        β_parameter_concatenated = vcat(β_parameter_seeds_array, β_parameter_offsprings_array[:, 1], β_parameter_offsprings_array[:, 2], β_parameter_offsprings_array[:, 3], β_parameter_offsprings_array[:, 4])
        c_parameter_concatenated = vcat(c_parameter_seeds_array, c_parameter_offsprings_array[:, 1], c_parameter_offsprings_array[:, 2], c_parameter_offsprings_array[:, 3], c_parameter_offsprings_array[:, 4])
        γ_parameter_concatenated = vcat(γ_parameter_seeds_array, γ_parameter_offsprings_array[:, 1], γ_parameter_offsprings_array[:, 2], γ_parameter_offsprings_array[:, 3], γ_parameter_offsprings_array[:, 4])
        I0_parameter_concatenated = vcat(I0_parameter_seeds_array, I0_parameter_offsprings_array[:, 1], I0_parameter_offsprings_array[:, 2], I0_parameter_offsprings_array[:, 3], I0_parameter_offsprings_array[:, 4])
        error_seeds_concatenated = vcat(error_seeds_arr, error_offsprings_arr[:, 1], error_offsprings_arr[:, 2], error_offsprings_arr[:, 3], error_offsprings_arr[:, 4])

        println("Run = $(curr_run)")
        for i = 1:seeds_size
            β_parameter_seeds_array[i] = β_parameter_concatenated[args[i]]
            c_parameter_seeds_array[i] = c_parameter_concatenated[args[i]]
            γ_parameter_seeds_array[i] = γ_parameter_concatenated[args[i]]
            I0_parameter_seeds_array[i] = I0_parameter_concatenated[args[i]]
            error_seeds_arr[i] = error_seeds_concatenated[args[i]]

            if error_seeds_arr[i] < best_error
                β_parameter_best = β_parameter_seeds_array[i]
                c_parameter_best = c_parameter_seeds_array[i]
                γ_parameter_best = γ_parameter_seeds_array[i]
                I0_parameter_best = I0_parameter_seeds_array[i]
                best_error = error_seeds_arr[i]
            end

            println("Seed = $(i): $(error_seeds_arr[i])")

            save(joinpath(@__DIR__, "cgo$(method_num)", "$(curr_run)", "results_$(i).jld"),
                "error", error_seeds_arr[i],
                "β_parameter", β_parameter_seeds_array[i],
                "c_parameter", c_parameter_seeds_array[i],
                "γ_parameter", γ_parameter_seeds_array[i],
                "I0_parameter", I0_parameter_seeds_array[i],
            )
        end
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
    # [1, 50]
    # β = 0.05 
    # c = 10.0
    # γ = 0.02

    # p = [β, c, γ, δt]

    # Начальные условия
    N = 100000
    # I0 = 10
    agents_initial = Array{InfectionStatus}(undef, N)

    for i in 1:N
        if i <= 25
            s = Infected
        else
            s = Susceptible
        end
        agents_initial[i] = s
    end
    run_model(agents_initial, nsteps, δt, 0.05, 10.0, 0.02)
    return

    # for i in 1:N
    #     if i <= 19.143075017374898
    #         s = Infected
    #     else
    #         s = Susceptible
    #     end
    #     agents_initial[i] = s
    # end
    # println(run_model(agents_initial, nsteps, δt, 0.04435752824364243, 20.727694942223863, 0.04445284459329697))
    # return


    # run_model_plot(agents_initial, nsteps, δt)

    # for i in 1:N
    #     if i <= 20
    #         s = Infected
    #     else
    #         s = Susceptible
    #     end
    #     agents_initial[i] = s
    # end
    # run_model(agents_initial, nsteps, δt, 0.1, 18.0, 0.035)

    # lhs_simulations(100,agents_initial,nsteps,δt)
    # 10 sec
    # @time lhs_simulations(10, agents_initial, nsteps, δt, 10)
    # lhs_simulations_series(10, agents_initial, nsteps, δt, 10)

    # @time mcmc_simulations(200, agents_initial, nsteps, δt, 10)
    # @time mcmc_simulations_lhs(200, agents_initial, nsteps, δt, 1)
    # @time run_surrogate_model(200, agents_initial, nsteps, δt, 9)
    # @time run_swarm_model(20, agents_initial, nsteps, δt, 1)
    # @time genetic_algorithm(20, agents_initial, nsteps, δt, 1)
    # @time run_cgo_model(5, agents_initial, nsteps, δt, 1)


    # mcmc_simulations_metropolis(250,agents_initial,nsteps,δt)
    # mcmc_simulations_metropolis_lhs(250,agents_initial,nsteps,δt)
    # run_surrogate_model_NN(100,agents_initial,nsteps,δt)
end

main()
