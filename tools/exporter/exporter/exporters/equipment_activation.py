# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('Ʒ��', 'color', String, REQUIRED),
	('��λ', 'bodypart', String, REQUIRED),
	('������Ƭ', 'stone', Int, REQUIRED),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		tem_k = v['color'] + '_' + POS_TO_KEY(v['bodypart'])
		res[tem_k] = v['stone']

	return res
