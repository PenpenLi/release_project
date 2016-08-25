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

json = 'skeleton/boss_601_pitlord/boss_601_pitlord.ExportJson'
name = 'boss_601_pitlord' -- cocostudio project name
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-107,0,97,330}
anim_flipped = false
default_run_speed = 22

bullet_creator = {

	idle = {
		leave_op = {
			remove_obj = true,
		},
		duration = 80, 
		operation = {
			[35] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {350,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[45] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {500,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[55] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {650,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[65] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {800,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[75] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {950,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
		},
	},

	state_order = {'idle', },
}

bullet = {
	
	json = 'skeleton/boss_601_pitlord_tx/boss_601_pitlord_tx.ExportJson',
	name = 'boss_601_pitlord_tx',
	zorder = ZBoss,

	--scale_x = 0.5,
	--scale_y = 0.5,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 25, 
		operation = {
			[12] = {
				shake_scene = {1, 10, 15, 0, 0},	
			},
		},
		frames = {
			[9] =  {
				attack_box = { -50, 0, 50, 550 },
				velocity_flipped = { 80, 130 },
				--att_pause = 100,
				interval = 200,
			},
			[20] = {},
		},
		anim = {
			name = 'Stand',
			framecount = 25,
			duration = 25,
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
	duration = 25,  
	frames = {
		[16] =  {
			attack_box = { 150, -30, 425, 130 },
			att_pause = 3,
			interval = 200,
			velocity_flipped = { 120, 30 },
		},
		[19] = {},
	},	
	anim = {
		name = 'Attack1',
		framecount = 25,
		duration = 25,
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
	duration = 43, 
	frames = {
		[20] =  {
			attack_box = { -30, 0, 320, 272 },
			att_pause = 3,
			interval = 200,
			velocity_flipped = { 260, 160 },
		},
		[28] = {},
	},	
	anim = {
		name = 'Attack4',
		framecount = 43,
		duration = 43,
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
	duration = 73, 
	frames = {
		[30] = {
			group_id = 1,
			attack_box = { -310, -35, 275, 100 },
			--att_pause = 3,
			interval = 200,
			velocity_flipped = { 20, 200 },
		},
		[31] = {
			group_id = 1,
			attack_box = { 70, 0, 290, 410 },
			--att_pause = 3,
			interval = 200,
			velocity_flipped = { 20, 200 },
		},
		[33] = {},
		[48] = {
			group_id = 2,
			attack_box = { -330, -10, 550, 210 },
			--att_pause = 5,
			interval = 200,
			velocity_flipped = { 220, 150 },
		},
		[51] = {
			group_id = 2,
			attack_box = { 0, 0, 520, 250 },
			--att_pause = 5,
			interval = 200,
			velocity_flipped = { 220, 150 },
		},
		[58] = {},
	},	
	anim = {
		name = 'Attack3',
		framecount = 73,
		duration = 73, 
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
	duration = 67, 
	operation = {
		[39] = {
			shake_scene = {1.5, 20, 30, 0, 0},	
		},
	},
	frames = {
		[40] =  {
			group_id = 1,
			attack_box = { 70, 0, 350, 200 },
			--att_pause = 5,
			interval = 3,
			velocity_flipped = { 120, 120 },
		},
		[44] =  {
			group_id = 1,
			attack_box = { 350, 0, 650, 256 },
			--att_pause = 5,
			interval = 3,
			velocity_flipped = { 120, 120 },
		},
		[47] =  {
			group_id = 1,
			attack_box = { 650, 0, 850, 210 },
			--att_pause = 5,
			interval = 3,
			velocity_flipped = { 120, 120 },
		},
		[50] = {},
	},	
	anim = {
		name = 'Attack2',
		framecount = 67,
		duration = 67,
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
	duration = 55,  
	operation = {
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet_creator',
				self_offset = {0,0}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				no_obstacle = true,
			},			
		},
	},
	anim = {
		name = 'Attack5',
		framecount = 55,
		duration = 55,
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
		framecount = 7,
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
		begin = 2,
		framecount = 7,
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
		goto_state = 'attack2',
	},
	duration = 30,
	anim = {
		name = 'Wound3',
		begin = 7,
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
	duration = 35,
	anim = {
		name = 'Run',
		framecount = 35,
		duration = 35,
	},
}

idle = {
	enter_op = {
	},
	duration = 53,
	anim = {
		name = 'Stand',
		framecount = 53,
		duration = 53,
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
		framecount = 59,
		duration = 59,
		loop = 0,
	},
}
