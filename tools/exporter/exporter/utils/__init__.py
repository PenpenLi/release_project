# -*- coding: UTF-8 -*-

import sys
import crontab_pro
import time

_RECORD_ERRORS = {}
_RECORD_STACK = ''
_RECORD_HOLDER = '__HOLDER__'

_EXPORT_FLAGS = ''

def push_errstack(desc):
	global _RECORD_STACK
	if _RECORD_STACK:
		_RECORD_STACK += '>>' + desc
	else:
		_RECORD_STACK = desc

def pop_errstack(pops = 1):
	global _RECORD_STACK
	_RECORD_STACK = '>>'.join(_RECORD_STACK.split('>>')[:-pops])

def tail_errstack(desc):
	pop_errstack(len(desc.split('>>')))
	push_errstack(desc)

def holder_errstack(holders = 1):
	for i in xrange(holders):
		push_errstack(_RECORD_HOLDER)

def merge_errstack():
	keys = _RECORD_STACK.split('>>')
	pkey = '>>'.join(keys[:-1])
	ckey = keys[-1]
	parent = get_value_by_link(_RECORD_ERRORS, pkey, '>>')
	if parent == None or ckey not in parent:
		return
	parent[ckey] = {'': allsub_error(parent[ckey])}

def has_error(flag = None):
	if flag == None:
		flag = _RECORD_STACK
	if flag:
		return get_value_by_link(_RECORD_ERRORS, flag, '>>')
	else:
		return _RECORD_ERRORS

def record_error(msg):
	if not _RECORD_STACK:
		return
	if _RECORD_STACK.split('>>')[-1] == _RECORD_HOLDER:
		return
	record = get_value_by_link(_RECORD_ERRORS, _RECORD_STACK, '>>')
	if record == None:
		record = set_value_by_link(_RECORD_ERRORS, _RECORD_STACK, {'': []}, '>>')
	record[''].append(msg)

def allsub_error(info):
	all = []
	for k, v in info.iteritems():
		if not k:
			all += v
		else:
			all += allsub_error(v)
	return all

def print_error(info, desc):
	for mdesc, minfo in info.iteritems():
		if not mdesc:
			print '\n' + desc
			for err in minfo[:10]:
				print '\t' + err
			if minfo[30:]:
				print '\t...还有%d条错误未显示' % (len(minfo) - 10)
		else:
			if not desc:
				print_error(minfo, mdesc)
			else:
				print_error(minfo, desc + ' > ' + mdesc)

def assert_error():
	if not has_error(''):
		return
	print '\n\n导表过程中发生错误'
	print_error(_RECORD_ERRORS, '')
	sys.exit(1)

def print_info(msg, tabs = 0):
	print '\t' * tabs + msg

def write_info(msg, tabs = 0, ln = False):
	if ln:
		ln = '\n'
	else:
		ln = ''
	sys.stdout.write('\t' * tabs + msg + ln)
	sys.stdout.flush()

def write_proc(msg, tabs = 0):
	write_info(msg + '...', tabs)

def write_ok():
	write_info('OK', ln = True)

def write_error():
	write_info('ERROR', ln = True)

def mod_name(m):
	return m.__name__.split('.')[-1]

def utf8_to_gbk(s):
	return s.decode('utf8').encode('gbk')

def gbk_to_utf8(s):
	return s.decode('gbk').encode('utf8')

def unicode_to_gbk(s):
	return s.encode('gbk')

def gbk_to_unicode(s):
	return s.decode('gbk')

def get_value_by_link(d, link, split = '.'):
	keys = link.split(split)
	ld = d
	for key in keys[:-1]:
		ld = ld.get(key, {})
	return ld.get(keys[-1])

def set_value_by_link(d, link, v, split = '.'):
	keys = link.split(split)
	ld = d
	for key in keys[:-1]:
		ld.setdefault(key, {})
		ld = ld[key]
	ld[keys[-1]] = v
	return v

# key : 调用本方法上层表对应配置行的 id, 用于报错提示
# name_dict : 需要转化的 属性名-值 对应表
# attr_conf : 属性配置表
def attributes_name_to_id_dict(key, name_dict, attr_conf):
	id_dict = {}
	for name, value in name_dict.iteritems():
		if not attr_conf.has_key(name):
			record_error('不支持的属性类型:%s。id: %d' % (name, key,))
			continue

		id_dict[attr_conf[name]['id']] = value
	return id_dict

def flag_init(flags):
	global _EXPORT_FLAGS
	_EXPORT_FLAGS = flags.split(',')

def flag_exist(flag):
	return flag in _EXPORT_FLAGS

def is_valid_crontab(crontab_desc):
	try:
		ce = crontab_pro.CronTab(crontab_desc)
		ce.next(time.time())
	except:
		return False
	return True

