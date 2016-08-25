# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��Ʒ����', 'name', String, REQUIRED),
	('Ʒ��', 'color', String, OPTIONAL),
	('��ע', '', String, COMMENT),
	('��ɫ������', 'energy', Int, OPTIONAL),
	('ħ��Ӿ���', 'soul_exp', Int, OPTIONAL),
	('��ɫ�Ӿ���', 'exp', Int, OPTIONAL),
	('Сͼ��', 'icon', String, OPTIONAL),
	('tips', 'tips', String, OPTIONAL),
	('��������', 'ui_type', String, OPTIONAL),
	('�ؿ�ID', 'battle_id', Int, OPTIONAL),
	('���ۼ۸�', 'price', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
