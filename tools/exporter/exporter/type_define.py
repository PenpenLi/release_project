# -*- coding: UTF-8 -*-

"""
导出配置
TYPE = XXX
DEFINE = XXX

type：Const，必填，指定数据文件格式为CSV还是XML
define：必填，指定数据文件定义格式

CSV导出配置
	TYPE = CSV
	DEFINE = (
		(column, field, type, require, share),
		...
	)
	例如：
	列1,lie2
	1,2
	DEFINE = (
		('列1', 'c1', Int, REQUIRED, SERVER),
		('lie2', 'c2', UInt, OPTIONAL, CLIENT),
	)

	*CSV会按照DEFINE中定义的column顺序去检查配置文件
	column：字符串，CSV表头的列名
	field：字符串，导出为JSON的对应字段名，可使用"field.subfield"这种形式定义嵌套
	type：类型，规定该项的填表格式和导出规则
	require：需求类型，规定该项的填表需求
		REQUIRED：必填
		OPTIONAL(default)：选填，default为该列默认值，该值不会进行任何导表检查和Id类型检查，可以随意设置，默认为None，表示不生效
		GROUP(name)：同name的组，必须同时填或者同时不填
	share：共享类型，选填，只允许SERVER、CLIENT、COMMON，默认为COMMON，除非list中share属性为SPLIT，否则此项不能定义
		COMMENT：忽略

XML导出配置
	TYPE = XML
	DEFINE = {
		root: child,
		tag: (name, type, share, (tag1, tag2, ...tagN),(
			(attr, field, type, require, share),
			...)),
		...
	}
	例如：
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

	*XML不会按照DEFINE中attr和tag的定义顺序去检查attr的定义顺序
	root：根标签，该项为特殊项，DEFINE中必须包含一个"root"Key指定XML的root中包含的单一子标签，该子标签必须为DICT
	tag：字符串，XML标签名
	name：字符串，XML标签导出为JSON的对应字段名
	attr：字符串，XML属性名
	type：字符串，tag中表示该标签的类型
		SINGLE：单一标签
		ARRAY：可多个标签，并形成数组，比如xml['tag'] = [..]
		DICT(name)：可多个标签，并按name指出的属性名作为Key形成字典xml['tag'] = {...}，特别的，root子项为xml = {...}
	share：共享类型，选填，只允许SERVER、CLIENT、COMMON，默认为COMMON，除非list、父tag中share属性为SPLIT，否则此项不能定义
	type：类型，attr中规定该项的填表格式和导出规则
	field：字符串，导出为JSON的对应字段名，不可使用"field.subfield"这种形式定义嵌套，XML已经拥有层次了
	require：需求类型，规定该项的填表需求
		REQUIRED：必填
		OPTIONAL(default)：选填，default为该列默认值，该值不会进行任何导表检查和Id类型检查，可以随意设置，默认为None，表示不生效
		GROUP(name)：同name的组，必须同时填或者同时不填，作用范围为同一个tag的属性
	share：共享类型，选填，只允许SERVER、CLIENT、COMMON，默认为COMMON，除非tag中share属性为SPLIT，否则此项不能定义
		COMMENT：忽略

原生导表函数export，导出为"定义器模块名.json"的JSON文件
def export(old, new, depend, raw):
	...
	return ret

	old：对应的旧数据
	new：新导出的数据
	depend：该导表的依赖项，经过导表检查，使用define module + exporter function名字索引
	raw：本次导表所有的原始数据，没有经过导表检查，使用define module名字索引
	ret：返回经过验证/修改的数据，或者返回None表示错误

派生导表函数export_xxx，导出为"定义器模块名_xxx.json"的JSON文件
def export_xxx(old, new, depend, raw):
	...
	return ret

	old：对应的旧数据
	new：新导出的数据
	depend：该导表的依赖项，经过导表检查，使用define module + exporter function名字索引
	raw：本次导表所有的原始数据，没有经过导表检查，使用define module名字索引
	ret：返回经过验证/修改的数据，或者返回None表示错误

导表器中作为数据定义的类型，类型的参数都是可选的
例如：可定义String接受任意字符串，也可定义String(encoding='ascii')仅接受英文字符

基础类型
	String
		encoding：字符串编码，默认UTF-8
		min：最小长度，按照编码规则确定长度，例如中文1个字长度是1，默认不限制
		max：最大长度，条件同上，默认不限制

	Bool：填写时只能填写1、0、true、false
		mode：导出模式，默认为str
			str：导出为字符，true和false，占空间多，C++中读出后也是true和false
			int：导出为数字，1和0，占空间少，C++中读出后也是1和0

	Int，UInt，Float
		min：最小值
		max：最大值

	Id：按照RULES中定义的index字段进行检索
		type：类型，必须是基础类型
		index：名字，必须是RULES中定义的index字段之一

	Pack：将组合类型进行封包，使其特性变为一个基础类型，从而重新成为组合类型的元素

组合类型
	Array(type)：用同种type类型的元素组成的数组，个数不定
		填表：type type type ...
		type：可以为任何类型

	Tuple(type1, type2, ..typeN)：用N个type类型的元素组成的元组，个数固定
		填表：type1 type2 ..typeN
		type1-N：可以为任何类型

	Dict(typeK, typeV)：用typeK类型为Key，typeV类型为Value的元素组成的字典，个数不定
		填表：typeK|typeV typeK|typeV ...
		typeK：必须是基础类型
		typeV：可以为任何类型

嵌套类型
	组合类型内的组合类型需要用()括起来
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

# 身体部位 -> key
def POS_TO_KEY(cn_name):
	if cn_name == '武器':
		return 'weapon'
	if cn_name == '戒指':
		return 'ring'
	if cn_name == '盔甲':
		return 'armor'
	if cn_name == '鞋子':
		return 'shoe'
	if cn_name == '头盔':
		return 'helmet'
	if cn_name == '项链':
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
			return None, '不是一个可解析的字符串'
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
			return '布尔（字符）'
		else:
			return '布尔（数字）'

	def check_option(self):
		rst, msg = super(Bool, self).check_option()
		if not rst:
			return False, msg
		if self.mode not in ('str', 'int'):
			return False, '模式必须为"str"或者"int"'
		return True, ''

	def export_value(self, v):
		rst, msg = super(Bool, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		if v not in ('1.0', '0.0', '1', '0', 'true', 'false'):
			return None, '（%s）不是一个布尔值' % v
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
		options.append('%s编码' % self.encoding)
		if self.min != None:
			options.append('最小长度%d' % self.min)
		if self.max != None:
			options.append('最大长度%d' % self.max)
		if options:
			return '字符串（%s）' % '，'.join(options)
		else:
			return '字符串'

	def check_option(self):
		rst, msg = super(String, self).check_option()
		if not rst:
			return False, msg
		if not is_string(self.encoding):
			return False, '编码设置必须为字符串'
		try:
			codecs.lookup(self.encoding)
		except:
			return False, '编码设置必须为系统支持的编码'
		if self.min != None:
			if not is_integer(self.min):
				return False, '最小长度设置必须为整数'
			if self.min <= 0:
				return False, '最小长度设置必须为大于0'
		if self.max != None:
			if not is_integer(self.max):
				return False, '最大长度设置必须为整数'
			if self.max <= 0:
				return False, '最大长度设置必须为大于0'
			if self.min != None and self.max < self.min:
				return False, '最大长度设置必须大于最小长度设置'
		return True, ''

	def export_value(self, v):
		rst, msg = super(String, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		try:
			v.decode(self.encoding)
		except:
			return None, '字符串（%s）不符合%s编码' % (v, self.encoding)
		if '\'' in v:
			return None, '字符串（%s）不能包含\'（英文单引号）' % v
		for c in ('\\', '"'):
			v = v.replace(c, '\\' + c)
		if self.min != None and len(v) < self.min:
			return None, '字符串（%s）长度小于最小长度%d' % (v, self.min)
		if self.max != None and len(v) > self.max:
			return None, '字符串（%s）长度大于最大长度%d' % (v, self.max)
		return v, ''

class Int(_BaseType):
	def __init__(self, min = None, max = None):
		super(Int, self).__init__()
		self.min = min
		self.max = max

	def __str__(self):
		options = []
		if self.min != None:
			options.append('最小值%d' % self.min)
		if self.max != None:
			options.append('最大值%d' % self.max)
		if options:
			return '整数（%s）' % '，'.join(options)
		else:
			return '整数'

	def check_option(self):
		rst, msg = super(Int, self).check_option()
		if not rst:
			return False, msg
		if self.min != None:
			if not is_integer(self.min):
				return False, '最小值设置必须为整数'
		if self.max != None:
			if not is_integer(self.max):
				return False, '最大值设置必须为整数'
			if self.min != None and self.max < self.min:
				return False, '最大值设置必须大于最小值设置'
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
				return None, '（%s）不是一个整数' % v
		if self.min != None and v < self.min:
			return None, '整数（%d）小于最小值%d' % (v, self.min)
		if self.max != None and v > self.max:
			return None, '整数（%d）大于最大值%d' % (v, self.max)
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
			options.append('最小值%.2f' % self.min)
		if self.max != None:
			options.append('最大值%.2f' % self.max)
		if options:
			return '浮点数（%s）' % '，'.join(options)
		else:
			return '浮点数'

	def check_option(self):
		rst, msg = super(Float, self).check_option()
		if not rst:
			return False, msg
		if self.min != None:
			if not is_float(self.min):
				return False, '最小值设置必须为浮点数'
		if self.max != None:
			if not is_float(self.max):
				return False, '最大值设置必须为浮点数'
			if self.min != None and compare_float(self.max, self.min) < 0:
				return False, '最大值设置必须大于最小值设置'
		return True, ''

	def export_value(self, v):
		rst, msg = super(Float, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		try:
			v = float(v)
		except:
			return None, '（%s）不是一个浮点数' % v
		if self.min != None and compare_float(v, self.min) < 0:
			return None, '浮点数（%.2f）小于最小值%.2f' % (v, self.min)
		if self.max != None and compare_float(v, self.max) > 0:
			return None, '浮点数（%.2f）大于最大值%.2f' % (v, self.max)
		return v, ''

class Id(_BaseType):
	def __init__(self, index):
		super(Id, self).__init__()
		self.type = None
		self.index = index

	def __str__(self):
		return 'Id（类型%s，索引%s）' % (str(self.type), self.index)

	def get_idtype(self):
		return [self]

	def get_idvalue(self, v):
		return {self.index: set([v])}

	def check_option(self):
		rst, msg = super(Id, self).check_option()
		if not rst:
			return False, msg
		if not is_string(self.index):
			return False, 'Id索引必须为字符串'
		return True, ''

	def export_value(self, v):
		rst, msg = super(Id, self).export_value(v)
		if rst == None:
			return None, msg
		v = rst
		rst, msg = self.type.export_value(v)
		if rst == None:
			return None, 'Id索引>' + msg
		v = rst
		return v, ''

class Pack(_BaseType):
	def __init__(self, type):
		super(Pack, self).__init__()
		self.type = type

	def __str__(self):
		return '包（%s）' % str(self.type)

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
			return False, '包设置>' + msg
		if inspect.isclass(self.type):
			self.type = self.type()
		rst, msg = self.type.check_option()
		if not rst:
			return False, '包类型设置>' + msg
		return True, ''

	def export_value(self, v):
		rst, msg = super(Pack, self).export_value(v)
		if rst == None:
			return None, '包（%s）>' % v + msg
		v = rst
		if v[0] != '(' or v[-1] != ')':
			return None, '包（%s）必须被括号包围' % v
		rst, msg = self.type.export_value(v[1:-1])
		if rst == None:
			return None, '包（%s）>' % v + msg
		return rst, ''

class Array(_ComboType):
	def __init__(self, type):
		super(Array, self).__init__()
		self.type = type

	def __str__(self):
		return '数组（%s）' % str(self.type)

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
			return False, '数组设置>' + msg
		#if not is_basetype(self.type):
		#	return False, '数组元素类型必须为基础类型'
		if inspect.isclass(self.type):
			self.type = self.type()
		rst, msg = self.type.check_option()
		if not rst:
			return False, '数组元素类型设置>' + msg
		return True, ''

	def export_value(self, v):
		rst, msg = super(Array, self).export_value(v)
		if rst == None:
			return None, '数组（%s）>' % v + msg
		v = rst
		varr = []
		bt = is_basetype(self.type)
		for m in Pack.parse_pack(v, ' '):
			if not bt:
				m = m[1:-1]
			rst, msg = self.type.export_value(m)
			if rst == None:
				return None, '数组（%s）元素（%s）>' % (v, m) + msg
			varr.append(rst)
		return varr, ''

class Tuple(_ComboType):
	def __init__(self, *types):
		super(Tuple, self).__init__()
		self.types = types

	def __str__(self):
		return '元组（%s）' % '，'.join(map(str, self.types))

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
			return False, '元组设置>' + msg
		newtypes = []
		for t in self.types:
			#if not is_basetype(t):
			#	return False, '元组元素类型必须为基础类型'
			if inspect.isclass(t):
				t = t()
			rst, msg = t.check_option()
			if not rst:
				return False, '元组元素类型设置>' + msg
			newtypes.append(t)
		self.types = tuple(newtypes)
		return True, ''

	def export_value(self, v):
		rst, msg = super(Tuple, self).export_value(v)
		if rst == None:
			return None, '元组（%s）>' % v + msg
		v = rst
		varr = Pack.parse_pack(v, ' ')
		if len(self.types) != len(varr):
			return None, '元组（%s）个数必须为%d' % (v, len(self.types))
		newvarr = []
		for t, m in zip(self.types, varr):
			if not is_basetype(t):
				m = m[1:-1]
			rst, msg = t.export_value(m)
			if rst == None:
				return None, '元组（%s）元素（%s）>' % (v, m) + msg
			newvarr.append(rst)
		return tuple(newvarr), ''

class Dict(_ComboType):
	def __init__(self, ktype, vtype):
		super(Dict, self).__init__()
		self.ktype = ktype
		self.vtype = vtype

	def __str__(self):
		return '字典（%s|%s）' % (str(self.ktype), str(self.vtype))

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
			return False, '字典设置>' + msg
		if not is_basetype(self.ktype):
			return False, '字典Key类型必须为基础类型'
		if inspect.isclass(self.ktype):
			self.ktype = self.ktype()
		rst, msg = self.ktype.check_option()
		if not rst:
			return False, '字典Key类型设置>' + msg
		#if not is_basetype(self.vtype):
		#	return False, '字典Value类型必须为基础类型'
		if inspect.isclass(self.vtype):
			self.vtype = self.vtype()
		rst, msg = self.vtype.check_option()
		if not rst:
			return False, '字典Value类型设置>' + msg
		return True, ''

	def export_value(self, v):
		rst, msg = super(Dict, self).export_value(v)
		if rst == None:
			return None, '字典（%s）>' % v + msg
		v = rst
		d = dict()
		for m in Pack.parse_pack(v, ' '):
			pair = Pack.parse_pack(m, '|')
			if len(pair) != 2:
				return None, '字典（%s）元素（%s）必须为Key|Value键值对' % (v, m)
			k, vv = pair
			rst, msg = self.ktype.export_value(k)
			if rst == None:
				return None, '字典（%s）元素（%s）中Key（%s）>' % (vv, m, k) + msg
			k = rst
			if not is_basetype(self.vtype):
				vv = vv[1:-1]
			rst, msg = self.vtype.export_value(vv)
			if rst == None:
				return None, '字典（%s）元素（%s）中Value（%s）>' % (vv, m, vv) + msg
			vv = rst
			d[k] = vv
		return d, ''

