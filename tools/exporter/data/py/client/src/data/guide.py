# -*- coding: UTF-8 -*-
_reload_all = True
data = {
	1: {"X": 770, "X1": 725, "X2": 820, "Y": 250, "Y1": 170, "Y2": 375, "click_area": [157, -150, 252, 55], "condition": [{"!first_lot_coin": "1"}, {"!first_lot_gem": "1"}], "delay": 0.3, "duration": 0, "fin_pre": 5, "force": 1, "gesture_ori": "����", "gesture_pos": [202, -70], "id": 1, "json": "gui/main/guide_left.ExportJson", "scene_x_offset": 1668.0, "tip_key": "enter_lottery", "tip_pos": [-100, 0], "trigger": "topui_main_surface_layer"},
	2: {"X": 260, "X1": 160, "X2": 320, "Y": 90, "Y1": 50, "Y2": 95, "click_area": [-408, -270, -248, -225], "condition": [{"!first_lot_coin": "1", "!first_lot_gem": "1"}], "delay": 0.3, "duration": 0, "fin_pre": 5, "force": 1, "gesture_ori": "����", "gesture_pos": [-308, -230], "id": 2, "json": "gui/main/guide_right.ExportJson", "pre_step": 1, "tip_key": "gold_lottery_1", "tip_pos": [0, -120], "trigger": "topui_lottery_layer"},
	3: {"X": 900, "X1": 770, "X2": 1130, "Y": 250, "Y1": 50, "Y2": 600, "click_area": [202, -270, 562, 280], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [332, -70], "guide_type": 3, "id": 3, "json": "gui/main/guide_right.ExportJson", "pre_step": 2, "tip_key": "gold_lottery_2", "tip_pos": [380, 100], "trigger": "topui_soul_gain_layer"},
	4: {"X": -200, "X1": 660, "X2": 810, "Y": -200, "Y1": 40, "Y2": 80, "click_area": [92, -280, 242, -240], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [-768, -520], "id": 4, "pre_step": 3, "trigger": "topui_lottery_items_panel"},
	5: {"X": 700, "X1": 625, "X2": 775, "Y": 90, "Y1": 50, "Y2": 95, "click_area": [57, -270, 207, -225], "condition": [{"!first_lot_gem": "1", "first_lot_coin": "1"}], "delay": 0.3, "duration": 0, "fin_pre": 5, "force": 1, "gesture_ori": "����", "gesture_pos": [132, -230], "id": 5, "json": "gui/main/guide_left.ExportJson", "pre_step": 1, "tip_key": "diamond_lottery_1", "tip_pos": [0, -120], "trigger": "topui_lottery_layer"},
	6: {"X": 900, "X1": 770, "X2": 1130, "Y": 250, "Y1": 50, "Y2": 600, "click_area": [202, -270, 562, 280], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [332, -70], "guide_type": 3, "id": 6, "json": "gui/main/guide_right.ExportJson", "pre_step": 5, "tip_key": "diamond_lottery_2", "tip_pos": [380, 100], "trigger": "topui_soul_gain_layer"},
	7: {"X": -200, "X1": 660, "X2": 810, "Y": -200, "Y1": 40, "Y2": 80, "click_area": [92, -280, 242, -240], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [-768, -520], "id": 7, "pre_step": 6, "trigger": "topui_lottery_items_panel"},
	8: {"X": 1020, "X1": 995, "X2": 1050, "Y": 635, "Y1": 580, "Y2": 630, "click_area": [427, 260, 482, 310], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [452, 315], "id": 8, "pre_step": 5, "trigger": "topui_lottery_layer"},
	9: {"X": 1070, "X1": 1050, "X2": 1110, "Y": 70, "Y1": 20, "Y2": 70, "click_area": [-110, 15, -30, 70], "condition": [{"!finish_battle": "1003", "first_lot_coin": "1", "first_lot_gem": "1"}], "delay": 0.3, "duration": 0, "fin_pre": 15, "force": 1, "gesture_ori": "����", "gesture_pos": [-65, 70], "id": 9, "json": "gui/main/guide_left.ExportJson", "tip_key": "battle_1_1", "tip_pos": [300, -120], "trigger": "topui_main_surface_layer"},
	10: {"X": 235, "X1": 185, "X2": 280, "Y": 472, "Y1": 387, "Y2": 492, "click_area": [-383, 67, -288, 172], "delay": 0.3, "duration": 0, "fin_pre": 15, "force": 1, "gesture_ori": "����", "gesture_pos": [-333, 152], "id": 10, "pre_step": 9, "trigger": "topui_map_layer"},
	11: {"X": 885, "X1": 780, "X2": 980, "Y": 100, "Y1": 50, "Y2": 105, "click_area": [212, -270, 412, -215], "delay": 0.3, "duration": 0, "fin_pre": 15, "force": 1, "gesture_ori": "����", "gesture_pos": [317, -220], "id": 11, "pre_step": 10, "trigger": "topui_fuben_detail_layer"},
	12: {"X": 505, "X1": 430, "X2": 580, "Y": 525, "Y1": 360, "Y2": 560, "click_area": [-138, 40, 12, 240], "condition": [{"!loaded_soul": "107"}], "delay": 0.3, "duration": 0, "fin_pre": 15, "force": 1, "gesture_ori": "����", "gesture_pos": [-63, 205], "id": 12, "json": "gui/main/guide_right.ExportJson", "next_step": 13, "pre_step": 11, "tip_key": "soul_deployment_1", "tip_pos": [140, -50], "trigger": "topui_skill_select_layer"},
	13: {"X": 680, "X1": 605, "X2": 755, "Y": 525, "Y1": 360, "Y2": 560, "click_area": [37, 40, 187, 240], "condition": [{"!loaded_soul": "107"}], "delay": 0.3, "duration": 0, "fin_pre": 15, "force": 1, "gesture_ori": "����", "gesture_pos": [112, 205], "id": 13, "json": "gui/main/guide_right.ExportJson", "next_step": 14, "pre_step": 12, "tip_key": "soul_deployment_2", "tip_pos": [140, -50], "trigger": "topui_skill_select_layer"},
	14: {"X": 915, "X1": 810, "X2": 1010, "Y": 90, "Y1": 35, "Y2": 95, "click_area": [242, -285, 442, -225], "condition": [{"!finish_battle": "1003", "loaded_soul": "108"}], "delay": 0.3, "duration": 0, "fin_pre": 15, "force": 1, "gesture_ori": "����", "gesture_pos": [347, -230], "id": 14, "json": "gui/main/guide_left.ExportJson", "tip_key": "soul_deployment_3", "tip_pos": [50, -120], "trigger": "topui_skill_select_layer"},
	15: {"X": 1065, "X1": 1040, "X2": 1090, "Y": 260, "Y1": 210, "Y2": 255, "click_area": [-110, 195, -40, 260], "condition": [{"!first_quest_reward": "1", "finish_battle": "1003"}], "delay": 0.3, "duration": 0, "fin_pre": 20, "force": 1, "gesture_ori": "����", "gesture_pos": [-75, 265], "id": 15, "json": "gui/main/guide_left.ExportJson", "tip_key": "task_reward", "tip_pos": [200, -50], "trigger": "topui_main_surface_layer"},
	16: {"X": 660, "X1": 580, "X2": 740, "Y": 610, "Y1": 560, "Y2": 605, "click_area": [12, 240, 172, 285], "delay": 0.3, "duration": 0, "fin_pre": 20, "force": 1, "gesture_ori": "����", "gesture_pos": [92, 290], "id": 16, "next_step": 17, "pre_step": 15, "trigger": "topui_task_layer"},
	17: {"X": 840, "X1": 225, "X2": 885, "Y": 470, "Y1": 405, "Y2": 525, "click_area": [-343, 85, 317, 205], "delay": 0.3, "duration": 0, "fin_pre": 20, "force": 1, "gesture_ori": "����", "gesture_pos": [272, 150], "id": 17, "pre_step": 16, "trigger": "topui_task_layer"},
	18: {"X": -200, "X1": 475, "X2": 665, "Y": -200, "Y1": 180, "Y2": 230, "click_area": [-93, -140, 97, -90], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [-768, -520], "id": 18, "json": "gui/main/guide_right.ExportJson", "pre_step": 17, "tip_key": "task_repeat", "tip_pos": [380, 100], "trigger": "topui_task_reward"},
	19: {"X": 1020, "X1": 995, "X2": 1050, "Y": 635, "Y1": 580, "Y2": 630, "click_area": [427, 260, 482, 310], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [452, 315], "id": 19, "pre_step": 18, "trigger": "topui_task_layer"},
	20: {"X": 1070, "X1": 1050, "X2": 1110, "Y": 70, "Y1": 20, "Y2": 70, "click_area": [-110, 15, -30, 70], "condition": [{"!finish_battle": "1006", "first_quest_reward": "1"}], "delay": 0.3, "duration": 0, "fin_pre": 24, "force": 1, "gesture_ori": "����", "gesture_pos": [-65, 70], "id": 20, "json": "gui/main/guide_left.ExportJson", "tip_key": "battle_1_2", "tip_pos": [300, -120], "trigger": "topui_main_surface_layer"},
	21: {"X": 195, "X1": 175, "X2": 215, "Y": 282, "Y1": 247, "Y2": 287, "click_area": [-393, -73, -353, -33], "delay": 0.3, "duration": 0, "fin_pre": 24, "force": 1, "gesture_ori": "����", "gesture_pos": [-373, -38], "id": 21, "pre_step": 20, "trigger": "topui_map_layer"},
	22: {"X": 885, "X1": 780, "X2": 980, "Y": 100, "Y1": 50, "Y2": 105, "click_area": [212, -270, 412, -215], "delay": 0.3, "duration": 0, "fin_pre": 24, "force": 1, "gesture_ori": "����", "gesture_pos": [317, -220], "id": 22, "pre_step": 21, "trigger": "topui_fuben_detail_layer"},
	23: {"X": 915, "X1": 810, "X2": 1010, "Y": 90, "Y1": 35, "Y2": 95, "click_area": [242, -285, 442, -225], "delay": 0.3, "duration": 0, "fin_pre": 24, "force": 1, "gesture_ori": "����", "gesture_pos": [347, -230], "id": 23, "json": "gui/main/guide_left.ExportJson", "pre_step": 22, "tip_key": "soul_element_1", "tip_pos": [50, -120], "trigger": "topui_skill_select_layer"},
	24: {"X": 980, "X1": 950, "X2": 1010, "Y": 70, "Y1": 20, "Y2": 70, "click_area": [-195, 15, -130, 70], "condition": [{"!first_proficiency": "1", "finish_battle": "1006"}], "delay": 0.3, "duration": 0, "fin_pre": 28, "force": 1, "gesture_ori": "����", "gesture_pos": [-165, 70], "id": 24, "json": "gui/main/guide_left.ExportJson", "tip_key": "avatar_strengthen_1", "tip_pos": [150, -120], "trigger": "topui_main_surface_layer"},
	25: {"X": 180, "X1": 150, "X2": 210, "Y": 415, "Y1": 360, "Y2": 420, "click_area": [-418, 40, -358, 100], "delay": 0.3, "duration": 0, "fin_pre": 28, "force": 1, "gesture_ori": "����", "gesture_pos": [-388, 95], "id": 25, "json": "gui/main/guide_right.ExportJson", "next_step": 26, "pre_step": 24, "tip_key": "avatar_strengthen_2", "tip_pos": [150, -120], "trigger": "topui_proficient_layer"},
	26: {"X": 670, "X1": 590, "X2": 740, "Y": 100, "Y1": 60, "Y2": 100, "click_area": [22, -260, 172, -220], "delay": 0.3, "duration": 0, "fin_pre": 28, "force": 1, "gesture_ori": "����", "gesture_pos": [102, -220], "id": 26, "next_step": 27, "pre_step": 25, "trigger": "topui_proficient_layer"},
	27: {"X": 1020, "X1": 995, "X2": 1050, "Y": 635, "Y1": 580, "Y2": 630, "click_area": [427, 260, 482, 310], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [452, 315], "id": 27, "pre_step": 26, "trigger": "topui_proficient_layer"},
	28: {"X": 1070, "X1": 1050, "X2": 1110, "Y": 70, "Y1": 20, "Y2": 70, "click_area": [-110, 15, -30, 70], "condition": [{"!finish_battle": "1009", "first_proficiency": "1"}], "delay": 0.3, "duration": 0, "fin_pre": 32, "force": 1, "gesture_ori": "����", "gesture_pos": [-65, 70], "id": 28, "json": "gui/main/guide_left.ExportJson", "tip_key": "battle_1_3", "tip_pos": [300, -120], "trigger": "topui_main_surface_layer"},
	29: {"X": 320, "X1": 300, "X2": 340, "Y": 322, "Y1": 277, "Y2": 317, "click_area": [-268, -43, -228, -3], "delay": 0.3, "duration": 0, "fin_pre": 32, "force": 1, "gesture_ori": "����", "gesture_pos": [-248, 2], "id": 29, "pre_step": 28, "trigger": "topui_map_layer"},
	30: {"X": 885, "X1": 780, "X2": 980, "Y": 100, "Y1": 50, "Y2": 105, "click_area": [212, -270, 412, -215], "delay": 0.3, "duration": 0, "fin_pre": 32, "force": 1, "gesture_ori": "����", "gesture_pos": [317, -220], "id": 30, "json": "gui/main/guide_left.ExportJson", "pre_step": 29, "tip_key": "soul_element_2", "tip_pos": [50, -120], "trigger": "topui_fuben_detail_layer"},
	31: {"X": 915, "X1": 810, "X2": 1010, "Y": 90, "Y1": 35, "Y2": 95, "click_area": [242, -285, 442, -225], "delay": 0.3, "duration": 0, "fin_pre": 32, "force": 1, "gesture_ori": "����", "gesture_pos": [347, -230], "id": 31, "pre_step": 30, "trigger": "topui_skill_select_layer"},
	32: {"X": 210, "X1": 120, "X2": 270, "Y": 365, "Y1": 160, "Y2": 360, "click_area": [-448, -160, -298, 40], "condition": [{"!first_eq_strengthen": "1", "finish_battle": "1009"}], "delay": 0.3, "duration": 0, "fin_pre": 35, "force": 1, "gesture_ori": "����", "gesture_pos": [-358, 45], "id": 32, "json": "gui/main/guide_right.ExportJson", "scene_x_offset": 1668.0, "tip_key": "equipment_strengthen_1", "tip_pos": [100, -120], "trigger": "topui_main_surface_layer"},
	33: {"X": 320, "X1": 210, "X2": 410, "Y": 125, "Y1": 65, "Y2": 125, "click_area": [-358, -255, -158, -195], "delay": 0.3, "duration": 0, "fin_pre": 35, "force": 1, "gesture_ori": "����", "gesture_pos": [-248, -195], "id": 33, "json": "gui/main/guide_right.ExportJson", "next_step": 34, "pre_step": 32, "tip_key": "equipment_strengthen_2", "tip_pos": [100, -120], "trigger": "topui_strengthen_layer"},
	34: {"X": 1020, "X1": 995, "X2": 1050, "Y": 635, "Y1": 580, "Y2": 630, "click_area": [427, 260, 482, 310], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [452, 315], "id": 34, "pre_step": 33, "trigger": "topui_strengthen_layer"},
	35: {"X": 1070, "X1": 1050, "X2": 1110, "Y": 70, "Y1": 20, "Y2": 70, "click_area": [-110, 15, -30, 70], "condition": [{"!finish_battle": "1012", "first_eq_strengthen": "1"}], "delay": 0.3, "duration": 0, "fin_pre": 39, "force": 1, "gesture_ori": "����", "gesture_pos": [-65, 70], "id": 35, "json": "gui/main/guide_left.ExportJson", "tip_key": "battle_1_4", "tip_pos": [300, -120], "trigger": "topui_main_surface_layer"},
	36: {"X": 400, "X1": 345, "X2": 460, "Y": 327, "Y1": 207, "Y2": 337, "click_area": [-223, -113, -108, 17], "delay": 0.3, "duration": 0, "fin_pre": 39, "force": 1, "gesture_ori": "����", "gesture_pos": [-168, 7], "id": 36, "pre_step": 35, "trigger": "topui_map_layer"},
	37: {"X": 885, "X1": 780, "X2": 980, "Y": 100, "Y1": 50, "Y2": 105, "click_area": [212, -270, 412, -215], "delay": 0.3, "duration": 0, "fin_pre": 39, "force": 1, "gesture_ori": "����", "gesture_pos": [317, -220], "id": 37, "pre_step": 36, "trigger": "topui_fuben_detail_layer"},
	38: {"X": 915, "X1": 810, "X2": 1010, "Y": 90, "Y1": 35, "Y2": 95, "click_area": [242, -285, 442, -225], "delay": 0.3, "duration": 0, "fin_pre": 39, "force": 1, "gesture_ori": "����", "gesture_pos": [347, -230], "id": 38, "json": "gui/main/guide_left.ExportJson", "pre_step": 37, "tip_key": "boss_fighting", "tip_pos": [50, -120], "trigger": "topui_skill_select_layer"},
	39: {"X": 705, "X1": 675, "X2": 735, "Y": 70, "Y1": 20, "Y2": 70, "click_area": [-465, 15, -400, 95], "condition": [{"!first_eq_activation": "1", "finish_battle": "1012"}], "delay": 0.3, "duration": 0, "fin_pre": 42, "force": 1, "gesture_ori": "����", "gesture_pos": [-440, 70], "id": 39, "json": "gui/main/guide_left.ExportJson", "tip_key": "equipment_activation_1", "tip_pos": [0, -120], "trigger": "topui_main_surface_layer"},
	40: {"X": 910, "X1": 590, "X2": 995, "Y": 465, "Y1": 375, "Y2": 470, "click_area": [22, 55, 427, 150], "delay": 0.3, "duration": 0, "fin_pre": 42, "force": 1, "gesture_ori": "����", "gesture_pos": [342, 145], "id": 40, "json": "gui/main/guide_left.ExportJson", "pre_step": 39, "tip_key": "equipment_activation_2", "tip_pos": [0, 50], "trigger": "topui_equip_sys_layer"},
	41: {"X": 470, "X1": 400, "X2": 535, "Y": 120, "Y1": 75, "Y2": 115, "click_area": [-168, -245, -33, -205], "delay": 0.3, "duration": 0, "fin_pre": 42, "force": 1, "gesture_ori": "����", "gesture_pos": [-98, -200], "id": 41, "next_step": 42, "pre_step": 40, "trigger": "topui_equipment_info_panel"},
	42: {"X": 670, "X1": 595, "X2": 730, "Y": 125, "Y1": 75, "Y2": 115, "click_area": [27, -245, 162, -205], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [102, -195], "id": 42, "json": "gui/main/guide_right.ExportJson", "pre_step": 41, "tip_key": "equipment_activation_3", "tip_pos": [380, -100], "trigger": "topui_equipment_info_panel"},
	43: {"X": -200, "X1": 0, "X2": 1136, "Y": -200, "Y1": 0, "Y2": 640, "click_area": [-568, -320, 568, 320], "delay": 0.3, "duration": 0, "force": 1, "gesture_ori": "����", "gesture_pos": [-768, -520], "guide_type": 2, "id": 43, "json": "gui/main/guide_left.ExportJson", "pre_step": 42, "tip_key": "walk_around", "tip_pos": [0, 0], "trigger": "topui_equip_sys_layer"}
}