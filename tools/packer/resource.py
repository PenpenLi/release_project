# -*- coding: UTF-8 -*-

import os,sys

src_dir = '../../src/client/res/'

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

def list_file(srcdir):
    flist = os.listdir(srcdir)
    for item in flist:
        filepath = os.path.join(srcdir, item)
        #print filepath, os.path.isdir(filepath)
        
        if os.path.isdir(filepath):
            list_file(filepath)
        elif os.path.isfile(filepath):
            fileinfo = os.path.splitext(filepath)
            file_name = fileinfo[0] # with relative path
            name_suffix = fileinfo[1]
            if name_suffix == '.png':
				cmd = 'pngquant 256 "%s" --force --speed 1 --output "%s"' % (filepath, filepath)
				print(cmd)
				os.system(cmd)




# os.system('dir %s' % (src_dir) )
list_file(src_dir + 'gui')
list_file(src_dir + 'skeleton')
