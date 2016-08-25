# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('物品名称', 'name', String, REQUIRED),
	('品质', 'color', String, REQUIRED),
	('备注', '', String, COMMENT),
	('小图标', 'icon', String, OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
	('出售价格', 'price', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
