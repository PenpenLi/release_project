

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 = {
	
	json = 'skeleton/boss_206_lina_tx/boss_206_lina_tx.ExportJson',
	name = 'boss_206_lina_tx', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 1,
	scale_y = 1,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 90,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -168, -60, 158, 30 },
				velocity_away = { 50, 100 },
				--att_pause = 100,
				interval = 15,
			},
		},
		anim = {
			name = 'Stand3',
			framecount = 60,
			duration = 60,
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
		duration = 96,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -168, -60, 200, 30 },
				velocity_away = { 50, 100 },
				--att_pause = 100,
				interval = 8,
			},
		},
		anim = {
			name = 'Stand3',
			framecount = 60,
			duration = 32,
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
	duration = 15,
	anim = {
		name = 'Aoyi',
		framecount = 15,
		duration = 15,
		loop = 0,
	},
	operation = {
		[12] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet',
				self_offset = {0,100}, 
				--enemy_offset = {0,0,},
				gravity = false,
				inherit_attr = true,
				is_surround = true,
			},
		},
	},
}
star_2={}
star_3={}
star_4={}
star_5={}

