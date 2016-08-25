# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('����', 'title', String, REQUIRED),
	('����', 'desc', String, REQUIRED),
	('��������', 'type', Int, REQUIRED),
	('���ŵȼ�����', 'lv', Int, OPTIONAL),
	('ǰ����������', 'pre_quest', Int, OPTIONAL),
	('����ʱ��', 'time_limit', Array(Int), OPTIONAL),
	('�������', 'condition', String, OPTIONAL),
	('��������', 'condition_count', Int, OPTIONAL(0)),
	('����','energy', Int, OPTIONAL),
	('���', 'gold', Int, OPTIONAL),
	('��ʯ', 'diamond', Int, OPTIONAL),
	('����', 'exp', Int, OPTIONAL),
	('��Ʒ', 'items', Array(Int), OPTIONAL),
	('��Ʒ����', 'items_count', Int, OPTIONAL),
	('��������', 'ui_type', String, OPTIONAL),
	('�ؿ�ID', 'battle_id', Int, OPTIONAL),
	('ͼ��·��', 'icon_id', String, OPTIONAL),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if v['type'] == 2:
			res[k] = v
	return res
	
def export_daily(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if v['type'] == 1:
			res[k] = v
	return res