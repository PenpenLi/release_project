# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('ID', 'id', Int, REQUIRED),
	('���ܿ����ؿ�', 'battle_id', Int, OPTIONAL),
	('�ȼ�����', 'lv', Int, OPTIONAL),
	('���ȼ�', 'priority', Int, OPTIONAL),
	('����', 'type', Int, REQUIRED),
	('����', 'title', String, REQUIRED),
	('����', 'description', String, OPTIONAL),
	('����ʱ��', 'start_time', String, OPTIONAL),
	('�ر�ʱ��', 'end_time', String, OPTIONAL),
	('ͼ��·��', 'icon_route',String,OPTIONAL),
	('������Ч', 'hint_effect', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	'''
	for k, v in new.iteritems():
		if v.has_key('start_time'):
			#v['start_time'] = time.localtime(v['start_time'])
			v['start_time'] = time.mktime(time.strptime(v['start_time'], '%Y-%m-%d %H:%M:%S'))
	'''
	return new
