local model		= import( 'model.interface' )
local state_mgr			= import( 'game_logic.state_mgr' )
local battle_const		= import( 'game_logic.battle_const' )

combat_attr 	= lua_class( 'combat_attr' )



--计算回复血量和回复魔法值的时间间隔
local _hp_time=os.time()
local _old_hp_time = os.time()



function combat_attr:_init()
	-- 默认值
	self.hp = 0
	self.max_hp = 0
	self.mp = 0
	self.max_mp = 0

	-- attack
	self.attack = 0
	self.crit_level = 0
	self.crit_damage = 0
	self.crit_rate = 0

	-- defense
	self.defense = 0
	self.crit_defense = 0
	self.def_rate = 0

	-- common
	self.speed_x = 0
	self.speed_y = 0
	self.hp_recover = 0

	self.jump_addition = 0
	
	-- not for config
	self.take_hp = 0

	self.is_force_bati = 0

	self.fc = 0

	self.ai = nil
	self.state_order = nil

	-- elements
	self.f_att = 0
	self.i_att = 0
	self.n_att = 0
	self.f_def = 0
	self.i_def = 0
	self.n_def = 0

	self.player = nil
end

function combat_attr:set_player(p)
	self.player = p
end

-- 裸装属性
function combat_attr:init_with_level( level )
	self.crit_damage = 1.5
	self.max_mp = 100
	self.speed_x = battle_const.RunSpeed

	level = level or 1
	local d = data.level[level]
	if d == nil then
		self.attack 	= 32
		self.crit_level	= 0
		self.max_hp		= 107
		self.defense	= 22

		self.hp_recover = self.max_hp / 1000
		return
	end
	self.attack = d.attack
	self.crit_level = d.crit
	self.max_hp = d.hp
	self.defense = d.def

	self.hp_recover = self.max_hp / 1000
	return
end

function combat_attr:init_with_strengthen_level( strength_lv )
	for i, j in ipairs(strength_lv) do
		local d = data.avatar_strengthen[i*100000 + j]
		local sum_attack = d.sum_attack
		local sum_defense = d.sum_defense
		local sum_crit_level = d.sum_crit_level
		local sum_hp = d.sum_max_hp
		if sum_attack then
			self.attack = self.attack + sum_attack
		end
		if sum_defense then
			self.defense = self.defense + sum_defense
		end
		if sum_crit_level then
			self.crit_level = self.crit_level + sum_crit_level
		end
		if sum_hp then
			self.max_hp = self.max_hp + sum_hp
		end
	end
end

function combat_attr:init_with_configdata( conf_data )
	for k, v in pairs(self) do
		if conf_data[k] ~= nil then
			self[k] = conf_data[k]
		end
	end
	self.crit_damage = 1.5
	self.speed_x = 15
	self:set_max_hp()

	self:calc_second_attr()
end

-- 从配置读入战斗数值
function combat_attr:load_conf_by_id( combat_conf_id )
	local loaded_attr = data.combat_attr[combat_conf_id]
	self:copy_from_attr( loaded_attr )
end

function combat_attr:copy_from_attr( src_combat_attr )
	if src_combat_attr == nil then
		print('COPY COMBAT CONFIGURE FAILED! combat attr id:')
		return
	end
	for i, v in pairs(self) do 
		if type(v) ~= 'function' then
			self[i] = src_combat_attr[i]
		end
	end

	self:calc_second_attr()
end

function combat_attr:append_property( equip )
	if equip == nil then
		return
	end
	local p_key = equip:get_prop_key()
	if self[p_key] ~= nil then
		self[p_key] = self[p_key] + equip:get_prop_value()
	end
	self:calc_second_attr()
end

function combat_attr:set_state_order( state_order )
	self.state_order = state_order
end

function combat_attr:set_ai( ai )
	self.ai = ai
end

function combat_attr:apply_equip_active_property( equips )
	if equips == nil then
		return
	end
	for k, v in pairs(equips) do
		local data = v.data
		if data.act_attack ~= nil then
			self.attack = self.attack + data.act_attack
		end
		if data.act_defense ~= nil then
			self.defense = self.defense + data.act_defense
		end
		if data.act_max_hp ~= nil then
			self.max_hp = self.max_hp + data.act_max_hp
		end
		if data.act_crit_level ~= nil then
			self.crit_level = self.crit_level + data.act_crit_level
		end
	end
end

function combat_attr:final_combat_attr()
	if self.player == nil then
		return
	end
	local player = self.player
	self:copy_from_attr(player.attrs)

	-- 装备激活属性
	self:apply_equip_active_property(player.equips)

	-- 装备附加
	self:append_property(player:get_wear('weapon'))
	self:append_property(player:get_wear('helmet'))
	self:append_property(player:get_wear('armor'))
	self:append_property(player:get_wear('necklace'))
	self:append_property(player:get_wear('ring'))
	self:append_property(player:get_wear('shoe'))

	--技能附加
	if player:get_loaded_skills() ~= nil then
		for _, skill in pairs(player:get_loaded_skills()) do
			self.f_def = self.f_def + skill:get_f_def()
			self.i_def = self.i_def + skill:get_i_def()
			self.n_def = self.n_def + skill:get_n_def()
		end
	end
	-- 玩家final_attr计算完成
	self:set_max_hp()
	self:calc_second_attr()
end

function combat_attr:apply_element_def(skills)
	self.f_def = 0
	self.i_def = 0
	self.n_def = 0
	for _, skill in pairs(skills) do
		self.n_def = self.n_def + skill:get_n_def()
		self.f_def = self.f_def + skill:get_f_def()
		self.i_def = self.i_def + skill:get_i_def()
	end
end

function combat_attr:get_appenddata_byid( combat_conf_id ) 
	if combat_conf_id == nil or data.combat_append[combat_conf_id] == nil then
		return nil
	end
	return data.combat_append[combat_conf_id]
end

function combat_attr:add_property( key, value )
	if self[key] == nil then
		return
	end

	if self['add_'..key] ~= nil then
		self['add_'..key](self, value)
		return
	end

	if type(self[key]) == 'boolean' then
		if value ~= nil then
			self[key] = value
		end
		return
	end

	local temp_result = self[key] + value
	if temp_result < 0 then
		self[key] = 0
	else
		self[key] = temp_result
	end
	self:calc_second_attr()
end

function combat_attr:add_mp( mp_add )
	local temp_mp = self.mp + mp_add
	if temp_mp > self.max_mp then
		self.mp = self.max_mp
	elseif temp_mp < 0 then
		self.mp = 0
	else
		self.mp = temp_mp
	end
end

function combat_attr:add_hp( hp_add )
	local temp_hp = self.hp + hp_add
	if temp_hp > self.max_hp then
		self.hp = self.max_hp
	elseif temp_hp < 0 then
		self.hp = 0
	else
		self.hp = temp_hp
	end
end

function combat_attr:add_jump_addition( jump_addition_add )
	self.jump_addition = self.jump_addition + jump_addition_add
end

function combat_attr:get_jump_addition(  )
	return self.jump_addition
end

function combat_attr:set_max_hp()
	if self.hp ~= self.max_hp then
		self.hp = self.max_hp
	end
end

function combat_attr:set_max_mp()
	if self.mp ~= self.max_mp then
		self.mp = self.max_mp
	end
end

--消耗魔法值

function combat_attr:calculate_mp( e_mp,mana_cost)
	-- body
	if mana_cost ~= nil then
		e_mp=e_mp-mana_cost
		if e_mp < 0 then
			e_mp=0
			return e_mp
		end
		return e_mp
	end
end

function combat_attr:calculate_hp( e_hp,hp_cost)
	e_hp=e_hp - self.max_hp*hp_cost
	if e_hp < 0 then
		e_hp=0
		return e_hp
	end
	return e_hp
end

function combat_attr:tick(  )
	-- body
	self:recover_hp_mp()

end


--更新回复血量,魔法
function combat_attr:recover_hp_mp()
	-- body
	 _hp_time = os.time()

 	local time = _hp_time - _old_hp_time
 	if time>0  then
		if self.hp<=0 then
			self.hp = 0
		else
			if self.mp<=0 then
				self.mp = 0
			end
			local hp = self.hp + self.hp_recover
			-- 没有了mp_recover
			local mp = self.mp
			
			if hp>=self.max_hp then
				hp = self.max_hp
			end
			if mp>=self.max_mp then
				mp = self.max_mp
			end
			self.hp=hp
			self.mp=mp

		end

 	end
	_old_hp_time =_hp_time
end

--满血复活
function combat_attr:reset_relive( entity )
	print(' relive entity ')
	-- body
	--entity.combat_attr:final_combat_attr()		
	entity.src_combat_attr:final_combat_attr()
	entity.combat_attr:copy_from_attr(entity.src_combat_attr)
	state_mgr.change_state(entity, 'idle')					--让玩家恢复idle状态
	entity.buff:clear_buffs()
end

function combat_attr:verify()
end


function combat_attr:calc_second_attr()
	local def_rate = self.defense / (5000 + self.defense)
	if def_rate < 0 then def_rate = 0 end
	if def_rate > 0.88 then def_rate = 0.88 end
	self.def_rate = def_rate

	local crit_rate = self.crit_level / (6000 + self.crit_level)
	if crit_rate < 0.05 then crit_rate = 0.05 end
	if crit_rate > 0.7 then crit_rate = 0.7 end
	self.crit_rate = crit_rate

	self.f_rate = self.f_def / (2000 + self.f_def)
	self.i_rate = self.i_def / (2000 + self.i_def)
	self.n_rate = self.n_def / (2000 + self.n_def)

	local env = {
		a = self,
	}
	setfenv(battle_const.FightingCapacityFormula,env)()
	self.fc = env.fc
end

function combat_attr:get_speed_x()
	return self.speed_x
end

function combat_attr:set_speed_x( val )
	self.speed_x = val
end

--取出火抗
function combat_attr:get_f_def(  )
	return self.f_def
end

--取出冰抗
function combat_attr:get_i_def(  )
	return self.i_def
end

--取出自然抗
function combat_attr:get_n_def(  )
	return self.n_def
end

function combat_attr:get_fighting_capacity()
	return self.fc
end

function combat_attr:get_max_hp( )
	return self.max_hp
end

function combat_attr:get_crit_level( )
	return self.crit_level
end

function combat_attr:get_defense( )
	return self.defense
end
function combat_attr:get_attack(  )
	return self.attack
end

