# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('����', 'name', String, OPTIONAL),
	('��Ļ', 'subtitle', String, REQUIRED),
	('����·��', 'json', String, OPTIONAL),
	('��������', 'arm_name', String, OPTIONAL),
	('������', 'animation', String, OPTIONAL),
	('��ʼ֡', 'start', Int, OPTIONAL),
	('����֡��', 'framecount', Int, OPTIONAL),
	('ѭ������', 'loop', Int, OPTIONAL),
	('λ��', 'position', String, OPTIONAL),
	('Y��ƫ��', 'y_offset', Int, OPTIONAL),
	('����', 'scale', Float, OPTIONAL),
	('��һ��', 'next_id', Int, OPTIONAL),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	for k, v in new.iteritems():
		if v.has_key('subtitle'):
			v['subtitle'] = v['subtitle'].replace(r'\\n', r'\n')
	return new
