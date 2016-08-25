# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('进化星级', 'soul_level', Int, REQUIRED),
	('所需碎片', 'piece', Int, REQUIRED),
	('重获返还', 'refund', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	sum_piece = 0
	for k, v in new.iteritems():
		sum_piece = sum_piece + v['piece']
		v['sum_piece'] = sum_piece
	return new
