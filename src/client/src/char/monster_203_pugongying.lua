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
	create_obj = {
		conf_id = 4,
		self_offset = {0,72}, -- 相对角色的位置，优先级最高
		enemy_offset = {-20,66}, -- 相对最近敌人的位置，优先级第二
		scene_offset = {1000, 200}, -- 相对于场景的位置，优先级最低
		duration = 150, -- obj的存活帧数
		attack_times = 1, -- obj攻击过多少次后算“完成攻击”
		is_follow = true, --开启子弹跟踪玩家功能
	},
]]

local command	= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )

plist = 'skeleton/monster_203_pugongying/monster_203_pugongying0.plist'
png = 'skeleton/monster_203_pugongying/monster_203_pugongying0.png'
json = 'skeleton/monster_203_pugongying/monster_203_pugongying.ExportJson'
name = 'monster_203_pugongying' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_jian_1.wav',
	death	= 'sound/monster_death_1.wav',
}


default_hit_box = {-50,35,50,135}
default_flipped = true
random_y_offset = true
is_air_monster	= true		--是否重力作用
default_fly_speed = 15

bullet = {
	plist = 'skeleton/monster_203_pugongying_zidan/monster_203_pugongying_zidan0.plist',
	png = 'skeleton/monster_203_pugongying_zidan/monster_203_pugongying_zidan0.png',
	json = 'skeleton/monster_203_pugongying_zidan/monster_203_pugongying_zidan.ExportJson',
	name = 'monster_203_pugongying_zidan', -- cocostudio project name
	zorder = ZBullet,

	-- default_hit_box = { 20, -10, 40, 10 }

	idle = {
		enter_cond = {
		},
		enter_op = {
			---- sound = role_sound.attack,
		},
		leave_op = {
			remove_obj = true,
		},
		duration = 300,  -- 状态帧率 30 f/s
		frames = {
			[1] =  {
				attack_box = { -2, -2, 2, 2 },
				interval = 200,
			},
		},
		anim = {
			name = 'Stand',
			framecount = 11,
			duration = 11, -- 动画帧率 30 f/s 14
		}
	},

	death = {
		enter_cond = {
			finish_attack={}
		},
	},

	state_order = {'death', 'idle', },
}
----------------------------------子弹分割线----------------------------------
--攻击
attack = {
	enter_cond = {
		--on_ground = {}, --在地面
	},
	last_cond = {
	},
	command = command.touch_right, --点击右边
	enter_op = {
		velocity = {0,0},
		bati = true,
		auto_facing = true,
	},
	duration = 35,  -- 状态帧率 30 f/s  --状态为28帧52
	operation = {
		[28] = {
			-- sound = role_sound.attack,
			create_obj = {
				conf_id = 'bullet',
				self_offset = {0,0}, 
				duration = 300,
				attack_times = 1,
				no_obstacle = true,

				gravity = false,
				all_angle = true,
				
				fly_speed = 50,
				dest_offset = {0,65},
				is_follow = 1,
				is_follow_rate = 5,
			},			
		},
	},
	anim = {
		[1] = {
			name = 'Attack',
			framecount = 35,
			duration = 35, -- 动画帧率 30 f/s
		},
	},
}

state_order = battle_const.AirMonsterDefaultStateOrder
--state_order = {'death','hit', { 'attack', 'attack2', 'skill' ,'skill1', 'skill2' , }, 'run','idle', }
---------------------------------------------------------------------------------
hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
	},
	leave_op = {
	},
	duration = 15, --状态20帧
	operation = {
		[5] = {
			velocity = {0,0},
		},
	},
	anim = {
		[1] = {
			name = "Wound",
			framecount = 15,
			duration = 15,
		},
		[2] = {
			name = "Wound2",
			framecount = 15,
			duration = 15,
		},

	},
}

--跑步状态
run = {
	enter_cond = {
		running_speed = {}, ---跑步速度
	},
	last_cond = {
		running_speed = {}, ---跑步速度
	},
	enter_op = {
	},
	duration = 30, --状态40帧
	anim = {
		name = 'Run', --动画名Run
		framecount = 30, --动画帧数22
		duration = 30, --在多少时间播放完动画
	},
}


--空闲状态
idle = {
	enter_op = {

	},
	duration = 30,  --状态80帧
	anim = {
		name = 'Stand',  --站的动画
		framecount = 30,  --动画帧数
		duration = 30,  --要在多少帧内播放完这个动画
	},
}

--死亡状态
death = {
	enter_cond = {
		not_in_state = {'death'}, --没有在死亡状态	
		hp_zero = {}, --hp为0
	},
	enter_op = {
		wudi = true,
		clear_buffs = true, --设置为无敌
		clear_goto_state = true,
		sound = role_sound.death, --播放死亡声音
		gravity = true,
		obstacle = true,
		velocity = {0,0},
	},
	leave_op = {
		remove_obj = true, --移除对象
	},
	duration = 90, --帧数为180帧
	operation = {
		[45] = {
			fade = {45,0},
		},
	},
	anim = {
		name = 'Death', --死亡动画名
		framecount = 26, --动画帧数
		duration = 30, --要在多少帧内播放完这个动画
		loop = 0, --不重复
	},
}

