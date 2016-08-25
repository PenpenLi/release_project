# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('备注', 'name', String, OPTIONAL),
	('怪物类型', 'type', Int, OPTIONAL),
	('怪物属性', 'element_type', String, OPTIONAL),
	('类', 'class', String, OPTIONAL),
	('AI配置', 'ai', String, OPTIONAL),
	('AI频率', 'ai_frequency', Int, OPTIONAL),
	('状态配置', 'state', String, REQUIRED),
	('出生buff', 'buff', Int, OPTIONAL),
	('小图标', 'icon', String, OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
