# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('名字', 'title', String, REQUIRED),
	('描述', 'desc', String, REQUIRED),
	('任务类型', 'type', Int, REQUIRED),
	('开放等级限制', 'lv', Int, OPTIONAL),
	('前置任务限制', 'pre_quest', Int, OPTIONAL),
	('任务时限', 'time_limit', Array(Int), OPTIONAL),
	('达成条件', 'condition', String, OPTIONAL),
	('条件计数', 'condition_count', Int, OPTIONAL(0)),
	('体力','energy', Int, OPTIONAL),
	('金币', 'gold', Int, OPTIONAL),
	('钻石', 'diamond', Int, OPTIONAL),
	('经验', 'exp', Int, OPTIONAL),
	('物品', 'items', Array(Int), OPTIONAL),
	('物品数量', 'items_count', Int, OPTIONAL),
	('界面类型', 'ui_type', String, OPTIONAL),
	('关卡ID', 'battle_id', Int, OPTIONAL),
	('图标路径', 'icon_id', String, OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if v['type'] == 2:
			res[k] = v
	return res
	
def export_daily(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if v['type'] == 1:
			res[k] = v
	return res