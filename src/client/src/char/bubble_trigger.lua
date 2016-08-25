local command			= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )

json = 'skeleton/bubble/bubble.ExportJson'
name = 'bubble' -- cocostudio project name
zorder = ZBoss

default_run_speed = 10

trigger = {
	enter_cond = {
		trigger_by_enemy = { x = 150 ,y = 50 },
	},
	last_cond = {
		trigger_by_enemy = { x = 150 ,y = 50 },
	},
	enter_op = {
		event = {
			name = 'enter_trigger',
		},
	},
	leave_op = {
		event = {
			name = 'outof_trigger',
		},
	},

	duration = battle_const.InfiniteTime,
 	anim = {
 		name = 'Stand',
 		framecount = 80,
 		duration = 144,
 	},
}

idle = {
	enter_op = {	
		velocity = {0, 0},
	},
	duration = 144,
 	anim = {
 		name = 'Stand',
 		framecount = 80,
 		duration = 144,
 	},
}

state_order = {'trigger', 'idle',}
