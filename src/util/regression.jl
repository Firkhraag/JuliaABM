# function linear_regression(
#     X::Matrix{Float64},
#     y::Vector{Float64},
#     learning_rate::Float64,
#     parameters::Vector{Float64},
#     num_runs::Int,
# )
#     # @time X_t = transpose(X)
#     for i = 1:num_runs
#         parameters -= learning_rate * transpose(X) * 2 / length(y) * (X * parameters - y)
#     end
# end

function linear_regression(
    X::Matrix{Float64},
    y::Vector{Float64},
    learning_rate::Float64,
    parameters::Vector{Float64},
    num_runs::Int,
)::Vector{Float64}
    for i = 1:num_runs
        parameters -= learning_rate * transpose(X) * 2 / length(y) * (X * parameters - y)
    end
    return parameters
end

# function stepwise_regression(
#     X_params::Matrix{Float64},
#     y::Vector{Float64},
# )::Tuple{Float64, Vector{Int}}
#     X = cat(X_params, [1.0 for i = 1:length(y)], dims = 2)

#     alpha_to_enter = 0.15
#     alpha_to_remove = 0.15

#     included_parameters = Int[]

#     m = zeros(Float64, size(X)[2] - 1)
#     sd = zeros(Float64, size(X)[2] - 1)

#     for i = 1:size(X)[2] - 1
#         m[i] = mean(X[:, i])
#         sd[i] = std(X[:, i])
#         if sd[i] > 0.0001
#             for j = 1:size(X)[1]
#                 X[j, i] = (X[j, i] - m[i]) / sd[i]
#             end
#         end
#     end

#     num_params = 1
#     exit = false
#     aic_default = 10000

#     parameters = [0.1 for i = 1:(num_params + 1)]
#     while !exit
#         println(num_params)
#         exit = true
#         pos = 0

#         indexes = copy(included_parameters)
#         push!(indexes, size(X)[2])
#         push!(indexes, 0)
#         for i = 1:(size(X)[2] - 1)
#             if i in included_parameters
#                 continue
#             end
#             indexes[length(indexes)] = i

#             linear_regression(X[:, indexes], y, 0.001, parameters, 10000)

#             sse = transpose((X[:, indexes] * parameters - y)) * (X[:, indexes] * parameters - y)
#             aic = length(y) * log(sse / length(y)) + 2 * num_params

#             if aic < aic_default
#                 aic_default = aic
#                 pos = i
#             end

#             for i = 1:(num_params + 1)
#                 parameters[i] = 0.1
#             end
#         end

#         if pos != 0
#             push!(included_parameters, pos)
#             exit = false
#             num_params += 1

#             push!(parameters, 0.1)
#         end

#         # if num_params > 2
#         #     pos = 0

#         #     for i = 1:(size(X)[2] - 1)
#         #         if !(i in included_parameters)
#         #             continue
#         #         end
#         #         indexes = copy(included_parameters)
#         #         filter!(e -> e ≠ i, indexes)
#         #         push!(indexes, size(X)[2])

#         #         linear_regression(X[:, indexes], y, 0.001, [0.1 for i = 1:(num_params - 1)], 10000)

#         #         sse = transpose((X[:, indexes] * parameters - y)) * (X[:, indexes] * parameters - y)
#         #         aic = length(y) * log(sse / length(y)) + 2 * (num_params - 2)

#         #         if aic < aic_default
#         #             aic_default = aic
#         #             pos = i
#         #         end

#         #         for i = 1:(num_params - 1)
#         #             parameters[i] = 0.1
#         #         end
#         #     end

#         #     if pos != 0
#         #         filter!(e -> e ≠ pos, included_parameters)
#         #         exit = false
#         #         num_params -= 1
#         #     end
#         # end

#         println(aic_default)
#         println(included_parameters)
#     end

#     return aic_default, included_parameters
# end

function stepwise_regression_aic(
    X_params::Matrix{Float64},
    y::Vector{Float64},
)::Tuple{Float64, Vector{Int}}
    X = cat(X_params, [1.0 for i = 1:length(y)], dims = 2)

    alpha_to_enter = 0.15
    alpha_to_remove = 0.15

    included_parameters = Int[]

    m = zeros(Float64, size(X)[2] - 1)
    sd = zeros(Float64, size(X)[2] - 1)

    for i = 1:size(X)[2] - 1
        m[i] = mean(X[:, i])
        sd[i] = std(X[:, i])
        if sd[i] > 0.0001
            for j = 1:size(X)[1]
                X[j, i] = (X[j, i] - m[i]) / sd[i]
            end
        end
    end

    aic_default = 10000
    num_params = 1
    exit = false
    while !exit
        println(num_params)
        exit = true

        pos = 0

        indexes = copy(included_parameters)
        push!(indexes, 0)
        push!(indexes, size(X)[2])
        for i = 1:(size(X)[2] - 1)
            if i in included_parameters
                continue
            end
            indexes[length(indexes) - 1] = i

            parameters = linear_regression(X[:, indexes], y, 0.001, [0.1 for i = 1:(num_params + 1)], 10000)

            sse = transpose((X[:, indexes] * parameters - y)) * (X[:, indexes] * parameters - y)
            aic = length(y) * log(sse / length(y)) + 2 * num_params

            if aic < aic_default
                aic_default = aic
                pos = i
            end
        end

        if pos != 0
            push!(included_parameters, pos)
            exit = false
            num_params += 1
        end
    end

    return aic_default, included_parameters
end

function stepwise_regression(
    X_params::Matrix{Float64},
    y::Vector{Float64},
)::Vector{Int}
    X = cat(X_params, [1.0 for i = 1:length(y)], dims = 2)

    alpha_to_enter = 0.05
    alpha_to_remove = 0.05

    included_parameters = Int[]

    m = zeros(Float64, size(X)[2] - 1)
    sd = zeros(Float64, size(X)[2] - 1)

    for i = 1:size(X)[2] - 1
        m[i] = mean(X[:, i])
        sd[i] = std(X[:, i])
        if sd[i] > 0.0001
            for j = 1:size(X)[1]
                X[j, i] = (X[j, i] - m[i]) / sd[i]
            end
        end
    end

    num_params = 1
    exit = false
    parameters = [0.1 for i = 1:(num_params + 1)]
    while !exit
        println(num_params)
        exit = true

        max_t = 0.0
        pos = 0

        dof = length(y) - num_params - 1
        t0 = quantile(TDist(dof), 1 - alpha_to_enter / 2)

        indexes = copy(included_parameters)
        push!(indexes, 0)
        push!(indexes, size(X)[2])

        for i = 1:(size(X)[2] - 1)
            if i in included_parameters
                continue
            end
            indexes[length(indexes) - 1] = i

            parameters = linear_regression(X[:, indexes], y, 0.001, parameters, 10000)

            sse = transpose((X[:, indexes] * parameters - y)) * (X[:, indexes] * parameters - y)

            ss = 0.0
            for k = 1:length(y)
                ss += (X[k, i] - mean(X[:, i]))^2
            end

            t = parameters[num_params] / sqrt(sse / (dof * ss))

            if abs(t) > abs(t0)
                if abs(t) > abs(max_t)
                    max_t = t
                    pos = i
                end
            end

            for i = 1:length(parameters)
                parameters[i] = 0.1
            end
        end

        if pos != 0
            push!(included_parameters, pos)
            push!(parameters, 0.1)
            exit = false
            num_params += 1
        end

        println(included_parameters)
    end

    return included_parameters
end