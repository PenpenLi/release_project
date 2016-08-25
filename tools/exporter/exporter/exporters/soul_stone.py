# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��Ʒ����', 'name', String, REQUIRED),
	('Ʒ��', 'color', String, OPTIONAL),
	('ħ��ID', 'soul_id', Int, OPTIONAL),
	('��ע', '', String, COMMENT),
	('Сͼ��', 'icon', String, OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
	('���ۼ۸�', 'price', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new

def export_map(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		res[v['soul_id']] = v['id']
	return res