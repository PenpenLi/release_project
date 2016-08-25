# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('名称', 'name', String, OPTIONAL),
	('字幕', 'subtitle', String, REQUIRED),
	('骨骼路径', 'json', String, OPTIONAL),
	('骨骼名称', 'arm_name', String, OPTIONAL),
	('动画名', 'animation', String, OPTIONAL),
	('开始帧', 'start', Int, OPTIONAL),
	('动画帧数', 'framecount', Int, OPTIONAL),
	('循环播放', 'loop', Int, OPTIONAL),
	('位置', 'position', String, OPTIONAL),
	('Y轴偏移', 'y_offset', Int, OPTIONAL),
	('缩放', 'scale', Float, OPTIONAL),
	('下一句', 'next_id', Int, OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	for k, v in new.iteritems():
		if v.has_key('subtitle'):
			v['subtitle'] = v['subtitle'].replace(r'\\n', r'\n')
	return new
