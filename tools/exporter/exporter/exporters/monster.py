# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('ģ��id', 'model_id', Int, REQUIRED),
	('��ע1', '', String, COMMENT),
	('��ע2', '', String, COMMENT),
	('����', 'f_att', Float, OPTIONAL),
	('����', 'i_att', Float, OPTIONAL),
	('��Ȼ��', 'n_att', Float, OPTIONAL),
	('��', 'f_def', Float, OPTIONAL),
	('����', 'i_def', Float, OPTIONAL),
	('��Ȼ��', 'n_def', Float, OPTIONAL),
	('Ѫ��', 'max_hp', Int, REQUIRED),
	('������', 'attack', Int, REQUIRED),
	('�����ȼ�', 'crit_level', Int, REQUIRED),
	('�����˺�����', 'crit_damage', Float, REQUIRED),
	('������', 'defense', Int, REQUIRED),
	('����buff', 'buff', Int, OPTIONAL),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
