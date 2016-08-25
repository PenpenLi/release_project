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

plist = 'skeleton/guai02/Guai020.plist'
png = 'skeleton/guai02/Guai020.png'
json = 'skeleton/guai02/Guai02.ExportJson'
name = 'Guai02' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_jian_1.wav',
	death	= 'sound/monster_death_1.wav',
}

combat_conf = 3
default_hit_box = {-40,0,50,120}
default_flipped = true
random_y_offset = true

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
	},
	leave_op = {
	},
	duration = 10,
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

attack = {
	enter_cond = {
		on_ground = {},
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		create_obj = {
			conf_id = 4,
			self_offset = {0,72}, 
			duration = 150,
			attack_times = 1,
			velocity = {80, -1},
		-- sound = role_sound.attack,
		},
	},
	duration = 14,  -- 状态帧率 60 f/s

	anim = {
		[1] = {
			name = 'Attack1',
			framecount = 14,
			duration = 14, -- 动画帧率 30 f/s
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
	duration = 20,
	anim = {
		name = 'Run',
		framecount = 20,
		duration = 20,
	},
}

idle = {
	enter_op = {
	},
	duration = 40,
	anim = {
		name = 'Stand',
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
		sound = role_sound.death,
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


state_order = {'death', 'attack', 'hit', 'run', 'idle', }
