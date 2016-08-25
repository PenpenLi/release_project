
json = 'skeleton/Tx-jianA/Tx-jianA.ExportJson'
name = 'Tx-jianA' -- cocostudio project name
zorder = ZEffect

-- combat_conf = 8

role_sound = {
	arrow = 'sound/slash_down.wav',
}

rain_attack = {
	damage_factor = 0.7,
	enter_cond = {
	},
	enter_op = {
		facing = "move",
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 80,
	frames = {
		[8] =  {
			attack_box = { -180, 150, 80, 300 },
			att_pause = 2,
		},
		[9] = {},
		[11] =  {
			attack_box = { -160, 120, 100, 270 },
			att_pause = 2,						
		},
		[12] = {},
		[14] =  {
			attack_box = { -140, 90, 120, 240 },
			att_pause = 2,	
		},
		[15] = {},
		[20] =  {
			attack_box = { -120, 0, 140, 150 },
			att_pause = 2,	
		},
		[21] = {},
	},
	anim = {
		name = 'Stand',
		framecount = 60,
		duration = 80,
		loop = 0,
	},
}

idle = {
	duration = 100,
}

state_order = { 'rain_attack','idle', }
