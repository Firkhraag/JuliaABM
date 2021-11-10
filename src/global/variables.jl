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
const num_universities = 138
const start_university_ids = Int[1, 50, 94, 123]
const end_university_ids = Int[49, 93, 122, 138]
const num_shops = 11109
const start_shop_ids = Int[1, 2984, 5671, 8191]
const end_shop_ids = Int[2983, 5670, 8190, 11109]
const num_restaurants = 12843
const start_restaurant_ids = Int[1, 4002, 8101, 10534]
const end_restaurant_ids = Int[4001, 8100, 10533, 12843]

const start_agent_ids_districts = [3932304, 8064022, 3334900, 5558488, 6429831, 2013133, 7110184, 6612084, 8723176, 7988040, 1432830, 3086728, 4174822, 8981940, 2569129, 4837102, 6523570, 4618685, 8433649, 8138906, 8852431, 6336921, 5763203, 7750130, 7516408, 6060616, 9798620, 9329840, 7355178, 6863236, 7593251, 9442724, 6780130, 1281692, 8916467, 8648791, 7670852, 10046423, 8787648, 9496999, 796497, 9914516, 9103353, 3455968, 7193364, 6245424, 9610763, 1866127, 2942384, 1, 5050706, 5254722, 5357212, 10020103, 336270, 9849703, 2151092, 6943399, 964508, 553665, 9663320, 7435552, 5457468, 5862849, 8505403, 5660226, 8575236, 3690660, 1717129, 9042069, 7273984, 7834408, 3809362, 5152979, 164609, 2290791, 
    6696394, 5962188, 6155901, 9751672, 2692893, 8284286, 8358722, 4290071, 7911444, 4049682, 1573367, 2818116, 4402043, 4727009, 2430314, 9992373, 4512627, 9951454, 4947921, 1126201, 9557203, 9706203, 9880165, 9161671, 7027736, 3213729, 9385981, 9273853, 3575584, 8211307, 9218476]
const end_agent_ids_districts = [4049681, 8138905, 3455967, 5660225, 6523569, 2151091, 7193363, 6696393, 8787647, 8064021, 1573366, 3213728, 4290070, 9042068, 2692892, 4947920, 6612083, 4727008, 8505402, 8211306, 8916466, 6429830, 5862848, 7834407, 7593250, 6155900, 9849702, 9385980, 7435551, 6943398, 7670851, 9496998, 6863235, 1432829, 8981939, 8723175, 7750129, 10072668, 8852430, 9557202, 964507, 9951453, 9161670, 3575583, 7273983, 6336920, 9663319, 2013132, 3086727, 164608, 5152978, 5357211, 5457467, 10046422, 553664, 9880164, 2290790, 7027735, 1126200, 796496, 9706202, 7516407, 5558487, 5962187, 8575235, 5763202, 8648790, 3809361, 1866126, 9103352, 7355177, 7911443, 3932303, 5254721, 336269, 2430313, 6780129, 6060615, 6245423, 9798619, 2818115, 8358721, 8433648, 4402042, 7988039, 4174821, 1717128, 2942383, 4512626, 4837101, 2569128, 10020102, 4618684, 9992372, 5050705, 
    1281691, 9610762, 9751671, 9914515, 9218475, 7110183, 3334899, 9442723, 9329839, 3690659, 8284285, 9273852]

const max_agent_age = 89

# Размер групп в образовательных учреждениях
const kindergarten_groups_size_1 = 10
const kindergarten_groups_size_2_3 = 15
const kindergarten_groups_size_4_5 = 20

const school_groups_size = 25

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

# American Time Use Survey 2019
# Probabilities
weekend_go_to_other_household_p = 0.269
weekend_go_to_restaurant_p = 0.295
weekend_go_to_shopping_p = 0.354
weekend_go_to_outdoor_p = 0.15
weekend_go_to_outdoor_t = 0.28
weekend_go_to_other_place_p = 0.402
weekend_go_to_other_place_t = 1.18
weekend_public_transport_p = 0.791
weekend_public_transport_t = 1.19

weekday_go_to_other_household_p = 0.177
weekday_go_to_restaurant_p = 0.255
weekday_go_to_shopping_p = 0.291
weekday_go_to_outdoor_p = 0.133
weekday_go_to_outdoor_t = 0.16
weekday_go_to_other_place_p = 0.483
weekday_go_to_other_place_t = 1.22
weekday_public_transport_p = 0.858
weekday_public_transport_t = 1.27

# Means
weekend_other_household_time_mean = 0.95
weekday_other_household_time_mean = 0.42
other_household_time_sd = 0.15

weekend_shopping_time_mean = 0.44
weekday_shopping_time_mean = 0.28
shopping_time_sd = 0.09

weekend_restaurant_time_mean = 0.38
weekday_restaurant_time_mean = 0.26
restaurant_time_sd = 0.09

shop_capacity_shape = 2.5
shop_capacity_scale = 20.0

# 30 minutes for 10 hours
restaurant_num_groups = 20
shop_num_groups = 20

# contact with only x closest agents
restaurant_num_nearest_agents_as_contact = 20
shop_num_nearest_agents_as_contact = 20

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

# Вероятность прогула для различных образовательных учреждений
const skip_kindergarten_probability = 0.1
const skip_school_probability = 0.1
const skip_university_probability = 0.5
