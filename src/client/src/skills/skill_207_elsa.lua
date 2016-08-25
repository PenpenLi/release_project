

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 = {
	
	json = 'skeleton/boss_207_elsa_tx/boss_207_elsa_tx.ExportJson',
	name = 'boss_207_elsa_tx', -- cocostudio project name
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
		duration = 14,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { 0, -40, 180, 58 },
				--impulse_away = { 100, 10 },
				--att_pause = 100,
				interval = 200,
			},
		},
		anim = {
			name = 'Stand2',
			framecount = 14,
			duration = 14,
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
				self_offset = { 70 ,90}, 
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

