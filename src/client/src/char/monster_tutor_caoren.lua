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

plist = 'skeleton/caoren/Caoren0.plist'
png = 'skeleton/caoren/Caoren0.png'
json = 'skeleton/caoren/Caoren.ExportJson'
name = 'Caoren' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-80,0,80,230}
anim_flipped = true
default_run_speed = 25
zorder = ZSceneObj
show_blood_slot = false


--state_order = battle_const.GroundMonsterDefaultStateOrder
state_order = {'trigger','hit','idle', }
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
	duration = 9,
	anim = {
		name = "wound",
		framecount = 9,
		duration = 9,

	},
}

idle = {
	enter_op = {
		bati = true,
	},
	duration = 30,
	anim = {
		name = 'stand',
		framecount = 1,
		duration = 1,
	},
}

trigger = {
	enter_cond = {
		trigger_by_enemy = { x = 250 ,y = 50 },
	},
	last_cond = {
		trigger_by_enemy = { x = 250 ,y = 50 },
	},
	enter_op = {
		bati = true,
		event = {
			name = 'enter_trigger',
		},
	},
	leave_op = {
		event = {
			name = 'outof_trigger',
		},
	},

	duration = battle_const.InfiniteTime,
 	-- anim = {
 	-- 	name = 'Stand',
 	-- 	framecount = 80,
 	-- 	duration = 144,
 	-- },
}