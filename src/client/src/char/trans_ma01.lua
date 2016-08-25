local command	= import( 'game_logic.command' )

json = 'skeleton/Tx-maA/Tx-maA.ExportJson'
name = 'Tx-maA' 

default_hit_box = {-40,0,50,120}
default_anim = {
	name = 'Run',
	framecount = 20,
	duration = 16,
}


idle = {
	enter_op = {
	},
	duration = 80,
	anim = {
		name = 'Stand',
		framecount = 20,
		duration = 40,
	},
}


state_order = {'idle', }
