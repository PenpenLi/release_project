# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('武器名', 'name', String, REQUIRED),
	('等级需求', 'Lv', Int, REQUIRED),
	('品质', 'color', String, OPTIONAL),
	('攻击', 'attack', Float, OPTIONAL),
	('防御', 'defense', Float, OPTIONAL),
	('血量', 'max_hp', Float, OPTIONAL),
	('暴击', 'crit_level', Float, OPTIONAL),
	('激活_攻击', 'act_attack', Float, OPTIONAL),
	('激活_防御', 'act_defense', Float, OPTIONAL),
	('激活_血量', 'act_max_hp', Float, OPTIONAL),
	('激活_暴击', 'act_crit_level', Float, OPTIONAL),
	('描述', 'description', String, OPTIONAL),
	('小图标', 'icon', String, OPTIONAL),
	('文件名', 'file', String, OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
