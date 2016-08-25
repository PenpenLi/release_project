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

json = 'skeleton/monster_303_minotaur/monster_303_minotaur.ExportJson'
name = 'monster_303_minotaur' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-30,20,105,165}
random_y_offset = true
anim_flipped = false
default_run_speed = 15

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
	duration = 42,  -- 状态帧率 30 f/s
	frames = {
		[28] =  {
			attack_box = { -25,20, 300, 95 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 180, 20 },
		},
		[35] = {},
	},	

	anim = {
		name = 'Attack2',
		framecount = 42,
		duration = 42, -- 动画帧率 30 f/s
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
	leave_op = {
		velocity = {0,0},
	},
	duration = 65,  -- 状态帧率 30 f/s
	operation = {
		[31]={
			velocity_flipped = {100,0},
		},
		[33]={
			velocity = {0,0},
		},	
		[50]={
			velocity_flipped = {230,0},
		},
		[60]={
			velocity = {0,0},
		},		
	},
	frames = {
		[19] =  {
			attack_box =  { -200,-20, 328, 240 },
			--att_pause = 6,
			interval = 200,
			velocity_flipped = { 10, 220 },
		},
		[23] = {},
		[32] =  {
			attack_box =  { 60,0, 370, 280 },
			att_pause = 2,
			interval = 200,
			velocity_flipped = { 30, 180 },
		},
		[37] = {},
		[53] =  {
			attack_box =  { -20,0, 195, 155 },
			att_pause = 3,
			interval = 200,
			velocity_flipped = { 180, 100 },
		},
		[65] = {},
	},	

	anim = {
		name = 'Attack1',
		framecount = 65,
		duration = 65, -- 动画帧率 30 f/s
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
		framecount = 14,
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
		framecount = 14,
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
		begin = 14,
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
	duration = 32,
	anim = {
		name = 'Run',
		framecount = 32,
		duration = 32,
	},
}

idle = {
	enter_op = {
	},
	duration = 27,
	anim = {
		name = 'Stand',
		framecount = 27,
		duration = 27,
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
	duration = 90,
	operation = {
		[60] = {
			fade = {30,0},
		},
	},
	anim = {
		name = 'Death',
		framecount = 26,
		duration = 26,
		loop = 0,
	},
}


