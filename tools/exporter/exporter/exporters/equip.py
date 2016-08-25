# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('�����ļ��ֶ�', 'confield', String, REQUIRED),
	('���', 'data_table', String, REQUIRED),
	('��������', 'skeletons', Dict(String,String), OPTIONAL),
	('Ƥ������', 'skin_num', Dict(String,Int), OPTIONAL),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
