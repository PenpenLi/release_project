# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('�����id', 'id', Int, REQUIRED),
	('�ȼ�����', 'level', Tuple(Int,Int), REQUIRED),
	('�����1', 'rand_1', Dict(String, Int), OPTIONAL),
	('�����1����', 'num_1', Int, OPTIONAL),
	('�����2', 'rand_2', Dict(String, Int), OPTIONAL),
	('�����2����', 'num_2', Int, OPTIONAL),
	('�����3', 'rand_3', Dict(String, Int), OPTIONAL),
	('�����3����', 'num_3', Int, OPTIONAL),
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
