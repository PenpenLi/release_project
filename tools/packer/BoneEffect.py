# -*- coding: UTF-8 -*-

import json
import shutil
import BoneConfig
import os

def ChangeEffect(json_obj):
    mov_datas = json_obj["animation_data"][0]["mov_data"]
    for mov in mov_datas:
        print(u"    动画名:" + mov["name"])
        bone_datas = mov["mov_bone_data"]
        for bone in bone_datas:
            flag = True
            for blist in BoneConfig.BLACKLIST:
                if blist[0].decode('gbk') == mov["name"] and blist[1].decode('gbk') == bone["name"]:
                    print(u"        x 不处理:")
                    print( "        " + blist[1])
                    flag = False
                    break

            if flag == True:
                for wlist in BoneConfig.WHITELIST:
                    if wlist[0].decode('gbk') == mov["name"] and wlist[1].decode('gbk') == bone["name"]:
                        print(u"        v 处理:")
                        print( "        " + wlist[1])
                        for fr in bone["frame_data"]:
                            fr["bd_src"] = 770
                            fr["bd_dst"] = 1
                        break



def HandleAJsonFile(file_name):
    fi = open(file_name, "r")
    jsn = json.load(fi)
    ChangeEffect(jsn)

    jsn_str = json.dumps(jsn, indent=1, ensure_ascii=False).encode('utf-8')
    fi.close()
    fo = open(file_name, "w")
    fo.write(jsn_str)
    fo.close()


# HandleAJsonFile("Guai01.ExportJson")
dirs = os.listdir(BoneConfig.CONFIG["working_dir"])
for chardir in dirs:
    print("\n\n===============================")
    print(u"文件位置: " + BoneConfig.CONFIG["working_dir"] + chardir)
    files = os.listdir(BoneConfig.CONFIG["working_dir"] + chardir)
    for jsonfile in files:
        if os.path.splitext(jsonfile)[1] == BoneConfig.CONFIG["file_sufix"]:
            hdlfile = (BoneConfig.CONFIG["working_dir"] + chardir + "/" + jsonfile)
            HandleAJsonFile(hdlfile)

