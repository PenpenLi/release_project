# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('词库', 'words', Array(String), REQUIRED),
	('备注', 'remark', String, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return {}
