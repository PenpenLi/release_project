# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('��ע', '', String, COMMENT),
	('����', 'nick_name', String, REQUIRED),
	('��ɫ����', 'role_type', String, REQUIRED),
	('��ͨ1', 'proficient1', Int, REQUIRED),
	('��ͨ2', 'proficient2', Int, REQUIRED),
	('��ͨ3', 'proficient3', Int, REQUIRED),
	('��ͨ4', 'proficient4', Int, REQUIRED),
	('��ͨ5', 'proficient5', Int, REQUIRED),
	('��ͨ6', 'proficient6', Int, REQUIRED),
	('��Ǯ', 'money', Int, REQUIRED),
	('�ȼ�', 'lv', Int, REQUIRED),
	('����', 'exp', Int, REQUIRED),
	('����', 'energy', Int, REQUIRED),
	('��ʯ', 'diamond', Int, REQUIRED),
	('����ID', 'weapon', Int, REQUIRED),
	('����ǿ��', 'weapon_lv', Int, OPTIONAL),
	('����ID', 'armor', Int, REQUIRED),
	('����ǿ��', 'armor_lv', Int, OPTIONAL),
	('ͷ��ID', 'helmet', Int, REQUIRED),
	('ͷ��ǿ��', 'helmet_lv', Int, OPTIONAL),
	('��ָID', 'ring', Int, REQUIRED),
	('��ָǿ��', 'ring_lv', Int, OPTIONAL),
	('����ID', 'necklace', Int, REQUIRED),
	('����ǿ��', 'necklace_lv', Int, OPTIONAL),
	('Ь��ID', 'shoe', Int, REQUIRED),
	('Ь��ǿ��', 'shoe_lv', Int, OPTIONAL),
	('����1', 'skill1', Int, OPTIONAL),
	('��1�ȼ�', 'skill1_lv', Int, OPTIONAL),
	('��1�Ǽ�', 'skill1_star', Int, OPTIONAL),
	('����2', 'skill2', Int, OPTIONAL),
	('��2�ȼ�', 'skill2_lv', Int, OPTIONAL),
	('��2�Ǽ�', 'skill2_star', Int, OPTIONAL),
	('����3', 'skill3', Int, OPTIONAL),
	('��3�ȼ�', 'skill3_lv', Int, OPTIONAL),
	('��3�Ǽ�', 'skill3_star', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
