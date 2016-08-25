

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 = {
	
	json = 'skeleton/monster_204_moonkin_zidan/monster_204_moonkin_zidan.ExportJson',
	name = 'monster_204_moonkin_zidan', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 1,
	scale_y = 1,

	idle = {
		enter_cond = {
		},
		enter_op = {
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 45,  -- 状态帧率 30 f/s
		operation = {
			[15]={
				velocity_flipped={100,0},
			},
			[35]={
				fade = {10,100},
			},
		},
		frames = {
			[1] =  {
				attack_box = { -40, 0, 40, 130 },
				interval = 200,
			},
			[40]={},
		},
		anim = {
			name = 'Stand',
			framecount = 5,
			duration = 5,
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
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 75,  -- 状态帧率 30 f/s
		operation = {
			[15]={
				velocity_flipped={100,0},
			},
			[65]={
				fade = {10,100},
			},
		},
		frames = {
			[1] =  {
				attack_box = { -40, 0, 40, 130 },
				interval = 200,
			},
			[70]={},
		},
		anim = {
			name = 'Stand',
			framecount = 5,
			duration = 5,
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
	duration = 23,
	anim = {
		name = 'Aoyi2',
		framecount = 23,
		duration = 23,
		loop = 0,
	},
	operation = {
		[1] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet',
				self_offset = {0,0}, 
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

