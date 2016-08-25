# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('����id', 'id', Int, REQUIRED),
	('�������', 'born_pos', Tuple(Int,Int), REQUIRED),
	('�������', 'width', Int, REQUIRED),
	('�����߶�', 'height', Int, REQUIRED),
	('̨���ļ���', 'floot_file', String, REQUIRED),
	('̨�׶������', 'floot', String, REQUIRED),
	('�����ļ���', 'bg_json', String, REQUIRED),
	('����������', 'bg_music', String, REQUIRED),
	('ͷ������', 'head_portrait_pos', Tuple(Int,Int), REQUIRED),
	('������tagֵ', 'root_tag', Int, REQUIRED),
	('0������', 'sr_0', Float, REQUIRED),
	('01������', 'sr_01', Float, REQUIRED),
	('02������', 'sr_02', Float, REQUIRED),
	('03������', 'sr_03', Float, REQUIRED),
	('04������', 'sr_04', Float, REQUIRED),
	('05������', 'sr_05', Float, REQUIRED),
	('��������', 'scene_anims', Array(String), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
