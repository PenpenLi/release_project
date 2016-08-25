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

json = 'skeleton/boss_206_lina/boss_206_lina.ExportJson'
name = 'boss_206_lina' -- cocostudio project name
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-38,30,42,200}
anim_flipped = false
default_run_speed = 38

bullet = {
	
	json = 'skeleton/boss_206_lina_tx/boss_206_lina_tx.ExportJson',
	name = 'boss_206_lina_tx', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 1,
	scale_y = 1,

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
				interval = 200,
			},
		},
		anim = {
			name = 'Stand1',
			framecount = 9,
			duration = 9,
		}
	},

	state_order = { 'idle', },

}

bullet2 = {
	
	json = 'skeleton/boss_206_lina_tx/boss_206_lina_tx.ExportJson',
	name = 'boss_206_lina_tx', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 1,
	scale_y = 1,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 10,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -90, -50, 45, 40 },
				velocity_flipped = { 100, 120 },
				--att_pause = 100,
				interval = 200,
			},
		},
		anim = {
			name = 'Stand2',
			framecount = 4,
			duration = 4,
		}
	},

	state_order = { 'idle', },

}

bullet3 = {
	
	json = 'skeleton/boss_206_lina_tx/boss_206_lina_tx.ExportJson',
	name = 'boss_206_lina_tx', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 1,
	scale_y = 1,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 90,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -168, -60, 158, 30 },
				velocity_away = { 50, 120 },
				--att_pause = 100,
				interval = 15,
				collider_shake = {1, 15, 15, 0, 0},
			},
		},
		anim = {
			name = 'Stand3',
			framecount = 60,
			duration = 60,
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
	duration = 28,  -- 状态帧率 30 f/s
	operation = {
		[21] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,80}, 
				--enemy_offset = {0,0,},
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				--fly_speed = 120,
				--dest_offset = {0, 50},
				is_follow = 0,
				velocity = {100,-20},
			},		
		},
		[22] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,100}, 
				--enemy_offset = {0,0,},
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				--fly_speed = 120,
				--dest_offset = {0, 100},
				is_follow = 0,
				velocity = {100,0},
			},		
		},
		[23] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,120}, 
				--enemy_offset = {0,0,},
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				--fly_speed = 120,
				--dest_offset = {0, 150},
				is_follow = 0,
				velocity = {100,20},
			},		
		},
	},
	anim = {
			name = 'Attack1',
			framecount = 28,
			duration = 28, -- 动画帧率 30 f/s
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
	duration = 38,  -- 状态帧率 30 f/s
	operation = {
		[31] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {125,125}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				velocity = {260,0},
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
	duration = 33,  -- 状态帧率 30 f/s
	operation = {
		[22] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {0,130}, 
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
			framecount = 33,
			duration = 33, -- 动画帧率 30 f/s
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
			framecount = 16,
			duration = 15,
		},
		[2] = {
			name = "Wound2",
			framecount = 16,
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
		--bubble_dialogue_info = {id = {20601}, time = 4},	
		goto_state = 'skill2',
	},
	duration = 30,
	anim = {
		name = 'Wound3',
		begin = 10,
		framecount = 19,
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
	duration = 22,
	anim = {
		name = 'Run',
		framecount = 22,
		duration = 22,
	},
}

idle = {
	enter_op = {
	},
	duration = 30,
	anim = {
		[1] = {
			name = "Stand",
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
		framecount = 19,
		duration = 38,
		loop = 0,
	},
}


