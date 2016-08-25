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

json = 'skeleton/boss_308_blademaster/boss_308_blademaster.ExportJson'
name = 'boss_308_blademaster' -- cocostudio project name
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-50,0,60,206}
anim_flipped = false
default_run_speed = 38

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
	duration = 33,  -- 状态帧率 30 f/s
	frames = {
		[15] =  {
			attack_box = { -200, -60, 295, 350 },
			att_pause = 3,
			interval = 200,
			velocity_flipped = { 120, 30 },
		},
		[19] = {},
	},	
	anim = {
			name = 'Attack1',
			framecount = 33,
			duration = 33, -- 动画帧率 30 f/s
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
	duration = 47,  -- 状态帧率 30 f/s
	frames = {
		[16] =  {
			group_id = 1,
			attack_box = { -180, -60, 460, 210 },
			--att_pause = 4,
			interval = 200,
			velocity_flipped = { 20, 10 },
		},
		[18] =  {
			group_id = 1,
			attack_box = { 280, 0, 560, 230 },
			--att_pause = 4,
			interval = 200,
			velocity_flipped = { 20, 10 },
		},
		[20] = {},
		[31] =  {
			group_id = 2,
			attack_box = { 125, -18, 390, 300 },
			--att_pause = 4,
			interval = 200,
			velocity_flipped = { 120, 120 },
		},
		[33] =  {
			group_id = 2,
			attack_box = { 160, -18, 850, 230 },
			--att_pause = 4,
			interval = 200,
			velocity_flipped = { 120, 120 },
		},
		[36] =  {
			group_id = 2,
			attack_box = { 750, -18, 1100, 200 },
			--att_pause = 4,
			interval = 200,
			velocity_flipped = { 120, 120 },
		},
		[38] =  {
			group_id = 2,
			attack_box = { 1050, -18, 1380, 150 },
			--att_pause = 4,
			interval = 200,
			velocity_flipped = { 120, 120 },
		},
		[40] = {},
	},	
	anim = {
			name = 'Attack2',
			framecount = 47,
			duration = 47, -- 动画帧率 30 f/s
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
		--face_target = true,
	},
	duration = 50,  -- 状态帧率 30 f/s
	operation={
		[40] = {
			velocity_flipped = {450,0},
		},
		[41] = {
			anim = {
				name = 'Attack3_0',
				framecount = 5,
				duration = 5, -- 动画帧率 30 f/s
			},
		},
	},
	frames = {
		[41] =  {
			attack_box = { -60, 30, 90, 150 },
			att_state = 'skill2',
			--att_pause = 4,
			--interval = 200,
		},
	},	
	anim = {
			name = 'Attack3',
			framecount = 25,
			duration = 40, -- 动画帧率 30 f/s
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
		wudi = true,
	},
	duration = 51,  -- 状态帧率 30 f/s
	frames = {
		[1] = {
			attack_box = { -188, 0, 158, 198 },
			velocity_away = { -30, 131 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[5] =  {
			attack_box = { -188, 0, 158, 198 },
			att_pause = 2,
			interval = 200,
			velocity_away = { -30, 60 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[6] = {},
		[10] =  {
			attack_box = { -128, 0, 120, 200 },
			att_pause = 2,
			interval = 200,
			velocity_away = { -30, 60 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[12] = {},
		[15] =  {
			attack_box = { -160, 0, 155, 180 },
			att_pause = 2,
			interval = 200,
			velocity_away = { -30, 60 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[16] = {},
		[21] =  {
			attack_box = { -120, 0, 128, 200 },
			att_pause = 2,
			interval = 200,
			velocity_away = { -30, 60 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[23] = {},
		[26] =  {
			attack_box = { -150, 0, 138, 200 },
			att_pause = 2,
			interval = 200,
			velocity_away = { -30, 60 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[28] = {},
		[32] =  {
			attack_box = { -200, 0, 120, 200 },
			att_pause = 2,
			interval = 200,
			velocity_away = { -30, 60 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[34] = {},
		[37] =  {
			attack_box = { -126, 0, 130, 200 },
			att_pause = 2,
			interval = 200,
			velocity_away = { -30, 260 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[39] = {},
	},	
	anim = {
			name = 'Attack3_1',
			framecount = 51,
			duration = 51, -- 动画帧率 30 f/s
	},
}

skill3 = {

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
		--apply_buffs = {9997},
	},
	duration = 94,  -- 状态帧率 30 f/s
	operation = {
		[30] = {
			velocity_flipped = {50,0},
		},
		[31] = {
			anim = {
				name = 'Attack4_1',
				framecount = 5,
				duration = 5, -- 动画帧率 30 f/s
			},
		},
		[91] = {
			anim = {
				name = 'Attack4_2',
				framecount = 4,
				duration = 4, -- 动画帧率 30 f/s
			},
		},
		[90] = {
			velocity = {0,0},
		},
	},
	frames = {
		[31] =  {
			attack_box = { -210, 60, 196, 310 },
			--att_pause = 4,
			interval = 5,
			velocity_away = { -50, 131 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
		[90] = {},
	},	
	anim = {
			name = 'Attack4',
			framecount = 16,
			duration = 30, -- 动画帧率 30 f/s
	},
}

state_order = battle_const.BossHumanDefaultStateOrder
--state_order = {'death',{ 'attack', 'attack2', 'skill' ,'skill2', },'hit', 'run','idle', }
---------------------------------------------------------------------------------

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		--velocity = {0,0},
		-- sound = role_sound.hit,
		--bati = true,
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
		hit_box = nil,
		wudi = true,
		velocity = {0,0},
	},
	leave_op = {
		face_target = true,
		goto_state = 'attack',
	},
	duration = 30,
	anim = {
		name = 'Wound3',
		begin = 11,
		framecount = 21,
		duration = 20,
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
	duration = 12,
	anim = {
		name = 'Run',
		framecount = 19,
		duration = 12,
	},
}

idle = {
	enter_op = {
	},
	duration = 39,
	anim = {
		name = 'Stand',
		framecount = 39,
		duration = 39,
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
		framecount = 34,
		duration = 34,
		loop = 0,
	},
}


