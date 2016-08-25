# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('随机库id', 'id', Int, REQUIRED),
	('等级区间', 'level', Tuple(Int,Int), REQUIRED),
	('随机组1', 'rand_1', Dict(String, Int), OPTIONAL),
	('随机组1数量', 'num_1', Int, OPTIONAL),
	('随机组2', 'rand_2', Dict(String, Int), OPTIONAL),
	('随机组2数量', 'num_2', Int, OPTIONAL),
	('随机组3', 'rand_3', Dict(String, Int), OPTIONAL),
	('随机组3数量', 'num_3', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new

def export_level_list(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		for i in xrange(v['level'][0], v['level'][1]+1):
			res[i] = k
	return res
