# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('是否导表', '_exp_flag', Bool, OPTIONAL(False)),
	('宝箱ID', 'id', Int, REQUIRED),
	('代币掉落', 'proxy_money', Int, OPTIONAL),
        ('代币种类', 'kind', Int, OPTIONAL),
	('金币掉落', 'money', Int, OPTIONAL),
	('物品掉落权重', 'drop', Array(Dict(Int,Array(Int))), OPTIONAL),
	('备注', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
