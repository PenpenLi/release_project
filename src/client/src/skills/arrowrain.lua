

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )

role_sound = {
	sound = 'sound/hero_arrowrain_1.wav',
}

star_1 = {
	damage_factor = 0.5,
	enter_cond = {
		mp_limit = {mp = 20,},
	},
	last_cond = {
	},
	command = command.slide_down,
	enter_op = {
		sound = role_sound.sound,
		create_obj = {
			conf_id = 8,
			num = 1,
			self_offset = {250, 0},
			limit = 2,
			set_flipped = true,
			inherit_attr = true,
		},
		stick_ctrl = true,
		bati = true,
		mana_cost = 20,
	},
	leave_op = {
		velocity = {0,0},
	},
	duration = 15,
	frames = {
	},
	anim = {
		name = 'Aoyi',
		framecount = 16,
		duration = 16,
		loop = 0,
	},
}
