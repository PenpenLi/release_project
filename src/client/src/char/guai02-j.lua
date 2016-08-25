--[[
enter_cond = {}, --状态进入条件 条件之间为与的关系
last_cond = {}, --状态持续条件 条件之间为与的关系
command = nil, --进入状态所需按键指令
enter_op = {}, --状态进入时操作
leave_op = {}, --状态离开时操作
interrupt_op = {}, --状态被打断时操作
child = { --子状态，即必须处于当前状态才能进入的状态，子状态只在满足条件时候出发，没有持续时间
	enter_cond = {}, --状态进入条件 条件之间为与的关系
	command = nil, --进入状态所需按键指令
	enter_op = {}, --状态进入时操作
},
]]

local command	= import( 'game_logic.command' )

plist = 'skeleton/guai02-j/Guai020.plist'
png = 'skeleton/guai02-j/Guai020.png'
json = 'skeleton/guai02-j/Guai02-j.ExportJson'
name = 'Guai02-j' -- cocostudio project name
zorder = ZBullet

role_sound = {
	attack 	= 'sound/monster_jian_1.wav',
}
-- default_hit_box = { 20, -10, 40, 10 }
combat_conf = 4

idle = {
	enter_op = {
	},
	duration = 40,
	anim = {
		name = 'Stand',
	},
}

succeed = {
	enter_cond = {
		finish_attack = {},
	},
	enter_op = {
		remove_obj = true,
	},
	leave_op = {
	},
	duration = 10,
	anim = {
		name = 'Stand',
	},
}

attack = {
	enter_op = {
		facing = "move",
		-- flipped_x = true,
		--  velocity = {50,-1},
		gravity = false,
		-- sound = role_sound.attack,
	},
	duration = 40,
	anim = {
		name = 'Stand',
	},
	frames = {
		[1] =  {
			attack_box = { 20, -10, 40, 10 },
		-- 	interval = 200,
			-- att_pause = 2,
		},
	},	
}

death = {
	enter_cond = {
		not_in_state = {'death'},
		life_expired = {},
	},
	enter_op = {
		remove_obj = true,
	},
	duration = 18,
	anim = {
		name = 'Stand',
		framecount = 18,
		duration = 18,
	},
}


state_order = {'death', 'succeed', 'attack', 'idle', }
