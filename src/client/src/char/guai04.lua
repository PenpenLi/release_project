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

plist = 'skeleton/guai04/Guai040.plist'
png = 'skeleton/guai04/Guai040.png'
json = 'skeleton/guai04/Guai04.ExportJson'
name = 'Guai04' -- cocostudio project name
role_sound = {
	attack 	= 'sound/monster_jian_1.wav',
	death	= 'sound/monster_death_1.wav',
}

combat_conf = 2
default_hit_box = {-40,30,70,170}
default_flipped = true
random_y_offset = true
is_air_monster	= true		--是否重力作用
default_fly_speed = 100

hit = {
	enter_cond = {
		hitable = {},
	},
	enter_op = {
	},
	leave_op = {
		velocity = {0,0}
	},
	duration = 15, --状态20帧
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

--攻击
attack = {
	enter_cond = {
		--on_ground = {}, --在地面
	},
	last_cond = {
	},
	command = command.touch_right, --点击右边
	enter_op = {
		-- create_obj = {		--创建箭的实体
		-- 	conf_id = 15,
		-- 	self_offset = {50,97}, 
		-- 	duration = 100,
		-- 	attack_times = 1,
		-- 	velocity = {-70, 90},
		-- 	is_follow = true,
		-- 	no_obstacle = true,
		-- 	-- sound = role_sound.attack,
		-- },
		auto_facing = true,

	},
	duration = 17,  -- 状态帧率 60 f/s  --状态为28帧
	frames = {
		[1] =  {
			attack_box = { 10, -80, 200, 10 },
			att_pause = 2,
			--impulse = { 0, 150 },
		 	-- interval = 200,
			 -- att_pause = 2,
		},
		--[10] = {},
	},	
	anim = { --动画
			name = 'Attack', --动画名
			framecount = 17,		--一共14帧
			duration = 17, -- 动画帧率 30 f/s --在十四帧播放完它
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
	duration = 32, --状态40帧
	anim = {
		name = 'Run', --动画名
		framecount = 32, --动画帧数
		duration = 32, --在多少时间播放完动画
	},
}


--空闲状态
idle = {
	enter_op = {

	},
	duration = 40,  --状态80帧
	anim = {
		name = 'Run',  --站的动画
		framecount = 32,  --动画帧数
		duration = 40,  --要在多少帧内播放完这个动画
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
		sound = role_sound.death, --播放死亡声音
	},
	leave_op = {
		remove_obj = true, --移除对象
	},
	duration = 22, --帧数为180帧
	anim = {
		name = 'Death2', --死亡动画名
		framecount = 22, --动画帧数
		duration = 22, --要在多少帧内播放完这个动画
		loop = 0, --不重复
	},
}

--状态优先级集合
--state_order = {'death', 'attack', 'hit', 'run', 'idle', }
state_order = {'death','attack', 'hit', 'run',  'idle',}