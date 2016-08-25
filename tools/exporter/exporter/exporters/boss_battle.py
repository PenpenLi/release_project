# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('怪物id', 'boss_id', Int, REQUIRED),
	('解锁关卡', 'unlock', Int, REQUIRED),
	('跳转关卡', 'battle_id', Int, REQUIRED),
    ('怪物属性', 'property', String, REQUIRED),
	('怪物图标', 'icon', String, REQUIRED),
	('备注', 'remark', String, REQUIRED),
)

import time

def export(old, new, depend, raw):
	return new
