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

json = 'skeleton/boss_207_elsa/boss_207_elsa.ExportJson'
name = 'boss_207_elsa' -- cocostudio project name
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-40,20,45,206}
anim_flipped = false
default_run_speed = 32

bullet = {
	
	json = 'skeleton/boss_207_elsa_tx/boss_207_elsa_tx.ExportJson',
	name = 'boss_207_elsa_tx', -- cocostudio project name
	zorder = ZBullet,

	--scale_x = 1,
	--scale_y = 1,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 180,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -6, -6, 6, 6 },
				--velocity_flipped = { 10, 180 },
				--att_pause = 100,
				interval = 5,
			},
		},
		anim = {
			name = 'Stand1',
			framecount = 8,
			duration = 8,
		}
	},

	death = {
		enter_cond = {
			finish_attack={}
		},
	},

	state_order = {'death', 'idle', },

}

bullet2 = {
	
	json = 'skeleton/boss_207_elsa_tx/boss_207_elsa_tx.ExportJson',
	name = 'boss_207_elsa_tx', -- cocostudio project name
	zorder = ZBullet,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 14,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { 0, -40, 180, 58 },
				--velocity_flipped = { 100, 10 },
				--att_pause = 100,
				interval = 200,
			},
		},
		anim = {
			name = 'Stand2',
			framecount = 14,
			duration = 14,
		}
	},

	state_order = { 'idle', },

}

bullet3 = {
	
	json = 'skeleton/boss_207_elsa_tx/boss_207_elsa_tx.ExportJson',
	name = 'boss_207_elsa_tx', -- cocostudio project name
	zorder = ZBullet,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 23,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -185, 0, 220, 130 },
				velocity_away = { 10,290 },
				--att_pause = 100,
				interval = 4,
			},
			[20] = {},
		},
		operation = {
			[5] = {
				shake_scene = {1, 10, 15, 0, 0},	 -- 晃动屏幕 参数：duration, strength_x, strength_y, offset_x, offset_y
			},
		},
		anim = {
			name = 'Stand4',
			framecount = 23,
			duration = 23,
		}
	},

	state_order = { 'idle', },

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
	duration = 33,  -- 状态帧率 30 f/s
	operation = {
		[21] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {128,58}, 
				--enemy_offset = {0,0,},
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				fly_speed = 60,
				dest_offset = {0, 20},
				is_follow = 1,
			},		
		},
		[22] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {128,108}, 
				--enemy_offset = {0,0,},
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				fly_speed = 60,
				dest_offset = {0, 80},
				is_follow = 1,
			},		
		},
		[23] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {128,158}, 
				--enemy_offset = {0,0,},
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				fly_speed = 60,
				dest_offset = {0, 138},
				is_follow = 1,
			},		
		},
	},
	anim = {
			name = 'Attack1',
			framecount = 33,
			duration = 33, -- 动画帧率 30 f/s
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
		face_target = true,
		goto_state = 'skill2',
	},
	duration = 38,  -- 状态帧率 30 f/s
	operation = {
		[25] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {108,118}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
	},
	anim = {
			name = 'Attack2',
			framecount = 38,
			duration = 38, -- 动画帧率 30 f/s
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
	duration = 34,  -- 状态帧率 30 f/s
	operation = {
		[22] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {0,0}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				is_surround = true,
			},	
		},
	},
	anim = {
			name = 'Attack3',
			framecount = 34,
			duration = 34, -- 动画帧率 30 f/s
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
		begin = 4,
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
		face_target = true,
		goto_state = 'skill2',
	},
	duration = 30,
	anim = {
		name = 'Wound3',
		begin = 10,
		framecount = 17,
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
	duration = 24,
	anim = {
		name = 'Run',
		framecount = 24,
		duration = 24,
	},
}

idle = {
	enter_op = {
	},
	duration = 30,
	anim = {
		[1] = {
			name = "Stand1",
			framecount = 30,
			duration = 30,
		},
		[2] = {
			name = "Stand2",
			framecount = 30,
			duration = 30,
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
		framecount = 17,
		duration = 34,
		loop = 0,
	},
}


