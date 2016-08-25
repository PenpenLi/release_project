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
--  flipped_x = true

local command	= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )

equip_conf = {
	-- 对应data.equip.lua的id
	weapon = 4,
	armor = 5,
	helmet = 6,
}

-- resource
json = 'skeleton/cike/cike.ExportJson'
name = 'cike' -- cocostudio project name

-- ejson = 'skeleton/cike/cike.ExportJson'
-- ename = 'cike' -- cocostudio project name
zorder = ZPlayer

--TODO:for preload
role_sound = {
	knife1	= 'sound/hero_knife_1.wav',
	knife2  = 'sound/hero_knife_2.wav',
	knife3	= 'sound/hero_knife_3.wav',
	knife4  = 'sound/hero_knife_4.wav',
	attack1	= 'sound/hero_attack_1.wav',
	attack2 = 'sound/hero_attack_2.wav', 
	attack3	= 'sound/hero_attack_3.wav',
	attack4 = 'sound/hero_attack_4.wav',
	walk 	= 'sound/hero_walk_1.wav',
	wound	= 'sound/hero_wound_1.wav',
	death	= 'sound/hero_death_1.wav',
	falling = 'sound/hero_fallingonground_1.wav',
	jump = 'sound/hero_jump_1.wav'
}

-- config
combat_conf = 1
default_hit_box = {-50,0,50,150}
default_run_speed = 80


idle = {
	enter_op = {
		velocity = {0,0},
		stick_ctrl = true,
	},
	duration = 30,
	anim = {
		[1] = {
			name = 'Stand',
			framecount = 40,
			duration = 30,
		},
		[2] = {
			name = 'Stand2',
			framecount = 40,
			duration = 30,
		},
	},
}

run = {
	enter_cond = {
		running = {},
	},
	last_cond = {
		running = {},
	},
	enter_op = {
		stick_ctrl = true,
		facing = 'move',
	},
	duration = 15,
	anim = {
		name = 'Run',
		framecount = 20,
		duration = 15,
	},
	operation = {
		[1] = {
			sound = role_sound.walk,
		},
		[7] = {
			sound = role_sound.walk,
		},
	},
}
attack = {
	enter_cond = {
		enemy_in_range = {},
	},
	last_cond = {
		enemy_in_range = {},
	},
	enter_op = {
		run_speed = -20,
		stick_ctrl = true,
		facing = 'auto',
		--gravity = false,
		
	},
	leave_op = {
		run_speed = 20,
		--gravity = true,
		--y_speed =0,
 	},
	duration = 46,  -- 状态帧率 30 f/s
	frames = {
		[4] =  {
			attack_box = { 0, 0, 150, 150 },
			att_pause = 2,
			velocity_flipped = { 0, 0 },
			mana_gain = 3,
			damage_factor = 0.3
		},
		
		[5] = {},
		[18] =  {
			attack_box = { 0, 0, 150, 150 },
			att_pause = 2,
			velocity_flipped = { 0, 0 },
			mana_gain = 3,
			damage_factor = 0.45
		},
		[19] = {},
		[31] =  {
			attack_box = { 0, 0, 150, 150 },
			att_pause = 2,
			velocity_flipped = { 0, 0 },
			mana_gain = 3,
			damage_factor = 0.55
		},
		[32] = {},
		[45] =  {
			attack_box = { 0, 0, 150, 150 },
			att_pause = 5,
			velocity_flipped = { 50, 140 },
			mana_gain = 3,
			damage_factor = 0.7
		},
		[46] = {},		
	},	
  
	anim = {
		name = 'Attack1',	
		framecount = 46,
		duration = 46, -- 动画帧率 30 f/s
	},
	operation = {
		[7] = {
				sound = role_sound.knife1,
				y_speed = 0,
		},
		[18] = {
				sound = role_sound.knife2,
				y_speed = 0,
		},
		[31] = {
				sound = role_sound.knife3,
				y_speed = 0,
		},
		[45] = {
				sound = role_sound.knife3,
				y_speed = 0,
		},
	},
}

hit = {
	enter_cond = {
		hitable={},
	},
	enter_op = {
		stick_ctrl = false,
		facing = 'move',
		sound = role_sound.wound,
	},
	operation = {
		[5]={
			--velocity = {0,0},
			x_speed = 0,
		},		
	},
	duration = 6,
	anim = {
		[1] = {
			name = "Wound",
			framecount = 12,
			duration = 6,
		},
		[2] = {
			name = "Wound2",
			framecount = 12,
			duration = 6,
		},
	},
}

hit_fly = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		stick_ctrl = false,
		facing = 'move',
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Wound3',
		framecount = 6,
		duration = 6,
		loop = 0,
	},
}

fly_hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		stick_ctrl = false,
		facing = 'move',
		-- sound = role_sound.hit,
	},
	leave_op = {
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Wound3',
		begin = 4,
		framecount = 9,
		duration = 6,
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
		stick_ctrl = false,
		facing = 'move',
		hit_box = nil,
		wudi = true,
		velocity = {0,0},
	},
	leave_op = {
	},
	duration = 20,
	anim = {
		name = 'Wound3',
		begin = 15,
		framecount = 20,
		duration = 6,
		loop = 0,
	},
}

falling = {
	enter_cond = { 
		falling={},
	},
	last_cond = {
		falling={},
	},
	enter_op = {
		stick_ctrl = true,
		facing = 'move',
	},
	leave_op ={
		sound = role_sound.falling,
	},
	duration = 500,
	anim = {
		name = 'JumpEnd',
		framecount = 9,
		duration = 15,
	},
}

double_jump = {
	enter_cond = {
		in_air = {},
		not_in_state = {'jump'},
		jump_count = 1,
	},
	command = command.touch_right,
	enter_op = {
		sound = role_sound.jump,
		-- y_speed = 200,
		jump_speed = 200,
		jump = true,
	},
}

rising = {
	enter_cond = { 
		rising = {},
	},
	last_cond = {
		rising = {},
	},
	enter_op = {
		stick_ctrl = true,
		facing = 'move',
	},
	duration = 500,
	anim = {
		name = 'JumpEnd',
		framecount = 9,
		duration = 15,
		loop = 0,
	},
}

jump = {
	enter_cond = {
		on_ground={},
		jump_count = 2,
	},
	command = command.touch_right,
	enter_op = {
		sound = role_sound.jump,
		-- y_speed = 220,
		jump_speed = 220,
		stick_ctrl = true,
		facing = 'move',
		jump = true,
	},
	duration = 14,
	anim = {
		name = 'Jump',
		framecount = 14,
		duration = 14,
		loop = 0,
	},
}

death = {
	enter_cond = {
		not_in_state = {'death' },
		hp_zero = {},
	},
	enter_op = {
		velocity = {0,0},
		wudi = true,
		clear_buffs = true,
		sound = role_sound.death,
	},
	leave_op = {
-- 		remove_obj = true,
	},
	duration = 5000,
	anim = {
		name = 'Death',
		framecount = 17,
		duration = 17,
		loop = 0,
	},
}