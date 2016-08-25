# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('描述', '', String, COMMENT),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new