using Plots

include("../data/temperature.jl")

function plot_duration_influence()
    duration_parameter = 6.75
    duration_influence(x) = 1 / (1 + exp(-x + duration_parameter))

    scalefontsizes(1.2)
    duration_range = range(0, stop=24, length=100)
    duration_plot = plot(
        duration_range, duration_influence.(duration_range), lw = 3, legend = false, color = "green", fontfamily = "Times")
    xlabel!("Hour")
    ylabel!("Contact duration influence")
    savefig(duration_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "duration_influence.pdf"))
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
#     savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "temperature_influence.pdf"))
# end

function plot_temperature_influence_year()
    temperature_parameters = Float64[-0.9, -0.8, -0.05, -0.35, -0.05, -0.05, -0.85]
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

    scalefontsizes(1.1)
    ticks = range(1, stop = 365, length = 13)
    ticklabels = ["Aug" "Sep" "Oct" "Nov" "Dec" "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug"]
    temperature_plot = plot(
        1:365,
        [temp_influences[i, :] for i = 1:7],
        xticks = (ticks, ticklabels),
        legend=:bottom,
        # color = ["red" "blue" "green" "violet" "orange" "grey" "black"]
        lw = 3,
        fontfamily = "Times",
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Month")
    ylabel!("Air temperature influence")
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "temperature_influence_year.pdf"))
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
#     savefig(susceptibility_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "susceptibility_influence.pdf"))
# end

function plot_susceptibility_influence_age()
    susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]
    susceptibility_influence(x, v) = 2 / (1 + exp(susceptibility_parameters[v] * x))

    ig_levels = [0.1505164955165073, 0.24272685839757013, 0.27446634642134227, 0.27335566991005594, 0.2735622560350999, 0.27338288255941956, 0.35102037547122344, 0.3506582993180788, 0.3501344468578805, 0.3843581109268843, 0.38512561297996545, 0.3841741589663935, 0.39680562463247615, 0.39678143520059356, 0.3963905886612963, 0.3963375288649048, 0.3965702682420548, 0.5090656587262238, 0.5090815491354699, 0.4645414640012885, 0.4644123788635453, 0.4645052320264773, 0.46437142322798197, 0.46404796055057324, 0.46404131051991415, 0.4642103769039795, 0.4644378565132235, 0.46431284676460083, 0.46420446317184094, 0.46417318616873177, 0.4641823756357343, 0.46431026812185305, 0.46428430374463076, 0.46419241271472667, 0.46442367046502736, 0.4641316362196958, 0.46375909790283526, 0.4639264468340825, 0.46374602109520874, 0.46389155709992, 0.4638894246832213, 0.4639072611334911, 0.4635306092460304, 0.46391631085834933, 0.46365848864301656, 0.46397048228918875, 0.46371709601587097, 0.4635952965866837, 0.46359555005295366, 0.4637930222367746, 0.4636360565700838, 0.46388701957152984, 0.46390561946497944, 0.46367085732813207, 0.4637113207404173, 0.463279562093781, 0.4631526289013043, 0.46311392536698287, 0.46362072192117104, 0.4634004652394673, 0.4633030057731725, 0.4251085457596629, 0.42579853946476415, 0.4253826719019012, 0.42499345597956945, 0.42718293068111934, 0.4260034329999044, 0.42633039649962223, 0.42622303029540065, 0.4263844159925822, 0.42651966706897754, 0.37526803040674195, 0.37532637246454903, 0.37551370107979276, 0.3762675778905722, 0.3724835780318056, 0.37297425583430915, 0.3727718999755025, 0.3737942833189381, 0.37366617813636965, 0.371607528787453, 0.37183632026679353, 0.3723822853489555, 0.37254019190309834, 0.3732338222929381, 0.36931013110281213, 0.36965447629422055, 0.37101932095070683, 0.3711536310341243, 0.36749595142533503]

    susceptibility_range = range(0, stop=89, length=200)
    susceptibility_plot = plot(
        susceptibility_range,
        [susceptibility_influence.(susceptibility_range, i) for i = 1:7],
        title = "Susceptibility influence",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Age")
    ylabel!("Influence")
    savefig(susceptibility_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "susceptibility_influence.pdf"))
end

function get_viral_load(
    days_infected::Int,
    incubation_period::Int,
    infection_period::Int,
    mean_viral_load::Float64
)::Float64
    if days_infected < 1
        if incubation_period == 1
            return mean_viral_load / 24
        end
        k = mean_viral_load / (incubation_period - 1)
        b = k * (incubation_period - 1)
        return (k * days_infected + b) / 12
    end
    k = 2 * mean_viral_load / (1 - infection_period)
    b = -k * infection_period
    return (k * days_infected + b) / 12
end

function plot_infectivity_influence()
    infectivity_range = range(-6, stop=14, length=100)
    infectivity_plot = plot(
        infectivity_range, infectivity_influence.(infectivity_range), title = "Infectivity influence", lw = 3, legend = false)
    xlabel!("Hour")
    ylabel!("Influence")
    savefig(infectivity_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "infectivity_influence.pdf"))
end

# plot_duration_influence()

# plot_temperature_influence()
# plot_temperature_influence_year()

# # plot_infectivity_influence()

# plot_susceptibility_influence()
plot_susceptibility_influence_age()

