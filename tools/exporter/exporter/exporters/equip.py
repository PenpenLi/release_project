# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('配置文件字段', 'confield', String, REQUIRED),
	('配表', 'data_table', String, REQUIRED),
	('骨骼命名', 'skeletons', Dict(String,String), OPTIONAL),
	('皮肤数量', 'skin_num', Dict(String,Int), OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
