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

json = 'skeleton/boss_309_panda/boss_309_panda.ExportJson'
name = 'boss_309_panda' -- cocostudio project name
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-58,-10,80,250}
anim_flipped = false
default_run_speed = 22

----------------------------------子弹分割线----------------------------------
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
	duration = 73,  
	frames = {
		[9] =  {
			attack_box = { -50, 90, 315, 185 },
			--att_pause = 3,
			interval = 5,
			velocity_flipped = { 10, 60 },
		},
		[53] = {},
		[65] =  {
			attack_box = { -100, 80, 338, 190 },
			att_pause = 2,
			interval = 200,
			velocity_flipped = { 220, 60 },
		},
		[69] = {},
	},		
	anim = {
		name = 'Attack1',
		framecount = 73,--54
		duration = 73,
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
	duration = 75, 
	frames = {
		[26] =  {
			attack_box = { 28, 50, 435, 245 },
			att_pause = 2,
			interval = 200,
			velocity_flipped = { 30, 320 },
		},
		[28] = {},
	},	
	anim = {
		name = 'Attack4',
		framecount = 56,
		duration = 56,
		loop = 0,
	},
}

attack3 = {

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
	duration = 100, 
	operation = {
		[21] = {
			velocity_flipped = {50,220},
		},
		[32] = {
			goto_state = 'skill',
		},
	},
	anim = {
		name = 'Attack2',
		framecount = 23,
		duration = 23,
		loop=0,
	},
}

skill = {

	enter_cond = {
	},
	last_cond = {
		in_air = {},
	},
	command = command.touch_right,
	enter_op = {
		-- sound = role_sound.attack,
		wudi = true,
	},
	leave_op = {
		goto_state='skill2',
	},
	duration = 100, 
	frames = {
		[1] =  {
			attack_box = { -150, -15, 140, 68 },
			att_pause = 2,
			interval = 3,
			velocity_away = { 20, -20 },
		},
	},	
	anim = {
		name = 'Attack2a',
		framecount = 11,
		duration = 11,
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
		--face_target = true,
	},
	duration = 40, 
	operation = {		
		[5] = {
			shake_scene = {1.5, 15, 20, 0, 0},	
		},
		[6] = {
			velocity_flipped = {60,100},
		},
		[16] = {
			velocity = {0,0},
		},
	},
	frames = {
		[5] =  {
			attack_box = { -160, -35, 160, 80 },
			att_pause = 3,
			interval = 200,
			velocity_away = { 120, 150 },
		},
		[9] = {},
	},	
	anim = {
		name = 'Attack2b',
		framecount = 16,
		duration = 16,
		loop = 0,
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
	duration = 100,  
	operation = {
		[40] = {
			velocity_flipped = {100,0},
		},
		[41] = {
			anim = {
				name = 'Attack3a',
				framecount = 15,
				duration = 15,
			},
		},
		[99] = {
			velocity = {0,0},
		},
	},
	frames = {
		[41] =  {
			group_id = 1,
			attack_box = { -80, 20, 115, 205 },
			att_pause = 3,
			interval = 20,
			velocity_flipped = { 30, 200 },
		},

	},
	anim = {
		name = 'Attack3',
		framecount = 40,
		duration = 40,
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
		framecount = 10,
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
		begin = 3,
		framecount = 10,
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
		--face_target = true,
		--goto_state = 'attack2',
	},
	duration = 30,
	anim = {
		name = 'Wound3',
		begin = 10,
		framecount = 20,
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
	duration = 28,
	anim = {
		name = 'Run',
		framecount = 28,
		duration = 28,
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
		framecount = 23,
		duration = 30,
		loop = 0,
	},
}
