# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('商品id', 'id', Int, REQUIRED),
	('类型', 'good_type', Int, REQUIRED),
	('物品id', 'item_id', Int, REQUIRED),
	('物品名称', 'item_name', String, REQUIRED),
	('商品描述', 'good_desc', String, REQUIRED),
	('出售数量', 'sell_num', Int, REQUIRED),
	('代币价格', 'price', Int, REQUIRED),
	('出现位置', 'position', Array(Int), REQUIRED),
	('等级区间', 'lv_limit', Array(Int), REQUIRED),
	('刷新权重', 'refresh_weight', Int, REQUIRED),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
