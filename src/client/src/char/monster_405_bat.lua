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

json = 'skeleton/monster_405_bat/monster_405_bat.ExportJson'
name = 'monster_405_bat' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-25,35,70,155}
default_fly_speed = 30
is_air_monster	= true

bullet = {
	json = 'skeleton/monster_405_bat_zidan/monster_405_bat_zidan.ExportJson',
	name = 'monster_405_bat_zidan', -- cocostudio project name
	zorder = ZBullet,

	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
			speed_reverse = -1,
		},
		leave_op = {
			--remove_obj = true,
		},
		duration = 660,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				group_id = 1,
				attack_box = { -80, -30, 40, 30 },
				--velocity_flipped = { 10, 180 },
				--att_pause = 100,
				interval = 60,
			},
		},
		anim = {
			name = 'Stand',
			framecount = 66,
			duration = 66,
		}
	},

	state_order = {'idle', },

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
	duration = 20,  -- 状态帧率 30 f/s
	frames = {
		[11] =  {
			attack_box = { 0,-10, 215, 90 },
			att_pause = 3,
			interval = 200,
			velocity_flipped = { 20, 30 },
		},
		[15] = {},
	},	

	anim = {
			name = 'Attack1',
			framecount = 20,
			duration = 20, -- 动画帧率 30 f/s
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
	duration = 21,  -- 状态帧率 30 f/s
	operation = {
		[20] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {20,60}, 
				--enemy_offset = {0,0,},
				duration = 660,
				--attack_times = 1,
				no_obstacle = false,

				gravity = false,
				all_angle = true,
				fly_speed = 50,
				dest_offset = {0, 70},   --瞄准敌人位置(平射弓箭不用填)
				is_follow = 0,
			},	
		},
	},
	anim = {
			name = 'Attack2',
			framecount = 21,
			duration = 21, -- 动画帧率 30 f/s
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
			name = "Wound1",
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
	duration = 32,
	anim = {
		name = 'Run',
		framecount = 32,
		duration = 32,
	},
}

idle = {
	enter_op = {
	},
	duration = 32,
	anim = {
		name = 'stand',
		framecount = 32,
		duration = 32,
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
		--sound = role_sound.death, --播放死亡声音
		velocity = {0,0},
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 30,
	anim = {
		name = 'Death2',
		framecount = 21,
		duration = 30,
		loop = 0,
	},
}


