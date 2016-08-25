
local command			= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )

json = 'skeleton/boss_307_robot/boss_307_robot.ExportJson'
name = 'boss_307_robot'
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-90,0,80,280}
anim_flipped = false
default_run_speed = 22

bullet = {
	
	json = 'skeleton/boss_307_robot_tx/boss_307_robot_tx.ExportJson',
	name = 'boss_307_robot_tx',
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
		duration = 35,  -- 状态帧率 30 f/s
		operation = {
			[1] = {
				velocity_flipped={1000,0},
			},
			[3] = {
				velocity = {0,0},
			},
			[5] = {
				anim = {
					name = 'Stand2',
					framecount = 31,
					duration = 31, -- 动画帧率 30 f/s
				},
			},
		},
		frames = {
			[5] =  {
				attack_box = { -170, -36, 225, 88 },
				velocity_away = { -10, 35 },
				--att_pause = 100,
				interval = 4,
			 	collider_shake = {0.5, 10, 10, 0, 0},
			},
		},
		anim = {
			name = 'Stand1',
			framecount = 10,
			duration = 4,
		}
	},

	state_order = { 'idle', },

}

bullet2 = {
	
	json = 'skeleton/boss_307_robot_tx/boss_307_robot_tx.ExportJson',
	name = 'boss_307_robot_tx',
	zorder = ZBullet,

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
				attack_box = { -68, 0, 68, 139 },
				interval = 200, 
			},
		},	

		leave_op = {
			remove_obj = true,
		},

		duration = 14,
		anim = {
			name = 'Stand4',
			framecount = 14,
			duration = 14,
		},
	},

	ground = {
		enter_cond = {
			on_ground = {},
		},
		enter_op = {
			goto_state = 'succeed',
			shake_scene = {0.5, 10, 15, 0, 0},	 -- 晃动屏幕 参数：duration, strength_x, strength_y, offset_x, offset_y
		},
	},

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		duration = 60,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -5, 0, 5, 60 },
				--velocity_away = { 100, 120 },
				--att_pause = 100,
				att_state = 'succeed',
			},
		},
		anim = {
			name = 'Stand3',
			framecount = 4,
			duration = 4,
		}
	},

	state_order = {'succeed', 'ground','idle',},

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
	duration = 56,  -- 状态帧率 30 f/s
	frames = {
		[22] =  {
			attack_box = { 146,128,380,380 },
			--att_pause = 1,
			interval = 5,
			velocity_flipped = { -20, 50 },
			collider_shake = {1, 15, 15, 0, 0},
		},
		[36] = {},
		[45] =  {
			attack_box = { -155,100,295,185 },
			--att_pause = 1,
			interval = 200,
			velocity_flipped = { 50, 50 },
			collider_shake = {1, 15, 15, 0, 0},
		},
		[48] = {
			attack_box = { 128,138,320,158 },
			--att_pause = 1,
			interval = 5,
			velocity_flipped = { 50, 50 },
			collider_shake = {0.5, 10, 10, 0, 0},
		},
	},	

	anim = {
			name = 'Attack1',
			framecount = 56,
			duration = 56, -- 动画帧率 30 f/s
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
	duration = 48,  -- 状态帧率 30 f/s
	frames = {
		[8] =  {
			attack_box = { -130, 100, 500, 160 },
			--att_pause = 6,
			interval = 3,
			velocity_flipped = { 150, 120 },
		},
		[10] =  {
			attack_box = { 285, 135, 575, 168 },
			att_pause = 3,
			interval = 3,
			velocity_flipped = { 50, 50 },
		},
		[20] = {},
	},	

	anim = {
			name = 'Attack3',
			framecount = 48,
			duration = 48, -- 动画帧率 30 f/s
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
	duration = 63,  -- 状态帧率 30 f/s
	operation = {
		[35] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {166,150}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
	},
	frames = {
		[10] =  {
			attack_box = { 35, 80, 205, 160 },
			--att_pause = 6,
			interval = 6,
			velocity_flipped = { 60, 30 },
		},
		[31] = {},
	},	
	anim = {
			name = 'Attack2',
			framecount = 63,
			duration = 63, -- 动画帧率 30 f/s
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
	duration = 46,  -- 状态帧率 30 f/s
	operation = {
		[30] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				--self_offset = {100,150}, 
				enemy_offset = {-120,1200},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				no_obstacle = false,
				velocity = {0,-200},
			},			
		},
		[31] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				--self_offset = {100,150}, 
				enemy_offset = {-50,1500},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				no_obstacle = false,
				velocity = {0,-200},
			},			
		},
		[32] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				--self_offset = {100,150}, 
				enemy_offset = {38,1480},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				no_obstacle = false,
				velocity = {0,-200},
			},			
		},
		[33] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				--self_offset = {100,150}, 
				enemy_offset = {136,1260},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				no_obstacle = false,
				velocity = {0,-200},
			},			
		},
	},
	anim = {
			name = 'Attack4',
			framecount = 46,
			duration = 46, -- 动画帧率 30 f/s
	},
}

state_order = battle_const.BossDefaultStateOrder
--state_order = {'death',{ 'attack', 'attack2', 'skill' ,'skill2', },'hit', 'run','idle', }
---------------------------------------------------------------------------------

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
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
	duration = 11,
	anim = {
		name = 'Stand',
		framecount = 11,
		duration = 11,
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
		framecount = 42,
		duration = 60,
		loop = 0,
	},
}


