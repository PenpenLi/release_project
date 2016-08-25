# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('步骤id', 'id', Int, REQUIRED),
	('备注', '', String, COMMENT),
	('下一个步骤', 'next_step', Int, OPTIONAL),
	('完成条件', 'fin_pre', Int, OPTIONAL),
	('前置步骤', 'pre_step', Int, OPTIONAL),
	('触发器', 'trigger', String, OPTIONAL),
	('触发条件', 'condition', Array(Dict(String,String)), OPTIONAL),
	('中心坐标', 'scene_x_offset', Float, OPTIONAL),
	('延时显示', 'delay', Float, OPTIONAL),
	('提示框资源', 'json', String, OPTIONAL),
	('提示框位置', 'tip_pos', Array(Int), OPTIONAL),
	('提示内容', 'tip_key', String, OPTIONAL),
	('X', 'X', Int, OPTIONAL),
	('Y', 'Y', Int, OPTIONAL),
	('X1', 'X1', Int, OPTIONAL),
	('Y1', 'Y1', Int, OPTIONAL),
	('X2', 'X2', Int, OPTIONAL),
	('Y2', 'Y2', Int, OPTIONAL),
	('原点位置', 'gesture_ori', String, OPTIONAL),
	('手指位置', 'gesture_pos', Array(Int), OPTIONAL),
	('点击区域', 'click_area', Array(Int), OPTIONAL),
	('是否强制', 'force', Int, OPTIONAL),
	('类型', 'guide_type', Int, OPTIONAL),
	('持续时间', 'duration', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
