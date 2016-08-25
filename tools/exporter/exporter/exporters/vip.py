# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('vip�ȼ�', 'vip_lv', Int, REQUIRED),
	('�����ü���������ʯ', 'sum_diamond', Int, REQUIRED),
	('ÿ�տɹ�����������', 'energy_max', Int, REQUIRED),
	('ÿ�տ�ʹ�õ���ִ���', 'midas_max', Int, REQUIRED),
	('ÿ�վ�Ӣ���������ô���', 'jy_reset_max', Int, REQUIRED),
	('ÿ������ɨ��ȯ����', 'free_sweep', Int, REQUIRED),
	('��Ȩ����', 'privilege', String, REQUIRED),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
