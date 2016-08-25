
local command		= import( 'game_logic.command' )

role_sound = {
	sound = 'sound/hero_slashleft_1.wav',
}

charge_left = {
	--damage_factor = 0.7,
	enter_cond = {
		-- mp_limit = {mp = 10,},
		--mp_limit = {mp = 10,},
		charge_count = {}
	},
	command = command.slide_left,
	enter_op = {
	    sound = role_sound.sound,
		velocity = {0,0},
		flipped_x = true,
		bati = true,
		gravity = false,
		-- mana_cost = 10,
		--mana_cost = 10,
		cost_charge_count = 1,
	},
	leave_op = {
		velocity = {0,0},
		gravity = true,
	},
	operation = {
		[5] = {
			offset = {300,0},
		},
	},
	duration = 8,
	frames = {
		[4] =  {
			attack_box = { -300, 30, 230, 150 },
			att_pause = 6,
			interval = 200,
			damage_factor = 0.17,
		},
	},
	anim = {
		name = 'AttackSkill2',
		begin = 6,
		framecount = 23,
		duration = 8,
	},
}