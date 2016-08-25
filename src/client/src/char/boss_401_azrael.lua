
local command			= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )

json = 'skeleton/boss_401_azrael/boss_401_azrael.ExportJson'
name = 'boss_401_azrael'
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-120,0,75,250}
anim_flipped = true
default_run_speed = 35

bullet = {
	
	json = 'skeleton/boss_401_azrael_tx/boss_401_azrael_tx.ExportJson',
	name = 'boss_401_azrael_tx',
	zorder = ZBullet,
	anim_flipped = true,

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
				attack_box = { -20, -20, 20, 20 },
				--velocity_away = { -10, 35 },
				--att_pause = 100,
				--interval = 4,
			},
		},
		anim = {
			name = 'Stand',
			framecount = 10,
			duration = 10,
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
	
	json = 'skeleton/boss_401_azrael_tx/boss_401_azrael_tx.ExportJson',
	name = 'boss_401_azrael_tx',
	zorder = ZBoss,
	anim_flipped = true,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 63,  -- 状态帧率 30 f/s
		operation = {
			[47] = {
				shake_scene = {1, 10, 15, 0, 0},
			},
		},
		frames = {
			[46] =  {
				attack_box = { 280, 0, 428, 350 },
				velocity_flipped = { 30, 180 },
				att_pause = 10,
				interval = 200,
			},
			[49] = {},
		},
		anim = {
			name = 'Stand2',
			framecount = 63,
			duration = 63,
		}
	},

	state_order = {'idle', },

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
	duration = 25,  -- 状态帧率 30 f/s
	frames = {
		[19] =  {
			attack_box = { 110,0,390,288 },
			--att_pause = 1,
			interval = 200,
			velocity_flipped = { 120, 50 },
		},
		[23] = {},
	},	

	anim = {
			name = 'Attack1',
			framecount = 25,
			duration = 25, -- 动画帧率 30 f/s
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
	duration = 41,  -- 状态帧率 30 f/s
	operation = {
		[25] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,160}, 
				--enemy_offset = {0,0,},
				duration = 600,
				attack_times = 1,
				no_obstacle = true,
				gravity = false,
				all_angle = true,

				fly_speed = 60,
				dest_offset = {0,100},
				is_follow = 1,
				is_follow_rate = 5,
			},	
		},
	},
	anim = {
			name = 'Attack4',
			framecount = 41,
			duration = 41, -- 动画帧率 30 f/s
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
	duration = 70,  -- 状态帧率 30 f/s
	frames = {
		[27] =  {
			attack_box = { 88, 88, 490, 220 },
			velocity_flipped = { 60, 65 },
			--att_pause = 100,
			interval = 12,
		},
		[65] = {},
	},
	anim = {
		name = 'Attack3',
		framecount = 70,
		duration = 70, -- 动画帧率 30 f/s
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
	duration = 75,  -- 状态帧率 30 f/s
	operation = {
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {0,0}, 
				--enemy_offset = {-120,1200},
				duration = 300,
				--attack_times = 1,
			},			
		},
		[10] = {
			fade = {10,0},
		},
		[60] = {
			fade = {10,255},
		},
		[61] = {
			anim = {
				name = 'Attack5',
				begin = 14,
				framecount = 30,
				duration = 15, -- 动画帧率 30 f/s
			},
		},
	},
	anim = {
		name = 'Attack5',
		framecount = 14,
		duration = 14, -- 动画帧率 30 f/s
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
		wudi = true,
	},
	duration = 40,  -- 状态帧率 30 f/s
	operation = {
		[15] = {
			fade = {6,0},
		},
		[20] = {
			velocity_flipped = {-880,0},
		},
		[23] = {
			velocity = {0,0},
		},
		[30] = {
			fade = {10,255},
		},
		[31] = {
			anim = {
				name = 'Attack5',
				begin = 15,
				framecount = 30,
				duration = 10, -- 动画帧率 30 f/s
			},
		},
	},
	anim = {
		name = 'Attack5',
		framecount = 14,
		duration = 30, -- 动画帧率 30 f/s
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
		wudi = true,
	},
	duration = 40,  -- 状态帧率 30 f/s
	operation = {
		[15] = {
			fade = {6,0},
		},
		[20] = {
			velocity_flipped = {1000,0},
		},
		[23] = {
			velocity = {0,0},
		},
		[29] = {
			face_target = true,
		},
		[30] = {
			fade = {10,255},
		},
		[31] = {
			anim = {
				name = 'Attack5',
				begin = 15,
				framecount = 30,
				duration = 10, -- 动画帧率 30 f/s
			},
		},
	},
	anim = {
		name = 'Attack5',
		framecount = 14,
		duration = 30, -- 动画帧率 30 f/s
		loop = 0,
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
	duration = 24,
	anim = {
		name = 'run',
		framecount = 24,
		duration = 24,
	},
}

idle = {
	enter_op = {
	},
	duration = 40,
	anim = {
		name = 'stand',
		framecount = 40,
		duration = 40,
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
		framecount = 37,
		duration = 60,
		loop = 0,
	},
}


