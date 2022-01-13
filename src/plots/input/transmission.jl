using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings

include("../../data/temperature.jl")
include("../../model/virus.jl")
include("../../global/variables.jl")

default(legendfontsize = 12, guidefont = (17, :black), tickfont = (12, :black))

function plot_duration_influence()
    duration_parameter_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "duration_parameter_array.csv"), ',', Float64, '\n'))
    duration_parameter = mean(duration_parameter_array[burnin:step:length(duration_parameter_array)])
    duration_parameter = 3.312914862914865

    duration_influence(x) = 1 / (1 + exp(-x + duration_parameter))

    duration_range = range(0, stop=24, length=100)
    duration_plot = plot(
        duration_range,
        duration_influence.(duration_range),
        lw = 3,
        legend = false,
        color = "green",
        grid = false,
        # xlabel = L"\textrm{\sffamily Hours}",
        # ylabel = L"\textrm{\sffamily Contact duration influence (} D_{ijc}\textrm{\sffamily )}",
        xlabel = "Продолжительность, ч.",
        ylabel = L"D_{ijc}",
    )
    savefig(duration_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "duration_influence.pdf"))
end

# function plot_temperature_influence()
#     temperature_parameters = Float64[-0.8, -0.8, -0.05, -0.64, -0.2, -0.05, -0.8]
#     temp_influence(x, v) = temperature_parameters[v] * x + 1.0

#     temperature_range = range(0, stop=1, length=100)
#     temperature_plot = plot(
#         temperature_range,
#         [temp_influence.(temperature_range, i) for i = 1:7],
#         title = "Temperature influence",
#         lw = 3,
#         label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
#     xlabel!("Temperature")
#     ylabel!("Influence")
#     savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "temperature_influence.pdf"))
# end

function plot_temperature_influence_year()
    temperature_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "temperature_parameter_1_array.csv"), ',', Float64, '\n'))
    temperature_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "temperature_parameter_2_array.csv"), ',', Float64, '\n'))
    temperature_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "temperature_parameter_3_array.csv"), ',', Float64, '\n'))
    temperature_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "temperature_parameter_4_array.csv"), ',', Float64, '\n'))
    temperature_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "temperature_parameter_5_array.csv"), ',', Float64, '\n'))
    temperature_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "temperature_parameter_6_array.csv"), ',', Float64, '\n'))
    temperature_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "temperature_parameter_7_array.csv"), ',', Float64, '\n'))
 
    temperature_parameter_1_array = temperature_parameter_1_array[burnin:step:length(temperature_parameter_1_array)]
    temperature_parameter_2_array = temperature_parameter_2_array[burnin:step:length(temperature_parameter_2_array)]
    temperature_parameter_3_array = temperature_parameter_3_array[burnin:step:length(temperature_parameter_3_array)]
    temperature_parameter_4_array = temperature_parameter_4_array[burnin:step:length(temperature_parameter_4_array)]
    temperature_parameter_5_array = temperature_parameter_5_array[burnin:step:length(temperature_parameter_5_array)]
    temperature_parameter_6_array = temperature_parameter_6_array[burnin:step:length(temperature_parameter_6_array)]
    temperature_parameter_7_array = temperature_parameter_7_array[burnin:step:length(temperature_parameter_7_array)]

    temperature_parameters = -[
        mean(temperature_parameter_1_array),
        mean(temperature_parameter_2_array),
        mean(temperature_parameter_3_array),
        mean(temperature_parameter_4_array),
        mean(temperature_parameter_5_array),
        mean(temperature_parameter_6_array),
        mean(temperature_parameter_7_array)]

    temperature_parameters = [-0.9417996289424861, -0.6979200164914452, -0.1484436198721913, -0.2512430426716142, -0.14223871366728508, -0.14423830138115853, -0.6479158936301795]
    temp_influence(x, v) = temperature_parameters[v] * x + 1.0

    temperature = get_air_temperature()
    min_temp = minimum(temperature)
    max_min_temp = maximum(temperature) - minimum(temperature)
    temp_influences = Array{Float64,2}(undef, 7, 365)
    year_day = 213
    for s in 1:365
        current_temp = (temperature[year_day] - min_temp) / max_min_temp
        for v in 1:7
            temp_influences[v, s] = temperature_parameters[v] * current_temp + 1.0
        end
        if year_day == 365
            year_day = 1
        else
            year_day += 1
        end
    end

    # ticks = range(1, stop = 365, length = 13)
    # ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    ticks = range(1, stop = 365, length = 7)
    # ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    temperature_plot = plot(
        1:365,
        [temp_influences[i, :] for i = 1:7],
        xticks = (ticks, ticklabels),
        legend = (0.5, 0.5),
        lw = 3,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = false,
        # xlabel = L"\textrm{\sffamily Month}",
        # ylabel = L"\textrm{\sffamily Air temperature influence (} T_{mv}\textrm{\sffamily )}",
        xlabel = "Месяц",
        ylabel = L"T_{mv}",
    )
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "temperature_influence_year.pdf"))
end

# function plot_susceptibility_influence()
#     susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]
#     susceptibility_influence(x, v) = 2 / (1 + exp(susceptibility_parameters[v] * x))

#     susceptibility_range = range(0, stop=1, length=100)
#     susceptibility_plot = plot(
#         susceptibility_range,
#         [susceptibility_influence.(susceptibility_range, i) for i = 1:7],
#         title = "Susceptibility influence",
#         lw = 3,
#         label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
#     xlabel!("Ig level")
#     ylabel!("Influence")
#     savefig(susceptibility_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "susceptibility_influence.pdf"))
# end

function plot_susceptibility_influence_age()
    susceptibility_parameter_1_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "susceptibility_parameter_1_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_2_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "susceptibility_parameter_2_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_3_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "susceptibility_parameter_3_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_4_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "susceptibility_parameter_4_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_5_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "susceptibility_parameter_5_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_6_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "susceptibility_parameter_6_array.csv"), ',', Float64, '\n'))
    susceptibility_parameter_7_array = vec(readdlm(joinpath(@__DIR__, "..", "..", "..", "parameters", "tables", "susceptibility_parameter_7_array.csv"), ',', Float64, '\n'))

    susceptibility_parameter_1_array = susceptibility_parameter_1_array[burnin:step:length(susceptibility_parameter_1_array)]
    susceptibility_parameter_2_array = susceptibility_parameter_2_array[burnin:step:length(susceptibility_parameter_2_array)]
    susceptibility_parameter_3_array = susceptibility_parameter_3_array[burnin:step:length(susceptibility_parameter_3_array)]
    susceptibility_parameter_4_array = susceptibility_parameter_4_array[burnin:step:length(susceptibility_parameter_4_array)]
    susceptibility_parameter_5_array = susceptibility_parameter_5_array[burnin:step:length(susceptibility_parameter_5_array)]
    susceptibility_parameter_6_array = susceptibility_parameter_6_array[burnin:step:length(susceptibility_parameter_6_array)]
    susceptibility_parameter_7_array = susceptibility_parameter_7_array[burnin:step:length(susceptibility_parameter_7_array)]

    susceptibility_parameters = [
        mean(susceptibility_parameter_1_array),
        mean(susceptibility_parameter_2_array),
        mean(susceptibility_parameter_3_array),
        mean(susceptibility_parameter_4_array),
        mean(susceptibility_parameter_5_array),
        mean(susceptibility_parameter_6_array),
        mean(susceptibility_parameter_7_array)]

        susceptibility_parameters = [6.045066996495568, 5.970140177283035, 6.2762213976499694, 7.877563388991962, 7.463424036281181, 7.215854462997319, 7.164166151309008]
    susceptibility_influence(x, v) = 2 / (1 + exp(susceptibility_parameters[v] * x))

    ig_levels = [0.1505164955165073, 0.24272685839757013, 0.27446634642134227, 0.27335566991005594, 0.2735622560350999, 0.27338288255941956, 0.35102037547122344, 0.3506582993180788, 0.3501344468578805, 0.3843581109268843, 0.38512561297996545, 0.3841741589663935, 0.39680562463247615, 0.39678143520059356, 0.3963905886612963, 0.3963375288649048, 0.3965702682420548, 0.5090656587262238, 0.5090815491354699, 0.4645414640012885, 0.4644123788635453, 0.4645052320264773, 0.46437142322798197, 0.46404796055057324, 0.46404131051991415, 0.4642103769039795, 0.4644378565132235, 0.46431284676460083, 0.46420446317184094, 0.46417318616873177, 0.4641823756357343, 0.46431026812185305, 0.46428430374463076, 0.46419241271472667, 0.46442367046502736, 0.4641316362196958, 0.46375909790283526, 0.4639264468340825, 0.46374602109520874, 0.46389155709992, 0.4638894246832213, 0.4639072611334911, 0.4635306092460304, 0.46391631085834933, 0.46365848864301656, 0.46397048228918875, 0.46371709601587097, 0.4635952965866837, 0.46359555005295366, 0.4637930222367746, 0.4636360565700838, 0.46388701957152984, 0.46390561946497944, 0.46367085732813207, 0.4637113207404173, 0.463279562093781, 0.4631526289013043, 0.46311392536698287, 0.46362072192117104, 0.4634004652394673, 0.4633030057731725, 0.4251085457596629, 0.42579853946476415, 0.4253826719019012, 0.42499345597956945, 0.42718293068111934, 0.4260034329999044, 0.42633039649962223, 0.42622303029540065, 0.4263844159925822, 0.42651966706897754, 0.37526803040674195, 0.37532637246454903, 0.37551370107979276, 0.3762675778905722, 0.3724835780318056, 0.37297425583430915, 0.3727718999755025, 0.3737942833189381, 0.37366617813636965, 0.371607528787453, 0.37183632026679353, 0.3723822853489555, 0.37254019190309834, 0.3732338222929381, 0.36931013110281213, 0.36965447629422055, 0.37101932095070683, 0.3711536310341243, 0.36749595142533503]

    yticks = [0.0, 0.2, 0.4, 0.6]
    yticklabels = ["0.0", "0.2", "0.4", "0.6"]

    susceptibility_plot = plot(
        0:89,
        [susceptibility_influence.(ig_levels, i) for i = 1:7],
        legend=:top,
        lw = 3,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        yticks = (yticks, yticklabels),
        ylim=(0.0, 0.7),
        # xlabel = L"\textrm{\sffamily Age, years}",
        # ylabel = L"\textrm{\sffamily Agent susceptibility (} S_{jv}\textrm{\sffamily )}",
        xlabel = "Возраст, лет",
        ylabel = L"S_{jv}",
    )
    # susceptibility_plot = plot(
    #     0:89,
    #     [susceptibility_influence.(ig_levels, i) for i in [1, 2, 3, 4, 6, 7]],
    #     legend = (0.5, 0.9),
    #     lw = 3,
    #     color = [:red :royalblue :green4 :orange :grey30 :darkturquoise],
    #     label = ["FluA" "FluB" "RV" "RSV/AdV" "PIV" "CoV"],
    #     yticks = (yticks, yticklabels),
    #     ylim=(0.0, 0.7),
    #     grid = false,
    #     # xlabel = L"\textrm{\sffamily Age, years}",
    #     # ylabel = L"\textrm{\sffamily Agent susceptibility (} S_{jv}\textrm{\sffamily )}",
    #     xlabel = "Возраст, лет",
    #     ylabel = L"S_{jv}",
    # )
    savefig(susceptibility_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "susceptibility_influence.pdf"))
end

# function plot_infectivity_influence()
#     days_infected = collect(-4:10)
#     ticks = range(-4, stop = 10, length = 8)
#     ticklabels = ["-4" "-2" "0" "2" "4" "6" "8" "10"]
#     infectivity_plot = plot(
#         days_infected,
#         get_infectivity.(
#             days_infected,
#             5,
#             10,
#             6.0
#         ),
#         xticks = (ticks, ticklabels),
#         lw = 3,
#         color = "red",
#         legend = false)
#     xlabel!("Day")
#     ylabel!("Influence")
#     savefig(infectivity_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "infectivity_influence.pdf"))
# end

function plot_infectivity_influence()
    days_infected = collect(-4:10)
    ticks = range(-4, stop = 10, length = 8)
    ticklabels = ["-4" "-2" "0" "2" "4" "6" "8" "10"]
    infectivity_plot = plot(
        days_infected,
        [get_infectivity.(
            days_infected,
            5,
            10,
            i
        ) for i in [4.6, 4.7, 3.5, 6.0, 4.1, 4.8, 4.93]],
        xticks = (ticks, ticklabels),
        lw = 3,
        color = [:red :royalblue :green4 :darkorchid :orange :grey30 :darkturquoise],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = false,
        # xlabel = L"\textrm{\sffamily Day}",
        # ylabel = L"\textrm{\sffamily Agent infectivity (} I_{iv}\textrm{\sffamily )}",
        xlabel = "День",
        ylabel = L"I_{iv}",
    )
    savefig(infectivity_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "infectivity_influence.pdf"))
end

plot_duration_influence()
plot_temperature_influence_year()
plot_infectivity_influence()
plot_susceptibility_influence_age()