# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('物品ID', 'item_id', Int, REQUIRED),
	('物品名字', 'item_name', String, REQUIRED),
	('途径1类型', 'pathway1_type', Int, OPTIONAL()),
	('途径1内容', 'pathway1_content', Int, OPTIONAL()),
	('途径1icon', 'pathway1_icon', String, OPTIONAL()),
	('途径2类型', 'pathway2_type', Int, OPTIONAL()),
	('途径2内容', 'pathway2_content', Int, OPTIONAL()),
	('途径2icon', 'pathway2_icon', String, OPTIONAL()),
	('途径3类型', 'pathway3_type', Int, OPTIONAL()),
	('途径3内容', 'pathway3_content', Int, OPTIONAL()),
	('途径3icon', 'pathway3_icon', String, OPTIONAL()),
)

import time

def export(old, new, depend, raw):
	return new
