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
	('等级限制', 'lv', Int, REQUIRED),
	('攻击', 'att', Float, OPTIONAL),
	('暴击', 'crit', Float, OPTIONAL),
	('血量', 'hp', Float, OPTIONAL),
	('防御', 'def', Float, OPTIONAL),
	('小图标', 'icon', String, OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
	('出售价格', 'price', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
