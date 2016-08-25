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

json = 'skeleton/boss_305_juren/boss_305_juren.ExportJson'
name = 'boss_305_juren' -- cocostudio project name
zorder = ZBoss
bgjson = 'skeleton/boss_305_juren_beijing/boss_305_juren_beijing.ExportJson'
bgname = 'boss_305_juren_beijing' -- cocostudio project name
bgzorder = ZMonsterBG
boss = true
shadow = false

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-80,220,80,400}
anim_flipped = false
default_run_speed = 0
no_flipped = true --禁止面向目标，用于固定怪物
--gravity = false

bullet = {
	
	json = 'skeleton/boss_305_juren_tx/boss_305_juren_tx.ExportJson',
	name = 'boss_305_juren_tx', -- cocostudio project name
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
			[3] =  {
				attack_box = { -290, -30, 290, 100 },
				velocity_away = { 10, 280 },
				--att_pause = 100,
				interval = 200,
			},
			[5] = {},
		},
		operation = {
			[2] = {
				shake_scene = {2, 20, 30, 0, 0},	 -- 晃动屏幕 参数：duration, strength_x, strength_y, offset_x, offset_y
			},
		},
		anim = {
			name = 'Stand2',
			framecount = 18,
			duration = 18,
		}
	},

	state_order = { 'idle', },

}

bullet2 = {
	
	json = 'skeleton/boss_305_juren_tx/boss_305_juren_tx.ExportJson',
	name = 'boss_305_juren_tx', -- cocostudio project name
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
			[1] =  {
				group_id = 1,
				attack_box = { -380, -20, 380, 100 },
				velocity_away = { 10, 280 },
				--att_pause = 100,
				interval = 200,
			},
			[8] = {
				group_id = 1,
				attack_box = { -80, 0, 80, 550 },
				velocity_away = { 10, 280 },
				--att_pause = 100,
				interval = 200,
			},
			[13] = {},
		},
		operation = {
			[1] = {
				shake_scene = {3, 30, 50, 0, 0},	 -- 晃动屏幕 参数：duration, strength_x, strength_y, offset_x, offset_y
			},
		},
		anim = {
			name = 'Stand3',
			framecount = 19,
			duration = 19,
		}
	},

	state_order = { 'idle', },

}

bullet3 = {
	
	json = 'skeleton/boss_305_juren_tx/boss_305_juren_tx.ExportJson',
	name = 'boss_305_juren_tx', -- cocostudio project name
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
		duration = 60,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -190, 0, 230, 150 },
				--velocity_flipped = { 100, 120 },
				--att_pause = 100,
				interval = 28,
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
	duration = 140,  --33 + 13*7 +16
	operation = {
		[31] = {
			hit_box = {{-120,210,50,385}, {-425,0,-280,180}},
		},
		[32] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {-350,0}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[34] = {
			anim = {
				name = 'Attack1buffer',
				framecount = 13,
				duration = 13, -- 动画帧率 30 f/s
			},
		},
		[124] = {
			hit_box = {-80,220,80,400},
		},
		[125] = {
			anim = {
				name = 'Attack1and',
				framecount = 16,
				duration = 16, -- 动画帧率 30 f/s
			},
		},	
	},
	anim = {
			name = 'Attack1',
			framecount = 33,
			duration = 33, -- 动画帧率 30 f/s
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
	duration = 145,  --35 + 13*7 +19
	operation = {
		[32] = {
			hit_box = {{-25,210,150,385}, {295,0,435,165}},
		},
		[33] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {365,0}, 
				--enemy_offset = {0,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[34] = {
			anim = {
				name = 'Attack2buffer',
				framecount = 13,
				duration = 13, -- 动画帧率 30 f/s
			},
		},
		[124] = {
			hit_box = {-80,220,80,400},
		},
		[125] = {
			anim = {
				name = 'Attack2and',
				framecount = 19,
				duration = 19, -- 动画帧率 30 f/s
			},
		},	
	},
	anim = {
			name = 'Attack2',
			framecount = 35,
			duration = 35, -- 动画帧率 30 f/s
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
	duration = 137,  --35 + 13*7 +11
	operation = {
		[32] = {
			hit_box = {{-80,210,85,385}, {-165,0,188,160}},
		},
		[33] = {
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
		[34] = {
			anim = {
				name = 'Attack3buffer',
				framecount = 13,
				duration = 13, -- 动画帧率 30 f/s
			},
		},
		[124] = {
			hit_box = {-80,220,80,400},
		},
		[125] = {
			anim = {
				name = 'Attack3and',
				framecount = 11,
				duration = 11, -- 动画帧率 30 f/s
			},
		},	
	},
	anim = {
			name = 'Attack3',
			framecount = 35,
			duration = 35, -- 动画帧率 30 f/s
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
	duration = 124,  -- 状态帧率 30 f/s
	operation = {
		[35] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {650,110}, 
				--enemy_offset = {350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[36] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {650,-20}, 
				--enemy_offset = {350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[50] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {298,-20}, 
				--enemy_offset = {350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[70] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {-50,-20}, 
				--enemy_offset = {350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[90] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {-410,-20}, 
				--enemy_offset = {350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
	},
	anim = {
			name = 'Attack4',
			framecount = 124,
			duration = 124, -- 动画帧率 30 f/s
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
	duration = 120,  -- 状态帧率 30 f/s
	operation = {
		[36] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {-650,110}, 
				--enemy_offset = {-350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[37] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {-650,-20}, 
				--enemy_offset = {-350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[53] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {-310,-20}, 
				--enemy_offset = {-350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[75] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {-30,-20}, 
				--enemy_offset = {-350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},
		[93] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet3',
				self_offset = {370,-20}, 
				--enemy_offset = {-350,0,},
				duration = 300,
				--attack_times = 1,
				gravity = false,
			},			
		},	
	},
	anim = {
			name = 'Attack5',
			framecount = 120,
			duration = 120, -- 动画帧率 30 f/s
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
		bati = true,
	},
	leave_op = {
	},
	duration = 52,
	anim = {
		name = "Stand",
		framecount = 52,
		duration = 52,
	},
}

idle = {
	enter_op = {
		bati = true,
	},
	duration = 52,
	anim = {
		name = 'Stand',
		framecount = 52,
		duration = 52,
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
		--sound = role_sound.death,
		velocity = {0,0},
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 210,
	anim = {
		name = 'Death',
		framecount = 63,
		duration = 63,
		loop = 0,
	},
}


