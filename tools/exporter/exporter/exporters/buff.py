# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('备注', '', String, COMMENT),
	('类型', 'type', Int, OPTIONAL),
	('持续秒', 'duration', Float, REQUIRED),
	('跳动间隔', 'recur', Float, REQUIRED),
	('永久改变', 'p_effect', String, OPTIONAL),
	('临时减益', 't_effect', String, OPTIONAL),
	('霸体', 'is_bati', Int, OPTIONAL),
	('暂停动画', 'pause', Int, OPTIONAL),
	('状态优先级', 'state_order', String, OPTIONAL),
	('AI模块', 'ai', String, OPTIONAL),
	('叠加', 'max', Int, REQUIRED),
	('变色', 'color', Array(Int), OPTIONAL),
	('特效文件', 'effect_file', String, OPTIONAL),
	('特效配置', 'effect_name', Tuple(String,Int), OPTIONAL),
	('特效缩放', 'scale', Tuple(Float, Float), OPTIONAL),
	('特效位置', 'effect_offset', Array(String), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
