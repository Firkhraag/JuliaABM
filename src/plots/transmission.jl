using Plots

function plot_duration_influence()
    duration_parameter = 7.05
    duration_influence(x) = 1 / (1 + exp(-x + duration_parameter))

    duration_range = range(0, stop=24, length=100)
    duration_plot = plot(
        duration_range, duration_influence.(duration_range), title = "Duration influence", lw = 3, legend = false)
    xlabel!("Hour")
    ylabel!("Influence")
    savefig(duration_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "duration.pdf"))
end

function plot_temperature_influence()
    temperature_parameters = Float64[-0.8, -0.8, -0.05, -0.64, -0.2, -0.05, -0.8]
    temp_influence(x, v) = temperature_parameters[v] * x + 1.0

    temperature_range = range(0, stop=1, length=100)
    temperature_plot = plot(
        temperature_range,
        [temp_influence.(temperature_range, i) for i = 1:7],
        title = "Temperature influence",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Temperature")
    ylabel!("Influence")
    savefig(temperature_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "temperature.pdf"))
end

function plot_susceptibility_influence()
    susceptibility_parameters = Float64[2.61, 2.61, 3.17, 5.11, 4.69, 3.89, 3.77]
    susceptibility_influence(x, v) = 2 / (1 + exp(susceptibility_parameters[v] * x))

    susceptibility_range = range(0, stop=1, length=100)
    susceptibility_plot = plot(
        susceptibility_range,
        [susceptibility_influence.(susceptibility_range, i) for i = 1:7],
        title = "Susceptibility influence",
        lw = 3,
        label = ["FluA" "FluB" "RV" "RSV" "AdV" "PIV" "CoV"])
    xlabel!("Ig level")
    ylabel!("Influence")
    savefig(susceptibility_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "susceptibility.pdf"))
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
    savefig(infectivity_plot, joinpath(@__DIR__, "..", "..", "input", "plots", "infectivity.pdf"))
end

plot_duration_influence()
plot_temperature_influence()
# plot_infectivity_influence()
plot_susceptibility_influence()
