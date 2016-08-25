

local command		= import( 'game_logic.command' )
local battle_const	= import( 'game_logic.battle_const' )


role_sound = {
	--sound = 'sound/hero_dilie_1.wav',
}

bullet_1 ={
	json = 'skeleton/monster_107_mogu_zidan/monster_107_mogu_zidan.ExportJson',
	name = 'monster_107_mogu_zidan', -- cocostudio project name
	zorder = ZBullet,

	role_sound = {
		attack 	= 'sound/boss_heishui_1.wav',
	},

	scale_x = 1.5,
	scale_y = 1.5,

	succeed = {
		enter_cond = {
			hitable = {},
		},

		enter_op = {
			velocity = {0, 0},
		},

		frames = {
			[1] =  {
				attack_box = { -105, -105, 105, 105 },
				interval = 200,      --200帧之后才能攻击第二次
				-- apply_buff = {buff_conf_id={5,1},},
			},
		},	

		leave_op = {
			remove_obj = true,
		},

		duration = 7,
		anim = {
			name = 'Stand2',
			framecount = 7,
			duration = 7,
			loop = 0,
		},
	},

	idle = {
		enter_op = {
			facing = "move",
			-- flipped_x = true,
			--  velocity = {50,-1},
			gravity = false,
		},
		duration = 7,
		anim = {
			name = 'Stand',
			framecount = 7,
			duration = 7,
		},
		frames = {
			[1] =  {
				attack_box = { -20, -20, 20, 20 },
			-- 	interval = 200,
				-- att_pause = 2,
				att_state = 'succeed',
			},
		},	
	},

	state_order = { 'succeed','idle', },
}

bullet_2={}
bullet_3={}
bullet_4={}
bullet_5={}
----------------------------------子弹分割线----------------------------------
star_1={
	enter_cond = {
		--on_ground = {},
	},
	last_cond = {
	},
	enter_op = {
		sound = role_sound.sound,
		stick_ctrl = false,
		velocity = {0, 0},
		bati = true,
	},
	leave_op = {
		velocity = {0,0},
	},
	duration = 12,
	anim = {
		name = 'Aoyi4',
		framecount = 22,
		duration = 12,
		loop = 0,
	},
	operation = {
		[5] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id='bullet',
				self_offset = {0,90},  --从自己的前方的这个坐标点发出去
				--enemy_offset = {0,0,}, --追踪敌人脚下00点发出去
				duration = 180,          --持续多少帧
				no_obstacle = true,      --是否撞墙阻挡
				gravity = true,          --是否平行飞
				all_angle = true,       --子弹是否旋转
				fly_speed = 80,          --飞行速度
				--dest_offset = {0, 80},   --瞄准敌人位置(平射弓箭不用填)
				is_follow = false,       --跟踪导弹
			},
		},
	},
}
star_2={}
star_3={}
star_4={}
star_5={}

