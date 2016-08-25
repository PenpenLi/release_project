local entity			= import( 'world.entity' )
local math_ext			= import( 'utils.math_ext' )
local model 			= import( 'model.interface' )
local command			= import( 'game_logic.command' )
local state_mgr			= import( 'game_logic.state_mgr' )
local director			= import( 'world.director' )

scenebuff  = lua_class( 'scenebuff', entity.entity )

function scenebuff:_init( id, conf_id, scenebuff_id )
	self.id = id
	self.conf_id = conf_id
	self.scenebuff_id = scenebuff_id
	self.attr_data = data.monster[self.conf_id]
	self.model_id = self.attr_data.model_id
	self.data = data.monster_model[self.attr_data.model_id]
	self.type_id = self.data.type
	super(scenebuff, self)._init(id, conf_id)
end

function scenebuff:init_special_attr()
	--self.conf = import('char.'..self.data.state)
	self:set_default_conf()
	self:set_conf()

	local id = self.model_id
	local ms = data.monster_skill[id]
	local skills = {}
	if ms ~= nil then
		for k, v in pairs(ms) do
			skills[k] = monster_skill.skill(id, v)
		end
	end
	self.skills = skills

	if self.data.ai ~= nil then
		self.ai = import('behavior.'..self.data.ai)
	end
	self.battle_group = 2

	-- self.x_speed = 10

	self.src_combat_attr: init_with_configdata( self.attr_data )
	if self.conf.default_run_speed ~= nil then
		self.src_combat_attr: set_speed_x( self.conf.default_run_speed )
	end
	self.combat_attr:copy_from_attr(self.src_combat_attr)
end

function scenebuff:set_default_conf(  )
	self.conf = {
		-- local command	= import( 'game_logic.command' )

		json = 'skeleton/',
		name = 'Buff-Z03', -- cocostudio project name
		zorder = ZBuff,

		role_sound = {
			attack 	= 'sound/scene_portal_1.wav',
		},

		scale_y = 1.0, 	--缩放因子
		scale_x = 1.0, 	--缩放因子

		attack = {
			enter_cond = {
				trigger_by_enemy_box = {},  --是一个计算接近玩家距离
			}, 
			enter_op = {
				apply_trigger_buffs = {
					9997,
				},
				-- sound = role_sound.attack, --播放声音
			},
			leave_op = {
				remove_obj = true,
			},
			duration = 39,  -- 状态帧率 60 f/s
			anim = {
				name = 'Stand',
				framecount = 39,
				duration = 39,
				loop = -1,
			},
		},

		idle = {
			duration = 200,	-- 状态帧率 60 f/s
			enter_op = {
				gravity = false,
			},  --5qian
			anim = {
				name = 'Stand',
				framecount = 39,
				duration = 39,
				loop = -1,
			},
		},
		state_order = { 'attack','idle', }
	}
end

function scenebuff:set_conf(  )
	local d = data.scenebuff[self.scenebuff_id]

	--conf
	self.conf.name = d.name or self.conf.name
	self.conf.json = self.conf.json .. self.conf.name ..'/'..self.conf.name .. '.ExportJson'
	self.conf.scale_x = d.scale[1] or self.conf.scale_x
	self.conf.scale_y = d.scale[2] or self.conf.scale_y

	--idle
	self.conf.idle.duration = d.duration or self.conf.idle.duration
	self.conf.idle.anim.name = d.idle or self.conf.idle.anim.name
	self.conf.idle.anim.framecount = d.idle_anim[1] or self.conf.idle.anim.framecount
	self.conf.idle.anim.duration = d.idle_anim[2] or self.conf.idle.anim.duration

	--attack
	if d.attack ~= nil then
		self.conf.attack.anim.name = d.attack or self.conf.attack.anim.name
		self.conf.attack.anim.framecount = d.attack_anim[1] or self.conf.attack.anim.framecount
		self.conf.attack.anim.duration = d.attack_anim[2] or self.conf.attack.anim.duration
		self.conf.attack.duration = d.attack_anim[2] or self.conf.attack.duration
	else
		self.conf.attack.anim = nil
		self.conf.attack.duration = nil
	end

	self.conf.attack.enter_op.apply_trigger_buffs = d.buff_id
	self.conf.attack.enter_cond.trigger_by_enemy_box = d.distance
end


