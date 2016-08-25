

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 = {

	json = 'skeleton/boss_309_panda/boss_309_panda.ExportJson',
	name = 'boss_309_panda',
	zorder = ZBoss,

	idle = {

		enter_cond = {
		},
		last_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
			velocity = {0,0},
		},
		duration = 100, 
		operation = {
			[1] = {
				fade = {10,255},
			},
			[11] = {
				velocity_flipped = {50,220},
			},
			[22] = {
				goto_state = 'idle2',
			},
		},
		anim = {
			name = 'Attack2',
			begin = 11,
			framecount = 23,
			duration = 13,
			loop=0,
		},
	},

	idle2 = {

		enter_cond = {
		},
		last_cond = {
			in_air = {},
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			goto_state='idle3',
		},
		duration = 100, 
		frames = {
			[1] =  {
				attack_box = { -150, -15, 140, 68 },
				att_pause = 2,
				interval = 5,
				velocity_away = { 20, -20 },
			},
		},	
		anim = {
			name = 'Attack2a',
			framecount = 11,
			duration = 11,
		},
	},

	idle3 = {

		enter_cond = {
		},
		last_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
			velocity = {0,0},
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 40, 
		operation = {		
			[5] = {
				shake_scene = {1.5, 15, 20, 0, 0},	
			},
			[6] = {
				
				velocity_flipped = {60,100},
			},
			[16] = {
				velocity = {0,0},
			},
			[17] = {
				fade = {10,0},
			},
		},
		frames = {
			[5] =  {
				attack_box = { -160, -35, 160, 80 },
				att_pause = 3,
				interval = 200,
				velocity_away = { 120, 150 },
			},
			[9] = {},
		},
		anim = {
			name = 'Attack2b',
			framecount = 16,
			duration = 16,
			loop = 0,
		},
	},

	state_order = {{'idle3','idle2','idle'},},
	
}
bullet_2={}
bullet_3={}
bullet_4={
	idle3 = {

		enter_cond = {
		},
		last_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
			velocity = {0,0},
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 40, 
		operation = {		
			[5] = {
				shake_scene = {1.5, 15, 20, 0, 0},	
			},
			[6] = {
				
				velocity_flipped = {60,100},
			},
			[16] = {
				velocity = {0,0},
			},
			[17] = {
				fade = {10,0},
			},
		},
		frames = {
			[5] =  {
				attack_box = { -160, -35, 160, 80 },
				att_pause = 3,
				interval = 200,
				velocity_away = { 120, 150 },

				trigger = {
					{
						trigger_cond = {
						},
						operation = {
							{func = 'apply_buff', tar = 'e', args = {buff_id = 30901, },probability = 30 },
						},
					},
				},

			},
			[9] = {},
		},
		anim = {
			name = 'Attack2b',
			framecount = 16,
			duration = 16,
			loop = 0,
		},
	},
}
bullet_5={}
----------------------------------子弹分割线----------------------------------
star_1={
	enter_cond = {
		on_ground = {},
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
				inherit_attr = true,
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

