# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��Ʒ����', 'name', String, REQUIRED),
	('Ʒ��', 'color', String, REQUIRED),
	('��ע', '', String, COMMENT),
	('Сͼ��', 'icon', String, OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
	('���ۼ۸�', 'price', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
