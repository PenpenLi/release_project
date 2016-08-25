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

json = 'skeleton/monster_404_kulou_mage/monster_404_kulou_mage.ExportJson'
name = 'monster_404_kulou_mage' -- cocostudio project name

role_sound = {
	attack 	= 'sound/monster_knife_1.wav',
	hit 	= 'sound/monster_hurt_1.wav',
	death	= 'sound/monster_death_1.wav',
}

default_hit_box = {-32,0,45,150}
random_y_offset = true
default_run_speed = 18

bullet = {
	
	json = 'skeleton/monster_404_kulou_mage_zidan/monster_404_kulou_mage_zidan.ExportJson',
	name = 'monster_404_kulou_mage_zidan', -- cocostudio project name
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
		duration = 150,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -6, -6, 6, 6 },
				interval = 200,
				velocity_flipped = {10,10},
			},
		},
		anim = {
			name = 'Stand',
			framecount = 32,
			duration = 32,
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
	
	json = 'skeleton/monster_404_kulou_mage_zidan/monster_404_kulou_mage_zidan.ExportJson',
	name = 'monster_404_kulou_mage_zidan', -- cocostudio project name
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
		duration = 67,  -- 状态帧率 30 f/s
		frames = {
			[30] =  {
				attack_box = { -70, -10, 70, 70 },
				interval = 10,
				velocity_flipped = {10,10},
			},
			[53] = {},
		},
		anim = {
			name = 'Stand2',
			framecount = 67,
			duration = 67,
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
	duration = 25,  -- 状态帧率 30 f/s
	operation = {
		[15] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {108,118}, 
				--enemy_offset = {0,0,},
				duration = 300,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				fly_speed = 10,
				dest_offset = {0, 80},   --瞄准敌人位置(平射弓箭不用填)
				is_follow = 2,
			},	
		},
	},
	anim = {
		name = 'Attack1',
		framecount = 25,
		duration = 25, -- 动画帧率 30 f/s
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
	duration = 55,  -- 状态帧率 30 f/s
	operation = {
		[25] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {350,0}, 
				--enemy_offset = {0,0},
				duration = 300,
				no_obstacle = true,
				gravity = false,
				ground = true,
			},	
		},
		[38] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet2',
				self_offset = {150,0}, 
				--enemy_offset = {0,0},
				duration = 300,
				no_obstacle = true,
				gravity = false,
				ground = true,
			},	
		},
	},
	anim = {
		name = 'Attack2',
		framecount = 55,
		duration = 55, -- 动画帧率 30 f/s
	},
}

state_order = battle_const.GroundMonsterDefaultStateOrder
---------------------------------------------------------------------------------

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
		--velocity = {0,0},
		-- sound = role_sound.hit,
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
		framecount = 22,
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
	duration = 23,
	anim = {
		name = 'Run',
		framecount = 23,
		duration = 23,
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
		framecount = 18,
		duration = 30,
		loop = 0,
	},
}


