# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��ע', '', String, COMMENT),
	('qishi_json', 'qishi_json', String, REQUIRED),
	('qishi_name', 'qishi_name', String, REQUIRED),
	('cike_json', 'cike_json', String, REQUIRED),
	('cike_name', 'cike_name', String, REQUIRED),
)

import time

def export(old, new, depend, raw):
	return new
