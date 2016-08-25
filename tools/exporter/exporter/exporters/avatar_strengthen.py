# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��ͨ', 'type', String, OPTIONAL),
	('�ȼ�', 'lv', Int, OPTIONAL),
	('������Ʒ', 'item_id', Int,OPTIONAL),
	('���Ľ��', 'gold', Int, OPTIONAL),
	('����', 'attack', Int,OPTIONAL),
	('����', 'defense', Int, OPTIONAL),
	('����', 'max_hp', Int, OPTIONAL),
	('����', 'crit_level', Int, OPTIONAL),
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
