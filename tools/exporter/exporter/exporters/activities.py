# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('活动名字', 'title', String, REQUIRED),
	('活动内容', 'content', String, REQUIRED),
	('开启时间', 'start_time', String, REQUIRED),
	('关闭时间', 'end_time', String, REQUIRED),
	('图标路径', 'icon_route',String,OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
