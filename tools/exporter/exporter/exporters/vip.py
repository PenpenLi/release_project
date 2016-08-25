# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('vip等级', 'vip_lv', Int, REQUIRED),
	('升到该级所需总钻石', 'sum_diamond', Int, REQUIRED),
	('每日可购买体力次数', 'energy_max', Int, REQUIRED),
	('每日可使用点金手次数', 'midas_max', Int, REQUIRED),
	('每日精英副本可重置次数', 'jy_reset_max', Int, REQUIRED),
	('每日赠送扫荡券数量', 'free_sweep', Int, REQUIRED),
	('特权描述', 'privilege', String, REQUIRED),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
