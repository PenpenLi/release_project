# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('������', 'name', String, REQUIRED),
	('�ȼ�����', 'Lv', Int, REQUIRED),
	('Ʒ��', 'color', String, OPTIONAL),
	('����', 'attack', Float, OPTIONAL),
	('����', 'defense', Float, OPTIONAL),
	('Ѫ��', 'max_hp', Float, OPTIONAL),
	('����', 'crit_level', Float, OPTIONAL),
	('����_����', 'act_attack', Float, OPTIONAL),
	('����_����', 'act_defense', Float, OPTIONAL),
	('����_Ѫ��', 'act_max_hp', Float, OPTIONAL),
	('����_����', 'act_crit_level', Float, OPTIONAL),
	('����', 'description', String, OPTIONAL),
	('Сͼ��', 'icon', String, OPTIONAL),
	('�ļ���', 'file', String, OPTIONAL),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
