--[[
enter_cond = {}, --状态进入条件 条件之间为与的关系
last_cond = {}, --状态持续条件 条件之间为与的关系
command = nil, --进入状态所需按键指令
enter_op = {}, --状态进入时操作
leave_op = {}, --状态离开时操作
interrupt_op = {}, --状态被打断时操作
child = { --子状态，即必须处于当前状态才能进入的状态，子状态只在满足条件时候出发，没有持续时间
	enter_cond = {}, --状态进入条件 条件之间为与的关系
	command = nil, --进入状态所需按键指令
	enter_op = {}, --状态进入时操作
},
]]

local command			= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )

plist = 'skeleton/Building_goddess/Building_goddess0.plist'
png = 'skeleton/Building_goddess/Building_goddess0.png'
json = 'skeleton/Building_goddess/Building_goddess.ExportJson'
name = 'Building_goddess' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-100,0,79,277}
anim_flipped = false
default_run_speed = 25
zorder = ZSceneObj


--state_order = battle_const.GroundMonsterDefaultStateOrder
state_order = {'death','hit','idle', }
---------------------------------------------------------------------------------

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		velocity = {0,0},
		bati = true,
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = 15,
	anim = {
		[1] = {
			name = "Wound",
			framecount = 15,
			duration = 15,
		},
		[2] = {
			name = "Wound2",
			framecount = 15,
			duration = 15,
		},
	},
}

idle = {
	enter_op = {
		bati = true,
	},
	duration = 30,
	anim = {
		name = 'Stand',
		framecount = 30,
		duration = 30,
	},
}

death = {
	enter_cond = {
		not_in_state = {'death'},
		hp_zero = {},
	},
	enter_op = {
		wudi = true,
		clear_buffs = true,
		clear_goto_state = true,
		sound = role_sound.death,
		velocity = {0,0},
	},
	leave_op = {
		
	},
	duration = 90,
	operation = {
		-- [45] = {
		-- 	fade = {45,0},
		-- },
	},
	 anim = {
		name = 'Stand5',
	 	framecount = 30,
	 	duration = 30,
	 	loop = 0,
	 },
}


