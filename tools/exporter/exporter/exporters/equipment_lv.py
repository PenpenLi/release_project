# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('品质', 'color', String, REQUIRED),
	('等级', 'level', Int, REQUIRED),
	('碎片', 'stone', Int, REQUIRED),
	('金币', 'gold', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if not res.has_key(v['color']):
			res[v['color']] = {}
		res[v['color']][v['level']] = {}
		if v.has_key('stone'):
			res[v['color']][v['level']]['stone'] = v['stone']
		if v.has_key('gold'):
			res[v['color']][v['level']]['gold'] = v['gold']
	return res
