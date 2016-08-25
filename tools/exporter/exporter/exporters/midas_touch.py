# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('����', 'count', Int, REQUIRED),
	('��ʯ', 'diamond', Int, REQUIRED),
	('���', 'gold', Int, REQUIRED),
	('��������', 'critical_multiple', Dict(Int, Int), REQUIRED),

)

import time

def export(old, new, depend, raw):
	return new
