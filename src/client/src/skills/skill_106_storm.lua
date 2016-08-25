

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 ={
	
	json = 'skeleton/boss_106_storm_tx/boss_106_storm_tx.ExportJson',
	name = 'boss_106_storm_tx', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 0.8,
	scale_y = 0.9,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 56,  -- 状态帧率 30 f/s
		frames = {
			[36] =  {
				attack_box = { -130, 0, -55, 427 },
				interval = 200,
			},
			[40] = {},
			[41] =  {
				attack_box = { 65, -20, 150, 399 },
				interval = 200,
			},
			[44] = {},
			[45] =  {
				attack_box = { -20, 56, 50, 438 },
				interval = 200,
			},
			[46] = {},
		},
		anim = {
			name = 'Stand',
			framecount = 56,
			duration = 56,
		}
	},

	state_order = { 'idle', },
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
	duration = 15,
	anim = {
		name = 'Aoyi3',
		framecount = 25,
		duration = 15,
		loop = 0,
	},
	operation = {
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet',
				self_offset = {260,0}, 
				--enemy_offset = {0,0,},
				gravity = false,
				inherit_attr = true,
				ground = true,
			},
		},
	},
}
star_2={}
star_3={}
star_4={}
star_5={
	operation = {
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet',
				self_offset = {260,20}, 
				--enemy_offset = {0,0,},
				gravity = false,
				inherit_attr = true,
				ground = true,
			},
		},
		[2] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet',
				self_offset = {500,20}, 
				--enemy_offset = {0,0,},
				gravity = false,
				inherit_attr = true,
				ground = true,
			},
		},
	},
}

