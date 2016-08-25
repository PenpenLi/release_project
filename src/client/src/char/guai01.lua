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

plist = 'skeleton/guai01/Guai010.plist'
png = 'skeleton/guai01/Guai010.png'
json = 'skeleton/guai01/Guai01.ExportJson'
name = 'Guai01' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

combat_conf = 2
default_hit_box = {-40,0,50,120}
default_flipped = true
random_y_offset = true

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = 10,
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

hit_fly = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Death',
		framecount = 8,
		duration = 10,
		loop = 0,
	},
}

fly_hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Death',
		begin = 6,
		framecount = 8,
		duration = 10,
		loop = 0,
	},
}

fall_ground = {
	enter_cond = {
		in_state = {'hit_fly', 'fly_hit'},
		on_ground = {},
	},
	enter_op = {
		-- sound = role_sound.hit,
		hit_box = nil,
		wudi = true,
		velocity = {0,0},
	},
	leave_op = {
	},
	duration = 30,
	anim = {
		name = 'Death',
		begin = 8,
		framecount = 15,
		duration = 10,
		loop = 0,
	},
}

attack = {
	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		-- sound = role_sound.attack,
	},
	duration = 22,  -- 状态帧率 60 f/s
	frames = {
		[1] =  {
			attack_box = { 0, 40, 150, 90 },
			att_pause = 2,
			--impulse = { 0, 150 },
		},
		[5] = {},
	},	

	anim = {
		name = 'Attack1',
		framecount = 22,
		duration = 22, -- 动画帧率 30 f/s
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
	duration = 20,
	anim = {
		name = 'Run',
		framecount = 20,
		duration = 20,
	},
}

idle = {
	enter_op = {
	},
	duration = 40,
	anim = {
		name = 'Stand',
		framecount = 40,
		duration = 40,
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
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 90,
	anim = {
		name = 'Death',
		framecount = 18,
		duration = 18,
		loop = 0,
	},
}


state_order = {'death','attack', 'fall_ground', 'fly_hit', 'hit_fly', 'hit', 'run','idle', }
