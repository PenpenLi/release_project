# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('名字组', 'name', Array(String), REQUIRED),
)

import time

def export(old, new, depend, raw):
	return new
