# -*- coding: UTF-8 -*-

"""
��������
TYPE = XXX
DEFINE = XXX

type��Const�����ָ�������ļ���ʽΪCSV����XML
define�����ָ�������ļ������ʽ

CSV��������
	TYPE = CSV
	DEFINE = (
		(column, field, type, require, share),
		...
	)
	���磺
	��1,lie2
	1,2
	DEFINE = (
		('��1', 'c1', Int, REQUIRED, SERVER),
		('lie2', 'c2', UInt, OPTIONAL, CLIENT),
	)

	*CSV�ᰴ��DEFINE�ж����column˳��ȥ��������ļ�
	column���ַ�����CSV��ͷ������
	field���ַ���������ΪJSON�Ķ�Ӧ�ֶ�������ʹ��"field.subfield"������ʽ����Ƕ��
	type�����ͣ��涨���������ʽ�͵�������
	require���������ͣ��涨������������
		REQUIRED������
		OPTIONAL(default)��ѡ�defaultΪ����Ĭ��ֵ����ֵ��������κε������Id���ͼ�飬�����������ã�Ĭ��ΪNone����ʾ����Ч
		GROUP(name)��ͬname���飬����ͬʱ�����ͬʱ����
	share���������ͣ�ѡ�ֻ����SERVER��CLIENT��COMMON��Ĭ��ΪCOMMON������list��share����ΪSPLIT���������ܶ���
		COMMENT������

XML��������
	TYPE = XML
	DEFINE = {
		root: child,
		tag: (name, type, share, (tag1, tag2, ...tagN),(
			(attr, field, type, require, share),
			...)),
		...
	}
	���磺
	<buffers>
		<buff time="1">
			<feature visiable="1"/>
		</buff>
	</buffers>
	DEFINE = {
		'root': 'buff',
		'buff': ('bf', MULTIPLE, ('feature', ), (
			('time', 't', Int, REQUIRED),)),
		'feature': ('ft', SINGLE, (), (
			('visiable', 'v', Bool, OPTIONAL),)),
	}

	*XML���ᰴ��DEFINE��attr��tag�Ķ���˳��ȥ���attr�Ķ���˳��
	root������ǩ������Ϊ�����DEFINE�б������һ��"root"Keyָ��XML��root�а����ĵ�һ�ӱ�ǩ�����ӱ�ǩ����ΪDICT
	tag���ַ�����XML��ǩ��
	name���ַ�����XML��ǩ����ΪJSON�Ķ�Ӧ�ֶ���
	attr���ַ�����XML������
	type���ַ�����tag�б�ʾ�ñ�ǩ������
		SINGLE����һ��ǩ
		ARRAY���ɶ����ǩ�����γ����飬����xml['tag'] = [..]
		DICT(name)���ɶ����ǩ������nameָ������������ΪKey�γ��ֵ�xml['tag'] = {...}���ر�ģ�root����Ϊxml = {...}
	share���������ͣ�ѡ�ֻ����SERVER��CLIENT��COMMON��Ĭ��ΪCOMMON������list����tag��share����ΪSPLIT���������ܶ���
	type�����ͣ�attr�й涨���������ʽ�͵�������
	field���ַ���������ΪJSON�Ķ�Ӧ�ֶ���������ʹ��"field.subfield"������ʽ����Ƕ�ף�XML�Ѿ�ӵ�в����
	require���������ͣ��涨������������
		REQUIRED������
		OPTIONAL(default)��ѡ�defaultΪ����Ĭ��ֵ����ֵ��������κε������Id���ͼ�飬�����������ã�Ĭ��ΪNone����ʾ����Ч
		GROUP(name)��ͬname���飬����ͬʱ�����ͬʱ������÷�ΧΪͬһ��tag������
	share���������ͣ�ѡ�ֻ����SERVER��CLIENT��COMMON��Ĭ��ΪCOMMON������tag��share����ΪSPLIT���������ܶ���
		COMMENT������

ԭ��������export������Ϊ"������ģ����.json"��JSON�ļ�
def export(old, new, depend, raw):
	...
	return ret

	old����Ӧ�ľ�����
	new���µ���������
	depend���õ������������������飬ʹ��define module + exporter function��������
	raw�����ε������е�ԭʼ���ݣ�û�о��������飬ʹ��define module��������
	ret�����ؾ�����֤/�޸ĵ����ݣ����߷���None��ʾ����

����������export_xxx������Ϊ"������ģ����_xxx.json"��JSON�ļ�
def export_xxx(old, new, depend, raw):
	...
	return ret

	old����Ӧ�ľ�����
	new���µ���������
	depend���õ������������������飬ʹ��define module + exporter function��������
	raw�����ε������е�ԭʼ���ݣ�û�о��������飬ʹ��define module��������
	ret�����ؾ�����֤/�޸ĵ����ݣ����߷���None��ʾ����

����������Ϊ���ݶ�������ͣ����͵Ĳ������ǿ�ѡ��
���磺�ɶ���String���������ַ�����Ҳ�ɶ���String(encoding='ascii')������Ӣ���ַ�

��������
	String
		encoding���ַ������룬Ĭ��UTF-8
		min����С���ȣ����ձ������ȷ�����ȣ���������1���ֳ�����1��Ĭ�ϲ�����
		max����󳤶ȣ�����ͬ�ϣ�Ĭ�ϲ�����

	Bool����дʱֻ����д1��0��true��false
		mode������ģʽ��Ĭ��Ϊstr
			str������Ϊ�ַ���true��false��ռ�ռ�࣬C++�ж�����Ҳ��true��false
			int������Ϊ���֣�1��0��ռ�ռ��٣�C++�ж�����Ҳ��1��0

	Int��UInt��Float
		min����Сֵ
		max�����ֵ

	Id������RULES�ж����index�ֶν��м���
		type�����ͣ������ǻ�������
		index�����֣�������RULES�ж����index�ֶ�֮һ

	Pack����������ͽ��з����ʹ�����Ա�Ϊһ���������ͣ��Ӷ����³�Ϊ������͵�Ԫ��

�������
	Array(type)����ͬ��type���͵�Ԫ����ɵ����飬��������
		���type type type ...
		type������Ϊ�κ�����

	Tuple(type1, type2, ..typeN)����N��type���͵�Ԫ����ɵ�Ԫ�飬�����̶�
		���type1 type2 ..typeN
		type1-N������Ϊ�κ�����

	Dict(typeK, typeV)����typeK����ΪKey��typeV����ΪValue��Ԫ����ɵ��ֵ䣬��������
		���typeK|typeV typeK|typeV ...
		typeK�������ǻ�������
		typeV������Ϊ�κ�����

Ƕ������
	��������ڵ����������Ҫ��()������
"""

import codecs
import inspect

CSV = 1
XML = 2
XLS = 3
AVAILABLE_CONF_TYPE = (CSV, XML, XLS)

COMMON = 1
SERVER = 2
CLIENT = 3
SPLIT = 4

MAX_LEVEL = 80
STRENGTH_LV = 6
MAX_EQUIP_LEVEL = 30

DIC_QUALITY = ['Green', 'Blue', 'Purple', 'Orange']
DIC_POSITION = ['weapon', 'armor', 'helmet', 'necklace', 'ring', 'shoe']

# ���岿λ -> key
def POS_TO_KEY(cn_name):
	if cn_name == '����':
		return 'weapon'
	if cn_name == '��ָ':
		return 'ring'
	if cn_name == '����':
		return 'armor'
	if cn_name == 'Ь��':
		return 'shoe'
	if cn_name == 'ͷ��':
		return 'helmet'
	if cn_name == '����':
		return 'necklace'
	return 'unknown'

REQUIRED = 1
class OPTIONAL(object):
	def __init__(self, default = None):
		super(OPTIONAL, self).__init__()
		self.default = default
def GROUP(name):
	return name
COMMENT = 4

SINGLE = 1
ARRAY = 2
def DICT(name):
	return name

def is_optional(v):
	return (inspect.isclass(v) and issubclass(v, OPTIONAL)) or isinstance(v, OPTIONAL)

def is_string(v):
	return isinstance(v, basestring)

def is_integer(v):
	return isinstance(v, int) or isinstance(v, long)

def is_float(v):
	return isinstance(v, float)

def compare_float(f1, f2):
	zero = 0.00001
	diff = f1 - f2
	if diff > zero:
		return 1
	if diff < -zero:
		return -1
	return 0

def is_anytype(v):
	return (inspect.isclass(v) and issubclass(v, _Type)) or isinstance(v, _Type)

def is_basetype(v):
	return (inspect.isclass(v) and issubclass(v, _BaseType)) or isinstance(v, _BaseType)

class _Type(object):
	def get_idtype(self):
		return []

	def get_idvalue(self, v):
		return {}

	def check_option(self):
		return True, ''

	def export_value(self, v):
		if not is_string(v):
			return None, '����һ���ɽ������ַ���'
		return v, ''

class _BaseType(_Type):
	pass

class _ComboType(_Type):
	pass

class Bool(_BaseType):
	def __init__(self, mode = 'str'):
		super(Bool, self).__init__()
		self.mode = mode

	def __str__(self):
		if self.mode == 'str':
			return '�������ַ���'
		else:
			return '���������֣�'

	def check_option(self):
		rst, msg = super(Bool, self).check_option()
		if not rst:
			return False, msg
		if self.mode not in ('str', 'int'):
			return False, 'ģʽ����Ϊ"str"����"int"'
		return True, ''

	def export_value(self, v):
		rst, msg = super(Bool, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		if v not in ('1.0', '0.0', '1', '0', 'true', 'false'):
			return None, '��%s������һ������ֵ' % v
		if v in ('1', '1.0', 'true'):
			v = True
		else:
			v = False
		if self.mode == 'int':
			v = int(v)
		return v, ''

class String(_BaseType):
	def __init__(self, encoding = 'GBK', min = None, max = None):
		super(String, self).__init__()
		self.encoding = encoding
		self.min = min
		self.max = max

	def __str__(self):
		options = []
		options.append('%s����' % self.encoding)
		if self.min != None:
			options.append('��С����%d' % self.min)
		if self.max != None:
			options.append('��󳤶�%d' % self.max)
		if options:
			return '�ַ�����%s��' % '��'.join(options)
		else:
			return '�ַ���'

	def check_option(self):
		rst, msg = super(String, self).check_option()
		if not rst:
			return False, msg
		if not is_string(self.encoding):
			return False, '�������ñ���Ϊ�ַ���'
		try:
			codecs.lookup(self.encoding)
		except:
			return False, '�������ñ���Ϊϵͳ֧�ֵı���'
		if self.min != None:
			if not is_integer(self.min):
				return False, '��С�������ñ���Ϊ����'
			if self.min <= 0:
				return False, '��С�������ñ���Ϊ����0'
		if self.max != None:
			if not is_integer(self.max):
				return False, '��󳤶����ñ���Ϊ����'
			if self.max <= 0:
				return False, '��󳤶����ñ���Ϊ����0'
			if self.min != None and self.max < self.min:
				return False, '��󳤶����ñ��������С��������'
		return True, ''

	def export_value(self, v):
		rst, msg = super(String, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		try:
			v.decode(self.encoding)
		except:
			return None, '�ַ�����%s��������%s����' % (v, self.encoding)
		if '\'' in v:
			return None, '�ַ�����%s�����ܰ���\'��Ӣ�ĵ����ţ�' % v
		for c in ('\\', '"'):
			v = v.replace(c, '\\' + c)
		if self.min != None and len(v) < self.min:
			return None, '�ַ�����%s������С����С����%d' % (v, self.min)
		if self.max != None and len(v) > self.max:
			return None, '�ַ�����%s�����ȴ�����󳤶�%d' % (v, self.max)
		return v, ''

class Int(_BaseType):
	def __init__(self, min = None, max = None):
		super(Int, self).__init__()
		self.min = min
		self.max = max

	def __str__(self):
		options = []
		if self.min != None:
			options.append('��Сֵ%d' % self.min)
		if self.max != None:
			options.append('���ֵ%d' % self.max)
		if options:
			return '������%s��' % '��'.join(options)
		else:
			return '����'

	def check_option(self):
		rst, msg = super(Int, self).check_option()
		if not rst:
			return False, msg
		if self.min != None:
			if not is_integer(self.min):
				return False, '��Сֵ���ñ���Ϊ����'
		if self.max != None:
			if not is_integer(self.max):
				return False, '���ֵ���ñ���Ϊ����'
			if self.min != None and self.max < self.min:
				return False, '���ֵ���ñ��������Сֵ����'
		return True, ''

	def export_value(self, v):
		rst, msg = super(Int, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		try:
			v = int(v)
		except:
			try:
				v = int(float(v))
			except:
				return None, '��%s������һ������' % v
		if self.min != None and v < self.min:
			return None, '������%d��С����Сֵ%d' % (v, self.min)
		if self.max != None and v > self.max:
			return None, '������%d���������ֵ%d' % (v, self.max)
		return v, ''

class UInt(Int):
	def __init__(self, min = 0, max = None):
		super(UInt, self).__init__(min, max)

class Float(_BaseType):
	def __init__(self, min = None, max = None):
		super(Float, self).__init__()
		self.min = min
		self.max = max

	def __str__(self):
		options = []
		if self.min != None:
			options.append('��Сֵ%.2f' % self.min)
		if self.max != None:
			options.append('���ֵ%.2f' % self.max)
		if options:
			return '��������%s��' % '��'.join(options)
		else:
			return '������'

	def check_option(self):
		rst, msg = super(Float, self).check_option()
		if not rst:
			return False, msg
		if self.min != None:
			if not is_float(self.min):
				return False, '��Сֵ���ñ���Ϊ������'
		if self.max != None:
			if not is_float(self.max):
				return False, '���ֵ���ñ���Ϊ������'
			if self.min != None and compare_float(self.max, self.min) < 0:
				return False, '���ֵ���ñ��������Сֵ����'
		return True, ''

	def export_value(self, v):
		rst, msg = super(Float, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		try:
			v = float(v)
		except:
			return None, '��%s������һ��������' % v
		if self.min != None and compare_float(v, self.min) < 0:
			return None, '��������%.2f��С����Сֵ%.2f' % (v, self.min)
		if self.max != None and compare_float(v, self.max) > 0:
			return None, '��������%.2f���������ֵ%.2f' % (v, self.max)
		return v, ''

class Id(_BaseType):
	def __init__(self, index):
		super(Id, self).__init__()
		self.type = None
		self.index = index

	def __str__(self):
		return 'Id������%s������%s��' % (str(self.type), self.index)

	def get_idtype(self):
		return [self]

	def get_idvalue(self, v):
		return {self.index: set([v])}

	def check_option(self):
		rst, msg = super(Id, self).check_option()
		if not rst:
			return False, msg
		if not is_string(self.index):
			return False, 'Id��������Ϊ�ַ���'
		return True, ''

	def export_value(self, v):
		rst, msg = super(Id, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		rst, msg = self.type.export_value(v)
		if rst == None:
			return None, 'Id����>' + msg
		v = rst
		return v, ''

class Pack(_BaseType):
	def __init__(self, type):
		super(Pack, self).__init__()
		self.type = type

	def __str__(self):
		return '����%s��' % str(self.type)

	@staticmethod
	def parse_pack(v, split):
		groups = []
		pack = 0
		begin = 0
		for i in xrange(len(v)):
			if v[i] == split:
				if pack == 0:
					groups.append(v[begin:i])
					begin = i + 1
			elif v[i] == '(':
				pack += 1
			elif v[i] == ')':
				pack -= 1
		groups.append(v[begin:])
		return groups

	def get_idtype(self):
		return self.type.get_idtype()

	def get_idvalue(self, v):
		return self.type.get_idvalue(v)

	def check_option(self):
		rst, msg = super(Pack, self).check_option()
		if not rst:
			return False, '������>' + msg
		if inspect.isclass(self.type):
			self.type = self.type()
		rst, msg = self.type.check_option()
		if not rst:
			return False, '����������>' + msg
		return True, ''

	def export_value(self, v):
		rst, msg = super(Pack, self).export_value(v)
		if rst == None:
			return None, '����%s��>' % v + msg
		v = rst
		if v[0] != '(' or v[-1] != ')':
			return None, '����%s�����뱻���Ű�Χ' % v
		rst, msg = self.type.export_value(v[1:-1])
		if rst == None:
			return None, '����%s��>' % v + msg
		return rst, ''

class Array(_ComboType):
	def __init__(self, type):
		super(Array, self).__init__()
		self.type = type

	def __str__(self):
		return '���飨%s��' % str(self.type)

	def get_idtype(self):
		return self.type.get_idtype()

	def get_idvalue(self, v):
		d = {}
		for m in v:
			for ind, ids in self.type.get_idvalue(m).iteritems():
				d.setdefault(ind, set())
				d[ind].union(ids)
		return d

	def check_option(self):
		rst, msg = super(Array, self).check_option()
		if not rst:
			return False, '��������>' + msg
		#if not is_basetype(self.type):
		#	return False, '����Ԫ�����ͱ���Ϊ��������'
		if inspect.isclass(self.type):
			self.type = self.type()
		rst, msg = self.type.check_option()
		if not rst:
			return False, '����Ԫ����������>' + msg
		return True, ''

	def export_value(self, v):
		rst, msg = super(Array, self).export_value(v)
		if rst == None:
			return None, '���飨%s��>' % v + msg
		v = rst
		varr = []
		bt = is_basetype(self.type)
		for m in Pack.parse_pack(v, ' '):
			if not bt:
				m = m[1:-1]
			rst, msg = self.type.export_value(m)
			if rst == None:
				return None, '���飨%s��Ԫ�أ�%s��>' % (v, m) + msg
			varr.append(rst)
		return varr, ''

class Tuple(_ComboType):
	def __init__(self, *types):
		super(Tuple, self).__init__()
		self.types = types

	def __str__(self):
		return 'Ԫ�飨%s��' % '��'.join(map(str, self.types))

	def get_idtype(self):
		types = []
		for type in self.types:
			types += type.get_idtype()
		return types

	def get_idvalue(self, v):
		d = {}
		for type, m in zip(self.types, v):
			for ind, ids in type.get_idvalue(m).iteritems():
				d.setdefault(ind, set())
				d[ind].union(ids)
		return d

	def check_option(self):
		rst, msg = super(Tuple, self).check_option()
		if not rst:
			return False, 'Ԫ������>' + msg
		newtypes = []
		for t in self.types:
			#if not is_basetype(t):
			#	return False, 'Ԫ��Ԫ�����ͱ���Ϊ��������'
			if inspect.isclass(t):
				t = t()
			rst, msg = t.check_option()
			if not rst:
				return False, 'Ԫ��Ԫ����������>' + msg
			newtypes.append(t)
		self.types = tuple(newtypes)
		return True, ''

	def export_value(self, v):
		rst, msg = super(Tuple, self).export_value(v)
		if rst == None:
			return None, 'Ԫ�飨%s��>' % v + msg
		v = rst
		varr = Pack.parse_pack(v, ' ')
		if len(self.types) != len(varr):
			return None, 'Ԫ�飨%s����������Ϊ%d' % (v, len(self.types))
		newvarr = []
		for t, m in zip(self.types, varr):
			if not is_basetype(t):
				m = m[1:-1]
			rst, msg = t.export_value(m)
			if rst == None:
				return None, 'Ԫ�飨%s��Ԫ�أ�%s��>' % (v, m) + msg
			newvarr.append(rst)
		return tuple(newvarr), ''

class Dict(_ComboType):
	def __init__(self, ktype, vtype):
		super(Dict, self).__init__()
		self.ktype = ktype
		self.vtype = vtype

	def __str__(self):
		return '�ֵ䣨%s|%s��' % (str(self.ktype), str(self.vtype))

	def get_idtype(self):
		return self.ktype.get_idtype() + self.vtype.get_idtype()

	def get_idvalue(self, v):
		d = {}
		for k, m in v.iteritems():
			for ind, ids in self.ktype.get_idvalue(k).iteritems():
				d.setdefault(ind, set())
				d[ind].union(ids)
			for ind, ids in self.vtype.get_idvalue(m).iteritems():
				d.setdefault(ind, set())
				d[ind].union(ids)
		return d

	def check_option(self):
		rst, msg = super(Dict, self).check_option()
		if not rst:
			return False, '�ֵ�����>' + msg
		if not is_basetype(self.ktype):
			return False, '�ֵ�Key���ͱ���Ϊ��������'
		if inspect.isclass(self.ktype):
			self.ktype = self.ktype()
		rst, msg = self.ktype.check_option()
		if not rst:
			return False, '�ֵ�Key��������>' + msg
		#if not is_basetype(self.vtype):
		#	return False, '�ֵ�Value���ͱ���Ϊ��������'
		if inspect.isclass(self.vtype):
			self.vtype = self.vtype()
		rst, msg = self.vtype.check_option()
		if not rst:
			return False, '�ֵ�Value��������>' + msg
		return True, ''

	def export_value(self, v):
		rst, msg = super(Dict, self).export_value(v)
		if rst == None:
			return None, '�ֵ䣨%s��>' % v + msg
		v = rst
		d = dict()
		for m in Pack.parse_pack(v, ' '):
			pair = Pack.parse_pack(m, '|')
			if len(pair) != 2:
				return None, '�ֵ䣨%s��Ԫ�أ�%s������ΪKey|Value��ֵ��' % (v, m)
			k, vv = pair
			rst, msg = self.ktype.export_value(k)
			if rst == None:
				return None, '�ֵ䣨%s��Ԫ�أ�%s����Key��%s��>' % (vv, m, k) + msg
			k = rst
			if not is_basetype(self.vtype):
				vv = vv[1:-1]
			rst, msg = self.vtype.export_value(vv)
			if rst == None:
				return None, '�ֵ䣨%s��Ԫ�أ�%s����Value��%s��>' % (vv, m, vv) + msg
			vv = rst
			d[k] = vv
		return d, ''

