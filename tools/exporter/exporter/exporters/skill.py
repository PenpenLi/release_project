# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('�Ǽ�', 'star', Int, REQUIRED),
	('��ʼ�Ǽ�', 'init_star', Int, OPTIONAL),
	('������', 'name', String, REQUIRED),
	('��ע', '', String, COMMENT),
	('����', 'type', Int, OPTIONAL),
	('ͼ��', 'icon', String, REQUIRED),
	('����', 'conf', String, OPTIONAL),
	('�ӵ�', 'bullet', Array(String), OPTIONAL),
	('����ģ��', 'pet_model_id', Int, OPTIONAL),
	('���Է���', 'element_type', String, OPTIONAL),
	('������', '', String, COMMENT),
	('����', '', String, COMMENT),
	('��Χ', '', String, COMMENT),
	('�˺�', '', String, COMMENT),
	('�ۺ�', '', String, COMMENT),
	('keyֵ', '', String, COMMENT),
	('ս����', 'fc_factor', Int, REQUIRED),
	('cd', 'cd', Int, OPTIONAL),
	('�Լ�MP�仯', 'mp', String, OPTIONAL),
	('�Լ�HP�仯', 'hp', String, OPTIONAL),
	('MP����', 'mana_cost', Int, OPTIONAL),
	('�˺���ʽ', 'formula', String, OPTIONAL),
	('����', 'f_att', String, OPTIONAL),
	('����', 'i_att', String, OPTIONAL),
	('��Ȼ��', 'n_att', String, OPTIONAL),
	('��', 'f_def', String, OPTIONAL),
	('����', 'i_def', String, OPTIONAL),
	('��Ȼ��', 'n_def', String, OPTIONAL),
	('tips', 'tips', String, REQUIRED),
	('�Ǽ�����', 'star_tips', String, REQUIRED),
	('�����ַ�', 'star_value', Array(String), OPTIONAL),
	('�Լ����buff', 's_buff', Array(Int), OPTIONAL),
	('���˻��buff', 'e_buff', Array(Int), OPTIONAL),
	('��Ӧ�Ķ���', 'anim', String, OPTIONAL),
	('ai�÷ֹ�ʽ', 'ai_score', String, OPTIONAL),
	('ai��Χ', 'ai_area', Tuple(Int,Int,Int,Int), OPTIONAL),
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
