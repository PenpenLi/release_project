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

json = 'skeleton/monster_304_minotaur_mage/monster_304_minotaur_mage.ExportJson'
name = 'monster_304_minotaur_mage' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_jian_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-38,20,86,175}
random_y_offset = true
anim_flipped = false
default_run_speed = 12

bullet = {
	
	json = 'skeleton/monster_304_minotaur_mage_zidan/monster_304_minotaur_mage_zidan.ExportJson',
	name = 'monster_304_minotaur_mage_zidan', -- cocostudio project name
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
		duration = 180,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -25, -25, 16, 16 },
				interval = 200,
			},
		},
		anim = {
			name = 'Stand1',
			framecount = 19,
			duration = 19,
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
	
	json = 'skeleton/monster_304_minotaur_mage_zidan/monster_304_minotaur_mage_zidan.ExportJson',
	name = 'monster_304_minotaur_mage_zidan', -- cocostudio project name
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
		duration = 55,  -- 状态帧率 30 f/s
		frames = {
			[41] =  {
				attack_box = { -85, -85, 80, 80 },
				interval = 200,
			},
			[52] = {},
		},
		anim = {
			name = 'Stand2',
			framecount = 55,
			duration = 55,
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
	duration = 33,  -- 状态帧率 30 f/s 60
	operation = {
		[18] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {180,120}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = false,

				gravity = false,
				all_angle = false,
				fly_speed = 60,
				--dest_offset = {0, 60},   --瞄准敌人位置(平射弓箭不用填)
				is_follow = 0,
			},
		},
	},
	anim = {
		[1] = {
			name = 'Attack1',
			framecount = 33,
			duration = 33, -- 动画帧率 30 f/s
		},
	},
}

attack2 = {
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
	duration = 56,  -- 状态帧率 30 f/s 60
	operation = {
		[18] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				--self_offset = {100,80}, 
				enemy_offset = {-45,88},
				duration = 180,
				attack_times = 1,
				no_obstacle = false,

				gravity = false,	
			},
		},
		[32] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				--self_offset = {100,80}, 
				enemy_offset = {38,128},
				duration = 180,
				attack_times = 1,
				no_obstacle = false,

				gravity = false,	
			},
		},
	},
	anim = {
		[1] = {
			name = 'Attack2',
			framecount = 56,
			duration = 56, -- 动画帧率 30 f/s
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
		-- sound = role_sound.hit,
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
		-- sound = role_sound.hit,
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
		begin = 10,
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
	duration = 29,
	anim = {
		name = 'Run',
		framecount = 29,
		duration = 29,
	},
}

idle = {
	enter_op = {
	},
	duration = 28,
	anim = {
		name = 'Stand',
		framecount = 28,
		duration = 28,
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
		[70] = {
			fade = {30,0},
		},
	},
	anim = {
		name = 'Death',
		framecount = 23,
		duration = 23,
		loop = 0,
	},
}


