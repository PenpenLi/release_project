# -*- coding: UTF-8 -*-

CONFIG = {
        "working_dir"   : "../../src/client/res/skeleton/",
        "file_sufix"    : ".ExportJson"
}

# 配置不处理
BLACKLIST = (
        #(    'Stand', '特效2' ), # “Stand”动画下的“特效2”不作处理
        #(    'Run', '特效2' ) 
)

# 配置处理
WHITELIST = (
        (    'Stand', '特效2' ), # “Stand”动画下的“特效2”作处理，但由于BLACKLIST有同样的配置，优先级更高，所以这个配置不起作用
        (    'Run', '特效2' ),
        (    'Attack1', '特效2' ),
        (    'AttackSkill1', '特效1' ),
        (    'AttackSkill1', '特效2' ),
        (    'AttackSkill2', '特效1' ),
        (    'AttackSkill2', '特效2' ),
        (    'Stand', '图层 1' ), 
        (    'Stand', '图层 2' ), 
        (    'Stand', '图层 3' ), 
        (    'Stand', '图层 4' ), 
        (    'Stand', '图层 5' ), 
        (    'Stand', '图层 6' ), 
        (    'Stand', '图层 7' ), 
        (    'Stand', '图层 8' ), 
        (    'Stand', '图层 9' ), 
        (    'Stand', '图层 10' ), 
        (    'Stand', '图层 11' ), 
        (    'Stand', '图层 12' ) 
)
