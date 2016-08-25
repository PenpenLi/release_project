# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('����', 'date', String, REQUIRED),
	('ǩ������', 'reward', Tuple(Int, Int), OPTIONAL()),
	('��������VIP�ȼ�', 'vip_lv_needed', Int, REQUIRED),
	('����', 'mul_num', Int, REQUIRED),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
