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
FINAL_ENCODING = 'gbk'

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
		record_error('������Ŀ¼ <%s> ������' % os.path.join(path, EXPORTER_PATH))
	if not isdir( os.path.join(path, CONF_PATH) ):
		record_error('�����ļ�Ŀ¼ <%s> ������' % os.path.join(path, CONF_PATH))
	if not isdir( os.path.join(path, PYTHON_PATH) ):
		record_error('PYTHON ����Ŀ¼ <%s> ������' % os.path.join(path, PYTHON_PATH))
	if not isdir( os.path.join(path, LUA_PATH) ):
		record_error('LUA ����Ŀ¼ <%s> ������' % os.path.join(path, LUA_PATH))
	#if not isdir( os.path.join(path, JSON_PATH) ):
	#	record_error('JSON ����Ŀ¼ <%s> ������' % os.path.join(path, JSON_PATH))
	return path

def check_option_flags(flags):
	if not flags:
		return ''
	chars = set(flags)
	allow = set('qazxswedcvfrtgbnhyujmkiolp,')
	if chars - allow:
		record_error('���������� <%s> ֻ��ΪСд��ĸ�Ͷ��ŷָ���' % flags)
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
		record_error(' <%s> �����ļ�������' % conf)
		return False
	ext = set()
	for fname in files:
		if not os.path.isfile(fname):
			record_error(' <%s> ����һ����Ч���ļ�' % fname)
			continue
		ext.add(os.path.splitext(fname)[1])
	if has_error():
		return False
	if len(ext) != 1:
		record_error(' <%s> �����ļ����� <%s> ��ͳһ' % (fname, ', '.join(ext)))
		return False
	rule['files'] = files
	return True

def check_define_xls(conf, rule, mod):
	if type(mod.DEFINE) != tuple:
		record_error(' <%s> ��XLS���������tuple' % conf)
		return False
	columns = []
	fields = {}
	groups = {}
	for meta in mod.DEFINE:
		if type(meta) != tuple:
			record_error(' <%s> ��XLS����ĵ��������tuple' % conf)
			continue
		if not (4 <= len(meta) <= 5):
			record_error(' <%s> ��XLS����ĵ������������������ֶΡ����͡����󡢹���-ѡ�����' % conf)
			continue
		if len(meta) == 4:
			col, field, ctype, req = meta
			share = None
		else:
			col, field, ctype, req, share = meta
		if not is_string(col):
			record_error(' <%s> ��XLS�����������������Ϊstring' % conf)
			continue
		if col in columns:
			record_error(' <%s> ��XLS������������� <%s> �����ظ�' % (conf, col))
			continue
		if not is_string(field):
			record_error(' <%s> ��XLS������� <%s> �ֶβ�������Ϊstring' % (conf, col))
			continue
		if field in fields:
			record_error(' <%s> ��XLS������� <%s> �ֶβ��� <%s> �����ظ�' % (conf, col, field))
			continue
		if not is_anytype(ctype):
			record_error(' <%s> ��XLS������� <%s> ���Ͳ�������ΪԤ��������' % (conf, col))
			continue
		if inspect.isclass(ctype):
			ctype = ctype()
		rst, msg = ctype.check_option()
		if not rst:
			record_error(' <%s> ��XLS������� <%s> ���Ͳ���>' % (conf, col) + msg)
			continue
		for idtype in ctype.get_idtype():
			if idtype.index not in EXPORTER_INDEX:
				record_error(' <%s> ��XLS������� <%s> Id���Ͳ������������ <%s> ���ڵ����б��д���' % (conf, col, idtype.index))
		if has_error():
			continue
		if req not in (REQUIRED, COMMENT) and not is_optional(req) and not is_string(req):
			record_error(' <%s> ��XLS������� <%s> �����������Ϊ���ѡ����顢ע������' % (conf, col))
			continue
		if req == OPTIONAL:
			req = OPTIONAL()
		if rule['share'] == SPLIT:
			if share not in (COMMON, SERVER, CLIENT, None):
				record_error(' <%s> ��XLS������� <%s> �����������Ϊ���á�����ˡ��ͻ�������' % (conf, col))
				continue
		elif share != None:
				record_error(' <%s> ��XLS������� <%s> ����������ܶ���' % (conf, col))
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
			record_error(' <%s> ��XML����� <%s> �Ĺ������ͱ���͸���ǩ <%s> ����' % (conf, tag, ptag))
			return False
		if share == None:
			share = COMMON
	elif pshare != None:
		if share != None:
			record_error(' <%s> ��XML����� <%s> �Ĺ������ͱ���͸���ǩ <%s> ����' % (conf, tag, ptag))
			return False
		share = pshare
	for child in children:
		if not check_define_share(conf, define, child, tag, share):
			return False
	return True

def check_define_xml(conf, rule, mod):
	if type(mod.DEFINE) != dict:
		record_error(' <%s> ��XML���������dict' % conf)
		return False
	if 'root' not in mod.DEFINE:
		record_error(' <%s> ��XML����������root��' % conf)
		return False
	if not is_string(mod.DEFINE['root']):
		record_error(' <%s> ��XML����root�����Ϊstring' % conf)
		return False
	if mod.DEFINE['root'] not in mod.DEFINE:
		record_error(' <%s> ��XML����root�� <%s> ���ڶ�����' % (conf, mod.DEFINE['root']))
		return False
	if has_error():
		return False
	fields = {}
	groups = {}
	holder_errstack()
	for tag, define in mod.DEFINE.iteritems():
		tail_errstack('��ǩ' + tag)
		if tag == 'root':
			continue
		if not is_string(tag):
			record_error(' <%s> ��XML����ÿ���ǩ��������Ϊstring' % conf)
			continue
		if type(define) != tuple:
			record_error(' <%s> ��XML����� <%s> ��ÿ������Ϊtuple' % (conf, tag))
			continue
		if not (4 <= len(define) <= 5):
			record_error(' <%s> ��XML����� <%s> ��ÿ������������ֶ��������͡�����-ѡ�������ԣ�����' % (conf, tag))
			continue
		if len(define) == 4:
			name, ttype, children, attrs = define
			share = None
		else:
			name, ttype, share, children, attrs = define
		if not is_string(name):
			record_error(' <%s> ��XML����� <%s> �����ֲ�������Ϊstring' % (conf, tag))
			continue
		if ttype != SINGLE and ttype != ARRAY and not is_string(ttype):
			record_error(' <%s> ��XML����� <%s> �����Ͳ�������ΪԤ����ֵ' % (conf, tag))
			continue
		if tag == mod.DEFINE['root'] and not is_string(ttype):
			record_error(' <%s> ��XML�����root�ӱ�ǩ <%s> �����Ͳ�������ΪDICT' % (conf, tag))
			continue
		if type(children) != tuple:
			record_error(' <%s> ��XML����� <%s> �������������Ϊtuple' % (conf, tag))
			continue
		if rule['share'] == SPLIT:
			if share not in (COMMON, SERVER, CLIENT, SPLIT, None):
				record_error(' <%s> ��XML����� <%s> �����������Ϊ���á��ֲ𡢷���ˡ��ͻ�������' % (conf, tag))
				continue
		elif share != None:
				record_error(' <%s> ��XML����� <%s> ����������ܶ���' % (conf, tag))
				continue
		names = set()
		for child in children:
			if not is_string(child):
				record_error(' <%s> ��XML����� <%s> ���������ÿ�����Ϊstring' % (conf, tag))
				continue
			if child not in mod.DEFINE:
				record_error(' <%s> ��XML����� <%s> ����������� <%s> ���ڶ�����' % (conf, tag, child))
				continue
			childname = mod.DEFINE[child][0]
			if childname in names:
				record_error(' <%s> ��XML����� <%s> ����������� <%s> �����ֲ��� <%s> ��ͬһ�㼶�ظ�' % (conf, tag, child, childname))
				continue
			names.add(childname)
		if has_error():
			continue
		if type(attrs) != tuple:
			record_error(' <%s> ��XML����� <%s> �����Բ�������Ϊtuple' % (conf, tag))
			continue
		fields[tag] = {}
		groups[tag] = {}
		for attr in attrs:
			if type(attr) != tuple:
				record_error(' <%s> ��XML����� <%s> �����Բ������������tuple' % (conf, tag))
				continue
			if not (4 <= len(attr) <= 5):
				record_error(' <%s> ��XML����� <%s> �����Բ������������������������ֶΡ����͡����󡢹���-ѡ�����' % (conf, tag))
				continue
			if len(attr) == 4:
				aname, field, atype, req = attr
				ashare = None
			else:
				aname, field, atype, req, ashare = attr
			if not is_string(aname):
				record_error(' <%s> ��XML����� <%s> ����������������Ϊstring' % (conf, tag))
				continue
			if aname in children:
				record_error(' <%s> ��XML����� <%s> ������������ <%s> �������ӱ�ǩ��ͬ' % (conf, tag, aname))
				continue
			if aname in names:
				record_error(' <%s> ��XML����� <%s> ������������ <%s> �����ظ�' % (conf, tag, aname))
				continue
			if not is_string(field):
				record_error(' <%s> ��XML����� <%s> ������ <%s> �ֶβ�������Ϊstring' % (conf, tag, aname))
				continue
			if field in fields[tag]:
				record_error(' <%s> ��XML����� <%s> ������ <%s> �ֶβ��� <%s> �����ظ�' % (conf, tag, aname, field))
				continue
			if not is_anytype(atype):
				record_error(' <%s> ��XML����� <%s> ������ <%s> ���Ͳ�������ΪԤ��������' % (conf, tag, aname))
				continue
			if inspect.isclass(atype):
				atype = atype()
			rst, msg = atype.check_option()
			if not rst:
				record_error(' <%s> ��XML����� <%s> ������ <%s> ���Ͳ���>' % (conf, tag, aname) + msg)
				continue
			for idtype in atype.get_idtype():
				if idtype.index not in EXPORTER_INDEX:
					record_error(' <%s> ��XML����� <%s> ������ <%s> Id���Ͳ������������ <%s> ���ڵ����б��д���' % (conf, tag, aname, idtype.index))
			if has_error():
				continue
			if req not in (REQUIRED, COMMENT) and not is_optional(req) and not is_string(req):
				record_error(' <%s> ��XML����� <%s> ������ <%s> �������������Ϊ���ѡ����顢ע������' % (conf, tag, aname))
				continue
			if req == OPTIONAL:
				req = OPTIONAL()
			if rule['share'] == SPLIT and share == SPLIT:
				if ashare not in (COMMON, SERVER, CLIENT, None):
					record_error(' <%s> ��XML����� <%s> ������ <%s> �����������Ϊ���á�����ˡ��ͻ�������' % (conf, tag, aname))
					continue
			elif ashare != None:
					record_error(' <%s> ��XML����� <%s> ������ <%s> ����������ܶ���' % (conf, tag, aname))
					continue
			names.add(aname)
			fields[tag][aname] = (field, atype, req, ashare)
			if is_string(req):
				groups[tag].setdefault(req, set())
				groups[tag][req].add(aname)
		if has_error():
			continue
		if is_string(ttype) and ttype not in fields[tag]:
			record_error(' <%s> ��XML����� <%s> ��DICT����ָ�������� <%s> ���Բ�����' % (conf, tag, ttype))
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
		record_error(' <%s> �������ö�����' % conf)
		return False
	if not is_string(rule['define']):
		record_error(' <%s> �Ķ��������ñ�����string' % conf)
		return False
	pathpy = os.path.join(path, EXPORTER_PATH, rule['define'] + '.py')
	pathpyc = os.path.join(path, EXPORTER_PATH, rule['define'] + '.pyc')
	if not os.path.exists(pathpy) and not os.path.exists(pathpyc):
		record_error(' <%s> �Ķ����� <%s> ������' % (conf, pathpy))
		return False
	if os.path.exists(pathpy):
		path = pathpy
	else:
		path = pathpyc
	if not os.path.isfile(path):
		record_error(' <%s> �Ķ����� <%s> ����һ����Ч���ļ�' % (conf, path))
		return False
	try:
		mod = __import__('exporters.' + rule['define'], fromlist = [rule['define']])
	except Exception, e:
		record_error(' <%s> �Ķ����� <%s> �������>' % (conf, rule['define']) + str(e))
		return False
	if not hasattr(mod, 'TYPE'):
		record_error(' <%s> �Ķ����� <%s> �������������ļ�����' % (conf, rule['define']))
		return False
	if mod.TYPE not in AVAILABLE_CONF_TYPE:
		record_error(' <%s> �Ķ����� <%s> �������ļ����ͱ���ΪXML/XLS' % (conf, rule['define']))
		return False
	if not hasattr(mod, 'DEFINE'):
		record_error(' <%s> �Ķ����� <%s> �������������ļ�����' % (conf, rule['define']))
		return False
	if mod.TYPE == XML and not check_define_xml(conf, rule, mod):
		return False
	elif mod.TYPE == XLS and not check_define_xls(conf, rule, mod):
		return False
	confext = os.path.splitext(conf)[1][1:].upper()
	if mod.TYPE == XML and confext != 'XML':
		record_error(' <%s> �����ļ������붨���� <%s> �����ļ����Ͳ�ͳһ' % (conf, ', '.join(AVAILABLE_CONF_TYPE)))
		return False
	elif mod.TYPE == XLS and confext != 'XLSX':
		record_error(' <%s> �����ļ������붨���� <%s> �����ļ����Ͳ�ͳһ' % (conf, ', '.join(AVAILABLE_CONF_TYPE)))
		return False
	rule['define'] = mod
	return True

def check_rules_exporter(conf, rule):
	mod = rule['define']
	name = mod_name(mod)
	if not hasattr(mod, 'export'):
		record_error(' <%s> �ĵ����� <%s> ��������ԭ����������' % (conf, name))
		return False
	if len(inspect.getargspec(mod.export).args) != 4:
		record_error(' <%s> �ĵ����� <%s> ��������export�������ã�old��new��depend��rawdata������' % (conf, name))
		return False
	exfuncs = {name: mod.export}
	for attr in dir(mod):
		if not attr.startswith('export_'):
			continue
		funcname = attr[7:]
		if not funcname:
			record_error(' <%s> �ĵ����� <%s> ������������������������' % (conf, name))
			continue
		if funcname in exfuncs:
			record_error(' <%s> �ĵ����� <%s> ������������ <%s> �����ظ�' % (conf, name, funcname))
			continue
		func = getattr(mod, attr)
		if not inspect.isfunction(func):
			record_error(' <%s> �ĵ����� <%s> ������������ <%s> ������һ������' % (conf, name, funcname))
			continue
		if len(inspect.getargspec(func).args) != 4:
			record_error(' <%s> �ĵ����� <%s> ������������ <%s> �������ã�old��new��depend��rawdata������' % (conf, name, funcname))
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
			record_error(' <%s> �������б����Ϊstring����tuple' % conf)
			return False
		for d in rule['depend']:
			if not is_string(d):
				record_error(' <%s> �������б���ÿ��������string' % conf)
				continue
			if d not in RULES:
				record_error(' <%s> �������б��� <%s> �����ڵ����б��д���' % (conf, d))
		if has_error():
			return False
	return True

def check_rules_share(conf, rule):
	if 'share' not in rule:
		rule['share'] = COMMON
	else:
		if  rule['share'] not in (COMMON, SERVER, CLIENT, SPLIT):
			record_error(' <%s> �Ĺ������ͱ�����Ԥ���峣��' % conf)
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
			record_error(' <%s> �������б����Ϊint����tuple' % conf)
			return False
		for d in rule['feature']:
			tail_errstack('����' + str(d))
			if not is_integer(d):
				record_error(' <%s> �������б���ÿ�����Ա���Ϊ����' % conf)
				continue
			if d not in (DENY_DEL, DENY_ADD, IGNORE_TITLE, CHECK_BLINE, EACH_EXPORT, EXP_FILE):
				record_error(' <%s> �������б��� <%s> ������Ԥ���峣��' % (conf, d))
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
					record_error(' <%s> ��ID�����������Ϊstring' % conf)
					return False
		else:
			record_error(' <%s> ��ID���ñ���Ϊstring����string tuple' % conf)
			return False
	else:
		rule['id'] = ('id', )
	if rule['define'].TYPE == XLS:
		for mid in rule['id']:
			if mid not in rule['define'].COLUMNS:
				record_error(' <%s> ��ID���� <%s> �ڶ����� <%s> �����в�����' % (conf, mid, mod_name(rule['define'])))
				return False
			field, ctype, req, share = rule['define'].FIELDS[mid]
			if req != REQUIRED:
				record_error(' <%s> ��ID���� <%s> �ڶ����� <%s> �����б���Ϊ����' % (conf, mid, mod_name(rule['define'])))
				return False
			if share != None:
				record_error(' <%s> ��ID���� <%s> �ڶ����� <%s> �����в������ù������' % (conf, mid, mod_name(rule['define'])))
				return False
		if rule['index']:
			if len(rule['id']) == 1:
				EXPORTER_INDEX[rule['index']]['type'] = ctype
			else:
				record_error(' <%s> ��ID���� <%s> Ϊ�������������������' % (conf, rule['id']))
				return False
	elif rule['define'].TYPE == XML:
		if len(rule['id']) != 1:
			record_error(' <%s> ��ID���� <%s> XML����Ϊ����' % (conf, rule['id']))
			return False
		mid = rule['id'][0]
		tag = rule['define'].DEFINE['root']
		if mid not in rule['define'].FIELDS[tag]:
			record_error(' <%s> ��ID���� <%s> �ڶ����� <%s> ��root���� <%s> �����в�����' % (conf, mid, mod_name(rule['define']), tag))
			return False
		field, atype, req, share = rule['define'].FIELDS[tag][mid]
		if req != REQUIRED:
			record_error(' <%s> ��ID���� <%s> �ڶ����� <%s> ��root���� <%s> �����б���Ϊ����' % (conf, mid, mod_name(rule['define']), tag))
			return False
		if share != None:
			record_error(' <%s> ��ID���� <%s> �ڶ����� <%s> ��root���� <%s> �����в������ù������' % (conf, mid, mod_name(rule['define']), tag))
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
			record_error(' <%s> ���������ñ���Ϊstring' % conf)
			return False
		if rule['index'] in EXPORTER_INDEX:
			record_error(' <%s> ���������� <%s> �������ظ�' % (conf, rule['index']))
			return False
		EXPORTER_INDEX[rule['index']] = {'conf': conf, 'set': set(), 'type': None}
	else:
		rule['index'] = ''
	return True

def check_rules_queue(cur, wait):
	if cur in EXPORTER_QUEUE:
		return True
	#���μ��
	if cur in wait:
		return False
	#������˳������
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
		record_error('���붨�嵼���б�RULES')
		return False
	if type(RULES) != dict:
		record_error('�����б������һ��dict')
		return False

	#��ΪDEFINE�е�typeȷ��Id��������Щ
	holder_errstack(2)
	for conf, rule in RULES.iteritems():
		tail_errstack('�������>>�ļ�' + conf)
		if not check_rules_index(conf, rule):
			continue
	pop_errstack(2)
	if has_error():
		return False

	#�ټ��ʣ���
	holder_errstack(2)
	for conf, rule in RULES.iteritems():
		tail_errstack('�б���>>�ļ�' + conf)
		if not check_rules_file(path, conf, rule):
			continue
		tail_errstack('������>>�ļ�' + conf)
		if not check_rules_share(conf, rule):
			continue
		tail_errstack('���������>>�ļ�' + conf)
		if not check_rules_define(path, conf, rule):
			continue
		tail_errstack('���������>>�ļ�' + conf)
		if not check_rules_exporter(conf, rule):
			continue
		tail_errstack('�������>>�ļ�' + conf)
		if not check_rules_depend(conf, rule):
			continue
		tail_errstack('���Լ��>>�ļ�' + conf)
		if not check_rules_feature(conf, rule):
			continue
		tail_errstack('ID���>>�ļ�' + conf)
		if not check_rules_id(conf, rule):
			continue
	pop_errstack(2)
	if has_error():
		return False

	#��黷������
	push_errstack('�����������')
	if not check_rules_ring():
		record_error('�����б�����������')
		return False
	pop_errstack()

	#���ΪId�������type
	check_rules_idtype()
	return True

def check_option_depend(files, add):
	if add in files:
		return
	files.add(add)
	#�����������������
	rule = RULES[add]
	for d in rule['depend']:
		check_option_depend(files, d)
	#�����������Id������
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
	push_errstack('·�����')
	path = check_option_path(path)
	assert_error()

	push_errstack('�������')
	flags = check_option_flags(flags)
	assert_error()

	tail_errstack('������')
	rst = check_rules_config(path)
	assert_error()

	tail_errstack('�ļ����')
	rst, files = check_option_file(path, fname)
	if not rst:
		record_error('ָ�������ļ� <%s> ������' % fname)
	assert_error()
	pop_errstack()
	return files, path, flags

def proc_parse_xls(rule, index, sheet_name):
	define = rule['define']
	data = {}
	holder_errstack()
	for fname in rule['files']:
		tail_errstack('�ļ�' + fname)
		write_proc('��ʼ���� <%s> ' % fname, tabs = 1)
		try:
			reader = xlrd.open_workbook(fname).sheet_by_name(sheet_name.decode(ORIGIN_ENCODING))
		except Exception, e:
			record_error('��ȡXLS�ļ� <%s> ������Sheet <%s> ����>' % (fname, sheet_name ))
			write_error()
			continue
		try:
			fields = [v.value.encode(FINAL_ENCODING) for v in reader.row(0)]
		except Exception, e:
			record_error('��ȡXLS��ͷ <%s> ����>' % fname + str(e))
			write_error()
			continue
		#�ȶԱ�ͷ
		if len(set(fields)) != len(fields):
			fdset = set(fields)
			fdlist = list(fields)
			for fd in fdset:
				fdlist.remove(fd)
			record_error('XLS <%s> ��ͷ <%s> �����ظ�����' % (fname, '��'.join(fdlist)))
			write_error()
			continue
		#encoding
		if fields[0] != '�Ƿ񵼱�':
			record_error('��ͷ��һ�б���Ϊ �Ƿ񵼱�>')
			write_error()
			continue	
		if IGNORE_TITLE in rule['feature']:
			for field in fields:
				if field not in define.COLUMNS:
					record_error('XLS <%s> ��ͷ <%s> ���ڶ�����' % (fname, field))
					continue
			for field in set(define.COLUMNS) - set(fields):
				col, ctype, req, share = define.FIELDS[field]
				if req == REQUIRED:
					record_error('XLS <%s> ��ѡ��ͷ <%s> �������' % (fname, field))
					continue
			if has_error():
				write_error()
				continue
		else:
			if len(fields) != len(define.COLUMNS):
				record_error('XLS <%s> ��ͷ���� <%d> �붨������ <%d> ��ƥ��' % (fname, len(fields), len(define.COLUMNS)))
			else:
				for i, (field, col) in enumerate(zip(fields, define.COLUMNS)):
					col = col.decode(ORIGIN_ENCODING).encode(FINAL_ENCODING)
					if field != col:
						record_error('XLS <%s> ��ͷ <%d> �� <%s> �붨�� <%s> ��ƥ��' % (fname, i, field, col))
						break
			if has_error():
				write_error()
				continue
		holder_errstack()
		#������
		ignore = getattr(rule['define'], 'IGNORE', ())
		ignore_row = []
		ignore_col = []
		for i in xrange(1,reader.nrows):
			row = [unicode(v.value).encode('gbk') for v in reader.row(i)]
			tail_errstack('��' + str(i))
			if CHECK_BLINE not in rule['feature']:
				if not row:
					continue
				elif not ''.join(row):
					continue
			if len(row) != len(fields):
				record_error('XLS <%s> %d�б������ͷ <%s> ����ƥ�䡣������:%d ��ͷ����:%d' % (fname, i + 1, '��'.join(fields), len(row), len(fields)))
				continue
			#����������
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
							ignore_col.append('\t\tXLS <%s> %d�� <%s> �������� <%s> ������' % (fname, i + 1, head, col))
							break
						else:
							record_error('XLS <%s> %d�� <%s> ������ <%s> >' % (fname, i + 1, head, col) + msg)
							continue
					for ind, ids in ctype.get_idvalue(rst).iteritems():
						index.setdefault(ind, [])
						for idv in ids:
							index[ind].append((fname, '%d�� <%s> ��' % (i + 1, head), idv))
				else:
					if req == REQUIRED:
						if field in ignore:
							ignore_col.append('\t\tXLS <%s> %d�� <%s> �������Ϊ�ձ�����' % (fname, i + 1, head))
							break
						else:
							record_error('XLS <%s> %d�б�����д <%s> ��' % (fname, i + 1, head))
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
				record_error('XLS <%s> %d��û��ID����' % (fname, i + 1))
				continue
			if len(idvalue) > 1:
				idvalue = tuple(idvalue)
			else:
				idvalue = idvalue[0]
			if idvalue in data:
				record_error('XLS <%s> %d��ID���� <%s> �ظ�' % (fname, i + 1, idvalue))
				continue
			#�ж���
			for gname, gset in groups.iteritems():
				if gset != define.GROUPS[gname]:
					record_error('XLS <%s> %d�� <%s> �����ݱ���ͬʱ��д' % (fname, i + 1, gname))
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
	#����index����
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
		record_error('XML <%s> ��ǩ <%s> ���� <%s> ���������ڶ�����' % (fname, tname, '��'.join(extra)))
		return None
	#��������
	data = {}
	groups = {}
	for attr, (field, atype, req, share) in attrs.iteritems():
		value = unicode_to_gbk(element.get(gbk_to_unicode(attr), '')).strip().replace('\n', '')
		if req == COMMENT:
			continue
		if value:
			rst, msg = atype.export_value(value)
			if rst == None:
				record_error('XML <%s> ��ǩ <%s> ���� <%s> >' % (fname, tname, attr) + msg)
				continue
			for ind, ids in atype.get_idvalue(rst).iteritems():
				index.setdefault(ind, [])
				for idv in ids:
					index[ind].append((fname, '��ǩ <%s> ���� <%s> ' % (tname, attr), idv))
		else:
			if req == REQUIRED:
				record_error('XML <%s> ��ǩ <%s> ���� <%s> ������д' % (fname, tname, attr))
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
	#�ж���
	for gname, gset in groups.iteritems():
		if gset != define.GROUPS[etag][gname]:
			record_error('XML <%s> ��ǩ <%s> �� <%s> �����ݱ���ͬʱ��д' % (fname, tname, gname))
			continue
	if has_error():
		return None
	#�����ӱ�ǩ
	ctags = set()
	for child in list(element):
		ctag = unicode_to_gbk(child.tag)
		ctags.add(ctag)
		childname = tname + '.' + ctag
		if ctag not in children:
			record_error('XML <%s> ��ǩ <%s> ���������ӱ�ǩ <%s> ' % (fname, tname, childname))
			continue
		if ctag not in define.DEFINE:
			record_error('XML <%s> ��ǩ <%s> ���ӱ�ǩ <%s> ���������ڶ�����' % (fname, tnmae, childname))
			continue
		push_errstack('��ǩ' + ctag)
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
				record_error('XML <%s> ��ǩ <%s> ���ӱ�ǩ <%s> Key <%s> �ظ�' % (fname, tname, childname, idvalue))
				continue
			data[cname][idvalue] = meta
		elif cetype == ARRAY:
			data.setdefault(cname, [])
			data[cname].append(meta)
		else:
			if cname in data:
				record_error('XML <%s> ��ǩ <%s> ���ӱ�ǩ <%s> ����Ϊ��һ��ǩ' % (fname, tname, childname))
				continue
			data[cname] = meta
	#�ӱ�ǩ����������
	extra = set(children) - ctags
	if extra:
		record_error('XML <%s> ��ǩ <%s> ���ӱ�ǩ <%s> ������д' % (fname, tname, '��'.join(extra)))
	if has_error():
		return None
	return data

def proc_parse_xml(rule, index):
	define = rule['define']
	data = {}
	holder_errstack()
	for fname in rule['files']:
		tail_errstack('�ļ�' + fname)
		write_proc('��ʼ���� <%s> ' % fname, tabs = 1)
		try:
			f = open(fname)
		except Exception, e:
			record_error('���ļ� <%s> ����>' % fname + str(e))
			write_error()
			continue
		content = f.read()
		f.close()
		try:
			root = xml.etree.ElementTree.fromstring(gbk_to_utf8(content))
		except Exception, e:
			record_error('�����ļ� <%s> ����>' % fname + str(e))
			write_error()
			continue
		#����root
		childtag = define.DEFINE['root']
		for child in list(root):
			childname = unicode_to_gbk(root.tag) + '.' + childtag
			if unicode_to_gbk(child.tag) != childtag:
				record_error('XML <%s> root���������ӱ�ǩ <%s> ' % (fname, childname))
				continue
			push_errstack('��ǩ' + childtag)
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
				record_error('XML <%s> root���ӱ�ǩ <%s> Key <%s> �ظ�' % (fname, childname, idvalue))
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
	#����index����
	if rule['index']:
		EXPORTER_INDEX[rule['index']]['set'] = set(data.keys())
	return data

def proc_check_feature(conf, rule, name, old, new):
	for feature in rule['feature']:
		if feature == DENY_DEL:
			keys = set(old.keys()) - set(new.keys())
			if keys:
				record_error(' <%s> ������ɾ�������� <%s> ������ <%s> ' % (conf, name, keys.join('��')))
		elif feature == DENY_ADD:
			keys = set(new.keys()) - set(old.keys())
			if keys:
				record_error(' <%s> ���������������� <%s> ������ <%s> ' % (conf, name, keys.join('��')))

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
	write_proc('���ںϲ� <%s> ' % name, tabs = 2)
	if rule['share'] != SPLIT:
		record_error('�ϲ������� <%s> ����' % name)
		write_error()
		return None
	if not proc_merge_dict(server, client):
		record_error('�ϲ������� <%s> ����' % name)
		write_error()
		return None
	write_ok()
	return server

def proc_split_dict(fields, data, server, client, isdict = None, islist = None):
	for k, v in data.iteritems():
		#δ֪��������ΪCOMMON
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
	write_proc('���ڷֲ� <%s> ' % name, tabs = 2)
	if rule['share'] != SPLIT:
		record_error('�ֲ������� <%s> ����' % name)
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
			record_error('�ֲ������� <%s> ����' % name)
			write_error()
			return None
	write_ok()
	return server, client

def proc_load_file(fname):
	write_proc('���ڵ��� <%s> ' % fname, tabs = 2)
	if not os.path.exists(fname):
		write_ok()
		return {}
	if not os.path.isfile(fname):
		record_error('��Ӧ������ <%s> ����һ���ļ�' % fname)
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
		print_info('\t\t��������� <%s> �����������' % fname)
	return data

def proc_load_data(rule):
	holder_errstack()
	if EXP_FILE in rule['feature']:
		ext = '.py.exp'
	else:
		ext = '.py'
	for name in rule['exporter'].iterkeys():
		tail_errstack('������' + name)
		EXPORTER_OLDDATA[name] = {}
		holder_errstack()
		server = os.path.join(PYTHON_PATH, name + ext)
		client = os.path.join(PYTHON_PATH, name + ext)
		if rule['share'] == COMMON:
			tail_errstack('�ļ�' + server)
			data = proc_load_file(server)
		elif rule['share'] == SERVER:
			tail_errstack('�ļ�' + server)
			data = proc_load_file(server)
		elif rule['share'] == CLIENT:
			tail_errstack('�ļ�' + client)
			data = proc_load_file(client)
		else:
			tail_errstack('�ļ�' + server)
			sdata = proc_load_file(server)
			tail_errstack('�ļ�' + client)
			cdata = proc_load_file(client)
			tail_errstack('�ϲ�' + name)
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
	write_proc('���ڵ��� <%s> ' % fname, tabs = 2)
	try:
		f = open(fname, 'w')
	except Exception, e:
		record_error('��PYTHON�ļ� <%s> ����>' % fname + str(e))
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
		record_error('����PYTHON���� <%s> ����>' % fname + str(e))
		write_error()
		return False
	f.close()
	write_ok()
	return True

def proc_dump_lua(module_name, fname, data):
	write_proc('���ڵ��� <%s> ' % fname, tabs = 2)
	try:
		f = open(fname, 'w')
	except Exception, e:
		record_error('��LUA�ļ� <%s> ����>' % fname + str(e))
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
		record_error('����LUA���� <%s> ����>' % fname + str(e))
		write_error()
		return False
	f.close()
	write_ok()
	return True

def proc_dump_json(fname, data):
	write_proc('���ڵ��� <%s> ' % fname, tabs = 2)
	try:
		f = open(fname, 'w')
	except Exception, e:
		record_error('��JSON�ļ� <%s> ����>' % fname + str(e))
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
		record_error('����JSON���� <%s> ����>' % fname + str(e))
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
		tail_errstack('������' + name)
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
			tail_errstack('�ļ�' + name)
			proc_dump_python(py_client_out, data)
			proc_dump_lua(name, lua_client_out, data)
			#proc_dump_json(json_client_out, data)

			proc_dump_python(py_server_out, data)
			proc_dump_lua(name, lua_server_out, data)
			#proc_dump_json(json_server_out, data)
		elif rule['share'] == SERVER:
			tail_errstack('�ļ�' + name)
			proc_dump_python(py_server_out, data)
			proc_dump_lua(name, lua_server_out, data)
			#proc_dump_json(json_server_out, data)
		elif rule['share'] == CLIENT:
			tail_errstack('�ļ�' + name)
			proc_dump_python(py_client_out, data)
			proc_dump_lua(name, lua_client_out, data)
			#proc_dump_json(json_client_out, data)
		elif split_data != None:
			tail_errstack('�ֲ�' + name)
			split_data = proc_split_data(rule, name, data)

			sdata, cdata = split_data
			tail_errstack('�ļ�' + name)
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
	#����XLS/XML��ԭʼ�����ļ����������Ӧ������
	push_errstack('ԭʼ���ݽ���')
	print_info('\n��ʼ����XML/XLS�ļ�\n')
	index = {}
	holder_errstack()
	for conf in files:
		tail_errstack('�ļ�' + conf)
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

	tail_errstack('ID�������')
	write_proc('���ڼ������ID����')
	for iname, infos in index.iteritems():
		iconf = EXPORTER_INDEX[iname]['conf']
		iset = EXPORTER_INDEX[iname]['set']
		for fname, pos, value in infos:
			if value not in iset:
				record_error(' <%s> �ļ�%s��ID <%s> ���� <%s> ������ <%s> ��' % (fname, pos, iname, value, iconf))
	assert_error()
	write_ok()

	#���뵼�����ⲿ����
	flag_init(flags)

	#������˳����ж�ԭʼ���ݽ��е�����
	tail_errstack('���������ݽ���')
	print_info('\n��ʼ���XLS/XML�ļ�\n')
	holder_errstack()
	for conf in EXPORTER_QUEUE:
		if conf not in files:
			continue
		print_info('��ʼ��� <%s> ' % conf.decode(ORIGIN_ENCODING).encode(FINAL_ENCODING), tabs = 1)
		rule = RULES[conf]
		dpd = []
		for d in rule['depend']:
			dpd.append(mod_name(RULES[d]['define']))
		for name, func in rule['exporter'].iteritems():
			tail_errstack('������' + name)
			write_proc('���ڼ�� <%s> ' % name, tabs = 2)
			new = func(EXPORTER_OLDDATA[name], EXPORTER_RAWDATA[mod_name(rule['define'])], (dpd, EXPORTER_NEWDATA), EXPORTER_RAWDATA)
			if new == None:
				record_error(' <%s> �ĵ������� <%s> ���������з��ִ���' % (conf, name))
			elif type(new) != dict:
				record_error(' <%s> �ĵ������� <%s> ����ֵ���ܰ���һ��' % (conf, name))
			assert_error()
			proc_check_feature(conf, rule, name, EXPORTER_OLDDATA[name], new)
			assert_error()
			EXPORTER_NEWDATA[name] = new
			write_ok()
		print_info('')
	pop_errstack(2)

def cmd_export(files, path, flags):
	cmd_check(files, path, flags)

	#�����Ϻ󵼳�
	push_errstack('�������ݵ���')
	print_info('\n��ʼ�����ļ�\n')
	holder_errstack()
	for conf in files:
		print_info('��ʼ���� <%s> ' % conf.decode(ORIGIN_ENCODING).encode(FINAL_ENCODING), tabs = 1)
		rule = RULES[conf]
		if not proc_dump_data(rule):
			continue
		print_info('')
	pop_errstack()
	assert_error()

def gen_parser():
	parser = argparse.ArgumentParser(description = '�����ߣ���XLS/XML�����ļ�����ΪPYTHON/LUA/JSON�ļ�')
	cmd = parser.add_subparsers(title = '�����߿��ṩ�Ĺ���')

	common = argparse.ArgumentParser(add_help = False)
	common.add_argument('-f', '--file', dest = 'file', metavar = 'FILE',
		help = 'ָ������XLSX/XML�����ļ�������� <%s> Ŀ¼��·����Ĭ��Ϊ <%s> Ŀ¼�������ļ�' % (CONF_PATH, CONF_PATH))
	common.add_argument('-p', '--path', dest = 'path', metavar = 'PATH',
		help = 'ָ��XLSX/XML�����ļ�������ڵ�ǰĿ¼��·�����߾���·����Ĭ��ΪԤ������Ŀ¼ <%s>' % DATA_PATH)
	common.add_argument('-o', '--output', dest = 'output', metavar = 'OUTPUT',
		help = 'PYTHON/LUA/JSON�ļ�����Ŀ¼������ڵ�ǰĿ¼��·�����߾���·����Ĭ��ΪԤ������Ŀ¼ <%s>' % OUTPUT_PATH)
	common.add_argument('-l', '--flags', dest = 'flags', metavar = 'FLAGS',
		help = '���������Ӳ���')

	check = cmd.add_parser('check', parents = [common], help = '���XLS/XML�����ļ�������ʵ�ʵ���PYTHON/LUA�ļ�')
	check.set_defaults(handler = cmd_check)

	export = cmd.add_parser('export', parents = [common], help = '���XLS/XML�����ļ���������ΪPYTHON/LUA�ļ���Ŀ¼')
	export.set_defaults(handler = cmd_export)

	return parser

def main():
	parser = gen_parser()
	args = parser.parse_args()

	write_proc('��鵼������')
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
