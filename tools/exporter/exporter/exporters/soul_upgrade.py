# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('ħ��ȼ�', 'soul_level', Int, REQUIRED),
	('���辭��', 'exp', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	temp_sum = 0
	for k, v in new.iteritems():
		temp_sum = temp_sum + v['exp']
		v['sum_exp'] = temp_sum

	return new
