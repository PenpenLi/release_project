# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��Ʒid', 'goods_id', Int, REQUIRED),
	('��Ʒ����', 'count', Int, REQUIRED),
	('��ע', '', String, COMMENT),
	('������Ʒ', 'precious', Bool, REQUIRED),
	('Ȩ��', 'drop', Int, REQUIRED),
	('����', 'point', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	for id, val in new.iteritems():
		if not depend[1]['item_id'].has_key(val['goods_id']):
			record_error('û�������Ʒid %d' % (val['goods_id'],))
	return new
