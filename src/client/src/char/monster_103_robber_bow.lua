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

plist = 'skeleton/monster_103_robber_bow/monster_103_robber_bow0.plist'
png = 'skeleton/monster_103_robber_bow/monster_103_robber_bow0.png'
json = 'skeleton/monster_103_robber_bow/monster_103_robber_bow.ExportJson'
name = 'monster_103_robber_bow' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_jian_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-32,0,65,165}
random_y_offset = true
anim_flipped = true
default_run_speed = 20


bullet = {

	plist = 'skeleton/guai02-j/Guai020.plist',
	png = 'skeleton/guai02-j/Guai020.png',
	json = 'skeleton/guai02-j/Guai02-j.ExportJson',
	name = 'Guai02-j', -- cocostudio project name
	zorder = ZBullet,
	
	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 90,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { 20, -10, 40, 10 },
				interval = 200,
			},
		},
		anim = {
			name = 'Stand',
		}
	},

	death = {
		enter_cond = {
			finish_attack={}
		},
	},

	state_order = {'death', 'idle', },
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
	duration = 21,  -- 状态帧率 30 f/s
	operation = {
		[18] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,82}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				fly_speed = 80,
				--dest_offset = {0, 60},   --瞄准敌人位置(平射弓箭不用填)
				is_follow = 0,				
			},
		},
	},
	anim = {
		[1] = {
			name = 'Attack1',
			framecount = 21,
			duration = 21, -- 动画帧率 30 f/s
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
	duration = 35,  -- 状态帧率 30 f/s
	operation = {
		[24] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,82}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				fly_speed = 80,
				--dest_offset = {0, 60},   --瞄准敌人位置(平射弓箭不用填)
				is_follow = false,
			},
		},
		[30] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,82}, 
				duration = 180,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				fly_speed = 80,
				--dest_offset = {0, 60},   --瞄准敌人位置(平射弓箭不用填)
				is_follow = false,	
			},
		},
	},
	anim = {
		[1] = {
			name = 'Attack2',
			framecount = 32,
			duration = 35, -- 动画帧率 30 f/s
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
		-- sound = role_sound.hit,
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
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Wound3',
		begin = 3,
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
		begin = 7,
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
	duration = 15,
	anim = {
		name = 'Run',
		framecount = 24,
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

	duration = 90,
	operation = {
		[45] = {
			fade = {45,0},
		},
	},
	anim = {
		name = 'Death',
		framecount = 15,
		duration = 15,
		loop = 0,
	},
}


