
local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )

s = {
	s = 'sound/hero_slashdown_1.wav',
}

slash_down = {
	--damage_factor = 0.7,
	inherit_ate_speed = true,
	enter_cond = {
		--mp_limit = {mp = 10,},
		--charge_count = {}
		--in_air = {},
	},
	last_cond = {
	},
	command = command.slide_down,
	enter_op = {
		sound = s.s,
		stick_ctrl = false,
		velocity = {0,0},
		bati = true,
		--mana_cost = 10,
		--cost_charge_count = 1,
	},
	leave_op = {
		velocity = {0,0},
	},
	operation = {
		[6] = {
			velocity_flipped = {0,-500},
		},
	},
	duration = 17,
	frames = {
		[1] =  {
			attack_box = { -130, -10, 130, 180 },
			velocity_flipped = {60,-80},
			--att_pause = 2,
			interval = 100,
			damage_factor = 0.28,
		},
	},
	anim = {
		name = 'AttackSkill3',
		framecount = 17,
		duration = 17,
		loop = 0,
	},
}