# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('商品名称', 'name', String, OPTIONAL),
	('商品描述', 'title', String, OPTIONAL),
	('商品类型', 'good_type', Int, REQUIRED),
	('RMB', 'price', Int, REQUIRED),
	('钻石', 'diamond', Int, OPTIONAL),
	('赠送钻石', 'diamond_send', Int, OPTIONAL),
	('推荐', 'recommend', Int, OPTIONAL),
	('折扣', 'discount', Int, OPTIONAL),
	('终生购买次数', 'can_buy_count', Int, OPTIONAL),
	('图标路径','icon_route',String,OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
