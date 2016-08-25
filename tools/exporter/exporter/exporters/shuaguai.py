# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('关卡id', 'id', Int, REQUIRED),
	('第几批', 'shuaguai_id', Int, REQUIRED),
	('有无boss', 'flag_boss', Bool, REQUIRED),
	('怪物id', 'monster_id', Array(Int), REQUIRED),
	('怪物数量', 'monster_count', Array(Int), REQUIRED),
	('怪物阵营', 'monster_group', Array(Int), OPTIONAL),
	('怪物速度', 'speed_x', Int, OPTIONAL),
	('间隔','interval', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if not res.has_key(v['id']):
			res[v['id']] = {}
		res[v['id']][v['shuaguai_id']] = v
	return res
