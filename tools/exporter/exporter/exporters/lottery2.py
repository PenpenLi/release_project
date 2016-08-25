# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('物品id', 'goods_id', Int, REQUIRED),
	('物品数量', 'count', Int, REQUIRED),
	('备注', '', String, COMMENT),
	('贵重物品', 'precious', Bool, REQUIRED),
	('权重', 'drop', Int, REQUIRED),
	('积分', 'point', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	for id, val in new.iteritems():
		if not depend[1]['item_id'].has_key(val['goods_id']):
			record_error('没有这个物品id %d' % (val['goods_id'],))
	return new
