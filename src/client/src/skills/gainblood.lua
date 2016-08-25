local command		= import( 'game_logic.command' )
s = {
	s = 'sound/hero_jixue_1.wav',
}

gainblood = {
	enter_cond = {
	},
	command = command.slide_down,
	enter_op = {
		mana_cost = 0,
		fix_attr = {
			hp = 2000,
		},
		sound = s.s,
	},
	leave_op = {
	},
	duration = 15,
	anim = {
		name = 'Aoyi',
		framecount = 16,
		duration = 16,
		loop = 0,
	},
}
