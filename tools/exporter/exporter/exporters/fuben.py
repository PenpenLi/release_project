# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('�淨', 'type', String, OPTIONAL),
	('�½�id', 'chapter_id', Int, REQUIRED),
	('��ͼid', 'map_id', Int, REQUIRED),
	('����id', 'instance_id', Int, REQUIRED),
	('�ؿ�id', 'id', Int, REQUIRED),
	('��һ��', 'next_barrier', Int, OPTIONAL),
	('ǰ�ùؿ�', 'pre_barrier', Array(Int) , OPTIONAL),
	('����id', 'scene_id', Int, REQUIRED),
	('�ؿ�����', 'name', String, REQUIRED),
	('������������', 'object_conf', String, REQUIRED),
	('AI����', 'ai_conf', String, OPTIONAL),
	('��Ӫ�жԹ�ϵ', 'group_relation', Dict(Int,Dict(Int,Int)), OPTIONAL),
	('�����Ի�', 'begin_dialog', Int, OPTIONAL),
	('�����Ի�', 'end_dialog', Int, OPTIONAL),
	('�Ƽ�ս����', 'fighting_capability', Int, OPTIONAL),
	('�ȼ�����', 'lv_limit', Int, OPTIONAL),
	('����ȼ�', 'monster_level', Int, REQUIRED),
	('��������', 'energy', Int, OPTIONAL),
	('ÿ�մ���', 'daily_limit', Int, OPTIONAL),
	('�״ε���', 'first_drop', Array(Int), OPTIONAL),
	('��������Ȩ��', 'drop', Array(Dict(Int,Int)), OPTIONAL),
	('�������', 'exp', Int, OPTIONAL),
	('ս�龭��', 'soul_exp', Int, OPTIONAL),
	('��Ǯ����', 'gold', Int, OPTIONAL),
	('��ʯ����', 'diamond', Int, OPTIONAL),
	('���⽱��', 'extra_reward', Array(Array(Int)), OPTIONAL),
	('��������ͼ', 'fuben_thumbnail', String, OPTIONAL),
	('����ͼ��', 'monster_icon',Dict(String,Array(Int)), OPTIONAL),
	('�ؿ�����', 'fuben_description', String, OPTIONAL),
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
		
