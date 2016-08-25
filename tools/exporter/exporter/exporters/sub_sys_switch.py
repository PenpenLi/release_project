# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('ID', 'id', Int, REQUIRED),
	('功能开启关卡', 'battle_id', Int, OPTIONAL),
	('等级开启', 'lv', Int, OPTIONAL),
	('优先级', 'priority', Int, OPTIONAL),
	('类型', 'type', Int, REQUIRED),
	('名称', 'title', String, REQUIRED),
	('描述', 'description', String, OPTIONAL),
	('开启时间', 'start_time', String, OPTIONAL),
	('关闭时间', 'end_time', String, OPTIONAL),
	('图标路径', 'icon_route',String,OPTIONAL),
	('提醒特效', 'hint_effect', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	'''
	for k, v in new.iteritems():
		if v.has_key('start_time'):
			#v['start_time'] = time.localtime(v['start_time'])
			v['start_time'] = time.mktime(time.strptime(v['start_time'], '%Y-%m-%d %H:%M:%S'))
	'''
	return new
