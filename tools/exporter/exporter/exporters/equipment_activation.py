# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('品质', 'color', String, REQUIRED),
	('部位', 'bodypart', String, REQUIRED),
	('消耗碎片', 'stone', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		tem_k = v['color'] + '_' + POS_TO_KEY(v['bodypart'])
		res[tem_k] = v['stone']

	return res
