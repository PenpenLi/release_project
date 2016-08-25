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

use_skeleton = true

plist = 'skeleton/guai01/Guai010.plist'
png = 'skeleton/guai01/Guai010.png'
json = 'skeleton/sequence/seqmonster.ExportJson'
name = 'seqmonster' -- cocostudio project name

fr_plist = 'frames/monster/run.plist'
fr_png = 'frames/monster/run.png'

combat_conf = 2
default_hit_box = {-40,0,60,110}
default_flipped = true
random_y_offset = true

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
	},
	leave_op = {
		--velocity = {0, 0},
	},
	duration = 8,
	anim = {
		name = "injured",
		framecount = 8,
		duration = 8,
	},
}

attack = {
	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
	},
	duration = 18,  -- 状态帧率 60 f/s
	frames = {
		[10] =  {
			attack_box = { 20, 40, 300, 90 },
			att_pause = 1,
			-- impulse = { 0, 150 },
		},
		[11] = {},
	},	

	anim = {
		name = 'attack',
		framecount = 18,
		duration = 18, -- 动画帧率 30 f/s
	},
}


run = {
	enter_cond = {
		running_speed = {},
	},
	last_cond = {
		running_speed = {},
	},
	enter_op = {
	},
	duration = 29,
 	anim = {
 		name = 'run',
 		framecount = 29,
 		duration = 29,
 	},
}

idle = {
	enter_op = {
	},
	duration = 29,
 	anim = {
 		name = 'run',
 		framecount = 29,
 		duration = 29,
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
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 90,
	anim = {
		name = 'injured',
		framecount = 8,
		duration = 8,
		loop = 0,
	},
}


state_order = {'death', 'attack', 'hit', 'run', 'idle', }

