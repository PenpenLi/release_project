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

plist = 'skeleton/monster_501_papaxiong/monster_501_papaxiong0.plist'
png = 'skeleton/monster_501_papaxiong/monster_501_papaxiong0.png'
json = 'skeleton/monster_501_papaxiong/monster_501_papaxiong.ExportJson'
name = 'monster_501_papaxiong' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-135,0,133,190}
random_y_offset = true
anim_flipped = false
default_run_speed = 30

scale_x = 0.65
scale_y = 0.65

bullet = {
	
	json = 'skeleton/monster_501_papaxiong_tx/monster_501_papaxiong_tx.ExportJson',
	name = 'monster_501_papaxiong_tx', -- cocostudio project name
	zorder = ZBullet,

	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
		},
		leave_op = {
		},
		duration = 8,  -- 状态帧率 30 f/s
		anim = {
			name = 'Stand',
			framecount = 4,
			duration =8,
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

bullet2 = {
	
	json = 'skeleton/monster_501_papaxiong_tx/monster_501_papaxiong_tx.ExportJson',
	name = 'monster_501_papaxiong_tx', -- cocostudio project name
	zorder = ZBullet,

	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
		},
		leave_op = {

		},
		duration = 190,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -21, -43, 260, 56 },
				interval = 15,
			},
		},
		anim = {
			name = 'Stand2',
			framecount = 70,
			duration = 190,
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
		-- sound = role_sound.attack,
		velocity = {0,0},
		bati = true,
	},
	duration = 21,  -- 状态帧率 30 f/s
	frames = {
		[16] =  {
			attack_box = { 80, 33, 222, 245},
			att_pause = 6,
			interval = 200,
			velocity_flipped = {80,10},
			--impulse = { 0, 150 },
		},
		[20] = {},
	},	
	anim = {
		name = 'Attack1',
		framecount = 21,
		duration = 21, -- 动画帧率 30 f/s
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
	duration = 87,  -- 状态帧率 30 f/s
	operation = {

		[17] = {
			-- sound = role_sound.attack,
			anim = {
			name = 'Attack2-2',
			framecount = 62,
			duration = 62, -- 动画帧率 30 f/s
			},
			create_obj = {
			
				conf_id = 'bullet',
				self_offset = {100,50}, 
				duration = 8,
				attack_times = 1,
				no_obstacle = false,

				gravity = false,
				velocity = {0,0},		
			},
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {70,50}, 
				duration = 190,
				attack_times = 3,
				no_obstacle = false,

				gravity = false,
				velocity = {0,0},		
			},
		},	
		[79] = {},
		[80] = {
			anim = {
			name = 'Attack2-3',
			framecount = 6,
			duration = 6, -- 动画帧率 30 f/s
			},
		},
	},
	anim = {
			name = 'Attack2-1',
			framecount = 16,
			duration = 16, -- 动画帧率 30 f/s
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
		apply_buffs = {111},
	},
	duration = 100,  -- 状态帧率 30 f/s
	operation = {
		[6]={
			anim = {
				name = 'Attack3-2',
				framecount = 90,
				duration = 90, -- 动画帧率 30 f/s
			},
		},
		[95]={
			clear_buffs = {111},		
		},
		[96]={
			anim = {
				name = 'Attack3-3',
				framecount = 5,
				duration = 5, -- 动画帧率 30 f/s
			},
		},
		[100] = {},
	},
	anim = {
			name = 'Attack3-1',
			framecount = 5,
			duration = 5, -- 动画帧率 30 f/s
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
			name = "Wound",
			framecount = 19,
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
		name = 'Wound2',
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
		framecount = 21,
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
	duration = 20,
	anim = {
		name = 'Run',
		framecount = 26,
		duration = 20,
	},
}

idle = {
	enter_op = {
	},
	duration = 28,
	anim = {
		name = 'Stand',
		framecount = 28,
		duration = 28,
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
		[45] = {
			fade = {45,0},
		},
	},
	anim = {
		name = 'Death',
		framecount = 21,
		duration = 22,
		loop = 0,
	},
}


