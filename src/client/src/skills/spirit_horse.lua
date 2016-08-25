
local command		= import( 'game_logic.command' )

s = {
	s = 'sound/hero_whirlwind_1.wav',
	hit = 'sound/monster_hurt_2.wav',
}

star_1 = {
    damage_factor = 1,
	enter_cond = {
		--mp_limit = {mp = 0,},
	},
	command = command.skill_1,
	enter_op = {
		velocity = {0,0},
		wudi = true,
	},
	duration = 90,  -- 状态帧率 60 f/s
	leave_op = {
		run_speed = -240,
		velocity = {0,0},
		gravity = true,
		detransformation = true,			--换回来。
	},
	frames = {
		[1] =  {
			attack_box = { 0, -30, 150, 150 },
			--att_pause = 4,
			velocity_flipped = {0,80},
			interval = 15,
		},
	},	
	anim = {
		name = 'Aoyi',
		framecount = 16,
		duration = 16,
		loop = 0,
	},
	operation = {
		[17] = {
			run_speed = 240,
			sound = s.s,
			stick_ctrl = true,
			facing = 'move',
			bati = true,
			mana_cost = 0,
			gravity = false,
			transformation = 'char.trans_ma01',	
		},
	},
}
