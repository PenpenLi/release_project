# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��ע', '', String, COMMENT),
	('����', 'type', Int, OPTIONAL),
	('������', 'duration', Float, REQUIRED),
	('�������', 'recur', Float, REQUIRED),
	('���øı�', 'p_effect', String, OPTIONAL),
	('��ʱ����', 't_effect', String, OPTIONAL),
	('����', 'is_bati', Int, OPTIONAL),
	('��ͣ����', 'pause', Int, OPTIONAL),
	('״̬���ȼ�', 'state_order', String, OPTIONAL),
	('AIģ��', 'ai', String, OPTIONAL),
	('����', 'max', Int, REQUIRED),
	('��ɫ', 'color', Array(Int), OPTIONAL),
	('��Ч�ļ�', 'effect_file', String, OPTIONAL),
	('��Ч����', 'effect_name', Tuple(String,Int), OPTIONAL),
	('��Ч����', 'scale', Tuple(Float, Float), OPTIONAL),
	('��Чλ��', 'effect_offset', Array(String), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
