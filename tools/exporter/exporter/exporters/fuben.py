# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('玩法', 'type', String, OPTIONAL),
	('章节id', 'chapter_id', Int, REQUIRED),
	('地图id', 'map_id', Int, REQUIRED),
	('副本id', 'instance_id', Int, REQUIRED),
	('关卡id', 'id', Int, REQUIRED),
	('下一关', 'next_barrier', Int, OPTIONAL),
	('前置关卡', 'pre_barrier', Array(Int) , OPTIONAL),
	('场景id', 'scene_id', Int, REQUIRED),
	('关卡名字', 'name', String, REQUIRED),
	('场景物体配置', 'object_conf', String, REQUIRED),
	('AI配置', 'ai_conf', String, OPTIONAL),
	('阵营敌对关系', 'group_relation', Dict(Int,Dict(Int,Int)), OPTIONAL),
	('开场对话', 'begin_dialog', Int, OPTIONAL),
	('结束对话', 'end_dialog', Int, OPTIONAL),
	('推荐战斗力', 'fighting_capability', Int, OPTIONAL),
	('等级限制', 'lv_limit', Int, OPTIONAL),
	('怪物等级', 'monster_level', Int, REQUIRED),
	('消耗体力', 'energy', Int, OPTIONAL),
	('每日次数', 'daily_limit', Int, OPTIONAL),
	('首次掉落', 'first_drop', Array(Int), OPTIONAL),
	('副本掉落权重', 'drop', Array(Dict(Int,Int)), OPTIONAL),
	('经验掉落', 'exp', Int, OPTIONAL),
	('战灵经验', 'soul_exp', Int, OPTIONAL),
	('金钱掉落', 'gold', Int, OPTIONAL),
	('钻石掉落', 'diamond', Int, OPTIONAL),
	('额外奖励', 'extra_reward', Array(Array(Int)), OPTIONAL),
	('副本缩略图', 'fuben_thumbnail', String, OPTIONAL),
	('怪物图标', 'monster_icon',Dict(String,Array(Int)), OPTIONAL),
	('关卡描述', 'fuben_description', String, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new

def export_entrance(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if not res.has_key(v['chapter_id']):
			res[v['chapter_id']] = {}
		if not res[v['chapter_id']].has_key(v['instance_id']):
			res[v['chapter_id']][v['instance_id']] = -1
		if res[v['chapter_id']][v['instance_id']] == -1 or res[v['chapter_id']][v['instance_id']] > v['id']:
			res[v['chapter_id']][v['instance_id']] = v['id']
	return res
		
def export_type_entrance(old, new, depend, raw):
	res = {}
	for k, v in new.iteritems():
		if v.has_key('type'):
			if not res.has_key(v['type']):
				res[v['type']] = -1
			if res[v['type']] == -1 or res[v['type']] > v['chapter_id']:
				res[v['type']] = v['chapter_id']
		else:
			if not res.has_key('normal'):
				res['normal'] = -1
			if res['normal'] == -1 or res['normal'] > v['chapter_id']:
				res['normal'] = v['chapter_id']
	return res
		
