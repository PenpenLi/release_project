# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('��ƷID', 'item_id', Int, REQUIRED),
	('��Ʒ����', 'item_name', String, REQUIRED),
	(';��1����', 'pathway1_type', Int, OPTIONAL()),
	(';��1����', 'pathway1_content', Int, OPTIONAL()),
	(';��1icon', 'pathway1_icon', String, OPTIONAL()),
	(';��2����', 'pathway2_type', Int, OPTIONAL()),
	(';��2����', 'pathway2_content', Int, OPTIONAL()),
	(';��2icon', 'pathway2_icon', String, OPTIONAL()),
	(';��3����', 'pathway3_type', Int, OPTIONAL()),
	(';��3����', 'pathway3_content', Int, OPTIONAL()),
	(';��3icon', 'pathway3_icon', String, OPTIONAL()),
)

import time

def export(old, new, depend, raw):
	return new
