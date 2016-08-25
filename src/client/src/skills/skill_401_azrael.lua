

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 = {

	json = 'skeleton/boss_401_azrael_tx/boss_401_azrael_tx.ExportJson',
	name = 'boss_401_azrael_tx',
	zorder = ZBoss,
	anim_flipped = true,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 46,  -- 状态帧率 30 f/s
		operation = {
			[30] = {
				shake_scene = {1, 7, 12, 0, 0},
			},
		},
		frames = {
			[29] =  {
				attack_box = { 250, 0, 428, 350 },
				velocity_flipped = { 30, 180 },
				att_pause = 10,
				interval = 200,
			},
			[32] = {},
		},
		anim = {
			name = 'Stand2',
			begin = 18,
			framecount = 63,
			duration = 46,
		}
	},

	state_order = {'idle', },
	
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
		duration = 46,  -- 状态帧率 30 f/s
		operation = {
			[30] = {
				shake_scene = {1, 7, 12, 0, 0},
			},
		},
		frames = {
			[29] =  {
				attack_box = { 250, 0, 428, 350 },
				velocity_flipped = { 30, 180 },
				att_pause = 10,
				interval = 200,
				trigger = {
					{
						trigger_cond = {
							enemy_death = {},
						},
						operation = {
							{func = 'add_mp', tar = 'self', args = {mp = 10}, },
							{func = 'set_skill_cd', tar = 'self', args = {skill_id = 401, cd = 0}, },
						},
					},
				},
			},
			[32] = {},
		},
		anim = {
			name = 'Stand2',
			begin = 18,
			framecount = 63,
			duration = 46,
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
	operation = {
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet',
				self_offset = { 0 ,0}, 
				--enemy_offset = {0,0,},
				gravity = false,
				inherit_attr = true,
				ground = true,
			},
		},
	},
	anim = {
		name = 'Aoyi4',
		framecount = 22,
		duration = 12,
		loop = 0,
	},
}
star_2={}
star_3={}
star_4={}
star_5={}

