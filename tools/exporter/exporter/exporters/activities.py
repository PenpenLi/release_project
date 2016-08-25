# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('�����', 'title', String, REQUIRED),
	('�����', 'content', String, REQUIRED),
	('����ʱ��', 'start_time', String, REQUIRED),
	('�ر�ʱ��', 'end_time', String, REQUIRED),
	('ͼ��·��', 'icon_route',String,OPTIONAL),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new