# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��ע', 'name', String, OPTIONAL),
	('��������', 'type', Int, OPTIONAL),
	('��������', 'element_type', String, OPTIONAL),
	('��', 'class', String, OPTIONAL),
	('AI����', 'ai', String, OPTIONAL),
	('AIƵ��', 'ai_frequency', Int, OPTIONAL),
	('״̬����', 'state', String, REQUIRED),
	('����buff', 'buff', Int, OPTIONAL),
	('Сͼ��', 'icon', String, OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
