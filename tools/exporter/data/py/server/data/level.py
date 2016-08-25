# -*- coding: UTF-8 -*-
_reload_all = True
data = {
	1: {"attack": 56, "crit": 35, "def": 43, "exp": 25, "hp": 207, "level": 1, "sum_exp": 25},
	2: {"attack": 59, "crit": 37, "def": 45, "exp": 25, "hp": 218, "level": 2, "sum_exp": 50},
	3: {"attack": 62, "crit": 39, "def": 47, "exp": 25, "hp": 229, "level": 3, "sum_exp": 75},
	4: {"attack": 66, "crit": 42, "def": 50, "exp": 30, "hp": 244, "level": 4, "sum_exp": 105},
	5: {"attack": 70, "crit": 44, "def": 53, "exp": 30, "hp": 259, "level": 5, "sum_exp": 135},
	6: {"attack": 74, "crit": 47, "def": 57, "exp": 30, "hp": 274, "level": 6, "sum_exp": 165},
	7: {"attack": 78, "crit": 49, "def": 60, "exp": 50, "hp": 289, "level": 7, "sum_exp": 215},
	8: {"attack": 83, "crit": 52, "def": 63, "exp": 80, "hp": 307, "level": 8, "sum_exp": 295},
	9: {"attack": 88, "crit": 56, "def": 67, "exp": 100, "hp": 326, "level": 9, "sum_exp": 395},
	10: {"attack": 93, "crit": 59, "def": 71, "exp": 130, "hp": 344, "level": 10, "sum_exp": 525},
	11: {"attack": 98, "crit": 62, "def": 75, "exp": 130, "hp": 363, "level": 11, "sum_exp": 655},
	12: {"attack": 104, "crit": 66, "def": 79, "exp": 130, "hp": 385, "level": 12, "sum_exp": 785},
	13: {"attack": 110, "crit": 70, "def": 84, "exp": 130, "hp": 407, "level": 13, "sum_exp": 915},
	14: {"attack": 116, "crit": 73, "def": 89, "exp": 130, "hp": 429, "level": 14, "sum_exp": 1045},
	15: {"attack": 122, "crit": 77, "def": 93, "exp": 130, "hp": 451, "level": 15, "sum_exp": 1175},
	16: {"attack": 129, "crit": 82, "def": 99, "exp": 130, "hp": 477, "level": 16, "sum_exp": 1305},
	17: {"attack": 136, "crit": 86, "def": 104, "exp": 130, "hp": 503, "level": 17, "sum_exp": 1435},
	18: {"attack": 143, "crit": 90, "def": 109, "exp": 130, "hp": 529, "level": 18, "sum_exp": 1565},
	19: {"attack": 150, "crit": 95, "def": 115, "exp": 130, "hp": 555, "level": 19, "sum_exp": 1695},
	20: {"attack": 158, "crit": 100, "def": 121, "exp": 130, "hp": 585, "level": 20, "sum_exp": 1825},
	21: {"attack": 166, "crit": 105, "def": 127, "exp": 130, "hp": 614, "level": 21, "sum_exp": 1955},
	22: {"attack": 174, "crit": 110, "def": 133, "exp": 150, "hp": 644, "level": 22, "sum_exp": 2105},
	23: {"attack": 182, "crit": 115, "def": 139, "exp": 160, "hp": 673, "level": 23, "sum_exp": 2265},
	24: {"attack": 191, "crit": 121, "def": 146, "exp": 180, "hp": 707, "level": 24, "sum_exp": 2445},
	25: {"attack": 200, "crit": 126, "def": 153, "exp": 190, "hp": 740, "level": 25, "sum_exp": 2635},
	26: {"attack": 209, "crit": 132, "def": 160, "exp": 200, "hp": 773, "level": 26, "sum_exp": 2835},
	27: {"attack": 218, "crit": 138, "def": 167, "exp": 240, "hp": 807, "level": 27, "sum_exp": 3075},
	28: {"attack": 228, "crit": 144, "def": 174, "exp": 280, "hp": 844, "level": 28, "sum_exp": 3355},
	29: {"attack": 238, "crit": 150, "def": 182, "exp": 300, "hp": 881, "level": 29, "sum_exp": 3655},
	30: {"attack": 248, "crit": 157, "def": 189, "exp": 350, "hp": 918, "level": 30, "sum_exp": 4005},
	31: {"attack": 258, "crit": 163, "def": 197, "exp": 400, "hp": 955, "level": 31, "sum_exp": 4405},
	32: {"attack": 269, "crit": 170, "def": 206, "exp": 450, "hp": 995, "level": 32, "sum_exp": 4855},
	33: {"attack": 280, "crit": 177, "def": 214, "exp": 500, "hp": 1036, "level": 33, "sum_exp": 5355},
	34: {"attack": 291, "crit": 184, "def": 222, "exp": 610, "hp": 1077, "level": 34, "sum_exp": 5965},
	35: {"attack": 302, "crit": 191, "def": 231, "exp": 720, "hp": 1117, "level": 35, "sum_exp": 6685},
	36: {"attack": 314, "crit": 198, "def": 240, "exp": 830, "hp": 1162, "level": 36, "sum_exp": 7515},
	37: {"attack": 326, "crit": 206, "def": 249, "exp": 1100, "hp": 1206, "level": 37, "sum_exp": 8615},
	38: {"attack": 338, "crit": 214, "def": 258, "exp": 1200, "hp": 1251, "level": 38, "sum_exp": 9815},
	39: {"attack": 350, "crit": 221, "def": 267, "exp": 1200, "hp": 1295, "level": 39, "sum_exp": 11015},
	40: {"attack": 363, "crit": 229, "def": 277, "exp": 1500, "hp": 1343, "level": 40, "sum_exp": 12515},
	41: {"attack": 376, "crit": 238, "def": 287, "exp": 1500, "hp": 1391, "level": 41, "sum_exp": 14015},
	42: {"attack": 389, "crit": 246, "def": 297, "exp": 1700, "hp": 1439, "level": 42, "sum_exp": 15715},
	43: {"attack": 402, "crit": 254, "def": 307, "exp": 1700, "hp": 1487, "level": 43, "sum_exp": 17415},
	44: {"attack": 416, "crit": 263, "def": 318, "exp": 1700, "hp": 1539, "level": 44, "sum_exp": 19115},
	45: {"attack": 430, "crit": 272, "def": 329, "exp": 1800, "hp": 1591, "level": 45, "sum_exp": 20915},
	46: {"attack": 444, "crit": 281, "def": 339, "exp": 2000, "hp": 1643, "level": 46, "sum_exp": 22915},
	47: {"attack": 458, "crit": 289, "def": 350, "exp": 2000, "hp": 1695, "level": 47, "sum_exp": 24915},
	48: {"attack": 473, "crit": 299, "def": 361, "exp": 2200, "hp": 1750, "level": 48, "sum_exp": 27115},
	49: {"attack": 488, "crit": 308, "def": 373, "exp": 2200, "hp": 1806, "level": 49, "sum_exp": 29315},
	50: {"attack": 503, "crit": 318, "def": 384, "exp": 2300, "hp": 1861, "level": 50, "sum_exp": 31615},
	51: {"attack": 518, "crit": 327, "def": 396, "exp": 2300, "hp": 1917, "level": 51, "sum_exp": 33915},
	52: {"attack": 534, "crit": 337, "def": 408, "exp": 2300, "hp": 1976, "level": 52, "sum_exp": 36215},
	53: {"attack": 550, "crit": 348, "def": 420, "exp": 2500, "hp": 2035, "level": 53, "sum_exp": 38715},
	54: {"attack": 566, "crit": 358, "def": 432, "exp": 2700, "hp": 2094, "level": 54, "sum_exp": 41415},
	55: {"attack": 582, "crit": 368, "def": 445, "exp": 2700, "hp": 2153, "level": 55, "sum_exp": 44115},
	56: {"attack": 599, "crit": 379, "def": 458, "exp": 2800, "hp": 2216, "level": 56, "sum_exp": 46915},
	57: {"attack": 616, "crit": 389, "def": 471, "exp": 3000, "hp": 2279, "level": 57, "sum_exp": 49915},
	58: {"attack": 633, "crit": 400, "def": 484, "exp": 3200, "hp": 2342, "level": 58, "sum_exp": 53115},
	59: {"attack": 650, "crit": 411, "def": 497, "exp": 3300, "hp": 2405, "level": 59, "sum_exp": 56415},
	60: {"attack": 668, "crit": 422, "def": 510, "exp": 3300, "hp": 2472, "level": 60, "sum_exp": 59715},
	61: {"attack": 686, "crit": 434, "def": 524, "exp": 3300, "hp": 2538, "level": 61, "sum_exp": 63015},
	62: {"attack": 704, "crit": 445, "def": 538, "exp": 3500, "hp": 2605, "level": 62, "sum_exp": 66515},
	63: {"attack": 722, "crit": 456, "def": 552, "exp": 3500, "hp": 2671, "level": 63, "sum_exp": 70015},
	64: {"attack": 741, "crit": 468, "def": 566, "exp": 3700, "hp": 2742, "level": 64, "sum_exp": 73715},
	65: {"attack": 760, "crit": 480, "def": 581, "exp": 3800, "hp": 2812, "level": 65, "sum_exp": 77515},
	66: {"attack": 779, "crit": 492, "def": 595, "exp": 4000, "hp": 2882, "level": 66, "sum_exp": 81515},
	67: {"attack": 798, "crit": 504, "def": 610, "exp": 4200, "hp": 2953, "level": 67, "sum_exp": 85715},
	68: {"attack": 818, "crit": 517, "def": 625, "exp": 4300, "hp": 3027, "level": 68, "sum_exp": 90015},
	69: {"attack": 838, "crit": 530, "def": 640, "exp": 4500, "hp": 3101, "level": 69, "sum_exp": 94515},
	70: {"attack": 858, "crit": 542, "def": 656, "exp": 4700, "hp": 3175, "level": 70, "sum_exp": 99215},
	71: {"attack": 878, "crit": 555, "def": 671, "exp": 4700, "hp": 3249, "level": 71, "sum_exp": 103915},
	72: {"attack": 899, "crit": 568, "def": 687, "exp": 4700, "hp": 3326, "level": 72, "sum_exp": 108615},
	73: {"attack": 920, "crit": 581, "def": 703, "exp": 4700, "hp": 3404, "level": 73, "sum_exp": 113315},
	74: {"attack": 941, "crit": 595, "def": 719, "exp": 4700, "hp": 3482, "level": 74, "sum_exp": 118015},
	75: {"attack": 962, "crit": 608, "def": 735, "exp": 4700, "hp": 3559, "level": 75, "sum_exp": 122715},
	76: {"attack": 984, "crit": 622, "def": 752, "exp": 4700, "hp": 3641, "level": 76, "sum_exp": 127415},
	77: {"attack": 1006, "crit": 636, "def": 769, "exp": 4700, "hp": 3722, "level": 77, "sum_exp": 132115},
	78: {"attack": 1028, "crit": 650, "def": 785, "exp": 4700, "hp": 3804, "level": 78, "sum_exp": 136815},
	79: {"attack": 1050, "crit": 664, "def": 802, "exp": 4800, "hp": 3885, "level": 79, "sum_exp": 141615},
	80: {"attack": 1073, "crit": 678, "def": 820, "exp": 4800, "hp": 3970, "level": 80, "sum_exp": 146415}
}