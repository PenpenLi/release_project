# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('次数', 'count', Int, REQUIRED),
	('钻石', 'diamond', Int, REQUIRED),
	('金币', 'gold', Int, REQUIRED),
	('暴击翻倍', 'critical_multiple', Dict(Int, Int), REQUIRED),

)

import time

def export(old, new, depend, raw):
	return new
