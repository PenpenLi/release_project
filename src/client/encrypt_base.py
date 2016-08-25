# -*- coding: UTF-8 -*-

import os,sys
import hashlib
import zipfile
import json
import urllib


IS_RELEASE = True
dst_dir = 'base_encrypt/'

suffix_list = set(['.lua',
                    '.tmx',
                    '.png', 
                    '.plist', 
                    '.ExportJson', 
                    '.wav', 
                    '.mp3', 
                    '.ttf', 
                    '.fnt', 
                    '.frag', 
                    '.vert', 
                    '.ccz', 
                    '.json'])

sound_suffix = set(['.wav',
                    '.mp3',])

pic_suffix = set(['.png', '.ccz'])
                    
text_suffix = set(['.tmx',
                    '.ExportJson', 
                    '.fnt', 
                    '.frag', 
                    '.vert', 
                    '.json',
                    '.plist',])

source_suffix = set(['.lua',])

font_suffix = set(['.ttf',])

def inc_version(version):
	versions = version.split('.')
	versions[-1] = str(int(versions[-1])+1)
	return '.'.join(versions)

def change_encoding(name):
	#return name.decode('gbk').encode('utf8')
	#return name.decode('utf8').encode('utf8')
	if name != urllib.quote(name):
		print 'ERROR path', name, urllib.quote(name)
	return urllib.quote(name).decode('utf8')

def make_dir(filepath):
	path = os.path.dirname(filepath)
	if not os.path.exists(path):
		os.makedirs(path)

def get_md5(filepath):
	m = hashlib.md5()
	f = open(filepath, 'rb')
	m.update(f.read())
	f.close()
	return m.hexdigest()

def make_zip(src_path, dst_path):
	filename = src_path.split('/')[-1]
	z = zipfile.ZipFile(dst_path+ '.zip', 'w') 
	#print 'zip...', filepath, filename
	z.write(src_path, filename, zipfile.ZIP_DEFLATED)
	z.close()

def raw_copy(src_path, dst_path):
	open(dst_path, "wb").write(open(src_path, "rb").read())

def encrypt(src_path, dst_path):
	key = '7ES0ZS123F4QE5NA'
	cmd = './encrypt "%s" "%s" "%s"' % (key, src_path, dst_path)
	#print cmd
	#os.popen(cmd)
	os.system(cmd)

def compress_png(src_path, dst_path):
	cmd = 'pngquant 256 "%s" --force --speed 1 --output "%s"' % (src_path, dst_path)
	#print cmd
	#os.popen(cmd)
	os.system(cmd)

def list_file(srcdir):
	new_version = False
	flist = os.listdir(srcdir)
	for item in flist:
		filepath = os.path.join(srcdir, item)
		if os.path.isdir(filepath):
			list_file(filepath)
		elif os.path.isfile(filepath):
			fileinfo = os.path.splitext(filepath)
			filename = filepath.split('/')[-1]
			name_suffix = fileinfo[1]
			#make_dir(dst_dir + filepath)

			if name_suffix in suffix_list:
				file_key = change_encoding(filepath)
				
				print 'A... ', file_key
				
				#png - 压缩且加密
				if name_suffix == '.png':
					compress_png(filepath, filepath)
					encrypt(filepath, filepath)
				#ccz
				elif name_suffix == '.ccz':
					pass
				#文本 - 压缩不加密
				elif name_suffix in text_suffix:
					pass
				#代码 - 加密不压缩
				elif name_suffix in source_suffix:
					encrypt(filepath, filepath)
				#声音
				elif name_suffix in sound_suffix:
					pass
				#字体
				elif name_suffix in font_suffix:
					pass
				else:
					print 'other file...', filepath	
	return

def make_data_zip(srcdir, pack_zip):
	flist = os.listdir(srcdir)
	for item in flist:
		filepath = os.path.join(srcdir, item)
		if os.path.isdir(filepath):
			make_data_zip(filepath, pack_zip)
		elif os.path.isfile(filepath):
			fileinfo = os.path.splitext(filepath)
			name_suffix = fileinfo[1]
			if name_suffix in suffix_list:
				#代码及png 将加密后内容加入 data.zip中
				if name_suffix == '.png' or name_suffix in source_suffix:
					pack_zip.write(dst_dir + filepath, filepath, zipfile.ZIP_DEFLATED)
				#其他文件 将源文件加入 data.zip中
				else:
					pack_zip.write(filepath, filepath, zipfile.ZIP_DEFLATED)
					

def load_json(filepath):
	f = open(filepath, "rb")
	info = json.loads(f.read())
	f.close()
	return info

def delete_empty_dir(dstdir):
	flist = os.listdir(dstdir)
	for filename in flist:
		filepath = os.path.join(dstdir, filename)
		if os.path.isdir(filepath) and filename[0] != '.':
			if len(os.listdir(filepath)) == 0:
				print 'Ddir ', filepath, os.listdir(filepath)
				os.removedirs(filepath)
			else:
				delete_empty_dir(filepath)

def check_delete(assets, old_assets):
	delete = False
	for key, value in old_assets.iteritems():
		if not assets.has_key(key):
			print 'D... ', key, value['md5']
			try:
				os.remove(dst_dir + key.encode('utf8'))
			except:
				pass
			delete = True
	
	return delete


def main():
	list_file('base')
	list_file('../cocos/frameworks/cocos2d-x/cocos/scripting/lua-bindings/script/')



if __name__ == '__main__':
	main()
