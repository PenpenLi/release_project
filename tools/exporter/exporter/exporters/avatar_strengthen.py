# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('精通', 'type', String, OPTIONAL),
	('等级', 'lv', Int, OPTIONAL),
	('消耗物品', 'item_id', Int,OPTIONAL),
	('消耗金币', 'gold', Int, OPTIONAL),
	('攻击', 'attack', Int,OPTIONAL),
	('防御', 'defense', Int, OPTIONAL),
	('生命', 'max_hp', Int, OPTIONAL),
	('暴击', 'crit_level', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	for i in xrange(1,STRENGTH_LV+1):
		sum_attack = 0
		sum_defense = 0
		sum_max_hp = 0
		sum_crit_level = 0
		for j in xrange(1,MAX_LEVEL):
			key = i*100000 + j
			if new[key].has_key('attack'):
				sum_attack = sum_attack + new[key]['attack']
				new[key]['sum_attack'] = sum_attack
			if new[key].has_key('defense'):
				sum_defense = sum_defense + new[key]['defense']
				new[key]['sum_defense'] = sum_defense
			if new[key].has_key('max_hp'):
				sum_max_hp = sum_max_hp + new[key]['max_hp']
				new[key]['sum_max_hp'] = sum_max_hp
			if new[key].has_key('crit_level'):
				sum_crit_level = sum_crit_level + new[key]['crit_level']
				new[key]['sum_crit_level'] = sum_crit_level
	return new
