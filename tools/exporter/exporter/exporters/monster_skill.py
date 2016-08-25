# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('模型id', 'model_id', Int, REQUIRED),
	('状态名', 'state', String, REQUIRED),
	('子弹', 'bullet', Array(String), OPTIONAL),
	('技能名', 'name', String, REQUIRED),
	('备注', '', String, COMMENT),
	('伤害公式', 'formula', String, OPTIONAL),
	('自己获得buff', 's_buff', Array(Int), OPTIONAL),
	('敌人获得buff', 'e_buff', Array(Int), OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if not res.has_key(v['model_id']):
			res[v['model_id']] = {}
		res[v['model_id']][v['state']] = v
	return res
