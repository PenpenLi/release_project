# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('����ID', 'battle_id', Int, REQUIRED),
	('����BUFF', 'buff_array', Array(Int), REQUIRED),
)

import time

def export(old, new, depend, raw):
	return new
