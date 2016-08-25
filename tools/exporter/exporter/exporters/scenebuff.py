# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('备注', '', String, COMMENT),
	('buff_id', 'buff_id', Array(Int), REQUIRED),
	('name', 'name', String, REQUIRED),
	('存在时间', 'duration', Int, REQUIRED),
	('触发距离', 'distance', Array(Int), OPTIONAL),
	('特效缩放', 'scale', Array(Float), OPTIONAL),
	('idle', 'idle', String, REQUIRED),
	('idle_anim', 'idle_anim', Array(Int), REQUIRED),
	('attack', 'attack', String, OPTIONAL),
	('attack_anim', 'attack_anim', Array(Int), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
