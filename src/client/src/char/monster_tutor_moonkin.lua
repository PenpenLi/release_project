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

plist = 'skeleton/monster_204_moonkin/monster_204_moonkin0.plist'
png = 'skeleton/monster_204_moonkin/monster_204_moonkin0.png'
json = 'skeleton/monster_204_moonkin/monster_204_moonkin.ExportJson'
name = 'monster_204_moonkin' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-70,0,65,200}
anim_flipped = false
default_run_speed = 30
boss = false
zorder = ZBoss

bullet = {
	
	json = 'skeleton/monster_204_moonkin_zidan/monster_204_moonkin_zidan.ExportJson',
	name = 'monster_204_moonkin_zidan', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 1,
	scale_y = 1,

	idle = {
		enter_cond = {
		},
		enter_op = {
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 60,  -- 状态帧率 30 f/s
		operation = {
			[15]={
				velocity_flipped={100,0},
			},
			[50]={
				fade = {10,100},
			},
		},
		frames = {
			[1] =  {
				attack_box = { -40, 0, 40, 130 },
				interval = 200,
			},
		},
		anim = {
			name = 'Stand',
			framecount = 5,
			duration = 5,
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
		velocity = {0,0},
		bati = true,
	},
	duration = 29,  -- 状态帧率 30 f/s
	frames = {
		[18] =  {
			attack_box = { 80, 50, 200, 175 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 20, 10 },
		},
		[27] = {},
	},	
	anim = {
		name = 'Attack1',
		framecount = 29,
		duration = 29, -- 动画帧率 30 f/s
	},
}

attack2 = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		velocity = {0,0},
		bati = true,
	},
	duration = 28,  -- 状态帧率 30 f/s
	frames = {
		[21] =  {
			attack_box = { 98, 20, 220, 250 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 20, 10 },
		},
		[26] = {},
	},	

	anim = {
			name = 'Attack2',
			framecount = 28,
			duration = 28, -- 动画帧率 30 f/s
	},
}

local fazidan ={
	create_obj={
		conf_id = 'bullet',
		self_offset = {0,10}, 
		duration = 180,
		attack_times = 1,
		no_obstacle = true,

		gravity = false,
		all_angle = false,
		fly_speed = 0,
		--dest_offset = {0, 60},   --瞄准敌人位置(平射弓箭不用填)
		is_follow = 0,			
	},
}

skill = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		velocity = {0,0},
		bati = true,
	},
	duration = 32,  -- 状态帧率 30 f/s
	operation = {
		[15] = fazidan,
		[25] = fazidan,
	},
	anim = {
			name = 'Attack3',
			framecount = 32,
			duration = 32, -- 动画帧率 30 f/s
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
	},
	leave_op = {
	},
	duration = battle_const.InfiniteTime,
	anim = {
		name = 'Wound3',
		begin = 3,
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
		hit_box = nil,
		wudi = true,
		velocity = {0,0},
	},
	leave_op = {
		face_target = true,
		--goto_state = 'skill',
	},
	duration = 30,
	anim = {
		name = 'Wound3',
		begin = 10,
		framecount = 18,
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
	duration = 18,
	anim = {
		name = 'Run',
		framecount = 18,
		duration = 18,
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
		framecount = 20,
		duration = 20,
		loop = 0,
	},
}


