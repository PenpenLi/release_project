# -*- coding: GBK -*-

import sys
import os
from exporter_def import *
EXPORTER_PATH = './exporters/'
sys.path.append(EXPORTER_PATH)

Type_To_C = {Int:'int',Bool:'bool',Float:'float',String:'std::string',UInt:'u32'}
Type_To_JSON = {Int:'.asInt()',Bool:'.asBool()',Float:'.asFloat()',String:'.asString()',UInt:'.asUInt()'}
key_no = 1
type_no = 2
def adjust_class_name(class_name):
	class_name_array = class_name.split('_')
	adjust_name = ''
	for name in class_name_array:
		adjust_name += name.capitalize() + ('_')
	return adjust_name[:-1]

class auto_config_gen:
	def __init__(self,filename,key_type):
		config_module = __import__(filename)
		if config_module.TYPE != CSV:
			print 'Only for Csv!'
			return
		if os.path.isdir('./auto_code')==False:
			os.mkdir('./auto_code')
		output_cpp_file = open('./auto_code/' + filename+"_config.cpp",'w')
		output_h_file = open('./auto_code/' + filename+"_config.h",'w')
		class_name = adjust_class_name(filename + '_config')
		print class_name
		output_h_file.write('#pragma once')
		output_h_file.write('\n')
		output_h_file.write('class' +' ' +class_name)
		output_h_file.write('\n{')
		output_h_file.write('\npublic:')

		output_cpp_file.write('#include"' + filename+ '_config.h"')
		output_cpp_file.write('\n')
		output_cpp_file.write('#include "data_manager.h"')
		output_cpp_file.write('\n')
		for  one_member in config_module.DEFINE:
			define_type = one_member[type_no]
			if define_type in Type_To_C:
				return_type = Type_To_C[define_type]
				json_type = Type_To_JSON[define_type]
			else:
				return_type = 'const Json::Value&'
				json_type = ''
			member_name = one_member[key_no]
			function_name = 'get_' + member_name + '(' +key_type +' key' ')'
			##.h 
			output_h_file.write('\n\tstatic '+return_type + ' ' + function_name+ ';')
            ##.cpp
			output_cpp_file.write('\n' + return_type +' ' + class_name +'::' + function_name)
			output_cpp_file.write('\n' + '{')
			output_cpp_file.write('\n\t' + 'return g_data_manager->get_data_value("'+filename+'"'+ ',key)'\
                                              + '["' + member_name+'"]' + json_type +';')
			output_cpp_file.write('\n' + '}')
			
			
			
		output_h_file.write('\n}')
		print "process success"
                        
if __name__=="__main__":
	config_name = sys.argv[1]
	if len(sys.argv)>2:
		key_type = sys.argv[2]
	else:
		key_type = 'int'
	auto_config_gen(config_name,key_type)

