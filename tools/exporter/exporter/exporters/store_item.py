# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('��Ʒid', 'id', Int, REQUIRED),
	('��Ʒ����', 'name', String, COMMENT),
	('��Ʒid', 'item', Int, REQUIRED),
	('��Ʒ����', 'item_num', Int, OPTIONAL),
	('��ʯ�۸�', 'diamond', Int, OPTIONAL),
	('��Ҽ۸�', 'gold', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
