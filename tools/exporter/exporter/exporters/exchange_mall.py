# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('��Ʒid', 'id', Int, REQUIRED),
	('����', 'good_type', Int, REQUIRED),
	('��Ʒid', 'item_id', Int, REQUIRED),
	('��Ʒ����', 'item_name', String, REQUIRED),
	('��Ʒ����', 'good_desc', String, REQUIRED),
	('��������', 'sell_num', Int, REQUIRED),
	('���Ҽ۸�', 'price', Int, REQUIRED),
	('����λ��', 'position', Array(Int), REQUIRED),
	('�ȼ�����', 'lv_limit', Array(Int), REQUIRED),
	('ˢ��Ȩ��', 'refresh_weight', Int, REQUIRED),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
