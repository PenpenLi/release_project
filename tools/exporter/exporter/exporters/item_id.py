# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('ÊÇ·ñµ¼±í', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
)

import time

# old:
#		old exported data
# new:
#		raw data
# depend:
#		(depend rule, all exported data)
# raw:
#		all raw data
# return:
#		exported data
def export(old, new, depend, raw):
	res = {}
	for k in depend[0]:
		for id in depend[1][k].iterkeys():
			res[id] = k
	return res
