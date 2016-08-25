

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 = {
	
	json = 'skeleton/boss_205_thunderbird/boss_205_thunderbird.ExportJson',
	name = 'boss_205_thunderbird', -- cocostudio project name
	zorder = ZBullet,

	scale_x = 0.8,
	scale_y = 0.8,

	idle = {
		enter_cond = {
		},
		enter_op = {
			-- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 50,  -- 状态帧率 30 f/s
		operation = {
			[1]={
				velocity_flipped = {200,-125},
			},
			[12]={
				anim = {
					name = 'Attack1',
					framecount = 11,
					duration = 11, -- 动画帧率 30 f/s
				},
			},	
			[15]={
				velocity_flipped = {150,-5},
			},
			[20]={
				velocity_flipped = {150,5},
			},
			[30]={
				velocity_flipped = {200,155},
			},
			[35]={
				anim = {
					name = 'Run',
					framecount = 21,
					duration = 6, -- 动画帧率 30 f/s
				},
			},
		},
		frames = {
			[12] =  {
				attack_box ={ -80,24, 108, 120 },
				att_pause = 3,
				interval = 4,
				velocity_flipped = { 50, 50 },
			},
			[35] ={},
		},
		anim = {
			name = 'Run',
			framecount = 21,
			duration = 6,
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
				self_offset = { -500, 400}, 
				--enemy_offset = {0,0,},
				no_obstacle = true,

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

