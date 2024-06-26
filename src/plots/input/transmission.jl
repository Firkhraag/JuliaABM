using Random
using DelimitedFiles
using Plots
using Statistics
using LaTeXStrings
using CSV
using DataFrames

include("../../../server/lib/model/virus.jl")
include("../../../server/lib/model/agent.jl")
include("../../../server/lib/global/variables.jl")

default(legendfontsize = 9, guidefont = (12, :black), tickfont = (11, :black))

const is_russian = false

function get_infectivity_transmission(
    days_infected::Int,
    incubation_period::Int,
    infection_period::Int,
    mean_viral_load::Float64,
    is_asymptomatic::Bool,
)::Float64
    if days_infected > incubation_period + infection_period
        return 0.0
    end
    if days_infected <= incubation_period
        if incubation_period == 1
            return mean_viral_load / 24
        end
        return mean_viral_load / 12 * (days_infected - 1) / (incubation_period - 1)
    else
        result = mean_viral_load / 6 * (days_infected - incubation_period - infection_period) / (1 - infection_period)
        if is_asymptomatic
            result /= 2
        end
        return result
    end
end

function plot_immunity_protection_influence()
    mean_immunity_durations = [359, 326, 128, 87, 110, 167, 154]

    ticks = range(1, stop = 360, length = 7)
    ticklabels = ["1" "60" "120" "180" "240" "300" "360"]

    xlabel_name = "Число дней после выздоровления"
    if !is_russian
        xlabel_name = "Days after the recovery"
    end
    ylabel_name = "Риск инфицирования"
    if !is_russian
        ylabel_name = L"R_{jv}"
    end

    arr = collect(1:365)

    yticks = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
    yticklabels = ["0.0", "0.2", "0.4", "0.6", "0.8", "1.0"]

    infectivity_plot = plot(
        1:365,
        [find_immunity_susceptibility_level.(arr, mean_immunity_durations[i]) for i = 1:num_viruses],
        xticks = (ticks, ticklabels),
        yticks = (yticks, yticklabels),
        lw = 1.5,
        margin = 6Plots.mm,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = true,
        legend = (0.9, 0.6),
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(infectivity_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "immunity_protection_influence.pdf"))
end

function plot_duration_influence()
    duration_parameter = 0.22637404671777045

    duration_influence(x) = 1 - exp(-duration_parameter * x)

    duration_range = range(0, stop=20, length=100)

    xlabel_name = "Продолжительность, часов"
    if !is_russian
        xlabel_name = "Contact duration, hours"
    end
    ylabel_name = "Риск инфицирования"
    if !is_russian
        ylabel_name = L"D_{ijc}"
    end

    duration_plot = plot(
        duration_range,
        duration_influence.(duration_range),
        lw = 1.5,
        legend = false,
        color = :black,
        grid = true,
        margin = 6Plots.mm,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(duration_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "duration_influence.pdf"))
end

function plot_temperature_influence()
    temperature_parameters = -[0.8846019152491571, 0.9313057237697472, 0.04837343942226003, 0.13610826071131651, 0.048281056835923, 0.07401637656561208, 0.36034078438752476]
    temp_influence(x, v) = temperature_parameters[v] * x + 1.0

    xlabel_name = "Нормализованная температура воздуха"
    if !is_russian
        xlabel_name = "Normalised air temperature"
    end
    ylabel_name = "Риск инфицирования"
    if !is_russian
        ylabel_name = L"T_{mv}"
    end

    temperature_range = range(0, stop=1, length=100)
    temperature_plot = plot(
        temperature_range,
        [temp_influence.(temperature_range, i) for i = 1:num_viruses],
        legend = (0.25, 0.55),
        lw = 1.5,
        margin = 6Plots.mm,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "temperature_influence.pdf"))
end

function plot_temperature_influence_year()
    temperature_parameters = -[0.8846019152491571, 0.9313057237697472, 0.04837343942226003, 0.13610826071131651, 0.048281056835923, 0.07401637656561208, 0.36034078438752476]
    temp_influence(x, v) = temperature_parameters[v] * x + 1.0

    temperature = Matrix(DataFrame(CSV.File("./input/tables/temperature.csv")))
    min_temp = -7.2
    max_min_temp = 26.6
    temp_influences = Array{Float64,2}(undef, 7, 365)
    year_day = 213
    for s in 1:365
        current_temp = (temperature[year_day] - min_temp) / max_min_temp
        for v in 1:num_viruses
            temp_influences[v, s] = temperature_parameters[v] * current_temp + 1.0
        end
        if year_day == 365
            year_day = 1
        else
            year_day += 1
        end
    end

    xlabel_name = "Месяц"
    if !is_russian
        xlabel_name = "Month"
    end
    ylabel_name = "Риск инфицирования"
    if !is_russian
        ylabel_name = L"T_{mv}"
    end

    ticks = range(1, stop = 365, length = 7)
    ticklabels = ["Aug" "Oct" "Dec" "Feb" "Apr" "Jun" "Aug"]
    if is_russian
        ticklabels = ["Авг" "Окт" "Дек" "Фев" "Апр" "Июн" "Авг"]
    end
    temperature_plot = plot(
        1:365,
        [temp_influences[i, :] for i = 1:num_viruses],
        xticks = (ticks, ticklabels),
        legend = (0.5, 0.7),
        lw = 1.5,
        margin = 6Plots.mm,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "temperature_influence_year.pdf"))
end

function plot_susceptibility_influence()
    susceptibility_parameters = [1.2452892952748845, 2.6338584916461577, 3.637956522922598, 2.925098036049022, 3.90751547248489, 2.7088533023807607, 4.379802012664986]
    susceptibility_influence(x, v) = 2 / (1 + exp(susceptibility_parameters[v] * x))

    xlabel_name = "Нормализованный уровень иммуноглобулинов"
    if !is_russian
        xlabel_name = "Normalised total Ig level"
    end
    ylabel_name = "Риск инфицирования"
    if !is_russian
        ylabel_name = L"S_{jv}"
    end

    susceptibility_range = range(0, stop=1, length=100)
    susceptibility_plot = plot(
        susceptibility_range,
        [susceptibility_influence.(susceptibility_range, i) for i = 1:num_viruses],
        lw = 1.5,
        legend = (0.92, 0.95),
        margin = 4Plots.mm,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(susceptibility_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "susceptibility_influence.pdf"))
end

function plot_susceptibility_influence_age()
    susceptibility_parameters = [1.2452892952748845, 2.6338584916461577, 3.637956522922598, 2.925098036049022, 3.90751547248489, 2.7088533023807607, 4.379802012664986]
    susceptibility_influence(x, v) = 2 / (1 + exp(susceptibility_parameters[v] * x))

    ig_levels = [0.1505164955165073, 0.24272685839757013, 0.27446634642134227, 0.27335566991005594, 0.2735622560350999, 0.27338288255941956, 0.35102037547122344, 0.3506582993180788, 0.3501344468578805, 0.3843581109268843, 0.38512561297996545, 0.3841741589663935, 0.39680562463247615, 0.39678143520059356, 0.3963905886612963, 0.3963375288649048, 0.3965702682420548, 0.5090656587262238, 0.5090815491354699, 0.4645414640012885, 0.4644123788635453, 0.4645052320264773, 0.46437142322798197, 0.46404796055057324, 0.46404131051991415, 0.4642103769039795, 0.4644378565132235, 0.46431284676460083, 0.46420446317184094, 0.46417318616873177, 0.4641823756357343, 0.46431026812185305, 0.46428430374463076, 0.46419241271472667, 0.46442367046502736, 0.4641316362196958, 0.46375909790283526, 0.4639264468340825, 0.46374602109520874, 0.46389155709992, 0.4638894246832213, 0.4639072611334911, 0.4635306092460304, 0.46391631085834933, 0.46365848864301656, 0.46397048228918875, 0.46371709601587097, 0.4635952965866837, 0.46359555005295366, 0.4637930222367746, 0.4636360565700838, 0.46388701957152984, 0.46390561946497944, 0.46367085732813207, 0.4637113207404173, 0.463279562093781, 0.4631526289013043, 0.46311392536698287, 0.46362072192117104, 0.4634004652394673, 0.4633030057731725, 0.4251085457596629, 0.42579853946476415, 0.4253826719019012, 0.42499345597956945, 0.42718293068111934, 0.4260034329999044, 0.42633039649962223, 0.42622303029540065, 0.4263844159925822, 0.42651966706897754, 0.37526803040674195, 0.37532637246454903, 0.37551370107979276, 0.3762675778905722, 0.3724835780318056, 0.37297425583430915, 0.3727718999755025, 0.3737942833189381, 0.37366617813636965, 0.371607528787453, 0.37183632026679353, 0.3723822853489555, 0.37254019190309834, 0.3732338222929381, 0.36931013110281213, 0.36965447629422055, 0.37101932095070683, 0.3711536310341243, 0.36749595142533503]

    yticks = [0.0, 0.2, 0.4, 0.6]
    yticklabels = ["0.0", "0.2", "0.4", "0.6"]

    xlabel_name = "Возраст, лет"
    if !is_russian
        xlabel_name = "Agent's age, years"
    end
    ylabel_name = "Риск инфицирования"
    if !is_russian
        ylabel_name = L"S_{jv}"
    end

    susceptibility_plot = plot(
        0:89,
        [susceptibility_influence.(ig_levels, i) for i = 1:num_viruses],
        lw = 1.5,
        legend = (0.92, 1.02),
        margin = 5Plots.mm,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        yticks = (yticks, yticklabels),
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        ylim = (0.0, 0.7),
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(susceptibility_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "susceptibility_influence_age.pdf"))
end

function plot_infectivity_influence()
    days_infected = collect(1:15)
    ticks = range(1, stop = 15, length = 8)
    ticklabels = ["1" "3" "5" "7" "9" "11" "13" "15"]

    xlabel_name = "Число дней после инфицирования"
    if !is_russian
        xlabel_name = "Days infected"
    end
    ylabel_name = "Риск инфицирования"
    if !is_russian
        ylabel_name = L"I_{iv}"
    end

    mean_incubation_duration = [1, 1, 2, 4, 6, 3, 3]
    mean_symptoms_duration = [8, 6, 11, 7, 9, 8, 8]
    mean_viral_loads = [4.6, 4.7, 3.5, 6.0, 4.1, 4.8, 4.93]

    infectivity_plot = plot(
        days_infected,
        [get_infectivity_transmission.(
            days_infected,
            mean_incubation_duration[i],
            mean_symptoms_duration[i],
            mean_viral_loads[i],
            false,
        ) for i in 1:num_viruses],
        xticks = (ticks, ticklabels),
        legend = (0.92, 0.95),
        lw = 1.5,
        margin = 6Plots.mm,
        color = [RGB(0.933, 0.4, 0.467) RGB(0.267, 0.467, 0.667) RGB(0.133, 0.533, 0.2) RGB(0.667, 0.2, 0.467) RGB(0.8, 0.733, 0.267) RGB(0.5, 0.5, 0.5) RGB(0.4, 0.8, 0.933)],
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"],
        grid = true,
        foreground_color_legend = nothing,
        background_color_legend = nothing,
        xlabel = xlabel_name,
        ylabel = ylabel_name,
    )
    savefig(infectivity_plot, joinpath(@__DIR__, "..", "..", "..", "input", "plots", "transmission", "infectivity_influence.pdf"))
end

plot_duration_influence()

plot_temperature_influence_year()
plot_temperature_influence()

plot_infectivity_influence()

plot_susceptibility_influence()
plot_susceptibility_influence_age()

plot_immunity_protection_influence()
