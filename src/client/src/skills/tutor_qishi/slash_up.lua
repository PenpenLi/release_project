
local command		= import( 'game_logic.command' )

s = {
	s = 'sound/hero_slashup_1.wav',
}

slash_up = {
	enter_cond = {
		--mp_limit = {mp = 10,},
		charge_count_up = {}
	},
	command = command.slide_up,
	enter_op = {
		sound = s.s,
		stick_ctrl = false,
		velocity_flipped = {25,220},
		bati = true,
		--mana_cost = 10,
		cost_charge_count_up = 1,
	},
	leave_op = {
		velocity = {0,0},
	},
	frames = {
		[1] =  {
			attack_box = { 0, 20, 140, 200 },
			--att_pause = 3,
			interval = 220,
			--velocity_flipped = {30,220},
			inherit_speed = true,
			--velocity = {25,220},
			damage_factor = 0.21,
		},
	},
	duration = 15,
	anim = {
		name = 'AttackSkill1',
		framecount = 20,
		duration = 15,
	},
}
