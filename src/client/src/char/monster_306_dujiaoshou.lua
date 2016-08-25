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

json = 'skeleton/monster_306_dujiaoshou/monster_306_dujiaoshou.ExportJson'
name = 'monster_306_dujiaoshou' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-75,0,90,185}
random_y_offset = true
anim_flipped = false
default_run_speed = 28

attack = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		-- sound = role_sound.attack,
		velocity = {0,0},
		bati = true,
	},
	duration = 48,  -- 状态帧率 30 f/s
	frames = {
		[17] =  {
			attack_box = { 180, 30, 300, 185 },
			att_pause = 2,
			interval = 6,
			--impulse = { 0, 150 },
		},
		[41] = {},
	},	
	anim = {
		name = 'Attack1',
		framecount = 48,
		duration = 48, -- 动画帧率 30 f/s
	},
}

attack2 = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		-- sound = role_sound.attack,
		velocity = {0,0},
		bati = true,
	},
	duration = 73,  -- 状态帧率 30 f/s
	operation = {
		[51]={
			velocity_flipped = {160,0},

			anim = {
				name = 'Attack2_Run',
				framecount = 9,
				duration = 9, -- 动画帧率 30 f/s
			},
		},
		[68]={
			velocity = {0,0},
		},
		[69]={
			anim = {
				name = 'Attack2_Back',
				framecount = 5,
				duration = 5, -- 动画帧率 30 f/s
			},
		},
		[75] = {},
	},
	frames = {
		[51] =  {
			attack_box =  { -50 , 0, 160, 170 },
			att_pause = 2,
			interval = 200,
			velocity_flipped = { 50, 200 },
		},
		[68] = {},
	},	
	anim = {
			name = 'Attack2_Start',
			framecount = 50,
			duration = 50, -- 动画帧率 30 f/s
	},
}

state_order = battle_const.GroundMonsterDefaultStateOrder
--state_order = {'death','fall_ground', 'fly_hit', 'hit_fly','hit', { 'attack', 'attack2', 'skill' ,'skill1', 'skill2' , }, 'run','idle', }
---------------------------------------------------------------------------------

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		--velocity = {0,0},
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = 15,
	operation = {
		[5] = {
			velocity = {0,0},
		},
	},
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
		name = 'Wound3',
		framecount = 11,
		duration = 20,
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
		name = 'Wound3',
		begin = 4,
		framecount = 11,
		duration = 15,
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
		name = 'Wound3',
		begin = 11,
		framecount = 26,
		duration = 16,
		loop = 0,
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
	duration = 10,
	anim = {
		name = 'Run',
		framecount = 30,
		duration = 10,
	},
}

idle = {
	enter_op = {
	},
	duration = 29,
	anim = {
		name = 'Stand',
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
		sound = role_sound.death,
		velocity = {0,0},
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 100,
	operation = {
		[55] = {
			fade = {45,0},
		},
	},
	anim = {
		name = 'Death',
		framecount = 47,
		duration = 47,
		loop = 0,
	},
}

