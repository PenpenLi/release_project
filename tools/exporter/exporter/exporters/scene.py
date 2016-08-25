# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('场景id', 'id', Int, REQUIRED),
	('入口坐标', 'born_pos', Tuple(Int,Int), REQUIRED),
	('场景宽度', 'width', Int, REQUIRED),
	('场景高度', 'height', Int, REQUIRED),
	('台阶文件名', 'floot_file', String, REQUIRED),
	('台阶对象层名', 'floot', String, REQUIRED),
	('背景文件名', 'bg_json', String, REQUIRED),
	('背景音乐名', 'bg_music', String, REQUIRED),
	('头像坐标', 'head_portrait_pos', Tuple(Int,Int), REQUIRED),
	('背景的tag值', 'root_tag', Int, REQUIRED),
	('0层速率', 'sr_0', Float, REQUIRED),
	('01层速率', 'sr_01', Float, REQUIRED),
	('02层速率', 'sr_02', Float, REQUIRED),
	('03层速率', 'sr_03', Float, REQUIRED),
	('04层速率', 'sr_04', Float, REQUIRED),
	('05层速率', 'sr_05', Float, REQUIRED),
	('场景动画', 'scene_anims', Array(String), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
