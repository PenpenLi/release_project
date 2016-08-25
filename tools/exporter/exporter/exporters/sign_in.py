# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('日期', 'date', String, REQUIRED),
	('签到奖励', 'reward', Tuple(Int, Int), OPTIONAL()),
	('翻倍所需VIP等级', 'vip_lv_needed', Int, REQUIRED),
	('倍数', 'mul_num', Int, REQUIRED),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
