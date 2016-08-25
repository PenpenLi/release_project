# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('等级', 'level', Int, REQUIRED),
	('备注', '', String, COMMENT),
	('升级经验', 'exp', Int, REQUIRED),
	('攻击', 'attack', Int, OPTIONAL),
	('暴击', 'crit', Int, OPTIONAL),
	('血量', 'hp', Int, OPTIONAL),
	('防御', 'def', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	temp_sum = 0
	for k, v in new.iteritems():
		temp_sum = temp_sum + v['exp']
		v['sum_exp'] = temp_sum

	return new
