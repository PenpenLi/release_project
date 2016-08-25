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
	('骑士身', 'q_armor', Array(String), OPTIONAL),
	('骑士左手', 'q_lefthand', String, OPTIONAL),
	('骑士右手', 'q_righthand', String, OPTIONAL),
	('骑士左脚', 'q_leftfoot', String, OPTIONAL),
	('骑士右脚', 'q_rightfoot', String, OPTIONAL),
	('刺客身', 'c_armor', Array(String), OPTIONAL),
	('刺客左手', 'c_lefthand', String, OPTIONAL),
	('刺客右手', 'c_righthand', String, OPTIONAL),
	('刺客左脚', 'c_leftfoot', String, OPTIONAL),
	('刺客右脚', 'c_rightfoot', String, OPTIONAL),
	('刺客斗篷', 'c_cloak', Array(String), OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
