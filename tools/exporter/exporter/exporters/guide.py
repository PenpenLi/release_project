# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('����id', 'id', Int, REQUIRED),
	('��ע', '', String, COMMENT),
	('��һ������', 'next_step', Int, OPTIONAL),
	('�������', 'fin_pre', Int, OPTIONAL),
	('ǰ�ò���', 'pre_step', Int, OPTIONAL),
	('������', 'trigger', String, OPTIONAL),
	('��������', 'condition', Array(Dict(String,String)), OPTIONAL),
	('��������', 'scene_x_offset', Float, OPTIONAL),
	('��ʱ��ʾ', 'delay', Float, OPTIONAL),
	('��ʾ����Դ', 'json', String, OPTIONAL),
	('��ʾ��λ��', 'tip_pos', Array(Int), OPTIONAL),
	('��ʾ����', 'tip_key', String, OPTIONAL),
	('X', 'X', Int, OPTIONAL),
	('Y', 'Y', Int, OPTIONAL),
	('X1', 'X1', Int, OPTIONAL),
	('Y1', 'Y1', Int, OPTIONAL),
	('X2', 'X2', Int, OPTIONAL),
	('Y2', 'Y2', Int, OPTIONAL),
	('ԭ��λ��', 'gesture_ori', String, OPTIONAL),
	('��ָλ��', 'gesture_pos', Array(Int), OPTIONAL),
	('�������', 'click_area', Array(Int), OPTIONAL),
	('�Ƿ�ǿ��', 'force', Int, OPTIONAL),
	('����', 'guide_type', Int, OPTIONAL),
	('����ʱ��', 'duration', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
