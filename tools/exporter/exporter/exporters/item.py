# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('物品名称', 'name', String, REQUIRED),
	('品质', 'color', String, OPTIONAL),
	('备注', '', String, COMMENT),
	('角色加体力', 'energy', Int, OPTIONAL),
	('魔灵加经验', 'soul_exp', Int, OPTIONAL),
	('角色加经验', 'exp', Int, OPTIONAL),
	('小图标', 'icon', String, OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
	('界面类型', 'ui_type', String, OPTIONAL),
	('关卡ID', 'battle_id', Int, OPTIONAL),
	('出售价格', 'price', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
