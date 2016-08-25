# -*- coding: UTF-8 -*-
_reload_all = True
data = {
	1: {"event": "enter_scene", "func_arg": ["gui/battle/guide_basicop_1.ExportJson"], "func_name": "show_info", "id": 1},
	2: {"bind_monster": "100000", "event": "enter_trigger", "func_arg": ["gui/battle/guide_basicop_1.ExportJson"], "func_name": "hide_info", "id": 2},
	5: {"bind_monster": "100000", "event": "enter_trigger", "func_arg": ["can_jump"], "func_name": "set_true", "id": 5},
	8: {"bind_monster": "100000", "event": "enter_trigger", "func_arg": ["jump", "gesture_jump", "432", "30"], "func_name": "show_tip", "id": 8},
	9: {"bind_monster": "100000", "event": "outof_trigger", "func_arg": ["jump"], "func_name": "hide_tip", "id": 9},
	13: {"bind_monster": "100001", "event": "enter_trigger", "func_arg": ["attack", "gesture_hp", "92", "270"], "func_name": "show_tip", "id": 13},
	14: {"bind_monster": "100001", "event": "outof_trigger", "func_arg": ["attack"], "func_name": "hide_tip", "id": 14},
	15: {"bind_monster": "100002", "event": "enter_trigger", "func_arg": ["energy", "gesture_hp", "92", "270"], "func_name": "show_tip", "id": 15},
	16: {"bind_monster": "100002", "event": "outof_trigger", "func_arg": ["energy"], "func_name": "hide_tip", "id": 16},
	17: {"bind_monster": "100003", "event": "enter_trigger", "func_arg": ["can_charge"], "func_name": "set_true", "id": 17},
	20: {"bind_monster": "100003", "event": "enter_trigger", "func_arg": ["charge", "gesture_charge", "232", "-120"], "func_name": "show_tip", "id": 20},
	21: {"bind_monster": "100003", "event": "outof_trigger", "func_arg": ["charge"], "func_name": "hide_tip", "id": 21},
	23: {"bind_monster": "100004", "event": "enter_trigger", "func_arg": ["can_slashup"], "func_name": "set_true", "id": 23},
	26: {"bind_monster": "100004", "event": "enter_trigger", "func_arg": ["slashup", "gesture_slashup", "382", "-20"], "func_name": "show_tip", "id": 26},
	27: {"bind_monster": "100004", "event": "outof_trigger", "func_arg": ["slashup"], "func_name": "hide_tip", "id": 27},
	29: {"bind_monster": "100005", "event": "enter_trigger", "func_arg": ["can_slashdown"], "func_name": "set_true", "id": 29},
	32: {"bind_monster": "100005", "event": "enter_trigger", "func_arg": ["slashdown", "gesture_slashdown", "382", "-20"], "func_name": "show_tip", "id": 32},
	33: {"bind_monster": "100005", "event": "outof_trigger", "func_arg": ["slashdown"], "func_name": "hide_tip", "id": 33},
	35: {"bind_monster": "100006", "event": "enter_trigger", "func_arg": ["can_releaseskill"], "func_name": "set_true", "id": 35},
	38: {"bind_monster": "100006", "event": "enter_trigger", "func_arg": ["releaseskill", "gesture_jump", "-80", "80", "����"], "func_name": "show_tip", "id": 38},
	39: {"bind_monster": "100006", "event": "outof_trigger", "func_arg": ["releaseskill"], "func_name": "hide_tip", "id": 39},
	42: {"event": "enter_scene", "func_arg": ["101", "1", "1", "2"], "func_name": "permanent_skill", "id": 42},
	43: {"event": "enter_scene", "func_name": "hide_skill_buttons", "id": 43},
	44: {"bind_monster": "100006", "event": "enter_trigger", "func_name": "show_skill_buttons", "id": 44},
	45: {"event": "finish_tutor", "func_name": "finish_tutorial", "id": 45},
	47: {"event": "finish_tutor", "func_arg": ["106"], "func_name": "unload_skill", "id": 47}
}