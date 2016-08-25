

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_creator_1 = {
	
	json = 'skeleton/boss_601_pitlord/boss_601_pitlord.ExportJson',
	name = 'boss_601_pitlord', -- cocostudio project name
	zorder = ZBoss,
	default_fade = 0,

	scale_x = 0.9,
	scale_y = 0.9,	

	idle = {
		leave_op = {
			remove_obj = true,
		},
		duration = 50, 
		operation = {
			[1] = {
				fade = {10,255},
			},
			[31] = {
				fade = {8,0},
			},
			[22] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {315,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[32] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {465,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[42] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {615,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
		},
		anim = {
			name = 'Attack5',
			begin=11,
			framecount = 55,
			duration = 45,
			loop = 0,
		}
	},

	state_order = {'idle', },
}
bullet_creator_2 ={}
bullet_creator_3 ={}
bullet_creator_4 ={}
bullet_creator_5 ={
	idle = {
		leave_op = {
			remove_obj = true,
		},
		duration = 70, 
		operation = {
			[1] = {
				fade = {10,255},
			},
			[31] = {
				fade = {8,0},
			},
			[22] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {315,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[32] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {465,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[42] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {615,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[52] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {765,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
			[62] = {
				-- sound = role_sound.attack,
				create_obj = {
					conf_id = 'bullet',
					self_offset = {915,0}, 
					--enemy_offset = {0,0,},
					duration = 300,
					--attack_times = 1,
					no_obstacle = true,
					ground = true,
					gravity = false,
				},			
			},
		},
		anim = {
			name = 'Attack5',
			begin=11,
			framecount = 55,
			duration = 45,
			loop = 0,
		}
	},
}

bullet_1 = {
	
	json = 'skeleton/boss_601_pitlord_tx/boss_601_pitlord_tx.ExportJson',
	name = 'boss_601_pitlord_tx',
	zorder = ZBoss,

	--scale_x = 0.5,
	--scale_y = 0.5,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 25, 
		operation = {
			[12] = {
				shake_scene = {1, 7, 10, 0, 0},	
			},
		},
		frames = {
			[9] =  {
				attack_box = { -50, 0, 50, 550 },
				velocity_flipped = { 150, 80 },
				--att_pause = 100,
				interval = 200,
			},
			[20] = {},
		},
		anim = {
			name = 'Stand',
			framecount = 25,
			duration = 25,
		}
	},

	state_order = {'idle', },
	
}
bullet_2={}
bullet_3={}
bullet_4={}
bullet_5={}
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
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet_creator',
				self_offset = { -115, 0}, 
				--enemy_offset = {0,0,},
				gravity = true,
				inherit_attr = true,
			},
		},
	},
}
star_2={}
star_3={}
star_4={}
star_5={}

