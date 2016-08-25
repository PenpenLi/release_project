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

json = 'skeleton/Buff-Z03/Buff-Z03.ExportJson'
name = 'Buff-Z03' -- cocostudio project name
zorder = ZBuff

role_sound = {
	attack 	= 'sound/scene_portal_1.wav',
}

combat_conf = 6
default_physics_box = {0,0}
physics_dynamic = false
--scale_y = 1.5 	--缩放因子
default_anim = {
	name = 'Stand',
	framecount = 200,
	duration = 200,
}

attack = {
	enter_cond = {
		trigger_by_enemy = {},  --是一个计算接近玩家距离
	}, 
	enter_op = {
		apply_buff = {
			buff_conf_id = {4,},
		},
		--transfer_to = 'battle',
		-- sound = role_sound.attack, --播放声音
		remove_obj = true,
	},
	duration = 90,  -- 状态帧率 60 f/s
}

idle = {
	duration = 200,	-- 状态帧率 60 f/s
	enter_op = {
	},  --5qian
	leave_op ={
		remove_obj = true,
	},
}

state_order = { 'attack','idle', }
