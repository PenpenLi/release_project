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

local command	= import( 'game_logic.command' )

plist = 'skeleton/guaix1/GuaiX10.plist'
png = 'skeleton/guaix1/GuaiX10.png'
json = 'skeleton/guaix1/GuaiX1.ExportJson'
name = 'GuaiX1' -- cocostudio project name
zorder = ZSceneObj

role_sound = {
	attack 	= 'sound/scene_dici_1.wav',
}

combat_conf = 7
default_physics_box = {10,10}
physics_dynamic = false

attack = {
	enter_cond = {
		trigger_by_enemy = {},
	},
	enter_op = {
		-- sound = role_sound.attack,
	},
	duration = 30,  -- 状态帧率 60 f/s
	frames = {
		[2] =  {
			attack_box = { -20, 20, 20, 90 },
			-- impulse = { 0, 150 },
		},
		[2] = {},

	},	

	anim = {
		name = 'Attack',
		framecount = 4,
		duration = 4, -- 动画帧率 30 f/s
		loop=0,
	},
}

idle = {
	duration = 150,
	anim = {
		name = 'Stand',
		framecount = 1,
		duration = 1,
	},
}

state_order = {'attack', 'idle', }
