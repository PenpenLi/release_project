

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )

role_sound = {
	sound = 'sound/hero_dilie_1.wav',
}

liedikan = {
	damage_factor = 0.3,
	enter_cond = {
		on_ground = {},
		mp_limit = {mp = 10,},
	},
	last_cond = {
	},
	command = command.slide_down,
	enter_op = {
		sound = role_sound.sound,
		stick_ctrl = false,
		velocity = {0, 40},
		bati = true,
		mana_cost = 10,
	},
	leave_op = {
		velocity = {0,0},
	},
	duration = 18,
	frames = {
		[3] =  {
			attack_box = { 20, -10, 220, 150 },
			velocity_flipped = {30,0},
			att_pause = 2,
			interval = 11,
		},
	},
	anim = {
		name = 'AttackSkill3',
		framecount = 18,
		duration = 18,
		loop = 0,
		effect = {
			name = 'stand',
			json = 'skeleton/TX-dilie/TX-dilie.ExportJson',
			armature_name = 'TX-dilie',
		},
	},
}