# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('ģ��id', 'model_id', Int, REQUIRED),
	('״̬��', 'state', String, REQUIRED),
	('�ӵ�', 'bullet', Array(String), OPTIONAL),
	('������', 'name', String, REQUIRED),
	('��ע', '', String, COMMENT),
	('�˺���ʽ', 'formula', String, OPTIONAL),
	('�Լ����buff', 's_buff', Array(Int), OPTIONAL),
	('���˻��buff', 'e_buff', Array(Int), OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if not res.has_key(v['model_id']):
			res[v['model_id']] = {}
		res[v['model_id']][v['state']] = v
	return res
