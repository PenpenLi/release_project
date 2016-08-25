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

plist = 'skeleton/boss_109_big_tree/boss_109_big_tree0.plist'
png = 'skeleton/boss_109_big_tree/boss_109_big_tree0.png'
json = 'skeleton/boss_109_big_tree/boss_109_big_tree.ExportJson'
name = 'boss_109_big_tree' -- cocostudio project name
zorder = ZBoss
boss = true

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-98,0,108,308}
anim_flipped = false
default_run_speed = 15

bullet = {
	
	json = 'skeleton/boss_109_big_tree_tx/boss_109_big_tree_tx.ExportJson',
	name = 'boss_109_big_tree_tx', -- cocostudio project name
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
		duration = 19,  -- 状态帧率 30 f/s
		frames = {
			[3] =  {
				attack_box = { -400, -30, 400, 30 },
				velocity_flipped = { 10, 180 },
				--att_pause = 100,
				interval = 200,
			},
			[10] = {},
		},
		anim = {
			name = 'Stand',
			framecount = 19,
			duration = 19,
		}
	},

	state_order = { 'idle', },

}

bullet2 = {
	
	json = 'skeleton/boss_109_big_tree_tx/boss_109_big_tree_tx.ExportJson',
	name = 'boss_109_big_tree_tx', -- cocostudio project name
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
		duration = 18,  -- 状态帧率 30 f/s
		frames = {
			[4] =  {
				attack_box = { -70, -60, 400, 60 },
				velocity_away = { 100, 120 },
				--att_pause = 100,
				interval = 200,
			},
			[7] = {},
		},
		anim = {
			name = 'Stand2',
			framecount = 18,
			duration = 18,
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
	duration = 24,  -- 状态帧率 30 f/s
	frames = {
		[20] =  {
			attack_box = { 50,0, 250, 250 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 50, 0 },
		},
		[23] = {},
	},	

	anim = {
			name = 'Attack2',
			framecount = 24,
			duration = 24, -- 动画帧率 30 f/s
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
	duration = 27,  -- 状态帧率 30 f/s
	frames = {
		[22] =  {
			attack_box = { -100, -50, 305, 150 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 50, 50 },
		},
		[26] = {},
	},	

	anim = {
			name = 'Attack1',
			framecount = 27,
			duration = 27, -- 动画帧率 30 f/s
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
	duration = 37,  -- 状态帧率 30 f/s
	operation = {
		[27] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {200,10}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[30] = {
			shake_scene = {1.5, 20, 30, 0, 0},	 -- 晃动屏幕 参数：duration, strength_x, strength_y, offset_x, offset_y
		},
	},
	anim = {
			name = 'Attack3',
			framecount = 37,
			duration = 37, -- 动画帧率 30 f/s
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
	duration = 44,  -- 状态帧率 30 f/s
	operation = {
		[25] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {100,150}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
	},
	anim = {
			name = 'Attack4',
			framecount = 44,
			duration = 44, -- 动画帧率 30 f/s
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

run = {
	enter_cond = {
		running_speed = {}, 
	},
	last_cond = {
		running_speed = {},
	},
	enter_op = {
	},
	duration = 31,
	anim = {
		name = 'run',
		framecount = 31,
		duration = 31,
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
		framecount = 24,
		duration = 60,
		loop = 0,
	},
}


