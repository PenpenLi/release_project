

local command		= import( 'game_logic.command' )

s = {
	s = 'sound/hero_whirlwind_1.wav',
	hit = 'sound/monster_hurt_2.wav',
}

hit_left = {
	enter_cond = {
		'hitable',
	},
	enter_op = {
		--velocity = {30,80},
		sound = s.hit,
	},
	leave_op = {
		--velocity = {0, 0},
	},
	duration = 15,
	anim = {
		name = "Wound",
		framecount = 15,
		duration = 15,
	},
}
star_1 = {
    damage_factor = 0.4,
	enter_cond = {
		--mp_limit = {mp = 50,},
		not_in_state = {'whirlwind','slash_up','slash_down','charge_right','charge_left' },
	},
	command = command.skill_1,
	enter_op = {
		run_speed = -20,
		sound = s.s,
		stick_ctrl = true,
		facing = 'move',
		bati = true,
	},
	duration = 65,  -- 状态帧率 60 f/s
	leave_op = {
		run_speed = 20,
		velocity = {0,0},
	},
	frames = {
		[1] =  {
			attack_box = { -150, -30, 150, 150 },
			att_pause = 2,
			velocity_flipped = {30,110},
			interval = 5,
			hit_state = hit_left,
		},
	},	
  
	anim = {
		name = 'Whirlwind',	
		framecount = 13,
		duration = 13, -- 动画帧率 30 f/s
	},
}