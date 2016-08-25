
local command		= import( 'game_logic.command' )

s = {
	s = 'sound/hero_slashup_1.wav',
}

slash_up = {
	--damage_factor = 0.8,
	enter_cond = {
		--mp_limit = {mp = 10,},
		charge_count_up = {}
		--charge_count = {}
	},
	command = command.slide_up,
	enter_op = {
		sound = s.s,
		stick_ctrl = false,
		bati = true,
		--mana_cost = 10,
		gravity = false,
		velocity = {0,0},
		cost_charge_count_up = 1,
	},
	leave_op = {
		velocity = {0,0},
		gravity = true,
	},
    operation = {
		[7] = {
			offset = {0,300},
		},
	},
	duration = 15,
	frames = {
		[6] =  {
			attack_box = { -60, -50, 170, 300 },
			att_pause = 6,
			interval = 200,
			velocity_flipped = {0,220},
			damage_factor = 0.21,
		},
	},
	anim = {
		name = 'AttackSkill1',
		begin = 5,
		framecount = 20,
		duration = 15,
	},
}