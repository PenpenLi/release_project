#!/usr/local/bin/python2.7
# -*- coding: UTF-8 -*-

import os
import csv
import json
import xlrd
import glob
import fnmatch
import inspect
import argparse
import xml.etree.ElementTree
from utils import *
from type_define import *
from data_list import *

ORIGIN_ENCODING = 'gbk'
FINAL_ENCODING = 'utf8'

DATA_PATH = '../'
OUTPUT_PATH = '../'

CONF_PATH = '../../conf'

PYTHON_PATH = 'data/py'
LUA_PATH = '../../src/'
JSON_PATH = 'data/json'

SERVER_PATH = 'server/data'
CLIENT_PATH = 'client/src/data'

EXPORTER_PATH = 'exporter/exporters/'

EXPORTER_QUEUE = []
EXPORTER_INDEX = {}
EXPORTER_RAWDATA = {}
EXPORTER_OLDDATA = {}
EXPORTER_NEWDATA = {}

CALL_FILES = None
CALL_PATH = None
CALL_OUTPUT = None
CALL_FLAGS = None

def isdir(path):
	if not os.path.exists(path):
		return False
	if not os.path.isdir(path):
		return False
	return True

def check_option_path(path):
	if not path:
		path = DATA_PATH
	print path
	if not isdir( os.path.join(path, EXPORTER_PATH) ):
		record_error('导出器目录 <%s> 不存在' % os.path.join(path, EXPORTER_PATH))
	if not isdir( os.path.join(path, CONF_PATH) ):
		record_error('配置文件目录 <%s> 不存在' % os.path.join(path, CONF_PATH))
	if not isdir( os.path.join(path, PYTHON_PATH) ):
		record_error('PYTHON 数据目录 <%s> 不存在' % os.path.join(path, PYTHON_PATH))
	if not isdir( os.path.join(path, LUA_PATH) ):
		record_error('LUA 数据目录 <%s> 不存在' % os.path.join(path, LUA_PATH))
	#if not isdir( os.path.join(path, JSON_PATH) ):
	#	record_error('JSON 数据目录 <%s> 不存在' % os.path.join(path, JSON_PATH))
	return path

def check_option_flags(flags):
	if not flags:
		return ''
	chars = set(flags)
	allow = set('qazxswedcvfrtgbnhyujmkiolp,')
	if chars - allow:
		record_error('导表器参数 <%s> 只能为小写字母和逗号分隔符' % flags)
	return flags

def check_rules_file(dpath, conf, rule):
	files = []
	for path in conf.split(','):
		fpath = os.path.join(dpath, CONF_PATH, path)
		fpath = fpath.decode(ORIGIN_ENCODING).encode(FINAL_ENCODING)
		if len(fpath.split('**')) > 1:
			top, fptn = fpath.split('**')
			fptn = os.path.split(fptn)[-1]
			for root, dirs, fnames in os.walk(top):
				if '.svn' in dirs:
					dirs.remove('.svn')
				for f in fnames:
					if fnmatch.fnmatch(f, fptn):
						files.append(os.path.join(root, f))
		else:
			files += glob.glob(fpath)
	if not files:
		record_error(' <%s> 配置文件不存在' % conf)
		return False
	ext = set()
	for fname in files:
		if not os.path.isfile(fname):
			record_error(' <%s> 不是一个有效的文件' % fname)
			continue
		ext.add(os.path.splitext(fname)[1])
	if has_error():
		return False
	if len(ext) != 1:
		record_error(' <%s> 配置文件类型 <%s> 不统一' % (fname, ', '.join(ext)))
		return False
	rule['files'] = files
	return True

def check_define_xls(conf, rule, mod):
	if type(mod.DEFINE) != tuple:
		record_error(' <%s> 的XLS定义必须是tuple' % conf)
		return False
	columns = []
	fields = {}
	groups = {}
	for meta in mod.DEFINE:
		if type(meta) != tuple:
			record_error(' <%s> 的XLS定义的单项必须是tuple' % conf)
			continue
		if not (4 <= len(meta) <= 5):
			record_error(' <%s> 的XLS定义的单项必须包含（列名、字段、类型、需求、共享-选填）参数' % conf)
			continue
		if len(meta) == 4:
			col, field, ctype, req = meta
			share = None
		else:
			col, field, ctype, req, share = meta
		if not is_string(col):
			record_error(' <%s> 的XLS定义的列名参数必须为string' % conf)
			continue
		if col in columns:
			record_error(' <%s> 的XLS定义的列名参数 <%s> 不能重复' % (conf, col))
			continue
		if not is_string(field):
			record_error(' <%s> 的XLS定义的列 <%s> 字段参数必须为string' % (conf, col))
			continue
		if field in fields:
			record_error(' <%s> 的XLS定义的列 <%s> 字段参数 <%s> 不能重复' % (conf, col, field))
			continue
		if not is_anytype(ctype):
			record_error(' <%s> 的XLS定义的列 <%s> 类型参数必须为预定义类型' % (conf, col))
			continue
		if inspect.isclass(ctype):
			ctype = ctype()
		rst, msg = ctype.check_option()
		if not rst:
			record_error(' <%s> 的XLS定义的列 <%s> 类型参数>' % (conf, col) + msg)
			continue
		for idtype in ctype.get_idtype():
			if idtype.index not in EXPORTER_INDEX:
				record_error(' <%s> 的XLS定义的列 <%s> Id类型参数定义的索引 <%s> 不在导表列表中存在' % (conf, col, idtype.index))
		if has_error():
			continue
		if req not in (REQUIRED, COMMENT) and not is_optional(req) and not is_string(req):
			record_error(' <%s> 的XLS定义的列 <%s> 需求参数必须为必填、选填、分组、注释三种' % (conf, col))
			continue
		if req == OPTIONAL:
			req = OPTIONAL()
		if rule['share'] == SPLIT:
			if share not in (COMMON, SERVER, CLIENT, None):
				record_error(' <%s> 的XLS定义的列 <%s> 共享参数必须为共用、服务端、客户端三种' % (conf, col))
				continue
		elif share != None:
				record_error(' <%s> 的XLS定义的列 <%s> 共享参数不能定义' % (conf, col))
				continue
		columns.append(col)
		fields[col] = (field, ctype, req, share)
		if is_string(req):
			groups.setdefault(req, set())
			groups[req].add(col)
	if has_error():
		return False
	mod.COLUMNS = tuple(columns)
	mod.FIELDS = fields
	mod.GROUPS = groups
	return True
	
def check_define_share(conf, define, tag, ptag, pshare):
	if len(define[tag]) == 4:
		name, ttype, children, attrs = define[tag]
		share = None
	else:
		name, ttype, share, children, attrs = define[tag]
	if pshare == SPLIT:
		if share not in (COMMON, SERVER, CLIENT, SPLIT, None):
			record_error(' <%s> 的XML定义的 <%s> 的共享类型必须和父标签 <%s> 兼容' % (conf, tag, ptag))
			return False
		if share == None:
			share = COMMON
	elif pshare != None:
		if share != None:
			record_error(' <%s> 的XML定义的 <%s> 的共享类型必须和父标签 <%s> 兼容' % (conf, tag, ptag))
			return False
		share = pshare
	for child in children:
		if not check_define_share(conf, define, child, tag, share):
			return False
	return True

def check_define_xml(conf, rule, mod):
	if type(mod.DEFINE) != dict:
		record_error(' <%s> 的XML定义必须是dict' % conf)
		return False
	if 'root' not in mod.DEFINE:
		record_error(' <%s> 的XML定义必须包含root项' % conf)
		return False
	if not is_string(mod.DEFINE['root']):
		record_error(' <%s> 的XML定义root项必须为string' % conf)
		return False
	if mod.DEFINE['root'] not in mod.DEFINE:
		record_error(' <%s> 的XML定义root项 <%s> 不在定义中' % (conf, mod.DEFINE['root']))
		return False
	if has_error():
		return False
	fields = {}
	groups = {}
	holder_errstack()
	for tag, define in mod.DEFINE.iteritems():
		tail_errstack('标签' + tag)
		if tag == 'root':
			continue
		if not is_string(tag):
			record_error(' <%s> 的XML定义每项标签参数必须为string' % conf)
			continue
		if type(define) != tuple:
			record_error(' <%s> 的XML定义的 <%s> 的每项定义必须为tuple' % (conf, tag))
			continue
		if not (4 <= len(define) <= 5):
			record_error(' <%s> 的XML定义的 <%s> 的每项定义必须包含（字段名、类型、共享-选填、子项、属性）参数' % (conf, tag))
			continue
		if len(define) == 4:
			name, ttype, children, attrs = define
			share = None
		else:
			name, ttype, share, children, attrs = define
		if not is_string(name):
			record_error(' <%s> 的XML定义的 <%s> 的名字参数必须为string' % (conf, tag))
			continue
		if ttype != SINGLE and ttype != ARRAY and not is_string(ttype):
			record_error(' <%s> 的XML定义的 <%s> 的类型参数必须为预定义值' % (conf, tag))
			continue
		if tag == mod.DEFINE['root'] and not is_string(ttype):
			record_error(' <%s> 的XML定义的root子标签 <%s> 的类型参数必须为DICT' % (conf, tag))
			continue
		if type(children) != tuple:
			record_error(' <%s> 的XML定义的 <%s> 的子项参数必须为tuple' % (conf, tag))
			continue
		if rule['share'] == SPLIT:
			if share not in (COMMON, SERVER, CLIENT, SPLIT, None):
				record_error(' <%s> 的XML定义的 <%s> 共享参数必须为共用、分拆、服务端、客户端四种' % (conf, tag))
				continue
		elif share != None:
				record_error(' <%s> 的XML定义的 <%s> 共享参数不能定义' % (conf, tag))
				continue
		names = set()
		for child in children:
			if not is_string(child):
				record_error(' <%s> 的XML定义的 <%s> 的子项参数每项必须为string' % (conf, tag))
				continue
			if child not in mod.DEFINE:
				record_error(' <%s> 的XML定义的 <%s> 的子项参数的 <%s> 不在定义中' % (conf, tag, child))
				continue
			childname = mod.DEFINE[child][0]
			if childname in names:
				record_error(' <%s> 的XML定义的 <%s> 的子项参数的 <%s> 的名字参数 <%s> 在同一层级重复' % (conf, tag, child, childname))
				continue
			names.add(childname)
		if has_error():
			continue
		if type(attrs) != tuple:
			record_error(' <%s> 的XML定义的 <%s> 的属性参数必须为tuple' % (conf, tag))
			continue
		fields[tag] = {}
		groups[tag] = {}
		for attr in attrs:
			if type(attr) != tuple:
				record_error(' <%s> 的XML定义的 <%s> 的属性参数单项必须是tuple' % (conf, tag))
				continue
			if not (4 <= len(attr) <= 5):
				record_error(' <%s> 的XML定义的 <%s> 的属性参数单项必须包含（属性名、字段、类型、需求、共享-选填）参数' % (conf, tag))
				continue
			if len(attr) == 4:
				aname, field, atype, req = attr
				ashare = None
			else:
				aname, field, atype, req, ashare = attr
			if not is_string(aname):
				record_error(' <%s> 的XML定义的 <%s> 的属性名参数必须为string' % (conf, tag))
				continue
			if aname in children:
				record_error(' <%s> 的XML定义的 <%s> 的属性名参数 <%s> 不能与子标签相同' % (conf, tag, aname))
				continue
			if aname in names:
				record_error(' <%s> 的XML定义的 <%s> 的属性名参数 <%s> 不能重复' % (conf, tag, aname))
				continue
			if not is_string(field):
				record_error(' <%s> 的XML定义的 <%s> 的属性 <%s> 字段参数必须为string' % (conf, tag, aname))
				continue
			if field in fields[tag]:
				record_error(' <%s> 的XML定义的 <%s> 的属性 <%s> 字段参数 <%s> 不能重复' % (conf, tag, aname, field))
				continue
			if not is_anytype(atype):
				record_error(' <%s> 的XML定义的 <%s> 的属性 <%s> 类型参数必须为预定义类型' % (conf, tag, aname))
				continue
			if inspect.isclass(atype):
				atype = atype()
			rst, msg = atype.check_option()
			if not rst:
				record_error(' <%s> 的XML定义的 <%s> 的属性 <%s> 类型参数>' % (conf, tag, aname) + msg)
				continue
			for idtype in atype.get_idtype():
				if idtype.index not in EXPORTER_INDEX:
					record_error(' <%s> 的XML定义的 <%s> 的属性 <%s> Id类型参数定义的索引 <%s> 不在导表列表中存在' % (conf, tag, aname, idtype.index))
			if has_error():
				continue
			if req not in (REQUIRED, COMMENT) and not is_optional(req) and not is_string(req):
				record_error(' <%s> 的XML定义的 <%s> 的属性 <%s> 的需求参数必须为必填、选填、分组、注释三种' % (conf, tag, aname))
				continue
			if req == OPTIONAL:
				req = OPTIONAL()
			if rule['share'] == SPLIT and share == SPLIT:
				if ashare not in (COMMON, SERVER, CLIENT, None):
					record_error(' <%s> 的XML定义的 <%s> 的属性 <%s> 共享参数必须为共用、服务端、客户端三种' % (conf, tag, aname))
					continue
			elif ashare != None:
					record_error(' <%s> 的XML定义的 <%s> 的属性 <%s> 共享参数不能定义' % (conf, tag, aname))
					continue
			names.add(aname)
			fields[tag][aname] = (field, atype, req, ashare)
			if is_string(req):
				groups[tag].setdefault(req, set())
				groups[tag][req].add(aname)
		if has_error():
			continue
		if is_string(ttype) and ttype not in fields[tag]:
			record_error(' <%s> 的XML定义的 <%s> 的DICT类型指定的索引 <%s> 属性不存在' % (conf, tag, ttype))
			continue
	pop_errstack()
	merge_errstack()
	if has_error():
		return False
	if not check_define_share(conf, mod.DEFINE, mod.DEFINE['root'], 'root', None):
		return False
	mod.FIELDS = fields
	mod.GROUPS = groups
	return True

def check_rules_define(path, conf, rule):
	if 'define' not in rule:
		record_error(' <%s> 必须设置定义器' % conf)
		return False
	if not is_string(rule['define']):
		record_error(' <%s> 的定义器设置必须是string' % conf)
		return False
	pathpy = os.path.join(path, EXPORTER_PATH, rule['define'] + '.py')
	pathpyc = os.path.join(path, EXPORTER_PATH, rule['define'] + '.pyc')
	if not os.path.exists(pathpy) and not os.path.exists(pathpyc):
		record_error(' <%s> 的定义器 <%s> 不存在' % (conf, pathpy))
		return False
	if os.path.exists(pathpy):
		path = pathpy
	else:
		path = pathpyc
	if not os.path.isfile(path):
		record_error(' <%s> 的定义器 <%s> 不是一个有效的文件' % (conf, path))
		return False
	try:
		mod = __import__('exporters.' + rule['define'], fromlist = [rule['define']])
	except Exception, e:
		record_error(' <%s> 的定义器 <%s> 导入错误>' % (conf, rule['define']) + str(e))
		return False
	if not hasattr(mod, 'TYPE'):
		record_error(' <%s> 的定义器 <%s> 必须设置配置文件类型' % (conf, rule['define']))
		return False
	if mod.TYPE not in AVAILABLE_CONF_TYPE:
		record_error(' <%s> 的定义器 <%s> 的配置文件类型必须为XML/XLS' % (conf, rule['define']))
		return False
	if not hasattr(mod, 'DEFINE'):
		record_error(' <%s> 的定义器 <%s> 必须设置配置文件定义' % (conf, rule['define']))
		return False
	if mod.TYPE == XML and not check_define_xml(conf, rule, mod):
		return False
	elif mod.TYPE == XLS and not check_define_xls(conf, rule, mod):
		return False
	confext = os.path.splitext(conf)[1][1:].upper()
	if mod.TYPE == XML and confext != 'XML':
		record_error(' <%s> 配置文件类型与定义器 <%s> 配置文件类型不统一' % (conf, ', '.join(AVAILABLE_CONF_TYPE)))
		return False
	elif mod.TYPE == XLS and confext != 'XLSX':
		record_error(' <%s> 配置文件类型与定义器 <%s> 配置文件类型不统一' % (conf, ', '.join(AVAILABLE_CONF_TYPE)))
		return False
	rule['define'] = mod
	return True

def check_rules_exporter(conf, rule):
	mod = rule['define']
	name = mod_name(mod)
	if not hasattr(mod, 'export'):
		record_error(' <%s> 的导表器 <%s> 必须设置原生导出函数' % (conf, name))
		return False
	if len(inspect.getargspec(mod.export).args) != 4:
		record_error(' <%s> 的导表器 <%s> 导出函数export必须设置（old、new、depend、rawdata）参数' % (conf, name))
		return False
	exfuncs = {name: mod.export}
	for attr in dir(mod):
		if not attr.startswith('export_'):
			continue
		funcname = attr[7:]
		if not funcname:
			record_error(' <%s> 的导表器 <%s> 派生导出函数必须设置名称' % (conf, name))
			continue
		if funcname in exfuncs:
			record_error(' <%s> 的导表器 <%s> 派生导出函数 <%s> 名称重复' % (conf, name, funcname))
			continue
		func = getattr(mod, attr)
		if not inspect.isfunction(func):
			record_error(' <%s> 的导表器 <%s> 派生导出函数 <%s> 必须是一个函数' % (conf, name, funcname))
			continue
		if len(inspect.getargspec(func).args) != 4:
			record_error(' <%s> 的导表器 <%s> 派生导出函数 <%s> 必须设置（old、new、depend、rawdata）参数' % (conf, name, funcname))
			continue
		exfuncs[name + '_' + funcname] = func
	if has_error():
		return False
	rule['exporter'] = exfuncs
	return True

def check_rules_depend(conf, rule):
	if 'depend' not in rule:
		rule['depend'] = ()
	else:
		if is_string(rule['depend']):
			rule['depend'] = (rule['depend'], )
		elif type(rule['depend']) != tuple:
			record_error(' <%s> 的依赖列表必须为string或者tuple' % conf)
			return False
		for d in rule['depend']:
			if not is_string(d):
				record_error(' <%s> 的依赖列表中每个必须是string' % conf)
				continue
			if d not in RULES:
				record_error(' <%s> 的依赖列表中 <%s> 必须在导表列表中存在' % (conf, d))
		if has_error():
			return False
	return True

def check_rules_share(conf, rule):
	if 'share' not in rule:
		rule['share'] = COMMON
	else:
		if  rule['share'] not in (COMMON, SERVER, CLIENT, SPLIT):
			record_error(' <%s> 的共享类型必须在预定义常量' % conf)
		if has_error():
			return False
	return True

def check_rules_feature(conf, rule):
	if 'feature' not in rule:
		rule['feature'] = ()
	else:
		if is_integer(rule['feature']):
			rule['feature'] = (rule['feature'], )
		elif type(rule['feature']) != tuple:
			record_error(' <%s> 的特性列表必须为int或者tuple' % conf)
			return False
		for d in rule['feature']:
			tail_errstack('特性' + str(d))
			if not is_integer(d):
				record_error(' <%s> 的特性列表中每个特性必须为整数' % conf)
				continue
			if d not in (DENY_DEL, DENY_ADD, IGNORE_TITLE, CHECK_BLINE, EACH_EXPORT, EXP_FILE):
				record_error(' <%s> 的特性列表中 <%s> 必须在预定义常量' % (conf, d))
		if has_error():
			return False
	return True

def check_rules_id(conf, rule):
	if 'id' in rule:
		if is_string(rule['id']):
			rule['id'] = (rule['id'], )
		elif type(rule['id']) == tuple:
			for mid in rule['id']:
				if not is_string(mid):
					record_error(' <%s> 的ID设置子项必须为string' % conf)
					return False
		else:
			record_error(' <%s> 的ID设置必须为string或者string tuple' % conf)
			return False
	else:
		rule['id'] = ('id', )
	if rule['define'].TYPE == XLS:
		for mid in rule['id']:
			if mid not in rule['define'].COLUMNS:
				record_error(' <%s> 的ID设置 <%s> 在定义器 <%s> 定义中不存在' % (conf, mid, mod_name(rule['define'])))
				return False
			field, ctype, req, share = rule['define'].FIELDS[mid]
			if req != REQUIRED:
				record_error(' <%s> 的ID设置 <%s> 在定义器 <%s> 定义中必须为必填' % (conf, mid, mod_name(rule['define'])))
				return False
			if share != None:
				record_error(' <%s> 的ID设置 <%s> 在定义器 <%s> 定义中不能设置共享参数' % (conf, mid, mod_name(rule['define'])))
				return False
		if rule['index']:
			if len(rule['id']) == 1:
				EXPORTER_INDEX[rule['index']]['type'] = ctype
			else:
				record_error(' <%s> 的ID设置 <%s> 为多项，不能设置索引参数' % (conf, rule['id']))
				return False
	elif rule['define'].TYPE == XML:
		if len(rule['id']) != 1:
			record_error(' <%s> 的ID设置 <%s> XML不能为多项' % (conf, rule['id']))
			return False
		mid = rule['id'][0]
		tag = rule['define'].DEFINE['root']
		if mid not in rule['define'].FIELDS[tag]:
			record_error(' <%s> 的ID设置 <%s> 在定义器 <%s> 的root子项 <%s> 属性中不存在' % (conf, mid, mod_name(rule['define']), tag))
			return False
		field, atype, req, share = rule['define'].FIELDS[tag][mid]
		if req != REQUIRED:
			record_error(' <%s> 的ID设置 <%s> 在定义器 <%s> 的root子项 <%s> 属性中必须为必填' % (conf, mid, mod_name(rule['define']), tag))
			return False
		if share != None:
			record_error(' <%s> 的ID设置 <%s> 在定义器 <%s> 的root子项 <%s> 属性中不能设置共享参数' % (conf, mid, mod_name(rule['define']), tag))
			return False
		if rule['index']:
			EXPORTER_INDEX[rule['index']]['type'] = atype
	return True

def check_rules_idtype():
	for rule in RULES.itervalues():
		define = rule['define']
		if define.TYPE == XLS:
			for col in define.FIELDS.keys():
				field, ctype, req, share = define.FIELDS[col]
				for idtype in ctype.get_idtype():
					idtype.type = EXPORTER_INDEX[idtype.index]['type']
		elif define.TYPE == XML:
			for attrs in define.FIELDS.itervalues():
				for attr in attrs.keys():
					field, atype, req, share = attrs[attr]
					for idtype in atype.get_idtype():
						idtype.type = EXPORTER_INDEX[idtype.index]['type']

def check_rules_index(conf, rule):
	if 'index' in rule:
		if not is_string(rule['index']):
			record_error(' <%s> 的索引设置必须为string' % conf)
			return False
		if rule['index'] in EXPORTER_INDEX:
			record_error(' <%s> 的索引设置 <%s> 不允许重复' % (conf, rule['index']))
			return False
		EXPORTER_INDEX[rule['index']] = {'conf': conf, 'set': set(), 'type': None}
	else:
		rule['index'] = ''
	return True

def check_rules_queue(cur, wait):
	if cur in EXPORTER_QUEUE:
		return True
	#环形检查
	if cur in wait:
		return False
	#按依赖顺序排列
	rule = RULES[cur]
	for d in rule['depend']:
		if d not in EXPORTER_QUEUE:
			if not check_rules_queue(d, wait + [cur]):
				return False
	EXPORTER_QUEUE.append(cur)
	return True

def check_rules_ring():
	for conf in RULES:
		if not check_rules_queue(conf, []):
			return False
	return True

def check_rules_config(path):
	if 'RULES' not in globals():
		record_error('必须定义导表列表RULES')
		return False
	if type(RULES) != dict:
		record_error('导表列表必须是一个dict')
		return False

	#先为DEFINE中的type确定Id索引有哪些
	holder_errstack(2)
	for conf, rule in RULES.iteritems():
		tail_errstack('索引检查>>文件' + conf)
		if not check_rules_index(conf, rule):
			continue
	pop_errstack(2)
	if has_error():
		return False

	#再检查剩余的
	holder_errstack(2)
	for conf, rule in RULES.iteritems():
		tail_errstack('列表检查>>文件' + conf)
		if not check_rules_file(path, conf, rule):
			continue
		tail_errstack('共享检查>>文件' + conf)
		if not check_rules_share(conf, rule):
			continue
		tail_errstack('定义器检查>>文件' + conf)
		if not check_rules_define(path, conf, rule):
			continue
		tail_errstack('导出器检查>>文件' + conf)
		if not check_rules_exporter(conf, rule):
			continue
		tail_errstack('依赖检查>>文件' + conf)
		if not check_rules_depend(conf, rule):
			continue
		tail_errstack('特性检查>>文件' + conf)
		if not check_rules_feature(conf, rule):
			continue
		tail_errstack('ID检查>>文件' + conf)
		if not check_rules_id(conf, rule):
			continue
	pop_errstack(2)
	if has_error():
		return False

	#检查环形依赖
	push_errstack('环形依赖检查')
	if not check_rules_ring():
		record_error('导表列表不允许环形依赖')
		return False
	pop_errstack()

	#最后为Id类型添加type
	check_rules_idtype()
	return True

def check_option_depend(files, add):
	if add in files:
		return
	files.add(add)
	#必须包含所有依赖项
	rule = RULES[add]
	for d in rule['depend']:
		check_option_depend(files, d)
	#必须包含所有Id依赖项
	for attrs in rule['define'].FIELDS.itervalues():
		for field, atype, req, share in attrs.itervalues():
			for idtype in atype.get_idtype():
				check_option_depend(files, EXPORTER_INDEX[idtype.index]['conf'])

def check_option_file(path, arg):
	if not arg:
		return True, set(RULES.keys())
	path = os.path.join(path, CONF_PATH, arg)
	if not os.path.exists(path):
		return False, None
	if not os.path.isfile(path):
		return False, None
	if arg not in RULES:
		return False, None
	files = set()
	check_option_depend(files, arg)
	return True, files

def check_cmd_option(fname, path, flags):
	push_errstack('路径检查')
	path = check_option_path(path)
	assert_error()

	push_errstack('参数检查')
	flags = check_option_flags(flags)
	assert_error()

	tail_errstack('规则检查')
	rst = check_rules_config(path)
	assert_error()

	tail_errstack('文件检查')
	rst, files = check_option_file(path, fname)
	if not rst:
		record_error('指定配置文件 <%s> 不存在' % fname)
	assert_error()
	pop_errstack()
	return files, path, flags

def proc_parse_xls(rule, index, sheet_name):
	define = rule['define']
	data = {}
	holder_errstack()
	for fname in rule['files']:
		tail_errstack('文件' + fname)
		write_proc('开始分析 <%s> ' % fname, tabs = 1)
		try:
			reader = xlrd.open_workbook(fname).sheet_by_name(sheet_name.decode(ORIGIN_ENCODING))
		except Exception, e:
			record_error('读取XLS文件 <%s> 不存在Sheet <%s> 错误>' % (fname, sheet_name ))
			write_error()
			continue
		try:
			fields = [v.value.encode(FINAL_ENCODING) for v in reader.row(0)]
		except Exception, e:
			record_error('读取XLS表头 <%s> 错误>' % fname + str(e))
			write_error()
			continue
		#比对表头
		if len(set(fields)) != len(fields):
			fdset = set(fields)
			fdlist = list(fields)
			for fd in fdset:
				fdlist.remove(fd)
			record_error('XLS <%s> 表头 <%s> 不能重复定义' % (fname, '，'.join(fdlist)))
			write_error()
			continue
		#encoding
		if fields[0] != '是否导表':
			record_error('表头第一列必须为 是否导表>')
			write_error()
			continue	
		if IGNORE_TITLE in rule['feature']:
			for field in fields:
				if field not in define.COLUMNS:
					record_error('XLS <%s> 表头 <%s> 不在定义中' % (fname, field))
					continue
			for field in set(define.COLUMNS) - set(fields):
				col, ctype, req, share = define.FIELDS[field]
				if req == REQUIRED:
					record_error('XLS <%s> 必选表头 <%s> 必须存在' % (fname, field))
					continue
			if has_error():
				write_error()
				continue
		else:
			if len(fields) != len(define.COLUMNS):
				record_error('XLS <%s> 表头列数 <%d> 与定义列数 <%d> 不匹配' % (fname, len(fields), len(define.COLUMNS)))
			else:
				for i, (field, col) in enumerate(zip(fields, define.COLUMNS)):
					col = col.decode(ORIGIN_ENCODING).encode(FINAL_ENCODING)
					if field != col:
						record_error('XLS <%s> 表头 <%d> 列 <%s> 与定义 <%s> 不匹配' % (fname, i, field, col))
						break
			if has_error():
				write_error()
				continue
		holder_errstack()
		#忽略列
		ignore = getattr(rule['define'], 'IGNORE', ())
		ignore_row = []
		ignore_col = []
		for i in xrange(1,reader.nrows):
			row = [unicode(v.value).encode('gbk') for v in reader.row(i)]
			tail_errstack('行' + str(i))
			if CHECK_BLINE not in rule['feature']:
				if not row:
					continue
				elif not ''.join(row):
					continue
			if len(row) != len(fields):
				record_error('XLS <%s> %d行必须与表头 <%s> 列数匹配。行列数:%d 表头列数:%d' % (fname, i + 1, '，'.join(fields), len(row), len(fields)))
				continue
			#导出行数据
			meta = {}
			groups = {}
			idvalue = []
			for j, col in enumerate(row):
				col = col.strip().replace('\n', '')
				head = fields[j].decode(FINAL_ENCODING).encode(ORIGIN_ENCODING)
				field, ctype, req, share = define.FIELDS[head]
				if req == COMMENT:
					continue
				if col:
					rst, msg = ctype.export_value(col)
					if rst == None:
						if field in ignore:
							ignore_col.append('\t\tXLS <%s> %d行 <%s> 因列数据 <%s> 被忽略' % (fname, i + 1, head, col))
							break
						else:
							record_error('XLS <%s> %d行 <%s> 列数据 <%s> >' % (fname, i + 1, head, col) + msg)
							continue
					for ind, ids in ctype.get_idvalue(rst).iteritems():
						index.setdefault(ind, [])
						for idv in ids:
							index[ind].append((fname, '%d行 <%s> 列' % (i + 1, head), idv))
				else:
					if req == REQUIRED:
						if field in ignore:
							ignore_col.append('\t\tXLS <%s> %d行 <%s> 因必填列为空被忽略' % (fname, i + 1, head))
							break
						else:
							record_error('XLS <%s> %d行必须填写 <%s> 列' % (fname, i + 1, head))
							continue
					elif is_optional(req):
						if req.default == None:
							continue
						else:
							rst = req.default
					else:
						continue
				set_value_by_link(meta, field, rst)
				if head in rule['id']:
					idvalue.append(rst)
				if is_string(req):
					groups.setdefault(req, set())
					groups[req].add(head)
			if has_error():
				continue
			if ignore_col:
				ignore_row += ignore_col
				ignore_col = []
				continue
			if not idvalue:
				record_error('XLS <%s> %d行没有ID数据' % (fname, i + 1))
				continue
			if len(idvalue) > 1:
				idvalue = tuple(idvalue)
			else:
				idvalue = idvalue[0]
			if idvalue in data:
				record_error('XLS <%s> %d行ID数据 <%s> 重复' % (fname, i + 1, idvalue))
				continue
			#判断组
			for gname, gset in groups.iteritems():
				if gset != define.GROUPS[gname]:
					record_error('XLS <%s> %d行 <%s> 组数据必须同时填写' % (fname, i + 1, gname))
					continue
			if has_error():
				continue
			if not meta['_exp_flag']:
				continue
			meta.pop('_exp_flag')
			data[idvalue] = meta
		pop_errstack()
		if has_error():
			write_error()
		else:
			write_ok()
	pop_errstack()
	merge_errstack()
	if has_error():
		return None
	#生成index集合
	if rule['index']:
		EXPORTER_INDEX[rule['index']]['set'] = set(data.keys())
	if ignore_row:
		print_info('\n'.join(ignore_row))
	return data

def proc_parse_element(fname, tname, define, element, index):
	etag = unicode_to_gbk(element.tag)
	if len(define.DEFINE[etag]) == 4:
		name, etype, children, attrdef = define.DEFINE[etag]
	else:
		name, etype, share, children, attrdef = define.DEFINE[etag]
	attrs = define.FIELDS[etag]
	extra = set(map(unicode_to_gbk, element.keys())) - set(attrs.keys())
	if extra:
		record_error('XML <%s> 标签 <%s> 属性 <%s> 并不包含在定义中' % (fname, tname, '，'.join(extra)))
		return None
	#导出属性
	data = {}
	groups = {}
	for attr, (field, atype, req, share) in attrs.iteritems():
		value = unicode_to_gbk(element.get(gbk_to_unicode(attr), '')).strip().replace('\n', '')
		if req == COMMENT:
			continue
		if value:
			rst, msg = atype.export_value(value)
			if rst == None:
				record_error('XML <%s> 标签 <%s> 属性 <%s> >' % (fname, tname, attr) + msg)
				continue
			for ind, ids in atype.get_idvalue(rst).iteritems():
				index.setdefault(ind, [])
				for idv in ids:
					index[ind].append((fname, '标签 <%s> 属性 <%s> ' % (tname, attr), idv))
		else:
			if req == REQUIRED:
				record_error('XML <%s> 标签 <%s> 属性 <%s> 必须填写' % (fname, tname, attr))
				continue
			elif is_optional(req):
				if req.default == None:
					continue
				else:
					rst = req.default
			else:
				continue
		set_value_by_link(data, field, rst)
		if is_string(req):
			groups.setdefault(req, set())
			groups[req].add(attr)
	if has_error():
		return None
	#判断组
	for gname, gset in groups.iteritems():
		if gset != define.GROUPS[etag][gname]:
			record_error('XML <%s> 标签 <%s> 的 <%s> 组数据必须同时填写' % (fname, tname, gname))
			continue
	if has_error():
		return None
	#导出子标签
	ctags = set()
	for child in list(element):
		ctag = unicode_to_gbk(child.tag)
		ctags.add(ctag)
		childname = tname + '.' + ctag
		if ctag not in children:
			record_error('XML <%s> 标签 <%s> 并不包含子标签 <%s> ' % (fname, tname, childname))
			continue
		if ctag not in define.DEFINE:
			record_error('XML <%s> 标签 <%s> 的子标签 <%s> 并不包含在定义中' % (fname, tnmae, childname))
			continue
		push_errstack('标签' + ctag)
		meta = proc_parse_element(fname, childname, define, child, index)
		pop_errstack()
		if meta == None:
			continue
		if len(define.DEFINE[ctag]) == 4:
			cname, cetype, cchildren, cattrdef = define.DEFINE[ctag]
		else:
			cname, cetype, cshare, cchildren, cattrdef = define.DEFINE[ctag]
		if is_string(cetype):
			data.setdefault(cname, {})
			idvalue = meta[define.FIELDS[ctag][cetype][0]]
			if idvalue in data[cname]:
				record_error('XML <%s> 标签 <%s> 的子标签 <%s> Key <%s> 重复' % (fname, tname, childname, idvalue))
				continue
			data[cname][idvalue] = meta
		elif cetype == ARRAY:
			data.setdefault(cname, [])
			data[cname].append(meta)
		else:
			if cname in data:
				record_error('XML <%s> 标签 <%s> 的子标签 <%s> 必须为单一标签' % (fname, tname, childname))
				continue
			data[cname] = meta
	#子标签定义完整性
	extra = set(children) - ctags
	if extra:
		record_error('XML <%s> 标签 <%s> 的子标签 <%s> 必须填写' % (fname, tname, '，'.join(extra)))
	if has_error():
		return None
	return data

def proc_parse_xml(rule, index):
	define = rule['define']
	data = {}
	holder_errstack()
	for fname in rule['files']:
		tail_errstack('文件' + fname)
		write_proc('开始分析 <%s> ' % fname, tabs = 1)
		try:
			f = open(fname)
		except Exception, e:
			record_error('打开文件 <%s> 错误>' % fname + str(e))
			write_error()
			continue
		content = f.read()
		f.close()
		try:
			root = xml.etree.ElementTree.fromstring(gbk_to_utf8(content))
		except Exception, e:
			record_error('解析文件 <%s> 错误>' % fname + str(e))
			write_error()
			continue
		#导出root
		childtag = define.DEFINE['root']
		for child in list(root):
			childname = unicode_to_gbk(root.tag) + '.' + childtag
			if unicode_to_gbk(child.tag) != childtag:
				record_error('XML <%s> root并不包含子标签 <%s> ' % (fname, childname))
				continue
			push_errstack('标签' + childtag)
			meta = proc_parse_element(fname, childname, define, child, index)
			pop_errstack()
			if meta == None:
				continue
			if len(define.DEFINE[childtag]) == 4:
				name, etype, children, attrdef = define.DEFINE[childtag]
			else:
				name, etype, share, children, attrdef = define.DEFINE[childtag]
			idvalue = meta[define.FIELDS[childtag][etype][0]]
			if idvalue in data:
				record_error('XML <%s> root的子标签 <%s> Key <%s> 重复' % (fname, childname, idvalue))
				continue
			data[idvalue] = meta
		if has_error():
			write_error()
		else:
			write_ok()
	pop_errstack()
	merge_errstack()
	if has_error():
		return None
	#生成index集合
	if rule['index']:
		EXPORTER_INDEX[rule['index']]['set'] = set(data.keys())
	return data

def proc_check_feature(conf, rule, name, old, new):
	for feature in rule['feature']:
		if feature == DENY_DEL:
			keys = set(old.keys()) - set(new.keys())
			if keys:
				record_error(' <%s> 不允许删除导表器 <%s> 的数据 <%s> ' % (conf, name, keys.join('，')))
		elif feature == DENY_ADD:
			keys = set(new.keys()) - set(old.keys())
			if keys:
				record_error(' <%s> 不允许新增导表器 <%s> 的数据 <%s> ' % (conf, name, keys.join('，')))

def proc_merge_dict(data, join):
	for k, v in join.iteritems():
		if k not in data:
			data[k] = v
		else:
			if type(data[k]) != type(v):
				return False
			if type(data[k]) == dict:
				if not proc_merge_dict(data[k], v):
					return False
			elif type(data[k]) == list:
				if len(data[k]) != len(v):
					return False
				for kk, vv in enumerate(v):
					if type(data[k][kk]) != type(vv):
						return False
					if type(data[k][kk]) == dict:
						if not proc_merge_dict(data[k][kk], vv):
							return False
					elif data[k][kk] != vv:
						return False
			elif data[k] != v:
				return False
	return True

def proc_merge_data(rule, name, server, client):
	write_proc('正在合并 <%s> ' % name, tabs = 2)
	if rule['share'] != SPLIT:
		record_error('合并旧数据 <%s> 错误' % name)
		write_error()
		return None
	if not proc_merge_dict(server, client):
		record_error('合并旧数据 <%s> 错误' % name)
		write_error()
		return None
	write_ok()
	return server

def proc_split_dict(fields, data, server, client, isdict = None, islist = None):
	for k, v in data.iteritems():
		#未知导出键作为COMMON
		if k not in fields:
			server[k] = v
			client[k] = v
		else:
			share = fields[k]
			if type(share) == dict:
				if isdict == None:
					isdict = share.get('__dict__', None)
				if islist == None:
					islist = share.get('__list__', None)
				if isdict:
					server[k] = {}
					client[k] = {}
					for kk, vv in v.iteritems():
						server[k][kk] = {}
						client[k][kk] = {}
						if not proc_split_dict(share, vv, server[k][kk], client[k][kk], isdict = False):
							return False
				elif islist:
					server[k] = []
					client[k] = []
					for kk, vv in enumerate(v):
						server[k].append({})
						client[k].append({})
						if not proc_split_dict(share, vv, server[k][kk], client[k][kk], islist = False):
							return False
				else:
					server[k] = {}
					client[k] = {}
					if not proc_split_dict(share, v, server[k], client[k]):
						return False
			elif share == COMMON:
				server[k] = v
				client[k] = v
			elif share == SERVER:
				server[k] = v
			elif share == CLIENT:
				client[k] = v
	return True

def proc_split_csv(define):
	fields = {}
	for row in define.DEFINE:
		if len(row) == 4:
			share = COMMON
		else:
			share = row[4]
		set_value_by_link(fields, row[1], share)
	fields['__dict__'] = True
	return fields

def proc_split_element(define, fields, tag):
	tagdef = define.DEFINE[tag]
	field = tagdef[0]
	if len(tagdef) == 4:
		fields[field] = COMMON
	else:
		share = tagdef[2]
		if share == SPLIT:
			fields[field] = {}
			ttype = tagdef[1]
			if is_string(ttype):
				fields[field]['__dict__'] = True
			elif ttype == ARRAY:
				fields[field]['__list__'] = True
			for attr in tagdef[4]:
				if len(attr) == 4:
					share = COMMON
				else:
					share = attr[4]
				set_value_by_link(fields[field], attr[1], share)
			for child in tagdef[3]:
				proc_split_element(define, fields[field], child)
		else:
			fields[field] = share

def proc_split_xml(define):
	fields = {}
	proc_split_element(define, fields, define.DEFINE['root'])
	return fields[define.DEFINE[define.DEFINE['root']][0]]

def proc_split_data(rule, name, data):
	write_proc('正在分拆 <%s> ' % name, tabs = 2)
	if rule['share'] != SPLIT:
		record_error('分拆新数据 <%s> 错误' % name)
		write_error()
		return None
	if rule['define'].TYPE == XLS:
		fields = proc_split_csv(rule['define'])
	else:
		fields = proc_split_xml(rule['define'])
	server = {}
	client = {}
	for k, v in data.iteritems():
		server[k] = {}
		client[k] = {}
		if not proc_split_dict(fields, v, server[k], client[k]):
			record_error('分拆新数据 <%s> 错误' % name)
			write_error()
			return None
	write_ok()
	return server, client

def proc_load_file(fname):
	write_proc('正在导入 <%s> ' % fname, tabs = 2)
	if not os.path.exists(fname):
		write_ok()
		return {}
	if not os.path.isfile(fname):
		record_error('对应旧数据 <%s> 不是一个文件' % fname)
		write_error()
		return None
	try:
		data = {}
		execfile(fname, {}, data)
		data = data['data']
	except Exception, e:
		data = None
	write_ok()
	if data == None:
		data = {}
		print_info('\t\t错误旧数据 <%s> 被空数据替代' % fname)
	return data

def proc_load_data(rule):
	holder_errstack()
	if EXP_FILE in rule['feature']:
		ext = '.py.exp'
	else:
		ext = '.py'
	for name in rule['exporter'].iterkeys():
		tail_errstack('导出器' + name)
		EXPORTER_OLDDATA[name] = {}
		holder_errstack()
		server = os.path.join(PYTHON_PATH, name + ext)
		client = os.path.join(PYTHON_PATH, name + ext)
		if rule['share'] == COMMON:
			tail_errstack('文件' + server)
			data = proc_load_file(server)
		elif rule['share'] == SERVER:
			tail_errstack('文件' + server)
			data = proc_load_file(server)
		elif rule['share'] == CLIENT:
			tail_errstack('文件' + client)
			data = proc_load_file(client)
		else:
			tail_errstack('文件' + server)
			sdata = proc_load_file(server)
			tail_errstack('文件' + client)
			cdata = proc_load_file(client)
			tail_errstack('合并' + name)
			if sdata == None or cdata == None:
				data = {}
			else:
				data = proc_merge_data(rule, name, sdata, cdata)
		pop_errstack()
		merge_errstack()
		if data == None:
			continue
		if has_error():
			continue
		EXPORTER_OLDDATA[name] = data
	pop_errstack()
	if has_error():
		return False
	return True

def proc_dump_value(data):
	if isinstance(data, dict):
		metas = []
		for k in sorted(data.keys()):
			metas.append('%s: %s' % (proc_dump_value(k), proc_dump_value(data[k])))
		return '{%s}' % (', '.join(metas))
	elif isinstance(data, tuple):
		metas = []
		for m in data:
			metas.append(proc_dump_value(m))
		return '(%s)' % (', '.join(metas))
	elif isinstance(data, list):
		metas = []
		for m in data:
			metas.append(proc_dump_value(m))
		return '[%s]' % (', '.join(metas))
	elif isinstance(data, basestring):
		return '"%s"' % data
	else:
		return str(data)

def proc_dump_lua_key(data):
	if isinstance(data, int):
		return '[%d]' % (data,)
	elif isinstance(data, float):
		return '[%f]' % (data,)
	elif isinstance(data, str):
		return '["%s"]' % (data,)
	elif isinstance(data, tuple):
		alls = []
		for val in data:
			alls.append(str(val))
		return '[\''+','.join(alls)+'\']'
	return str(data)
		
def proc_dump_lua_value(data):
	if isinstance(data, dict):
		metas = []
		for k in sorted(data.keys()):
			metas.append('%s=%s' % (proc_dump_lua_key(k), proc_dump_lua_value(data[k])))
		return '{%s}' % (', '.join(metas))
	elif isinstance(data, tuple) or isinstance(data, list):
		metas = []
		for m in data:
			metas.append(proc_dump_lua_value(m))
		return '{%s}' % (', '.join(metas))
	elif isinstance(data, basestring):
		return "'%s'" % data
	elif isinstance(data, bool):
		if data:
			return 'true'
		else:
			return 'false'
	else:
		return str(data)

def proc_dump_python(fname, data):
	write_proc('正在导出 <%s> ' % fname, tabs = 2)
	try:
		f = open(fname, 'w')
	except Exception, e:
		record_error('打开PYTHON文件 <%s> 错误>' % fname + str(e))
		write_error()
		return False
	lines = []
	try:
		f.write('# -*- coding: UTF-8 -*-\n')
		f.write('_reload_all = True\n')
		f.write('data = {\n')
		for k in sorted(data.keys()):
			lines.append('\t%s: %s' % (proc_dump_value(k), proc_dump_value(data[k])))
		f.write(',\n'.join(lines))
		f.write('\n}')
	except Exception, e:
		f.close()
		record_error('导出PYTHON数据 <%s> 错误>' % fname + str(e))
		write_error()
		return False
	f.close()
	write_ok()
	return True

def proc_dump_lua(module_name, fname, data):
	write_proc('正在导出 <%s> ' % fname, tabs = 2)
	try:
		f = open(fname, 'w')
	except Exception, e:
		record_error('打开LUA文件 <%s> 错误>' % fname + str(e))
		write_error()
		return False
	lines = []
	try:
		f.write("_G['data'].%s = {\n" %(module_name,))
		for k in sorted(data.keys()):
			lines.append('\t%s=%s' % (proc_dump_lua_key(k), proc_dump_lua_value(data[k]).decode('gbk').encode('utf8')))
		f.write(',\n'.join(lines))
		f.write('\n}')
	except Exception, e:
		f.close()
		record_error('导出LUA数据 <%s> 错误>' % fname + str(e))
		write_error()
		return False
	f.close()
	write_ok()
	return True

def proc_dump_json(fname, data):
	write_proc('正在导出 <%s> ' % fname, tabs = 2)
	try:
		f = open(fname, 'w')
	except Exception, e:
		record_error('打开JSON文件 <%s> 错误>' % fname + str(e))
		write_error()
		return False
	lines = []
	try:
		f.write('{\n')
		for k in sorted(data.keys()):
			if type(k) == tuple:
				sk = ','.join(map(str, k))
			else:
				sk = str(k)
			lines.append('\t"%s": %s' % (sk, json.dumps(data[k], f, encoding = 'gbk').decode('unicode_escape').encode('gbk')))
		f.write(',\n'.join(lines))
		f.write('\n}')
	except Exception, e:
		f.close()
		record_error('导出JSON数据 <%s> 错误>' % fname + str(e))
		write_error()
		return False
	f.close()
	write_ok()
	return True

def proc_dump_data(rule):
	holder_errstack()
	if EXP_FILE in rule['feature']:
		ext = '.exp'
	else:
		ext = ''
	python_ext = '.py' + ext
	lua_ext = '.lua' + ext
	json_ext = '.json' + ext
	for name in rule['exporter'].iterkeys():
		tail_errstack('导出器' + name)
		holder_errstack()
		data = EXPORTER_NEWDATA[name]
		split_data = None
		py_client_out = os.path.join(OUTPUT_PATH, PYTHON_PATH, CLIENT_PATH, name + python_ext)
		py_server_out = os.path.join(OUTPUT_PATH, PYTHON_PATH, SERVER_PATH, name + python_ext)
		lua_client_out = os.path.join(OUTPUT_PATH, LUA_PATH, CLIENT_PATH, name + lua_ext)
		lua_server_out = os.path.join(OUTPUT_PATH, LUA_PATH, SERVER_PATH, name + lua_ext)
		json_client_out = os.path.join(OUTPUT_PATH, JSON_PATH, CLIENT_PATH, name + json_ext)
		json_server_out = os.path.join(OUTPUT_PATH, JSON_PATH, SERVER_PATH, name + json_ext)
		if rule['share'] == COMMON:
			tail_errstack('文件' + name)
			proc_dump_python(py_client_out, data)
			proc_dump_lua(name, lua_client_out, data)
			#proc_dump_json(json_client_out, data)

			proc_dump_python(py_server_out, data)
			proc_dump_lua(name, lua_server_out, data)
			#proc_dump_json(json_server_out, data)
		elif rule['share'] == SERVER:
			tail_errstack('文件' + name)
			proc_dump_python(py_server_out, data)
			proc_dump_lua(name, lua_server_out, data)
			#proc_dump_json(json_server_out, data)
		elif rule['share'] == CLIENT:
			tail_errstack('文件' + name)
			proc_dump_python(py_client_out, data)
			proc_dump_lua(name, lua_client_out, data)
			#proc_dump_json(json_client_out, data)
		elif split_data != None:
			tail_errstack('分拆' + name)
			split_data = proc_split_data(rule, name, data)

			sdata, cdata = split_data
			tail_errstack('文件' + name)
			proc_dump_python(py_client_out, cdata)
			proc_dump_lua(name, lua_client_out, cdata)
			#proc_dump_json(json_client_out, cdata)

			proc_dump_python(py_server_out, sdata)
			proc_dump_lua(name, lua_server_out, sdata)
			#proc_dump_json(json_server_out, sdata)
				
		pop_errstack()
	pop_errstack()
	if has_error():
		return False
	return True

def cmd_check(files, path, flags):
	#分析XLS/XML至原始数据文件，并导入对应旧数据
	push_errstack('原始数据解析')
	print_info('\n开始分析XML/XLS文件\n')
	index = {}
	holder_errstack()
	for conf in files:
		tail_errstack('文件' + conf)
		rule = RULES[conf]
		if rule['define'].TYPE == XLS:
			rst = proc_parse_xls(rule, index, rule['sheet'])
		elif rule['define'].TYPE == XMl:
			rst = proc_parse_xml(rule, index)
		if rst == None:
			continue
		if not proc_load_data(rule):
			continue
		EXPORTER_RAWDATA[mod_name(rule['define'])] = rst
		print_info('')
	pop_errstack()
	assert_error()

	tail_errstack('ID依赖检查')
	write_proc('正在检查数据ID依赖')
	for iname, infos in index.iteritems():
		iconf = EXPORTER_INDEX[iname]['conf']
		iset = EXPORTER_INDEX[iname]['set']
		for fname, pos, value in infos:
			if value not in iset:
				record_error(' <%s> 文件%s的ID <%s> 数据 <%s> 不存在 <%s> 中' % (fname, pos, iname, value, iconf))
	assert_error()
	write_ok()

	#载入导表器外部参数
	flag_init(flags)

	#按依赖顺序进行对原始数据进行导表检查
	tail_errstack('导出器数据解析')
	print_info('\n开始检查XLS/XML文件\n')
	holder_errstack()
	for conf in EXPORTER_QUEUE:
		if conf not in files:
			continue
		print_info('开始检查 <%s> ' % conf.decode(ORIGIN_ENCODING).encode(FINAL_ENCODING), tabs = 1)
		rule = RULES[conf]
		dpd = []
		for d in rule['depend']:
			dpd.append(mod_name(RULES[d]['define']))
		for name, func in rule['exporter'].iteritems():
			tail_errstack('导出器' + name)
			write_proc('正在检查 <%s> ' % name, tabs = 2)
			new = func(EXPORTER_OLDDATA[name], EXPORTER_RAWDATA[mod_name(rule['define'])], (dpd, EXPORTER_NEWDATA), EXPORTER_RAWDATA)
			if new == None:
				record_error(' <%s> 的导出函数 <%s> 导出过程中发现错误' % (conf, name))
			elif type(new) != dict:
				record_error(' <%s> 的导出函数 <%s> 返回值仅能包含一项' % (conf, name))
			assert_error()
			proc_check_feature(conf, rule, name, EXPORTER_OLDDATA[name], new)
			assert_error()
			EXPORTER_NEWDATA[name] = new
			write_ok()
		print_info('')
	pop_errstack(2)

def cmd_export(files, path, flags):
	cmd_check(files, path, flags)

	#检查完毕后导出
	push_errstack('处理数据导出')
	print_info('\n开始导出文件\n')
	holder_errstack()
	for conf in files:
		print_info('开始导出 <%s> ' % conf.decode(ORIGIN_ENCODING).encode(FINAL_ENCODING), tabs = 1)
		rule = RULES[conf]
		if not proc_dump_data(rule):
			continue
		print_info('')
	pop_errstack()
	assert_error()

def gen_parser():
	parser = argparse.ArgumentParser(description = '导表工具：将XLS/XML配置文件导出为PYTHON/LUA/JSON文件')
	cmd = parser.add_subparsers(title = '导表工具可提供的功能')

	common = argparse.ArgumentParser(add_help = False)
	common.add_argument('-f', '--file', dest = 'file', metavar = 'FILE',
		help = '指定单个XLSX/XML配置文件，相对于 <%s> 目录的路径，默认为 <%s> 目录中所有文件' % (CONF_PATH, CONF_PATH))
	common.add_argument('-p', '--path', dest = 'path', metavar = 'PATH',
		help = '指定XLSX/XML配置文件，相对于当前目录的路径或者绝对路径，默认为预先设置目录 <%s>' % DATA_PATH)
	common.add_argument('-o', '--output', dest = 'output', metavar = 'OUTPUT',
		help = 'PYTHON/LUA/JSON文件数据目录，相对于当前目录的路径或者绝对路径，默认为预先设置目录 <%s>' % OUTPUT_PATH)
	common.add_argument('-l', '--flags', dest = 'flags', metavar = 'FLAGS',
		help = '导表器附加参数')

	check = cmd.add_parser('check', parents = [common], help = '检查XLS/XML配置文件，并不实际导出PYTHON/LUA文件')
	check.set_defaults(handler = cmd_check)

	export = cmd.add_parser('export', parents = [common], help = '检查XLS/XML配置文件，并导出为PYTHON/LUA文件到目录')
	export.set_defaults(handler = cmd_export)

	return parser

def main():
	parser = gen_parser()
	args = parser.parse_args()

	write_proc('检查导表设置')
	files = getattr(args, 'file', '')
	path = getattr(args, 'path', '')
	flags = getattr(args, 'flags', '')
	files, path, flags = check_cmd_option(files, path, flags)
	write_ok()

	args.handler(files, path, flags)

if __name__ == '__main__':
	try:
		import psyco
		psyco.full()
	except:
		pass
	main()
