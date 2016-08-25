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

json = 'skeleton/boss_205_thunderbird/boss_205_thunderbird.ExportJson'
name = 'boss_205_thunderbird' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-70,0,80,190}
anim_flipped = false
--default_run_speed = 50
default_fly_speed = 30
is_air_monster	= true
zorder = ZBoss
boss = true

bullet = {
	json = 'skeleton/boss_205_thunderbird_tx/boss_205_thunderbird_tx.ExportJson',
	name = 'boss_205_thunderbird_tx', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 0.7,
	scale_y = 0.7,

	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 48,  -- 状态帧率 30 f/s
		frames = {
			[38] =  {
				group_id = 1,
				attack_box = { -128, 152, -82, 490 },
				--velocity_flipped = { 10, 180 },
				--att_pause = 100,
				interval = 200,
				collider_shake = {1, 15, 15, 0, 0},
			},
			[41] =  {
				group_id = 1,
				attack_box = { -117, -12, 117, 12 },
				interval = 200,
			},
			[44] = {},
		},
		operation = {
			[36] = {
				anim = {
					name = 'Stand2',
					framecount = 12,
					duration = 12,
				},
			},
			[40] = {
				shake_scene = {1, 10, 15, 0, 0},	 -- 晃动屏幕 参数：duration, strength_x, strength_y, offset_x, offset_y
			},
		},
		anim = {
			name = 'Stand',
			framecount = 13,
			duration = 12,
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
		---- sound = role_sound.attack,
		velocity = {0,0},
		bati = true,
	},
	duration = 22,  -- 状态帧率 30 f/s
	frames = {
		[12] =  {
			attack_box = { 0,-80, 225, 230 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 50, 0 },
		},
		[16] = {},
	},	

	anim = {
			name = 'Attack2',
			framecount = 22,
			duration = 22, -- 动画帧率 30 f/s
	},
}

attack2 = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		---- sound = role_sound.attack,
		velocity = {0,0},
		bati = true,
	},
	leave_op = {
		velocity = {0,0},
	},
	duration = 45,  -- 状态帧率 30 f/s
	operation = {
		[1] ={
			velocity_flipped = {-70,90},
		},
		[20]={
			velocity_flipped = {200,-180},
		},
		[35]={
			velocity_flipped = {150,120},
		},
	},
	frames = {
		[20] =  {
			attack_box ={ -100,30, 135, 150 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = { 50, 50 },
			collider_shake = {1, 15, 15, 0, 0},
		},
	},	

	anim = {
			name = 'Attack1',
			framecount = 11,
			duration = 11, -- 动画帧率 30 f/s
	},
}

skill = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		---- sound = role_sound.attack,
		velocity = {0,0},
		bati = true,
	},
	duration = 55,  -- 状态帧率 30 f/s
	operation = {
		[25] = {
			---- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {100,500}, 
				duration = 300,
				--attack_times = 1,
				gravity = false,
				ground = true,
			},			
		},
		[35] = {
			---- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {350,500}, 
				duration = 300,
				--attack_times = 1,
				gravity = false,
				ground = true,
			},			
		},
		[45] = {
			---- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {600,500}, 
				duration = 300,
				--attack_times = 1,
				gravity = false,
				ground = true,
			},			
		},
	},
	anim = {
			name = 'Attack3',
			framecount = 37,
			duration = 55, -- 动画帧率 30 f/s
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
	duration = 21,
	anim = {
		name = 'Run',
		framecount = 21,
		duration = 21,
	},
}

idle = {
	enter_op = {
	},
	duration = 21,
	anim = {
		name = 'Stand',
		framecount = 21,
		duration = 21,
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
		clear_goto_state = true, --设置为无敌
		sound = role_sound.death, --播放死亡声音
		gravity = true,
		obstacle = true,
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
		framecount = 25,
		duration = 50,
		loop = 0,
	},
}


