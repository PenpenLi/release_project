# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('模型id', 'model_id', Int, REQUIRED),
	('备注1', '', String, COMMENT),
	('备注2', '', String, COMMENT),
	('火伤', 'f_att', Float, OPTIONAL),
	('冰伤', 'i_att', Float, OPTIONAL),
	('自然伤', 'n_att', Float, OPTIONAL),
	('火抗', 'f_def', Float, OPTIONAL),
	('冰抗', 'i_def', Float, OPTIONAL),
	('自然抗', 'n_def', Float, OPTIONAL),
	('血量', 'max_hp', Int, REQUIRED),
	('攻击力', 'attack', Int, REQUIRED),
	('暴击等级', 'crit_level', Int, REQUIRED),
	('暴击伤害倍数', 'crit_damage', Float, REQUIRED),
	('防御力', 'defense', Int, REQUIRED),
	('出生buff', 'buff', Int, OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
