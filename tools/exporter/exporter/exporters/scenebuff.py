# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��ע', '', String, COMMENT),
	('buff_id', 'buff_id', Array(Int), REQUIRED),
	('name', 'name', String, REQUIRED),
	('����ʱ��', 'duration', Int, REQUIRED),
	('��������', 'distance', Array(Int), OPTIONAL),
	('��Ч����', 'scale', Array(Float), OPTIONAL),
	('idle', 'idle', String, REQUIRED),
	('idle_anim', 'idle_anim', Array(Int), REQUIRED),
	('attack', 'attack', String, OPTIONAL),
	('attack_anim', 'attack_anim', Array(Int), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
