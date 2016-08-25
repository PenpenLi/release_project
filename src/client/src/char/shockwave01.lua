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


plist = 'skeleton/shockwave/shockwave0.plist'
png = 'skeleton/shockwave/shockwave0.png'
json = 'skeleton/shockwave/shockwave.ExportJson'
name = 'shockwave' -- cocostudio project name

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
	},
	duration = 5,
}

idle = {
	enter_op = {
		hit_box = {-50,0,50,100},
		impulse = {20, 0}
	},
	frames = {
		[1] =  {
			attack_box = { -50, 0, 50, 100 },
			att_pause = 20,
			impulse = { 120, 0 },
		},
	},
	anim = {
		name = 'wave',
		framecount = 14,
		duration = 14,
	},
}


state_order = { 'hit', 'idle', }