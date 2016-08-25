# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('�����Ǽ�', 'soul_level', Int, REQUIRED),
	('������Ƭ', 'piece', Int, REQUIRED),
	('�ػ񷵻�', 'refund', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	sum_piece = 0
	for k, v in new.iteritems():
		sum_piece = sum_piece + v['piece']
		v['sum_piece'] = sum_piece
	return new
