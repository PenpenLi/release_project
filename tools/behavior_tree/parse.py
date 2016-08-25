#!/usr/local/bin/python2.7
# -*- coding: UTF-8 -*-

import xmind
import tree_list
import node_type
import codecs

XMIND_PATH = '../../conf/'
OUTPUT_PATH = '../../src/client/src/behavior/'

def parse_tree(topic, dep):
	elements = []
	for i in topic.getMarkers():
		name = i.getMarkerId().name
		if node_type.TYPE.has_key(name):
			elements.append('type=%s' % node_type.TYPE[name])
		elif node_type.DECORATOR.has_key(name):
			elements.append('dec=%s' % node_type.DECORATOR[name])
			
	elements.append('title=\'%s\''%(topic.getTitle()) )
	content = topic.getNotes()
	if content != None:
		elements.append(content.getContent())
	if topic.getSubTopics() == None:
		return ','.join(elements)
	childs = []
	for sub in topic.getSubTopics():
		childs.append('\t'*dep+'{%s}'%parse_tree(sub, dep+1))
	elements.append('childs={\n%s\n%s}'%(',\n'.join(childs),'\t'*dep) )
	return ','.join(elements)

def dump_tree(filename, ainame):
	try:
		workbook = xmind.load(XMIND_PATH+filename+'.xmind')
		root = workbook.getSheets()[0].getRootTopic()
	except Exception, e:
		print('xmind <%s>', filename)
		return False
	if root.getSubTopics() == None:
		print '缺少xmind文件: %s'% filename
		return False
	try:
		f = codecs.open(OUTPUT_PATH+ainame+'.lua','w','utf-8')
		#f = open(OUTPUT_PATH+ainame+'.lua', 'w')
	except Exception, e:
		print('lua <%s>', ainame)
		return False
		
	lines = []
	f.write('tree = {')
	for sub in root.getSubTopics():
		lines.append(parse_tree(sub, 1))
	f.write(',\n'.join(lines))
	f.write('\n}')
	f.close()

def main():
	for file, ai in tree_list.LIST.iteritems():
		print '正在导出AI: %s'% file
		if dump_tree(file, ai) == False:
			print '出错啦！！！！！'
			return
	print '导出完成'
	

if __name__ == '__main__':
	try:
		import psyco
		psyco.full()
	except:
		pass
	main()