# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('星级', 'star', Int, REQUIRED),
	('初始星级', 'init_star', Int, OPTIONAL),
	('技能名', 'name', String, REQUIRED),
	('备注', '', String, COMMENT),
	('类型', 'type', Int, OPTIONAL),
	('图标', 'icon', String, REQUIRED),
	('配置', 'conf', String, OPTIONAL),
	('子弹', 'bullet', Array(String), OPTIONAL),
	('宠物模型', 'pet_model_id', Int, OPTIONAL),
	('属性分类', 'element_type', String, OPTIONAL),
	('攻击盒', '', String, COMMENT),
	('控制', '', String, COMMENT),
	('范围', '', String, COMMENT),
	('伤害', '', String, COMMENT),
	('综合', '', String, COMMENT),
	('key值', '', String, COMMENT),
	('战斗力', 'fc_factor', Int, REQUIRED),
	('cd', 'cd', Int, OPTIONAL),
	('自己MP变化', 'mp', String, OPTIONAL),
	('自己HP变化', 'hp', String, OPTIONAL),
	('MP消耗', 'mana_cost', Int, OPTIONAL),
	('伤害公式', 'formula', String, OPTIONAL),
	('火伤', 'f_att', String, OPTIONAL),
	('冰伤', 'i_att', String, OPTIONAL),
	('自然伤', 'n_att', String, OPTIONAL),
	('火抗', 'f_def', String, OPTIONAL),
	('冰抗', 'i_def', String, OPTIONAL),
	('自然抗', 'n_def', String, OPTIONAL),
	('tips', 'tips', String, REQUIRED),
	('星级描述', 'star_tips', String, REQUIRED),
	('高亮字符', 'star_value', Array(String), OPTIONAL),
	('自己获得buff', 's_buff', Array(Int), OPTIONAL),
	('敌人获得buff', 'e_buff', Array(Int), OPTIONAL),
	('对应的动画', 'anim', String, OPTIONAL),
	('ai得分公式', 'ai_score', String, OPTIONAL),
	('ai范围', 'ai_area', Tuple(Int,Int,Int,Int), OPTIONAL),
)

import time

def export(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if not res.has_key(v['id']):
			res[v['id']] = {}
		res[v['id']][v['star']] = v
	return res

def export_initstar(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if v.has_key('init_star') and v['init_star'] == 1:
			res[v['id']] = v['star']
	return res
