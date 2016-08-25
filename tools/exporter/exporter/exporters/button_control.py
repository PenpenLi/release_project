# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('ID', 'id', Int, REQUIRED),
	('备注', '', String, COMMENT),
	('层名', 'layer_name', String, REQUIRED),
	('按钮名', 'button_name', String, REQUIRED),
	('标签', 'button_tag', String, OPTIONAL),
	('功能开启ID', 'subsys_id', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if not res.has_key(v['layer_name']):
			res[v['layer_name']] = {}
		if not res[v['layer_name']].has_key(v['button_name']):
			res[v['layer_name']][v['button_name']] = {}
	
		if not v.has_key('button_tag'):
			res[v['layer_name']][v['button_name']]['nil'] = {}
			tmp = res[v['layer_name']][v['button_name']]['nil']
			tmp['id'] = v['id']
			if v.has_key('subsys_id'):
				tmp['subsys_id'] = v['subsys_id']
		else:
			res[v['layer_name']][v['button_name']][v['button_tag']] = {}
			tmp = res[v['layer_name']][v['button_name']][v['button_tag']]
			tmp['id'] = v['id']
			if v.has_key('subsys_id'):
				tmp['subsys_id'] = v['subsys_id']

	return res
