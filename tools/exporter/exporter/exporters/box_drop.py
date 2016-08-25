# -*- coding: UTF-8 -*-

from type_define import *
from utils import *

TYPE = XLS

DEFINE = (
	('�Ƿ񵼱�', '_exp_flag', Bool, OPTIONAL(False)),
	('����ID', 'id', Int, REQUIRED),
	('���ҵ���', 'proxy_money', Int, OPTIONAL),
        ('��������', 'kind', Int, OPTIONAL),
	('��ҵ���', 'money', Int, OPTIONAL),
	('��Ʒ����Ȩ��', 'drop', Array(Dict(Int,Array(Int))), OPTIONAL),
	('��ע', '', String, COMMENT),
)

import time

def export(old, new, depend, raw):
	return new
