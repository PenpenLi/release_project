# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��Ʒ����', 'name', String, OPTIONAL),
	('��Ʒ����', 'title', String, OPTIONAL),
	('��Ʒ����', 'good_type', Int, REQUIRED),
	('RMB', 'price', Int, REQUIRED),
	('��ʯ', 'diamond', Int, OPTIONAL),
	('������ʯ', 'diamond_send', Int, OPTIONAL),
	('�Ƽ�', 'recommend', Int, OPTIONAL),
	('�ۿ�', 'discount', Int, OPTIONAL),
	('�����������', 'can_buy_count', Int, OPTIONAL),
	('ͼ��·��','icon_route',String,OPTIONAL),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
