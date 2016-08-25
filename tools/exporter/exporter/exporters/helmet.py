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
	('配置文件', 'config_files', Array(String), OPTIONAL),
	('小图标', 'icon', String, OPTIONAL),
	('骑士头', 'q_head', Array(String), OPTIONAL),
	('骑士头盔', 'q_helmet', Array(String), OPTIONAL),
	('骑士表情', 'q_emotion', Array(String), OPTIONAL),
	('刺客头', 'c_head', Array(String), OPTIONAL),
	('刺客头盔', 'c_helmet', Array(String), OPTIONAL),
	('刺客表情', 'c_emotion', Array(String), OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
