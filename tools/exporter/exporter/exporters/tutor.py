# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��ע', '', String, COMMENT),
	('�����¼�', 'event', String, REQUIRED),
	('�󶨹���ID', 'bind_monster', String, OPTIONAL),
	('������', 'func_name', String, REQUIRED),
	('����', 'func_arg', Array(String), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
