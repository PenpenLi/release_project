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

json = 'skeleton/heishui0/TX-heishui.ExportJson'
name = 'TX-heishui' -- cocostudio project name
zorder = ZSceneObj

role_sound = {
	attack 	= 'sound/boss_heishui_1.wav',
}

combat_conf = 6
default_physics_box = {0,0}
physics_dynamic = false
scale_y = 0.5
default_anim = {
	name = 'Stand',
	framecount = 200,
	duration = 200,
}

attack = {
	enter_cond = {
		trigger_by_enemy = {},
	},
	enter_op = {
		-- sound = role_sound.attack,
	},
	duration = 30,  -- 状态帧率 60 f/s
	frames = {
		[1] =  {
			attack_box = { -20, 20, 20, 90 },
		},
		[1] = {},
	},
}

idle = {
	duration = 100,
}

state_order = { 'attack','idle', }
