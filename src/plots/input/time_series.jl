using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using LaTeXStrings
using CategoricalArrays
using Interpolations

include("../../data/temperature.jl")
include("../../data/etiology.jl")
include("../../util/moving_avg.jl")

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false

function plot_temperature()
    temperature_data = get_air_temperature()
    temperature_data_rearranged = Float64[]
    append!(temperature_data_rearranged, temperature_data[213:end])
    append!(temperature_data_rearranged, temperature_data[1:212])

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end

    label_names = ["base" "warming"]
    if is_russian
        label_names = ["базовый" "потепление"]
    end

    xlabel_name = "Month"
    if is_russian
        xlabel_name = "Месяц"
    end

    ylabel_name = "Temperature, °C"
    if is_russian
        ylabel_name = "Температура, °C"
    end

    temperature_plot = plot(
        1:365,
        [temperature_data_rearranged temperature_data_rearranged .+ 2.0],
        lw = 1.5,
        label = label_names,
        color = [RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2)],
        xticks = (ticks, ticklabels),
        grid = true,
        legend = (0.51, 0.91),
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Temperature, °C}",
        xlabel = xlabel_name,
        ylabel = ylabel_name,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
    )
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "temperature.pdf"))
end

function plot_all_data()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Float64, '\n')
    incidence_data = vec(incidence_data[5:45, 2:53])
    # incidence_data = vec(incidence_data[33:45, 2:53])

    years = collect(1962:2002)
    # years = collect(1990:2002)
    xs = [1959, 1970, 1979, 1989, 2002]
    ys = [5085, 7061, 7931, 8875, 10382]
    itp_cubic = interpolate(xs, ys, FritschCarlsonMonotonicInterpolation())
    mean_values = zeros(Float64, 41)
    for i in 1:length(years)
        mean_value = 0.0
        for j = 1:52
            incidence_data[(i - 1) * 52 + j] = incidence_data[(i - 1) * 52 + j] / itp_cubic(years[i])
            mean_value += incidence_data[(i - 1) * 52 + j]
        end
        mean_values[i] = mean_value / 52
    end

    itp_cubic = interpolate([i * 52 for i = 1:41], mean_values, FritschCarlsonMonotonicInterpolation())

    ticks = range(52, stop = length(incidence_data), length = 11)
    ticklabels = ["1962" "1966" "1970" "1974" "1978" "1982" "1986" "1990" "1994" "1998" "2002"]
    # ticks = range(1, stop = length(incidence_data), length = 7)
    # ticklabels = ["1990" "1992" "1994" "1996" "1998" "2000" "2002"]
    mean_incidence_plot = plot(
        52:2132,
        x -> itp_cubic(x),
        lw = 1,
        legend = false,
        # color = RGB(0.933, 0.4, 0.467),
        color = :black,
        xticks = (ticks, ticklabels),
        grid = true,
        size = (800, 500),
        margin = 6Plots.mm,
        xrotation = 45,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Num of cases per 1000 people}",
        xlabel = "Год",
        ylabel = "Число случаев на 1000 чел. / неделя",
    )
    savefig(mean_incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "mean_all_data.pdf"))

    ticks = range(1, stop = length(incidence_data), length = 11)
    ticklabels = ["1962" "1966" "1970" "1974" "1978" "1982" "1986" "1990" "1994" "1998" "2002"]
    # ticks = range(1, stop = length(incidence_data), length = 7)
    # ticklabels = ["1990" "1992" "1994" "1996" "1998" "2000" "2002"]
    incidence_plot = plot(
        1:length(incidence_data),
        incidence_data,
        lw = 1,
        legend = false,
        # color = RGB(0.933, 0.4, 0.467),
        color = :black,
        xticks = (ticks, ticklabels),
        grid = true,
        size = (800, 500),
        margin = 6Plots.mm,
        xrotation = 45,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Num of cases per 1000 people}",
        xlabel = "Год",
        ylabel = "Число случаев на 1000 чел. / неделя",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "all_data.pdf"))
end

function plot_incidence()
    incidence_data = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu.csv"), ',', Int, '\n')
    incidence_data_mean = mean(incidence_data[39:45, 2:53], dims = 1)[1, :] ./ 10072

    println(incidence_data_mean)

    stds = zeros(Float64, 52)
    for i = 1:52
        stds[i] = std(incidence_data[39:45, i] ./ 10072)
    end

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    incidence_plot = plot(
        1:52,
        incidence_data_mean,
        lw = 1,
        legend = false,
        color = "red",
        xticks = (ticks, ticklabels),
        grid = true,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Num of cases per 1000 people}",
        yerror = stds,
        ribbon = stds,
        fillalpha = .5,
        xlabel = "Месяц",
        ylabel = "Число случаев на 1000 ч.",
    )
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence.pdf"))
end

function plot_incidence_age_groups()
    incidence_data_0 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu0-2.csv"), ',', Int, '\n')
    incidence_data_3 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu3-6.csv"), ',', Int, '\n')
    incidence_data_7 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu7-14.csv"), ',', Int, '\n')
    incidence_data_15 = readdlm(joinpath(@__DIR__, "..", "..", "..", "input", "tables", "flu15+.csv"), ',', Int, '\n')

    incidence_data_mean_0 = mean(incidence_data_0[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_3 = mean(incidence_data_3[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_7 = mean(incidence_data_7[2:53, 21:27], dims = 2)[:, 1] ./ 10072
    incidence_data_mean_15 = mean(incidence_data_15[2:53, 21:27], dims = 2)[:, 1] ./ 10072

    incidence_plot = plot(1:52, incidence_data_mean_0, title = "Incidence", lw = 1, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence0-2.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_3, title = "Incidence", lw = 1, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence3-6.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_7, title = "Incidence", lw = 1, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence7-14.pdf"))

    incidence_plot = plot(1:52, incidence_data_mean_15, title = "Incidence", lw = 1, legend = false)
    xlabel!("Week")
    ylabel!("Incidence")
    savefig(incidence_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "incidence15+.pdf"))
end

function plot_Flu()
    FluA_arr = [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 50, 60, 75, 310, 1675, 1850, 1500, 1250, 900, 375, 350, 290, 220, 175, 165, 100, 50, 40, 25, 15, 9, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0]
    FluA_arr2 = [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 15, 44, 72, 50, 10, 80, 266, 333, 480, 588, 625, 575, 622, 423, 450, 269, 190, 138, 89, 60, 30, 20, 12, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    # FluA_arr3 = [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 44, 90, 140, 239, 300, 400, 40, 10, 10, 50, 50, 70, 150, 170, 200, 170, 280, 250, 150, 145, 140, 135, 174, 50, 60, 30, 8, 0, 0, 0, 0, 0, 0, 0]

    FluA_arr = (FluA_arr + FluA_arr2) ./ 2
    # FluA_arr = (FluA_arr + FluA_arr2 + FluA_arr3) ./ 3
    FluA_arr = moving_average(FluA_arr, 3)

    FluB_arr = FluA_arr .* 1/3

    FluA_plot = plot(
        1:52,
        FluA_arr,
        lw = 1,
        legend = false,
        color = "orange",
        grid = true,
        xlabel = "Месяц",
        ylabel = "Случаи",
    )
    savefig(FluA_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "FluA_plot.pdf"))

    FluB_plot = plot(
        1:52,
        FluB_arr,
        lw = 1,
        legend = false,
        color = "orange",
        grid = true,
        xlabel = "Месяц",
        ylabel = "Случаи",
    )
    savefig(FluB_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "FluB_plot.pdf"))
end

function plot_RV()
    arr = [50.0, 50, 86, 90, 70, 74, 97, 115, 158, 130, 131, 103, 112, 112, 136, 90, 111, 128, 130, 140, 118, 152, 49, 22, 51, 80, 82, 100, 78, 57, 70, 73, 102, 101, 80, 62, 68, 60, 66, 52, 42, 69, 74, 38, 50, 42, 36, 38, 24, 44, 45, 40]
    arr2 = [11.0, 10, 20, 24, 10, 20, 41, 42, 43, 54, 42, 52, 39, 37, 20, 15, 20, 38, 41, 28, 30, 21, 9, 1, 10, 50, 62, 52, 31, 40, 36, 41, 42, 32, 84, 71, 78, 72, 32, 28, 39, 37, 72, 67, 41, 52, 40, 24, 40, 39, 36, 30]
    
    arr = (arr + arr2) ./ 2
    arr = moving_average(arr, 3)

    RV_plot = plot(
        1:52,
        arr,
        lw = 1,
        legend = false,
        color = "orange",
        grid = true,
        xlabel = "Месяц",
        ylabel = "Случаи",
    )
    savefig(RV_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "RV_plot.pdf"))
end

function plot_RSV()
    arr = [8.0, 8, 8, 8, 8, 5, 7, 8, 11, 11, 18, 14, 15, 18, 35, 55, 53, 70, 90, 130, 45, 30, 80, 140, 100, 120, 145, 180, 150, 68, 72, 60, 80, 75, 55, 60, 65, 62, 50, 45, 50, 20, 24, 19, 15, 10, 10, 9, 11, 10, 9, 8]
    arr2 = [8.0, 9, 9, 4, 4, 10, 9, 10, 3, 12, 8, 10, 12, 7, 10, 13, 9, 15, 21, 25, 30, 10, 2, 22, 18, 30, 77, 72, 48, 61, 90, 120, 150, 145, 92, 119, 78, 69, 49, 57, 49, 43, 46, 24, 40, 24, 24, 10, 10, 9, 7, 11]
    
    arr = (arr + arr2) ./ 2
    arr = moving_average(arr, 3)

    RSV_plot = plot(
        1:52,
        arr,
        lw = 1,
        legend = false,
        color = "orange",
        grid = true,
        xlabel = "Месяц",
        ylabel = "Случаи",
    )
    savefig(RSV_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "RSV_plot.pdf"))
end

function plot_AdV()
    arr = [20.0, 30, 40, 20, 30, 25, 15, 19, 17, 18, 20, 25, 30, 21, 38, 40, 42, 30, 40, 50, 51, 41, 10, 8, 30, 40, 38, 70, 67, 20, 28, 20, 29, 20, 28, 16, 10, 20, 18, 27, 19, 19, 32, 31, 20, 20, 15, 8, 20, 35, 35, 35]
    arr2 = [9.0, 11, 13, 5, 7, 12, 12, 18, 16, 22, 18, 22, 31, 32, 33, 17, 28, 39, 29, 40, 30, 56, 11, 1, 38, 30, 39, 28, 59, 19, 46, 20, 22, 47, 38, 40, 25, 17, 18, 10, 6, 6, 21, 11, 19, 12, 27, 18, 10, 27, 10, 10]
    
    arr = (arr + arr2) ./ 2
    arr = moving_average(arr, 3)

    AdV_plot = plot(
        1:52,
        arr,
        lw = 1,
        legend = false,
        color = "orange",
        grid = true,
        xlabel = "Месяц",
        ylabel = "Случаи",
    )
    savefig(AdV_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "AdV_plot.pdf"))
end

function plot_PIV()
    arr = [15.0, 18, 20, 33, 15, 36, 33, 38, 38, 50, 40, 43, 46, 75, 55, 35, 85, 53, 65, 40, 70, 20, 10, 45, 32, 33, 51, 34, 22, 12, 12, 14, 16, 18, 20, 8, 24, 20, 15, 5, 20, 15, 15, 20, 19, 18, 31, 18, 18, 17, 15, 14]
    arr2 = [10.0, 11, 6, 8, 12, 19, 22, 20, 20, 22, 28, 32, 47, 29, 31, 38, 17, 40, 31, 36, 32, 48, 11, 6, 30, 38, 12, 30, 22, 12, 20, 17, 30, 45, 11, 14, 17, 15, 15, 10, 15, 20, 17, 18, 23, 10, 10, 18, 17, 16, 17, 14]
    
    arr = (arr + arr2) ./ 2
    arr = moving_average(arr, 3)

    PIV_plot = plot(
        1:52,
        arr,
        lw = 1,
        legend = false,
        color = "orange",
        grid = true,
        xlabel = "Месяц",
        ylabel = "Случаи",
    )
    savefig(PIV_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "PIV_plot.pdf"))
end

function plot_CoV()
    arr = [1.0, 2, 1, 2, 1, 1, 2, 1, 2, 1, 1, 2, 8, 10, 5, 7, 7, 14, 8, 25, 35, 30, 1, 5, 16, 14, 25, 35, 32, 50, 10, 18, 12, 30, 36, 25, 14, 16, 5, 3, 1, 3, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    arr2 = [5.0, 1, 1, 2, 1, 1, 6, 1, 3, 1, 1, 5, 9, 1, 5, 1, 1, 5, 1, 3, 2, 1, 5, 1, 3, 1, 1, 9, 5, 5, 9, 3, 4, 3, 12, 18, 16, 15, 7, 1, 13, 3, 3, 10, 2, 1, 1, 1, 1, 1, 1, 1]
    
    arr = (arr + arr2) ./ 2
    arr = moving_average(arr, 3)

    CoV_plot = plot(
        1:52,
        arr,
        lw = 1,
        legend = false,
        color = "orange",
        grid = true,
        xlabel = "Месяц",
        ylabel = "Случаи",
    )
    savefig(CoV_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "CoV_plot.pdf"))
end

function plot_etiology()
    FluA_arr = [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 50, 60, 75, 310, 1675, 1850, 1500, 1250, 900, 375, 350, 290, 220, 175, 165, 100, 50, 40, 25, 15, 9, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0]
    FluA_arr2 = [0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 15, 44, 72, 50, 10, 80, 266, 333, 480, 588, 625, 575, 622, 423, 450, 269, 190, 138, 89, 60, 30, 20, 12, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    FluA_arr = (FluA_arr + FluA_arr2) ./ 2

    RV_arr = [50.0, 50, 86, 90, 70, 74, 97, 115, 158, 130, 131, 103, 112, 112, 136, 90, 111, 128, 130, 140, 118, 152, 49, 22, 51, 80, 82, 100, 78, 57, 70, 73, 102, 101, 80, 62, 68, 60, 66, 52, 42, 69, 74, 38, 50, 42, 36, 38, 24, 44, 45, 40]
    RV_arr2 = [11.0, 10, 20, 24, 10, 20, 41, 42, 43, 54, 42, 52, 39, 37, 20, 15, 20, 38, 41, 28, 30, 21, 9, 1, 10, 50, 62, 52, 31, 40, 36, 41, 42, 32, 84, 71, 78, 72, 32, 28, 39, 37, 72, 67, 41, 52, 40, 24, 40, 39, 36, 30]
    RV_arr = (RV_arr + RV_arr2) ./ 2
    
    RSV_arr = [8.0, 8, 8, 8, 8, 5, 7, 8, 11, 11, 18, 14, 15, 18, 35, 55, 53, 70, 90, 130, 45, 30, 80, 140, 100, 120, 145, 180, 150, 68, 72, 60, 80, 75, 55, 60, 65, 62, 50, 45, 50, 20, 24, 19, 15, 10, 10, 9, 11, 10, 9, 8]
    RSV_arr2 = [8.0, 9, 9, 4, 4, 10, 9, 10, 3, 12, 8, 10, 12, 7, 10, 13, 9, 15, 21, 25, 30, 10, 2, 22, 18, 30, 77, 72, 48, 61, 90, 120, 150, 145, 92, 119, 78, 69, 49, 57, 49, 43, 46, 24, 40, 24, 24, 10, 10, 9, 7, 11]
    RSV_arr = (RSV_arr + RSV_arr2) ./ 2

    AdV_arr = [20.0, 30, 40, 20, 30, 25, 15, 19, 17, 18, 20, 25, 30, 21, 38, 40, 42, 30, 40, 50, 51, 41, 10, 8, 30, 40, 38, 70, 67, 20, 28, 20, 29, 20, 28, 16, 10, 20, 18, 27, 19, 19, 32, 31, 20, 20, 15, 8, 20, 35, 35, 35]
    AdV_arr2 = [9.0, 11, 13, 5, 7, 12, 12, 18, 16, 22, 18, 22, 31, 32, 33, 17, 28, 39, 29, 40, 30, 56, 11, 1, 38, 30, 39, 28, 59, 19, 46, 20, 22, 47, 38, 40, 25, 17, 18, 10, 6, 6, 21, 11, 19, 12, 27, 18, 10, 27, 10, 10]
    AdV_arr = (AdV_arr + AdV_arr2) ./ 2

    PIV_arr = [15.0, 18, 20, 33, 15, 36, 33, 38, 38, 50, 40, 43, 46, 75, 55, 35, 85, 53, 65, 40, 70, 20, 10, 45, 32, 33, 51, 34, 22, 12, 12, 14, 16, 18, 20, 8, 24, 20, 15, 5, 20, 15, 15, 20, 19, 18, 31, 18, 18, 17, 15, 14]
    PIV_arr2 = [10.0, 11, 6, 8, 12, 19, 22, 20, 20, 22, 28, 32, 47, 29, 31, 38, 17, 40, 31, 36, 32, 48, 11, 6, 30, 38, 12, 30, 22, 12, 20, 17, 30, 45, 11, 14, 17, 15, 15, 10, 15, 20, 17, 18, 23, 10, 10, 18, 17, 16, 17, 14]
    PIV_arr = (PIV_arr + PIV_arr2) ./ 2

    CoV_arr = [1.0, 2, 1, 2, 1, 1, 2, 1, 2, 1, 1, 2, 8, 10, 5, 7, 7, 14, 8, 25, 35, 30, 1, 5, 16, 14, 25, 35, 32, 50, 10, 18, 12, 30, 36, 25, 14, 16, 5, 3, 1, 3, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    CoV_arr2 = [5.0, 1, 1, 2, 1, 1, 6, 1, 3, 1, 1, 5, 9, 1, 5, 1, 1, 5, 1, 3, 2, 1, 5, 1, 3, 1, 1, 9, 5, 5, 9, 3, 4, 3, 12, 18, 16, 15, 7, 1, 13, 3, 3, 10, 2, 1, 1, 1, 1, 1, 1, 1]
    CoV_arr = (CoV_arr + CoV_arr2) ./ 2

    FluA_arr = moving_average(FluA_arr, 3)
    RV_arr = moving_average(RV_arr, 3)
    RSV_arr = moving_average(RSV_arr, 3)
    AdV_arr = moving_average(AdV_arr, 3)
    PIV_arr = moving_average(PIV_arr, 3)
    CoV_arr = moving_average(CoV_arr, 3)

    FluB_arr = FluA_arr .* 1/3

    sum_arr = FluA_arr + FluB_arr + RV_arr + RSV_arr + AdV_arr + PIV_arr + CoV_arr

    FluA_ratio = FluA_arr ./ sum_arr
    FluB_ratio = FluB_arr ./ sum_arr
    RV_ratio = RV_arr ./ sum_arr
    RSV_ratio = RSV_arr ./ sum_arr
    AdV_ratio = AdV_arr ./ sum_arr
    PIV_ratio = PIV_arr ./ sum_arr
    CoV_ratio = CoV_arr ./ sum_arr

    FluA_ratio = moving_average(FluA_ratio, 3)
    FluB_ratio = moving_average(FluB_ratio, 3)
    RV_ratio = moving_average(RV_ratio, 3)
    RSV_ratio = moving_average(RSV_ratio, 3)
    AdV_ratio = moving_average(AdV_ratio, 3)
    PIV_ratio = moving_average(PIV_ratio, 3)
    CoV_ratio = moving_average(CoV_ratio, 3)

    ticks = range(1, stop = 52, length = 7)
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    etiology_plot = plot(
        1:52,
        [FluA_ratio, FluB_ratio, RV_ratio, RSV_ratio, AdV_ratio, PIV_ratio, CoV_ratio],
        legend = (0.85, 0.97),
        lw = 1,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        xticks = (ticks, ticklabels),
        grid = true,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Ratio}",
        xlabel = "Месяц",
        ylabel = "Доля",
    )
    savefig(etiology_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "time_series", "etiology.pdf"))
end

# plot_Flu()
# plot_RV()
# plot_RSV()
# plot_AdV()
# plot_PIV()
# plot_CoV()
# plot_etiology()

plot_temperature()
# plot_all_data()
# plot_incidence()
# plot_incidence_age_groups()
# plot_etiology()
