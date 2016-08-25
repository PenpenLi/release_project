# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('Ʒ��', 'color', String, REQUIRED),
	('�ȼ�', 'level', Int, REQUIRED),
	('��Ƭ', 'stone', Int, REQUIRED),
	('���', 'gold', Int, OPTIONAL),
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
