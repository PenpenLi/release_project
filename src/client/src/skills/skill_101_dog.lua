

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 ={
	json = 'skeleton/skill_101_dog/skill_101_dog.ExportJson',
	name = 'skill_101_dog', -- cocostudio project name
	zorder = ZBullet,

	role_sound = {
		attack 	= 'sound/boss_heishui_1.wav',
	},

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
		duration = 15,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -100, 0, 500, 145 },
				interval = 200,
				velocity_flipped = { 80, 30 },
			},
			[10] = {},
		},
		anim = {
			name = 'Stand',
			framecount = 15,
			duration = 15,
		},
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
				self_offset = {-68,15}, 
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

