# using Distributions, Random

# abstract type AbstractAgent end

# struct Collective <: AbstractCollective
#     # Среднее время проводимое агентами
#     mean_time_spent::Float64
#     # Среднеквадратическое отклонение времени проводимого агентами
#     time_spent_sd::Float64
#     # Активен на текущем шаге
#     is_active::Bool
#     # Агенты
#     agents::Array{AbstractAgent}

#     function Collective(mean_time_spent::Float64, time_spent_sd::Float64)
#         new(mean_time_spent, time_spent_sd, true, AbstractAgent[])
#     end
# end

# # collectives = Dict(
# #     "Household" => Collective(12.4, 5.13),
# #     "Kindergarten" => Collective(5.88, 2.52),
# #     "School" => Collective(4.783, 2.67),
# #     "University" => Collective(2.1, 3.0),
# #     "Workplace" => Collective(3.0, 3.0)
# # )

# function get_contact_duration(mean::Float64, sd::Float64)
#     return rand(truncated(Normal(mean, sd), 0.0, Inf))
# end

#     # private fun getHouseholdContactDurationWithKindergarten(): Double {
#     #     // Normal distribution (mean = 5.0, SD = 2.05)
#     #     val rand = java.util.Random()
#     #     return min(20.0, max(0.0,5.0 + rand.nextGaussian() * 2.05))
#     # }

#     # private fun getHouseholdContactDurationWithWork(): Double {
#     #     // Normal distribution (mean = 8.0, SD = 3.28)
#     #     val rand = java.util.Random()
#     #     return min(20.0, max(0.0,5.0 + rand.nextGaussian() * 2.05))
#     # }

#     # private fun getHouseholdContactDurationWithSchool(): Double {
#     #     // Normal distribution (mean = 6.0, SD = 2.46)
#     #     val rand = java.util.Random()
#     #     return min(20.0, max(0.0,6.0 + rand.nextGaussian() * 2.46))
#     # }

#     # private fun getHouseholdContactDurationWithUniversity(): Double {
#     #     // Normal distribution (mean = 9.0, SD = 3.69)
#     #     val rand = java.util.Random()
#     #     return min(20.0, max(0.0,7.0 + rand.nextGaussian() * 3.69))
#     # }
