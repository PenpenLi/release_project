

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 = {
	
	json = 'skeleton/boss_307_robot_tx/boss_307_robot_tx.ExportJson',
	name = 'boss_307_robot_tx',
	zorder = ZBullet,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 35,  -- 状态帧率 30 f/s
		operation = {
			[1] = {
				velocity_flipped={1000,0},
			},
			[3] = {
				velocity = {0,0},
			},
			[5] = {
				anim = {
					name = 'Stand2',
					framecount = 31,
					duration = 31, -- 动画帧率 30 f/s
				},
			},
		},
		frames = {
			[5] =  {
				attack_box = { -170, -36, 225, 88 },
				velocity_away = { -10, 35 },
				--att_pause = 100,
				interval = 5,
			},
		},
		anim = {
			name = 'Stand1',
			framecount = 10,
			duration = 4,
		}
	},

	state_order = { 'idle', },
	
}
bullet_2={}
bullet_3={}
bullet_4={}
bullet_5={
	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 66,  -- 状态帧率 30 f/s
		operation = {
			[1] = {
				velocity_flipped={1000,0},
			},
			[3] = {
				velocity = {0,0},
			},
			[5] = {
				anim = {
					name = 'Stand2',
					framecount = 31,
					duration = 31, -- 动画帧率 30 f/s
				},
			},
		},
		frames = {
			[5] =  {
				attack_box = { -170, -36, 225, 88 },
				velocity_away = { -10, 35 },
				--att_pause = 100,
				interval = 5,
			},
		},
		anim = {
			name = 'Stand1',
			framecount = 10,
			duration = 4,
		}
	},
}
----------------------------------子弹分割线----------------------------------
star_1={
	enter_cond = {
		--on_ground = {},
	},
	last_cond = {
	},
	enter_op = {
		sound = role_sound.sound,
		stick_ctrl = false,
		velocity = {0, 0},
		bati = true,
	},
	leave_op = {
		velocity = {0,0},
	},
	duration = 12,
	anim = {
		name = 'Aoyi4',
		framecount = 22,
		duration = 12,
		loop = 0,
	},
	operation = {
		[5] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet',
				self_offset = { 0 ,100}, 
				--enemy_offset = {0,0,},
				gravity = false,
				inherit_attr = true,
			},
		},
	},
}
star_2={}
star_3={}
star_4={}
star_5={}

