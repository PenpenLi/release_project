# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('商品id', 'id', Int, REQUIRED),
	('物品名称', 'name', String, COMMENT),
	('物品id', 'item', Int, REQUIRED),
	('物品数量', 'item_num', Int, OPTIONAL),
	('钻石价格', 'diamond', Int, OPTIONAL),
	('金币价格', 'gold', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
