# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('品质', 'color', String, REQUIRED),
	('部位', 'bodypart', String, REQUIRED),
	('等级区间', 'level', Tuple(Int,Int), REQUIRED),
	('攻击', 'attack', Float, OPTIONAL),
	('防御', 'defense', Float, OPTIONAL),
	('生命', 'max_hp', Float, OPTIONAL),
	('暴击', 'crit_level', Float, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		tem_k = v['color'] + '_' + POS_TO_KEY(v['bodypart'])
		if not res.has_key(tem_k):
			res[tem_k] = {}
		for i in xrange(v['level'][0], v['level'][1]):
			res[tem_k][i] = {}
			if v.has_key('attack'):
				res[tem_k][i]['attack'] = v['attack']
			if v.has_key('defense'):
				res[tem_k][i]['defense'] = v['defense']
			if v.has_key('max_hp'):
				res[tem_k][i]['max_hp'] = v['max_hp']
			if v.has_key('crit_level'):
				res[tem_k][i]['crit_level'] = v['crit_level']

	for v in DIC_QUALITY:
		for vv in DIC_POSITION:
			tmp_k = v + '_' + vv
			for i in xrange(1, MAX_EQUIP_LEVEL + 1):
				if not res.has_key(tmp_k):
					res[tmp_k] = {}
				p_l = i - 1
				if not res[tmp_k].has_key(p_l):
					res[tmp_k][p_l] = {}
				if res[tmp_k][p_l].has_key('attack'):
					sum_lv(res[tmp_k], 'attack', i) 
				if res[tmp_k][p_l].has_key('defense'):
					sum_lv(res[tmp_k], 'defense', i) 
				if res[tmp_k][p_l].has_key('max_hp'):
					sum_lv(res[tmp_k], 'max_hp', i) 
				if res[tmp_k][p_l].has_key('crit_level'):
					sum_lv(res[tmp_k], 'crit_level', i) 

	return res

def sum_lv( arr, key, lv ):
	sum_key = key + '_sum'

	if not arr.has_key(lv):
		arr[lv] = {}
	if not arr[lv].has_key(sum_key):
		arr[lv][sum_key] = 0

	if lv > 0:
		pre_lv = lv - 1
		if not arr.has_key(pre_lv):
			arr[pre_lv] = {}
		if not arr[pre_lv].has_key(sum_key):
			arr[pre_lv][sum_key] = 0
		if not arr[pre_lv].has_key(key):
			arr[pre_lv][key] = 0

		arr[lv][sum_key] = arr[pre_lv][sum_key] + arr[pre_lv][key]
