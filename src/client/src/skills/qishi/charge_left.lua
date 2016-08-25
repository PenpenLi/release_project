
local command		= import( 'game_logic.command' )

role_sound = {
	sound = 'sound/hero_slashleft_1.wav',
}

charge_left = {
	enter_cond = {
		--mp_limit = {mp = 10,},
		charge_count = {}
	},
	command = command.slide_left,
	enter_op = {
	    sound = role_sound.sound,
		velocity = {-300,120},
		flipped_x = true,
		bati = true,
		--mana_cost = 10,
		cost_charge_count = 1,
	},
	leave_op = {
		velocity = {0,0},
	},
	operation = {
		[5] = {
			x_speed = -100,
		},
	},
	duration = 10,
	frames = {
		[1] =  {
			attack_box = { 80, -0, 230, 60 },
			--att_pause = 2,
			interval = 12,
			attack = 0.5,
			inherit_speed = true,
			damage_factor = 0.17,
		},
	},
	anim = {
		name = 'AttackSkill2',
		framecount = 15,
		duration = 10,
	},
}
