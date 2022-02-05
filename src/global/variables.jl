# Разбиение по потокам
const num_agents = 10072668
const start_agent_ids = Int[1, 2483024, 4977885, 7516450]
const end_agent_ids = Int[2483023, 4977884, 7516449, 10072668]
const num_households = 3974287
const start_household_ids = Int[1, 994512, 1957295, 2980361]
const end_household_ids = Int[994511, 1957294, 2980360, 3974287]
const num_kindergartens = 1697
const start_kindergarten_ids = Int[1, 435, 891, 1309]
const end_kindergarten_ids = Int[434, 890, 1308, 1697]
const num_schools = 989
const start_school_ids = Int[1, 243, 516, 752]
const end_school_ids = Int[242, 515, 751, 989]
const num_colleges = 138
const start_college_ids = Int[1, 50, 94, 123]
const end_college_ids = Int[49, 93, 122, 138]
const num_shops = 11109
const start_shop_ids = Int[1, 2984, 5671, 8191]
const end_shop_ids = Int[2983, 5670, 8190, 11109]
const num_restaurants = 12843
const start_restaurant_ids = Int[1, 4002, 8101, 10534]
const end_restaurant_ids = Int[4001, 8100, 10533, 12843]

# Примерное число агентов в различных возрастных группах
const num_agents_age_groups = [266648, 304625, 531915, 8969480]

# Максимальный возраст агента
const max_agent_age = 89

# MCMC параметры
const burnin = 1
const step = 5

# Размеры групп в детских садах
const kindergarten_groups_size_1 = 10
const kindergarten_groups_size_2_3 = 15
const kindergarten_groups_size_4_5 = 20

# Размеры групп в школах
const school_groups_size = 25

# Размеры групп в институтах
const college_groups_size_1 = 15
const college_groups_size_2_3 = 14
const college_groups_size_4 = 13
const college_groups_size_5 = 11
const college_groups_size_6 = 10

# Вероятность прогула института
const skip_college_probability = 0.33

# Параметр распределения Ципфа
const zipf_parameter = 1.059

# Средняя разница в возрасте между матерью и ребенком
const mean_child_mother_age_difference = 28

# const num_of_close_friends_mean = 5.1
# const num_of_close_friends_sd = 1.4

# Probabilities from American Time Use Survey 2019
# const weekend_other_household_p = 0.269
# const weekend_other_household_t = 0.95
# const weekend_restaurant_p = 0.295
# const weekend_restaurant_t = 0.38
# const weekend_shopping_p = 0.354
# const weekend_shopping_t = 0.44
# const weekend_outdoor_p = 0.15
# const weekend_outdoor_t = 0.28
# const weekend_other_place_p = 0.402
# const weekend_other_place_t = 1.18

# const weekday_other_household_p = 0.177
# const weekday_other_household_t = 0.42
# const weekday_restaurant_p = 0.255
# const weekday_restaurant_t = 0.26
# const weekday_shopping_p = 0.291
# const weekday_shopping_t = 0.28
# const weekday_outdoor_p = 0.133
# const weekday_outdoor_t = 0.16
# const weekday_other_place_p = 0.483
# const weekday_other_place_t = 1.22

# const other_household_time_sd = 0.15
# const shopping_time_sd = 0.09
# const restaurant_time_sd = 0.09

# shop_capacity_shape = 2.5
# shop_capacity_scale = 20.0

# 30 minutes for 10 hours
const restaurant_num_groups = 20
# 30 minutes for 12 hours
# const shop_num_groups = 24

const restaurant_num_nearest_agents_as_contact = 15
const shop_num_nearest_agents_as_contact = 15
const school_num_of_teacher_contacts = 10

# const prob_shopping_together = 0.7
# const prob_restaurant_together = 0.9
