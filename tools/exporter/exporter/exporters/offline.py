# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('id', 'id', Int, REQUIRED),
	('备注', '', String, COMMENT),
	('名称', 'nick_name', String, REQUIRED),
	('角色类型', 'role_type', String, REQUIRED),
	('精通1', 'proficient1', Int, REQUIRED),
	('精通2', 'proficient2', Int, REQUIRED),
	('精通3', 'proficient3', Int, REQUIRED),
	('精通4', 'proficient4', Int, REQUIRED),
	('精通5', 'proficient5', Int, REQUIRED),
	('精通6', 'proficient6', Int, REQUIRED),
	('金钱', 'money', Int, REQUIRED),
	('等级', 'lv', Int, REQUIRED),
	('经验', 'exp', Int, REQUIRED),
	('体力', 'energy', Int, REQUIRED),
	('钻石', 'diamond', Int, REQUIRED),
	('武器ID', 'weapon', Int, REQUIRED),
	('武器强化', 'weapon_lv', Int, OPTIONAL),
	('盔甲ID', 'armor', Int, REQUIRED),
	('盔甲强化', 'armor_lv', Int, OPTIONAL),
	('头盔ID', 'helmet', Int, REQUIRED),
	('头盔强化', 'helmet_lv', Int, OPTIONAL),
	('戒指ID', 'ring', Int, REQUIRED),
	('戒指强化', 'ring_lv', Int, OPTIONAL),
	('项链ID', 'necklace', Int, REQUIRED),
	('项链强化', 'necklace_lv', Int, OPTIONAL),
	('鞋子ID', 'shoe', Int, REQUIRED),
	('鞋子强化', 'shoe_lv', Int, OPTIONAL),
	('技能1', 'skill1', Int, OPTIONAL),
	('技1等级', 'skill1_lv', Int, OPTIONAL),
	('技1星级', 'skill1_star', Int, OPTIONAL),
	('技能2', 'skill2', Int, OPTIONAL),
	('技2等级', 'skill2_lv', Int, OPTIONAL),
	('技2星级', 'skill2_star', Int, OPTIONAL),
	('技能3', 'skill3', Int, OPTIONAL),
	('技3等级', 'skill3_lv', Int, OPTIONAL),
	('技3星级', 'skill3_star', Int, OPTIONAL),
)

import time

def export(old, new, depend, raw):
	return new
