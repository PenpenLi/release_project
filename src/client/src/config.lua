require 'data/fuben'
require 'data/fuben_entrance'
require 'data/fuben_type_entrance'
require 'data/scene'
require 'data/monster'
require 'data/monster_model'
require 'data/monster_skill'
require 'data/weapon'
require 'data/helmet'
require 'data/armor'
require 'data/necklace'
require 'data/ring'
require 'data/shoe'
require 'data/skill'
require 'data/buff'
require 'data/equip'
require 'data/language'
require 'data/dialog'
require 'data/bubble_dia'
require 'data/offline'
require 'data/tutor'
require 'data/shuaguai'
require 'data/level'
require 'data/item'
require 'data/item_id'
require 'data/material'
require 'data/quest'
require 'data/quest_daily'
require 'data/soul_upgrade'
require 'data/soul_stone'
require 'data/soul_evolution'
require 'data/avatar_strengthen'
require 'data/material'
require 'data/equip_frag'
require 'data/equip_qh_stone'
require 'data/equipment_lv'
require 'data/equipment_strengthen'
require 'data/lottery'
require 'data/lottery2'
require 'data/equipment_activation'
require 'data/namelist'
require 'data/mall'
require 'data/vip'
require 'data/email'
require 'data/activities'
require 'data/notice'
require 'data/token_coin'
require 'data/skill_initstar'
require 'data/scenebuff'
require 'data/wing'

-- game relative utils
require 'data/sign_in'
require 'data/item'
require 'data/gem'
require 'data/exchange_mall' 
require 'data/boss_battle'
require 'data/soul'
require 'data/midas_touch'
require 'data/guide'
require 'data/soul_stone_map'
require 'data/guide_tips'
require 'data/diamond_gold'
require 'data/energy_purchase'
require 'data/illegal_word'
require 'data/rmb_cost'
require 'data/guide_state'
require 'data/button_control'
require 'data/sub_sys_switch'
require 'data/store_item'

-- ui
TextureTypePLIST		= 1
TextureTypeLOCAL		= 0


-- Zorder
ZUIGray		= -1000
ZLayer05	= 0
ZLayer04	= 1
ZLayer03	= 2
ZLayer02	= 3
ZMonsterBG	= 9
ZLayer01	= 10
ZBackGround	= 50
ZShadow		= 65
ZSceneObj	= 70
ZBoss		= 90
ZMonster	= 95
ZPet		= 98
ZBuff		= 99
ZPlayer		= 100
ZBullet		= 105 -- 箭和波
ZEffect		= 150
ZForeGround	= 160
ZUITutor	= 600
ZUIInteract	= 700
ZUILoading	= 900

ZUIAccounts = 800
ZUIBox		= 801
ZUIBoxList	= 802


Color = {
	Black 		= cc.c3b( 0,   0,   0 ),
	White 		= cc.c3b(251, 241, 201),
	Red			= cc.c3b(243,  63,   0 ),
	Green		= cc.c3b( 172,  236,  0 ),
	Yellow		= cc.c3b(255, 255,  0 ),
	Blue		= cc.c3b( 0,  166, 243),
	Purple		= cc.c3b(150,  0,  255),
	Orange		= cc.c3b(255, 165,   0),
	Rice_Yellow = cc.c3b(251, 241, 201),
	Dark_Yellow = cc.c3b(255, 206, 56),
	Dark_Green 	= cc.c3b( 0 , 255 , 0),
	Brown		= cc.c3b(82, 63, 40),
}



EnumLevel = 
{
	White		= 'White',	--	白色
	Green		= 'Green',	--	绿色
	Blue	 	= 'Blue',	--	蓝色
	Purple 		= 'Purple',	--	紫色
	Orange		= 'Orange',	--	橙色

}

EnumEquip = 
{
	equip_type_weapon	 = 'weapon',	--	武器
	equip_type_helmet	 = 'helmet',	--	头盔
	equip_type_armor	 = 'armor',	--	盔甲
	equip_type_necklace	 = 'necklace',	--	项链
	equip_type_ring      = 'ring',	--	戒指
	equip_type_shoe  	 = 'shoe'	--	鞋子
}

EnumMainSfeBtn = {
	btn_head		= 1,
	btn_chat 		= 2,
	btn_achievement = 3,
	btn_bag 		= 4,
	btn_soul 		= 5,
	btn_proficient 	= 6,
	btn_map 		= 7,
	btn_sign 		= 8,
	btn_market 		= 9,
	btn_activity 	= 10,
	btn_assignment 	= 11,

} 



EnumGoods = 
{
	equip_stone	 = 1,	--	装备
	soul_frag	 = 2,	--	宝石
	item	 	 = 3,	--	道具
}

EnumSkillElements = 
{
	fire	= 'fire',	--	火
	ice	 	= 'ice',	--	冰
	nature	= 'nature',	--	自然
	all	= 'all',	--	自然
	real = 'real_all'
}

EnumSkillTypes = 
{
	active		= 1, --主动
	passive	 	= 2, --被动
}

EnumBuffTypes = 
{
	permenant		= 1,	--	永久改变
	temporary		= 2,	--	临时增益

}

EnumProficientTypes = 
{
	power			= 1,
	courage			= 2,	--	勇气
	technique		= 3,
	life			= 4,
	strong			= 5,
	tenacity		= 6,


}

EnumMap = 
{
	Common		= 1,	--	普通关卡
	Elite		= 2,	--	精英关卡
}

EnumUiType = {
	common_map 	= { type='common_map'	,file='ui.map_layer.map_layer'},
	elite_map 	= { type='elite_map'	,file='ui.map_layer.map_layer'},
	td_map		= { type='td_map'		,file='ui.td_ui.td_map_layer'},
	shop 		= { type='shop'			,file='ui.shop_layer.shop_layer'},
	lottery 	= { type='lottery'		,file='ui.lottery_layer.lottery_layer'},
	strengthen	= { type='strengthen'	,file='ui.strengthen_layer.strengthen_layer'},
	fuben_detail= { type='fuben_detail'	,file='ui.fuben_detail.fuben_detail_layer'},
	pvp			= { type='pvp'			,file='ui.pvp_ui.pvp_layer'},
	midas_touch = { type='midas_touch'	,file='ui.midas_touch_layer.midas_touch_layer'},
	soul_exp	= { type='soul_exp'	,file='ui.soul_exp_layer.soul_exp_layer' }
}
