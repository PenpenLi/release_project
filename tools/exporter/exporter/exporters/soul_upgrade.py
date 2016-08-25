# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('魔灵等级', 'soul_level', Int, REQUIRED),
	('所需经验', 'exp', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	temp_sum = 0
	for k, v in new.iteritems():
		temp_sum = temp_sum + v['exp']
		v['sum_exp'] = temp_sum

	return new
