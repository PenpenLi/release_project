# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('����id', 'boss_id', Int, REQUIRED),
	('�����ؿ�', 'unlock', Int, REQUIRED),
	('��ת�ؿ�', 'battle_id', Int, REQUIRED),
    ('��������', 'property', String, REQUIRED),
	('����ͼ��', 'icon', String, REQUIRED),
	('��ע', 'remark', String, REQUIRED),
)

import time

def export(old, new, depend, raw):
	return new
