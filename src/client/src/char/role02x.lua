local command			= import( 'game_logic.command' )

json = 'skeleton/wall/wall.ExportJson'
name = 'wall' -- cocostudio project name
scale_y = 500
zorder = ZBoss


rigid_box = {-80, 0, 80, 830}
-- anim_flipped = true
-- default_flipped = true
default_run_speed = 10

show_damage_data = true

idle = {
	enter_op = {	
		velocity = {0, 0},
	},
	duration = 144,
 	anim = {
 		name = 'Animation1',
 		framecount = 72,
 		duration = 144,
 	},
}

death = {
	enter_cond = {
		not_in_state = {'death'},
		hp_zero = {},
	},
	enter_op = {
		wudi = true,
		clear_buffs = true,
		clear_goto_state = true,
		velocity = {0, 0},
	},
	leave_op = {
		remove_obj = true,
	},
	duration = 90,
	anim = {
		name = 'Animation1',
		framecount = 18,
		duration = 18,
		loop = 0,
	},
}

state_order = {'death', 'idle',}
