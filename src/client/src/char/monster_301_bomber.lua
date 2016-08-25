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
	create_obj = {
		conf_id = 4,
		self_offset = {0,72}, -- 相对角色的位置，优先级最高
		enemy_offset = {-20,66}, -- 相对最近敌人的位置，优先级第二
		scene_offset = {1000, 200}, -- 相对于场景的位置，优先级最低
		scene_offset = {'player', 'self'}, -- 
		duration = 150, -- obj的存活帧数
		attack_times = 1, -- obj攻击过多少次后算“完成攻击”
	},
]]

local command	= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )

json = 'skeleton/monster_301_bomber/monster_301_bomber.ExportJson'
name = 'monster_301_bomber' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_jian_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-45,0,45,125}
random_y_offset = true
anim_flipped = false
default_run_speed = 40

bullet = {
	
	json = 'skeleton/monster_301_bomber_zidan/monster_301_bomber_zidan.ExportJson',
	name = 'monster_301_bomber_zidan', -- cocostudio project name
	zorder = ZBullet,
	shadow = true,
	-- default_hit_box = { 20, -10, 40, 10 }

	succeed = {
		enter_cond = {
			hitable = {},
		},

		enter_op = {
			gravity = false,
			velocity = {0, 0},
		},

		frames = {
			[1] =  {
				attack_box = { -45, -15, 60, 100 },
				interval = 200,      --200帧之后才能攻击第二次
			},
		},	

		leave_op = {
			remove_obj = true,
		},

		duration = 11,
		anim = {
			name = 'Stand3',
			framecount = 11,
			duration = 11,
		},
	},

	ground = {
		enter_cond = {
			on_ground = {},
		},
		enter_op = {
			velocity = {0, 0},
			---- sound = role_sound.attack,
		},
		duration = 55,
		operation = {
			[1]={
				velocity_flipped = {10,90},
			},
			[15]={
				velocity = {0,0},
			},
			[54]={
				goto_state = 'succeed',
			},
		},
		frames = {
			[1] =  {
				attack_box = { -20, 18, 25, 62 },
			-- 	interval = 200,
				-- att_pause = 2,
				att_state = 'succeed',
			},
		},
		anim = {
			name = 'Stand2',
			framecount = 11,
			duration = 11,
		},
	},

	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
		},
		duration = 11,
		frames = {
			[1] =  {
				attack_box = { -20, 18, 25, 62 },
			-- 	interval = 200,
				-- att_pause = 2,
				att_state = 'succeed',
			},
		},
		anim = {
			name = 'Stand1',
			framecount = 11,
			duration = 11,
		},
	},

	state_order = {'succeed', 'ground','idle',},
}

bullet2 = {
	
	json = 'skeleton/monster_301_bomber_zidan/monster_301_bomber_zidan.ExportJson',
	name = 'monster_301_bomber_zidan', -- cocostudio project name
	zorder = ZBullet,
	shadow = false,

	-- default_hit_box = { 20, -10, 40, 10 }

	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,

		},
		duration = 11,  -- 状态帧率 30 f/s
		operation = {
    		[1] = {
    			shake_scene = {0.5, 10, 15, 0, 0},	 -- 晃动屏幕 参数：duration, strength_x, strength_y, offset_x, offset_y
    		}
		},
		frames = {
			[1] =  {
				attack_box = { -45, -15, 60, 100 },
				interval = 200,
			}
		},

		anim = {
			name = 'Stand3',
			framecount = 11,
			duration = 11,
		}
	},

	state_order = { 'idle', },
}
----------------------------------子弹分割线----------------------------------
attack = {
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
	duration = 46,  -- 状态帧率 30 f/s 60
	operation = {
		[38] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,80}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = false,

				gravity = true,
				velocity = {85,220},		
			},
		},
	},
	anim = {
		[1] = {
			name = 'Attack1',
			framecount = 46,
			duration = 46, -- 动画帧率 30 f/s
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
		framecount = 9,
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
		framecount = 9,
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
		begin = 9,
		framecount = 16,
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
	duration = 26,
	anim = {
		name = 'Stand',
		framecount = 26,
		duration = 26,
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
		[44] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {45,10}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
			},
		},
		[48] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {-75,35}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
			},
		},
		[50] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {-65,85}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
			},
		},
		[90] = {
			fade = {10,0},
		},
	},
	anim = {
		name = 'Death',
		framecount = 81,
		duration = 81,
		loop = 0,
	},
}


