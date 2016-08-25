
local command	= import( 'game_logic.command' )

plist = 'skeleton/pet_108_fairy/pet_108_fairy0.plist'
png = 'skeleton/pet_108_fairy/pet_108_fairy0.png'
json = 'skeleton/pet_108_fairy/pet_108_fairy.ExportJson'
name = 'pet_108_fairy' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_jian_1.wav',
	death	= 'sound/monster_death_1.wav',
}

--default_hit_box = {-40,0,50,120}
default_flipped = true
default_fly_speed = 80
pet = true

attack1 = {

	enter_cond = {
	},
	last_cond = {
	},
	command = command.touch_right,
	enter_op = {
		-- sound = role_sound.attack,
		velocity = {0,0},
		bati = true,
	},
	duration = 15,  -- 状态帧率 30 f/s
	frames = {
		[1] =  {
			attack_box = { 80, 0, 170, 105 },
			att_pause = 6,
			interval = 200,
			--impulse = { 0, 150 },
		},
		[2] = {},
	},	
	anim = {
		name = 'Attack',
		framecount = 15,
		duration = 15, -- 动画帧率 30 f/s
		loop = -1,
	},
}

state_order = {'attack1','run', 'idle', }
---------------------------------------------------------------------------------
run = {
	enter_cond = {
		running_speed = {}, ---跑步速度
	},
	last_cond = {
		running_speed = {}, ---跑步速度
	},
	enter_op = {
	},
	duration = 13, --状态40帧
	anim = {
		name = 'Run', --动画名
		framecount = 13, --动画帧数
		duration = 13, --在多少时间播放完动画
		--loop = 0,
	},
}

idle = {
	enter_op = {
		add_ball = true
	},
	duration = 40,  --状态80帧
	anim = {
		name = 'Stand',  --站的动画
		framecount = 40,  --动画帧数
		duration = 40,  --要在多少帧内播放完这个动画
		--loop = 0,
	},
}

