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

json = 'skeleton/boss_106_storm/boss_106_storm.ExportJson'
name = 'boss_106_storm' -- cocostudio project name
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-115,50,95,310}
anim_flipped = false
default_run_speed = 15
show_damage_data = true

bullet = {
	
	json = 'skeleton/boss_106_storm_tx/boss_106_storm_tx.ExportJson',
	name = 'boss_106_storm_tx', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 0.8,
	scale_y = 0.9,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 56,  -- 状态帧率 30 f/s
		frames = {
			[36] =  {
				attack_box = { -130, 0, -55, 427 },
				interval = 200,
			},
			[40] = {},
			[41] =  {
				attack_box = { 65, -20, 150, 399 },
				interval = 200,
			},
			[44] = {},
			[45] =  {
				attack_box = { -20, 56, 50, 438 },
				interval = 200,
			},
			[46] = {},
		},
		anim = {
			name = 'Stand',
			framecount = 56,
			duration = 56,
		}
	},

	state_order = { 'idle', },

}

bullet2 = {
	
	json = 'skeleton/boss_106_storm_tx/boss_106_storm_tx.ExportJson',
	name = 'boss_106_storm_tx', -- cocostudio project name
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
		duration = 59,  -- 状态帧率 30 f/s
		frames = {
			[40] =  {
				attack_box = { -280, 0, 280, 480 },
				velocity_away = { 90, 190 },
				--att_pause = 100,
				interval = 200,
				collider_shake = {1.5, 25, 15, 0, 0},
			},
			[50] = {},
		},
		anim = {
			name = 'Stand02',
			framecount = 59,
			duration = 59,
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
	duration = 34,  -- 状态帧率 30 f/s
	frames = {
		[27] =  {
			attack_box = { 60,0, 330, 290 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 100, 0 },
		},
		[30] = {},
	},	

	anim = {
			name = 'Attack1',
			framecount = 34,
			duration = 34, -- 动画帧率 30 f/s
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
	duration = 44,  -- 状态帧率 30 f/s
	frames = {
		[31] =  {
			attack_box = { 80, 0, 580, 280 },
			--att_pause = 6,
			interval = 200,
			velocity_flipped = { 300, 0 },
			collider_shake = {1, 15, 15, 0, 0},
		},
		[37] = {},
	},	

	anim = {
			name = 'Attack2',
			framecount = 44,
			duration = 44, -- 动画帧率 30 f/s
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
	duration = 45,  -- 状态帧率 30 f/s
	operation = {
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				--self_offset = {360,0}, 
				enemy_offset = {130,20,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				ground = true,
			},			
		},
		[2] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				--self_offset = {360,0}, 
				enemy_offset = {-130,20,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
				ground = true,
			},			
		},
	},
	anim = {
			name = 'Attack3',
			framecount = 45,
			duration = 45, -- 动画帧率 30 f/s
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
	duration = 45,  -- 状态帧率 30 f/s
	operation = {
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {0,0}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
	},
	anim = {
			name = 'Attack3',
			framecount = 45,
			duration = 45, -- 动画帧率 30 f/s
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
		--velocity = {0,0},
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = 15,
	operation = {
		[2] = {
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
	duration = 15,
	anim = {
		name = 'Run',
		framecount = 15,
		duration = 15,
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
		framecount = 19,
		duration = 60,
		loop = 0,
	},
}


