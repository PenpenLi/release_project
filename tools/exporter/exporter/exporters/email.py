# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('标题', 'title', String, REQUIRED),
	('正文', 'body', String, OPTIONAL),
	('日期', 'date', String,OPTIONAL),
	('发件人', 'sender', String, OPTIONAL),
	('有无附件', 'with_items', Bool,OPTIONAL),
	('金钱', 'money', Int, OPTIONAL),
	('钻石', 'diamond', Int, OPTIONAL),
	('物品', 'items', Dict(Int, Int), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
