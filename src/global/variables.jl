const num_agents = 10072668
const start_agent_ids = Int[1, 2483024, 4977885, 7516450]
const end_agent_ids = Int[2483023, 4977884, 7516449, 10072668]
const num_households = 3974287
const start_household_ids = Int[1, 994512, 1957295, 2980361]
const end_household_ids = Int[994511, 1957294, 2980360, 3974287]
const num_kindergartens = 1695
const start_kindergarten_ids = Int[1, 435, 891, 1307]
const end_kindergarten_ids = Int[434, 890, 1306, 1695]
const num_schools = 988
const start_school_ids = Int[1, 242, 515, 751]
const end_school_ids = Int[241, 514, 750, 988]
const num_universities = 138
const start_university_ids = Int[1, 50, 94, 123]
const end_university_ids = Int[49, 93, 122, 138]

const max_agent_age = 89

# Размер групп в образовательных учреждениях
const kindergarten_groups_size_1 = 10
const kindergarten_groups_size_2_3 = 14
const kindergarten_groups_size_4_5 = 18

const school_groups_size = 24

const university_groups_size_1 = 15
const university_groups_size_2_3 = 14
const university_groups_size_4 = 13
const university_groups_size_5 = 11
const university_groups_size_6 = 10

# Параметры, отвечающие за связи на рабочих местах
const zipf_max_size = 994
const barabasi_albert_attachments = 6

const num_of_close_friends_mean = 5.1
const num_of_close_friends_sd = 1.4

# Household contact durations
# Продолжительность контактов в домохозяйствах
const household_mean_time_spent = 12.0
const household_time_spent_sd = 4.0

const household_workplace_mean_time_spent = 4.5
const household_workplace_time_spent_sd = 1.5

const household_school_mean_time_spent = 5.8
const household_school_time_spent_sd = 2.0

const household_kindergarten_mean_time_spent = 6.5
const household_kindergarten_time_spent_sd = 2.2

const household_university_mean_time_spent = 9.0
const household_university_time_spent_sd = 3.0

# American Time Use Survey
# 2019
weekend_go_to_other_household_p = 0.269
weekend_go_to_other_household_t = 0.95

weekend_go_to_restaurant_p = 0.295
weekend_go_to_restaurant_t = 0.38

weekend_go_to_shopping_p = 0.354
weekend_go_to_shopping_t = 0.44

weekend_go_to_outdoor_p = 0.15
weekend_go_to_outdoor_t = 0.28

weekend_go_to_other_place_p = 0.402
weekend_go_to_other_place_t = 1.18

weekend_transit_p = 0.791
weekend_transit_t = 1.19

# 2020
# weekend_go_to_other_household_p = 0.218
# weekend_go_to_other_household_t = 0.82

# weekend_go_to_restaurant_p = 0.188	
# weekend_go_to_restaurant_t = 0.16

# weekend_go_to_shopping_p = 0.283	
# weekend_go_to_shopping_t = 0.32

# weekend_go_to_outdoor_p = 0.183
# weekend_go_to_outdoor_t = 0.3

# weekend_go_to_other_place_p = 0.229
# weekend_go_to_other_place_t = 0.59

# weekend_transit_p = 0.626
# weekend_transit_t = 0.80

# 2019
weekday_go_to_other_household_p = 0.177
weekday_go_to_other_household_t = 0.42

weekday_go_to_restaurant_p = 0.255
weekday_go_to_restaurant_t = 0.26

weekday_go_to_shopping_p = 0.291
weekday_go_to_shopping_t = 0.28

weekday_go_to_outdoor_p = 0.133
weekday_go_to_outdoor_t = 0.16

weekday_go_to_other_place_p = 0.483
weekday_go_to_other_place_t = 1.22

weekday_transit_p = 0.858
weekday_transit_t = 1.27

# 2020

# weekday_go_to_other_household_p = 0.132	
# weekday_go_to_other_household_t = 0.43

# weekday_go_to_restaurant_p = 0.145	
# weekday_go_to_restaurant_t = 0.11

# weekday_go_to_shopping_p = 0.233
# weekday_go_to_shopping_t = 0.2

# weekday_go_to_outdoor_p = 0.182
# weekday_go_to_outdoor_t = 0.23

# weekday_go_to_other_place_p = 0.274
# weekday_go_to_other_place_t = 0.6

# weekday_transit_p = 0.68
# weekday_transit_t = 0.83

# Activity contact durations
# Продолжительность контактов в коллективах
const kindergarten_time_spent_shape = 2.5
const kindergarten_time_spent_scale = 1.6

const school_time_spent_shape = 1.78
const school_time_spent_scale = 1.95

const university_time_spent_shape = 2.0
const university_time_spent_scale = 1.07

const university_short_time_spent_shape = 2.0
const university_short_time_spent_scale = 1.07

const workplace_time_spent_shape = 1.81
const workplace_time_spent_scale = 1.7
