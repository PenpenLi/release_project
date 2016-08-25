# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('备注', '', String, COMMENT),
	('触发事件', 'event', String, REQUIRED),
	('绑定怪物ID', 'bind_monster', String, OPTIONAL),
	('函数名', 'func_name', String, REQUIRED),
	('参数', 'func_arg', Array(String), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
