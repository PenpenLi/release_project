

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	sound = 'sound/hero_whirlwind_1.wav',
}

----------------------------------子弹分割线----------------------------------
star_1={
	enter_cond = {
		--on_ground = {},
	},
	last_cond = {
	},
	enter_op = {
		run_speed = -20,
		sound = role_sound.sound,
		stick_ctrl = true,
		facing = 'move',
		bati = true,
		gravity = false,
	},
	leave_op = {
		run_speed = 20,
		velocity = {0,0},
		gravity = true,
	},
	duration = 60,
	operation = {
		[1] = {
			y_speed = -10,
		},
	},
	frames = {
		[1] =  {
			attack_box = { -150, -30, 150, 150 },
			att_pause = 2,
			velocity_away = {-30,128},
			interval = 10,
		},
	},	  
	anim = {
		name = 'Whirlwind',	
		framecount = 13,
		duration = 13, -- 动画帧率 30 f/s
	},
}

star_2={}
star_3={
	duration = 90,
}
star_4={}
star_5={
	duration = 120,
}

