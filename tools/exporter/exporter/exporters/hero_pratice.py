# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('场景ID', 'battle_id', Int, REQUIRED),
	('所加BUFF', 'buff_array', Array(Int), REQUIRED),
)

import time

def export(old, new, depend, raw):
	return new
