# -*- coding: UTF-8 -*-

import os,sys
import shutil
import zipfile
import re

valid_path_pattern = re.compile(r'^[-\w\\\./]+$')

def copy_files(srcdir, dstdir):
    flist = os.listdir(srcdir)
    for item in flist:
        new_src = os.path.join(srcdir, item)
        new_dst = os.path.join(dstdir, item)
        if os.path.isdir(new_src):
            copy_files(new_src, new_dst)
        elif os.path.isfile(new_src):
            # if os.path.exists(new_dst) == True:
                # print('  File exists:' + new_dst)
            if valid_path_pattern.match(new_src) == None:
                print('[WARNING]! Invalid path: ' + new_src)
            else:
                if os.path.isdir(dstdir) != True:
                    # print('[SYS] Create dir:] ' + dstdir)
                    os.makedirs(dstdir)
                shutil.copy(new_src,  new_dst)

def pack_config( mode ):
    proj_path = 'cocos/frameworks/runtime-src/proj.android/'
    base_path = 'cocos/base/'
    if mode == 'debug':
        # 调试版
        if os.path.exists( proj_path + 'build-cfg_debug.json' ) == True:
            shutil.copyfile(proj_path + 'build-cfg_debug.json', proj_path + 'build-cfg.json')
        if os.path.exists( 'pack_config_debug.lua' ) == True:
            shutil.copyfile('pack_config_debug.lua', base_path + 'pack_config.lua')
        if os.path.exists( base_path + 'data.zip') == True:
            os.remove( base_path + 'data.zip' )
    elif mode == 'release':
        if os.path.exists( proj_path + 'build-cfg_release.json' ) == True:
            shutil.copyfile(proj_path + 'build-cfg_release.json', proj_path + 'build-cfg.json')
        if os.path.exists( 'pack_config_release.lua' ) == True:
            shutil.copyfile('pack_config_release.lua', base_path + 'pack_config.lua')

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'debug':
        copy_files('client/base', 'cocos/base')
        copy_files('client/res', 'cocos/res')
        copy_files('client/src', 'cocos/src')
        pack_config( 'debug' )
        os.chdir('cocos')
        os.system('cocos compile -p android -j 4')
    else:
        copy_files('client/base', 'cocos/base')
        pack_config( 'release' )
        os.chdir('cocos')
        # sign... os.system('cocos compile -p android -j 4 -m release')
        os.system('cocos compile -p android -j 4')

