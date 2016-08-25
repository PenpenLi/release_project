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

json = 'skeleton/monster_208_fishman/monster_208_fishman.ExportJson'
name = 'monster_208_fishman' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-45,0,70,130}
random_y_offset = true
anim_flipped = false
default_run_speed = 25

bullet = {
	
	json = 'skeleton/monster_208_fishman_zidan/monster_208_fishman_zidan.ExportJson',
	name = 'monster_208_fishman_zidan', -- cocostudio project name
	zorder = ZBullet,

	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 180,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -5, -5, 5, 5 },
				interval = 200,
			},
		},
		anim = {
			name = 'Stand1',
			framecount = 21,
			duration = 21,
		}
	},

	ground = {
		enter_cond = {
			on_ground = {},
		},
	},

	death = {
		enter_cond = {
			finish_attack={}
		},
	},

	state_order = {'death', 'ground','idle', },
}
----------------------------------子弹分割线----------------------------------
attack = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		velocity = {0,0},
		bati = true,
	},
	duration = 31,  -- 状态帧率 30 f/s
	frames = {
		[12] =  {
			attack_box = { 100, 90, 207, 150 },
			att_pause = 4,
			interval = 200,
			velocity_flipped = { 20, 10 },
		},
		[27] = {},
	},	
	anim = {
		name = 'Attack1',
		framecount = 31,
		duration = 31, -- 动画帧率 30 f/s
	},
}

attack2 = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		velocity = {0,0},
		bati = true,
	},
	duration = 41,  -- 状态帧率 30 f/s
	operation = {
		[1]={
			velocity_flipped = {120,140},
		},
		[16]={
			velocity = {0,0},
		},
		[32]={
			velocity_flipped = {-130,100},
		},
		[37]={
			velocity = {0,0},
		},
	},
	frames = {
		[14] =  {
			attack_box = { 80, -10, 115, 50 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 30, 131 },
		},
		[31] = {},
	},	

	anim = {
			name = 'Attack2',
			framecount = 41,
			duration = 41, -- 动画帧率 30 f/s
	},
}

skill = {
	enter_cond = {
		on_ground = {},
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		velocity = {0,0},
		bati = true,
	},
	duration = 62,  -- 状态帧率 30 f/s 60
	operation = {
		[33] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {67,158}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = false,

				gravity = true,
				velocity = {50,200},		
			},
		},
		[34] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {67,158}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = false,

				gravity = true,
				velocity = {80,260},		
			},
		},
		[35] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {67,158}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = false,

				gravity = true,
				velocity = {120,150},		
			},
		},
	},
	anim = {
		[1] = {
			name = 'Attack3',
			framecount = 62,
			duration = 62, -- 动画帧率 30 f/s
		},
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
		duration = 11,
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
		begin = 3,
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
		framecount = 23,
		duration = 13,
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
	duration = 15,
	anim = {
		[1] = {
			name = "Run",
			framecount = 30,
			duration = 15,
		},
		[2] = {
			name = "Run2",
			framecount = 30,
			duration = 15,
		},
	},
}

idle = {
	enter_op = {
	},
	duration = 29,
	anim = {
		[1] = {
			name = "Stand",
			framecount = 29,
			duration = 29,
		},
		[2] = {
			name = "Stand2",
			framecount = 29,
			duration = 29,
		},
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
		velocity = {0,0},
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 120,
	operation = {
		[45] = {
			fade = {45,0},
		},
	},
	anim = {
		name = 'Death',
		framecount = 39,
		duration = 39,
		loop = 0,
	},
}


