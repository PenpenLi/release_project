# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('购买次数', 'purchase_count', Int, REQUIRED),
	('钻石', 'diamond', Int, REQUIRED),
	('体力', 'energy', Int, REQUIRED),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
