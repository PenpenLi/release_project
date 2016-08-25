--[[
enter_cond = {}, --状态进入条件 条件之间为与的关系
last_cond = {}, --状态持续条件 条件之间为与的关系
command = nil, --进入状态所需按键指令
skill1 => slide_left
skill2 => slide_right
skill3 => slide_up
skill4 => slide_down
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

plist = 'skeleton/bossA/bossA0.plist'
png = 'skeleton/bossA/bossA0.png'
json = 'skeleton/bossA/bossA.ExportJson'
name = 'bossA' -- cocostudio project name
zorder = ZBoss

role_sound = {
	walk 	= 'sound/boss_walk_1.wav',
	attack 	= 'sound/boss_attack_1.wav',
	skill	= 'sound/boss_skill_1.wav',
	death	= 'sound/boss_death_1.wav',
	ougi = 'sound/boss_skill_2.wav',
}

combat_conf = 5
default_hit_box = {-80,0,80,230}
anim_flipped = true
default_flipped = true
default_run_speed = 60

boss = true
show_damage_data = true

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
	},
	leave_op = {
		velocity = {0, 0},
	},
	duration = 10,
	anim = {
		name = "Wound",
		framecount = 15,
		duration = 15,
	},
}

attack = {
	enter_cond = {
	},
	last_cond = {
	},
    command = command.touch_right,
	enter_op = {
		auto_facing = true,
	},
	duration = 22,  -- 状态帧率 60 f/s
	frames = {
		[10] =  {
			attack_box = { 0, 40, 200, 250 },
			att_pause = 3,
			-- impulse = { 0, 150 },
		},
		[14] = {},
		interval = 222,
		hit_state = hero_hit,
	},
	operation = {
		[20] = {
			sound = role_sound.attack,
		},
	},
	anim = {
		name = 'Attack1',	
		framecount = 22,
		duration = 22, -- 动画帧率 30 f/s
	},
}

run = {	
	enter_cond = {
		running_speed = {},
	},
	duration = 40,
	anim = {
		name = 'run',
		framecount = 40,
		duration = 20,
	},
	operation = {
		[1] = {
			sound = role_sound.walk,
		},
		[10] = {
			sound = role_sound.walk,
		},
		[20] = {
			sound = role_sound.walk,
		},
		[30] = {
			sound = role_sound.walk,
		},
	},
}

idle = {
	enter_op = {	
		velocity = {0, 0},
	},
	duration = 144,
 	anim = {
 		name = 'stand',
 		framecount = 72,
 		duration = 144,
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
		velocity = {0, 0},
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 90,
	anim = {
		name = 'Death',
		framecount = 18,
		duration = 18,
		loop = 0,
	},
}

ougi = {                         -- 这个是奥义	
	enter_cond = {
		ai_control = {},
	},
	last_cond = {
	},
	enter_op = {
		sound = role_sound.ougi,
		wudi = true,
		velocity = {150, 150},
		create_obj = {
			conf_id = 6,
			num = 1,
			enemy_offset = {0, 0},
			limit = 2,
		},
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Attack1',
		framecount = 5,
		duration = 5,
		loop = 0,
	},
	operation = {
		[10] = {
			velocity = {0, 0},
			create_obj = {
				conf_id = 2,
				num = 1,
				enemy_offset = {-200, 0},
				limit = 2,
			},
		},
		[11] = {
			velocity = {0, 0},
			create_obj = {
				conf_id = 3,
				num = 1,
				enemy_offset = {-400, 0},
				limit = 2,
			},
		},
	},
}


skill1 = {                          --招黑水,带预发招动作
	enter_cond = {
		ai_control = {},
	},
	last_cond = {
	},
	enter_op = {
		sound = role_sound.skill,
		velocity = {0, 0},
	},
	duration = 40,
	anim = {
		name = 'Attack1',
		framecount = 5,
		duration = 5,
		loop = 0,
	},
	operation = {
		[30] = {
			velocity = {0, 0},
			create_obj = {
				conf_id = 6,
				num = 1,
				-- enemy_offset = {0,0},
				scene_offset = {'player', 'self'},
				limit = 2,
			},
		},
	},
}


skill2 = {                               --招近战小怪,带预发招动作,小怪全挂之前保持无敌
	enter_cond = {
		ai_control = {},
	},
	last_cond = {
	},
	enter_op = {
		sound = role_sound.skill,
		wudi = true,
		velocity = {0, 200},
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Attack1',
		framecount = 5,
		duration = 5,
		loop = 0,
	},
	operation = {
		[10] = {
			velocity = {0, 0},
			create_obj = {
				conf_id = 2,
				num = 1,
				scene_offset = {1000, 700},
				limit = 2,
			},
		},
		[11] = {
			velocity = {0, 0},
			create_obj = {
				conf_id = 2,
				num = 1,
				scene_offset = {1200, 700},
				limit = 2,
			},
		},
	},
}

skill3 = {                               --招远程小怪,带预发招动作,小怪全挂之前保持无敌
	enter_cond = {
		ai_control = {},
	},
	last_cond = {
	},
	enter_op = {
		sound = role_sound.skill,
		wudi = true,
		velocity = {0, 200},
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Attack1',
		framecount = 5,
		duration = 5,
		loop = 0,
	},
	operation = {
		[10] = {
			velocity = {0, 0},
			create_obj = {
				conf_id = 3,
				num = 1,
				enemy_offset = {-200, 0},
				limit = 2,
			},
		},
		[11] = {
			velocity = {0, 0},
			create_obj = {
				conf_id = 3,
				num = 1,
				enemy_offset = {-500, 0},
				limit = 2,
			},
		},
	},
}

skill4 = {                               --分身术，生成一个满血boss
	command = command.slide_down,
	enter_op = {
		auto_facing = true,
		velocity = {50, 0},
	},
	leave_op = {
		create_obj = {
			conf_id = 1,
			num = 1,
			enemy_offset = {200, 0},
			limit = 1,
		},
	},
	duration = 22,  -- 状态帧率 60 f/s
	anim = {
		name = 'Attack1',	
		framecount = 22,
		duration = 22, -- 动画帧率 30 f/s
	},
}


state_order = {'death', 'ougi', 'skill1', 'skill2', 'skill3', 'skill4','attack', 'hit', 'run','idle',}
