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

json = 'skeleton/monster_102_robber/monster_102_robber.ExportJson'
name = 'monster_102_robber' -- cocostudio project name
boss = true
scale_x = 1.3
scale_y = 1.3

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-65,0,58,233}
random_y_offset = true
anim_flipped = true
default_run_speed = 25

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
	duration = 27,  -- 状态帧率 30 f/s
	frames = {
		[24] =  {
			attack_box = { 130,0, 260, 195 },
			att_pause = 6,
			interval = 200,
			--impulse = { 0, 150 },
		},
		[27] = {},
	},	

	anim = {
		name = 'Attack1',
		framecount = 27,
		duration = 27, -- 动画帧率 30 f/s
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
	duration = 25,  -- 状态帧率 30 f/s
	frames = {
		[18] =  {
			attack_box = { -180, 10, 215, 130 },
			att_pause = 6,
			interval = 200,
			--impulse = { 0, 150 },
			collider_shake = {1, 15, 15, 0, 0},
		},
		[23] = {},
	},	

	anim = {
			name = 'Attack2',
			framecount = 25,
			duration = 25, -- 动画帧率 30 f/s
	},
}

skill = {
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
	leave_op = {
		velocity = {0,0},
	},
	duration = 53,  -- 状态帧率 30 f/s
	operation = {
		[23]={
			velocity_flipped = {80,0},
		},
		[27]={
			velocity = {0,0},
		},
		[35]={
			velocity_flipped = {80,0},
		},
		[40]={
			velocity = {0,0},
		},
		[48]={
			velocity_flipped = {80,0},
		},

		[28]={
			anim = {
				name = 'Attack1',
				begin = 15,
				framecount = 27,
				duration = 13, -- 动画帧率 30 f/s
			},
		},	
		[41]={
			anim = {
				name = 'Attack1',
				begin = 15,
				framecount = 27,
				duration = 13, -- 动画帧率 30 f/s
			},
		},		
	},
	frames = {
		[24] =  {
			attack_box =  { 130,0, 260, 195 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 80, 0 },
		},
		[26] = {},
		[37] =  {
			attack_box =  { 130,0, 260, 195 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 80, 0 },
		},
		[39] = {},
		[50] =  {
			attack_box =  { 130,0, 260, 195 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 80, 0 },
		},
		[52] = {},
	},	

	anim = {
		name = 'Attack1',
		framecount = 27,
		duration = 27, -- 动画帧率 30 f/s
	},
}

skill2 = {
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
	leave_op = {
		velocity = {0,0},
	},
	duration = 58,  -- 状态帧率 30 f/s
	operation = {
		[20]={
			velocity_flipped = {30,0},
		},
		[22]={
			velocity = {0,0},
		},
		[27]={
			velocity_flipped = {80,0},
		},
		[30]={
			velocity = {0,0},
		},
		[37]={
			velocity_flipped = {80,0},
		},

		[26]={
			anim = {
				name = 'Attack2',
				begin = 16,
				framecount = 25,
				duration = 10, -- 动画帧率 30 f/s
			},
		},	
		[36]={
			anim = {
				name = 'Attack2',
				begin = 16,
				framecount = 20,
				duration = 5, -- 动画帧率 30 f/s
			},
		},
		[41]={
			anim = {
				name = 'Attack2',
				begin = 20,
				framecount = 22,
				duration = 6, -- 动画帧率 30 f/s
			},
		},	
		[47]={
			anim = {
				name = 'Attack2',
				begin = 20,
				framecount = 22,
				duration = 6, -- 动画帧率 30 f/s
			},
		},
		[53]={
			anim = {
				name = 'Attack2',
				begin = 20,
				framecount = 25,
				duration = 6, -- 动画帧率 30 f/s
			},
		},

	},
	frames = {
		[18] =  {
			attack_box =  { -180, 10, 215, 130 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 60, 0 },
			collider_shake = {1, 15, 15, 0, 0},
		},
		[23] = {},
		[28] =  {
			attack_box =  { -180, 10, 215, 130 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 70, 0 },
			collider_shake = {1, 15, 15, 0, 0},
		},
		[33] = {},
		[38] =  {
			attack_box =  { -180, 10, 215, 130 },
			att_pause = 6,
			interval = 5,
			velocity_flipped = { 80, 0 },
			collider_shake = {1, 15, 15, 0, 0},
		},
		[53] = {},
	},	

	anim = {
		name = 'Attack2',
		framecount = 25,
		duration = 25, -- 动画帧率 30 f/s
	},
}

state_order = battle_const.BossHumanDefaultStateOrder
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
		begin = 6,
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
		framecount = 20,
		duration = 30,
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
		framecount = 20,
		duration = 10,
	},
}

idle = {
	enter_op = {
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
		remove_obj = true,
	},
	duration = 120,
	operation = {
		[90] = {
			fade = {30,0},
		},
	},
	anim = {
		name = 'Death',
		framecount = 19,
		duration = 19,
		loop = 0,
	},
}


