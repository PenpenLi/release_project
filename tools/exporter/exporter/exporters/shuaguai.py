# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('�ؿ�id', 'id', Int, REQUIRED),
	('�ڼ���', 'shuaguai_id', Int, REQUIRED),
	('����boss', 'flag_boss', Bool, REQUIRED),
	('����id', 'monster_id', Array(Int), REQUIRED),
	('��������', 'monster_count', Array(Int), REQUIRED),
	('������Ӫ', 'monster_group', Array(Int), OPTIONAL),
	('�����ٶ�', 'speed_x', Int, OPTIONAL),
	('���','interval', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if not res.has_key(v['id']):
			res[v['id']] = {}
		res[v['id']][v['shuaguai_id']] = v
	return res
