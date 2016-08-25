# -*- coding: UTF-8 -*-

import os,sys
import hashlib
import zipfile
import json
import urllib

#src_dir = ''
dst_dir = './content/'

IS_RELEASE = True

develop= {
	"packageUrl": "http://192.168.16.105:8888/content/",
	"remoteManifestUrl": "http://192.168.16.105:8888/manifest",
	"remoteVersionUrl": "http://192.168.16.105:8888/version",
}

release= {
	"packageUrl": "http://203.195.170.106:8888/content/",
	"remoteManifestUrl": "http://203.195.170.106:8888/manifest",
	"remoteVersionUrl": "http://203.195.170.106:8888/version",
}

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

def list_file(srcdir, assets, old_assets):
	new_version = False
	flist = os.listdir(srcdir)
	for item in flist:
		filepath = os.path.join(srcdir, item)
		if os.path.isdir(filepath):
			new_version = list_file(filepath, assets, old_assets) or new_version
		elif os.path.isfile(filepath):
			fileinfo = os.path.splitext(filepath)
			filename = filepath.split('/')[-1]
			name_suffix = fileinfo[1]
			if name_suffix in suffix_list:
				file_md5 = get_md5(filepath)
				file_key = change_encoding(filepath)
				
				#修改压缩文件后缀
				if name_suffix in text_suffix:
					file_key = file_key + '.zip'

				#没变跳过
				if old_assets.has_key(file_key) and old_assets[file_key]['md5'] == file_md5:
					assets[file_key] = old_assets[file_key]
					continue
				
				if old_assets.has_key(file_key):
					print 'M... ', file_key, old_assets[file_key]['md5'], file_md5
				else:
					print 'A... ', file_key, file_md5
				
				new_version = True
				assets[file_key] = {'md5':'...'}
				make_dir(dst_dir + filepath)
				#png - 压缩且加密
				if name_suffix == '.png':
					compress_png(filepath, dst_dir+filepath)
					if IS_RELEASE:
						encrypt(dst_dir+filepath, dst_dir+filepath)
					#raw_copy(filepath, dst_dir+filepath)
					#encrypt(dst_dir+filepath, dst_dir+filepath)
				#ccz
				elif name_suffix == '.ccz':
					raw_copy(filepath, dst_dir+filepath)
				#文本 - 压缩不加密
				elif name_suffix in text_suffix:
					make_zip(filepath, dst_dir+filepath)
					assets[file_key]['compressed'] = True
				#代码 - 加密不压缩
				elif name_suffix in source_suffix:
					raw_copy(filepath, dst_dir+filepath)
					if IS_RELEASE:
						encrypt(dst_dir+filepath, dst_dir+filepath)
				#声音
				elif name_suffix in sound_suffix:
					raw_copy(filepath, dst_dir+filepath)
				#字体
				elif name_suffix in font_suffix:
					raw_copy(filepath, dst_dir+filepath)
				else:
					print 'other file...', filepath	
				assets[file_key]['md5'] = file_md5
	return new_version

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
	new_version = False
	json_info = load_json('project.manifest')

	print('parse content...')
	assets = {}
	new_version = list_file('res', assets, json_info['assets']) or new_version
	new_version = list_file('src', assets, json_info['assets']) or new_version
	new_version = check_delete(assets, json_info['assets']) or new_version
	delete_empty_dir('content')

	print('make manifest...')
	if new_version:
		json_info['assets'] = assets
		json_info['version'] = inc_version(json_info['version'])

	json_version = develop
	if IS_RELEASE:
		json_version = release
	for k, v in json_version.iteritems():
		json_info[k] = v

	manifest_file = open('project.manifest.'+json_info['version'], 'w')
	manifest_file.write(json.dumps(json_info,sort_keys=True,indent=4,ensure_ascii=False).encode('utf8'))
	manifest_file.close()

	json_info.pop('assets')
	json_info.pop('searchPaths')

	version_file = open('version.manifest.'+json_info['version'], 'w')
	version_file.write(json.dumps(json_info,sort_keys=True,indent=4,ensure_ascii=False).encode('utf8'))
	version_file.close()

	os.system('cp project.manifest.'+json_info['version'] + ' project.manifest')
	os.system('cp version.manifest.'+json_info['version'] + ' version.manifest')

	print('make data.zip...')
	pack_zip = zipfile.ZipFile('data.zip', 'w') 
	make_data_zip('res', pack_zip)
	make_data_zip('src', pack_zip)
	pack_zip.write('project.manifest', 'project.manifest', zipfile.ZIP_DEFLATED)
	pack_zip.write('version.manifest', 'version.manifest', zipfile.ZIP_DEFLATED)
	pack_zip.close()


if __name__ == '__main__':
	main()
