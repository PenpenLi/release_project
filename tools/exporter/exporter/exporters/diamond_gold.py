# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��Ʒ����', 'name', String, REQUIRED),
	('Сͼ��', 'icon', String, REQUIRED),
	('tips', 'tips', String, REQUIRED),
	('color', 'color', String, REQUIRED),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
