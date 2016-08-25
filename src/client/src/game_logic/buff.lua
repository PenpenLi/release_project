local buff_cb	= import( 'game_logic.buff_callback' )
local buff_cond	= import( 'game_logic.buff_condition' )
local battle_const	= import( 'game_logic.battle_const' )
local combat	= import( 'model.combat' )
local director	= import( 'world.director')

buf = lua_class( 'buf' )

function buf:_init(id, buff_id, frame, caster, skill)
	self.skill = skill
	self.id = id
	self.buff_id = buff_id
	self.data = data.buff[buff_id]
	self.frame = frame
	self.buff_caster = caster
end

function buf:trigger(cur_frame)
	local buff_type = self.data.type
	if buff_type == EnumBuffTypes.temporary then
		return false
	elseif buff_type == EnumBuffTypes.permenant then
		local gap = cur_frame - self.frame
		local interval = self.data.recur*Fps
		return (gap > 0) and (gap < self.data.duration*Fps) and (gap % interval == 0)
	end
	return false
end

function buf:get_type()
	return self.data.type
end

function buf:is_finish(cur_frame)
	return self.data.duration*Fps + self.frame == cur_frame
end

function buf:get_max()
	return self.data.max
end

buff = lua_class( 'buff' )
local _color_interval = 40

function buff:_init( entity )
	self.buffs = {}
	self:bound_entity(entity)
	self.last_condition = nil
	self.frame = 0
	self.buff_count = 0
	self.counter = 1
end

function buff:grab_id()
	local id = self.counter
	self.counter = self.counter + 1
	return id
end

function buff:bound_entity( entity )
	self.entity = entity
end

function buff:unbound_entity( entity )
	self.entity = nil
end

function buff:clear_buffs( )
	for k, v in pairs(self.buffs) do
		self:buff_end(v)
		self.buffs[k] = nil
	end
end
function buff:apply_multi_buff( buff_args, caster_e, skill)
	local buff_ids = buff_args.buff_conf_id

	if buff_ids == nil then
		return
	end

	for k, v in pairs(buff_ids) do
		self:apply_buff( v , caster_e, buff_args.last_condition, skill)
	end
end

function buff:replace_conflict_buff( b )
	local num_of_this_buff = 0
	local earliest_buff
	local min_ttl = math.huge
	for k, v in pairs(self.buffs) do
		if v.data.id == b.buff_id then
			num_of_this_buff = num_of_this_buff + 1
			if v.frame < min_ttl then
				earliest_buff = k
				min_ttl = v.frame
			end
		end
	end
	if num_of_this_buff > b:get_max() then
		-- 已超过最大叠加次数
		-- print('reach max buff', temp_buff.max, num_of_this_buff, earliest_buff)
		self.buffs[earliest_buff] = nil
	end
end


function buff:check_conflict_buff( buff_id )
	-- todo
	return true
end

function buff:recalc_temporary_buff()
	local src_attr = self.entity.src_combat_attr
	local com_attr = self.entity.combat_attr
	src_attr.hp = com_attr.hp
	src_attr.mp = com_attr.mp
	com_attr:copy_from_attr(src_attr)

	local is_bati
	local state_order
	local buff_ai
	for k, b in pairs(self.buffs) do

		if b.data.is_bati ~= nil then
			is_bati = b.data.is_bati
		end
		if b.data.state_order ~= nil then
			state_order = b.data.state_order
		end
		if b.data.ai ~= nil then
			buff_ai = b.data.ai
		end
		self:append_temporary_buff(b.data.t_effect, b.buff_caster, b.skill)
	end
	-- 霸体
	if is_bati ~= nil then
		self.entity.src_combat_attr:add_property('is_force_bati', 1)
		self.entity.combat_attr:add_property('is_force_bati', 1)
	else
		self.entity.src_combat_attr:add_property('is_force_bati', -1)
		self.entity.combat_attr:add_property('is_force_bati', -1)
	end
	-- 状态优先级
	if state_order ~= nil then
		self.entity.src_combat_attr:set_state_order(battle_const[state_order])
		self.entity.combat_attr:set_state_order(battle_const[state_order])
	else
		self.entity.src_combat_attr:set_state_order(nil)
		self.entity.combat_attr:set_state_order(nil)
	end
	-- AI模块
	if buff_ai ~= nil then
		self.entity.src_combat_attr:set_ai(import('behavior.'..buff_ai))
		self.entity.combat_attr:set_ai(import('behavior.'..buff_ai))
	else
		self.entity.src_combat_attr:set_ai(nil)
		self.entity.combat_attr:set_ai(nil)
	end
end

function buff:apply_buff( buff_id, caster_e, last_cond, skill)
	if data.buff[buff_id] == nil then
		print('load buff failed, id:', buff_id)
		return
	end

	if self:check_conflict_buff(buff_id) == false then
		return
	end
	local cur_id = self:grab_id()
	local b = buf(cur_id, buff_id, self.frame, caster_e, skill)
	self:buff_begin(b)
end

function buff:reshow_buff()
	for k, b in pairs(self.buffs) do
		if b.data.effect_file ~= nil and b.data.effect_name ~= nil then
			local scale = 1.0
			if b.data.scale ~= nil then
				local rect = b.data.scale
				local hit_box = self.entity:get_world_hit_box()
				if hit_box ~= nil then
					--mao
					local hit_box_1 = hit_box[1]
					local x = hit_box_1[3] - hit_box_1[1]
					local y = hit_box_1[4] - hit_box_1[2]
					scale = math.max(x/rect[1], y/rect[2])
				end
			end
			local e_path = 'skeleton/' .. b.data.effect_file .. '/' .. b.data.effect_file .. '.ExportJson'
			self.entity.char: start_buff_effect(e_path, b.data.effect_file, b.data.effect_name, b.data.effect_offset, scale)
		end

	end
	self:recalc_temporary_buff()
end

function buff:buff_begin(b)
	self:replace_conflict_buff(b)
	self.buffs[b.id] = b

	-- 暂停
	if b.data.pause ~= nil then
		self.entity:pause(b.data.pause*FpsRate)
	end

	-- 特效
	if b.data.effect_file ~= nil and b.data.effect_name ~= nil then
		local scale = 1.0
		if b.data.scale ~= nil then
			local rect = b.data.scale
			local hit_box = self.entity:get_world_hit_box()
			if hit_box ~= nil then
				--mao
				local hit_box_1 = hit_box[1]
				local x = hit_box_1[3] - hit_box_1[1]
				local y = hit_box_1[4] - hit_box_1[2]
				scale = math.max(x/rect[1], y/rect[2])
			end
		end
		local e_path = 'skeleton/' .. b.data.effect_file .. '/' .. b.data.effect_file .. '.ExportJson'
		self.entity.char: start_buff_effect(e_path, b.data.effect_file, b.data.effect_name, b.data.effect_offset, scale)
	end

	self:recalc_temporary_buff()
end

function buff:buff_trigger(b)
	self:append_permenant_buff(b.data.p_effect, b.buff_caster, b.skill)
end

function buff:buff_end(b)
	self.buffs[b.id] = nil

	-- 暂停
	if b.data.pause ~= nil then
		self.entity:pause(0)
	end

	-- 特效
	if b.data.effect_file ~= nil and b.data.effect_name ~= nil then
		local e_path = 'skeleton/' .. b.data.effect_file .. '/' .. b.data.effect_file .. '.ExportJson'
		self.entity.char: cancel_buff_effect(e_path)
	end

	self:recalc_temporary_buff()
end

function buff:tick()
	self.frame = self.frame + 1
	local cur_frame = self.frame
	for k, v in pairs(self.buffs) do
		if v:trigger(cur_frame) then
			self:buff_trigger(v)
		end
		if v:is_finish(cur_frame) then
			self:buff_end(v)
		end
		if self.entity ~= nil and v.data.color ~= nil and cur_frame % _color_interval == 0 then
			self.entity.char: color_mask(v.data.color)
		end
	end
end

function buff:append_permenant_buff( buff_string, caster_e, skill )
	-- 永久增益
	if buff_string == nil then
		return
	end
	local formula = loadstring(buff_string)
	local env = {a=caster_e and caster_e.src_combat_attr or nil, b=self.entity.src_combat_attr, s = skill}
	setfenv(formula,env)()
	for k, v in pairs(env) do
		self.entity.src_combat_attr:add_property(k, v)
		self.entity.combat_attr:add_property(k, v)
		if k== 'hp' then 
			local now_battle = director.get_cur_battle()
			if v > 0 then 		-- buff加血飘字
				now_battle.proxy:show_damage_effect({type=5, pos=self.entity:get_world_pos(), direction=0, damage={is_crit = false, total = v}})
			else 				-- buff减血飘字
				local direct = self.entity:is_flipped() and 1 or -1
				now_battle.proxy:show_damage_effect({type=4, pos=self.entity:get_world_pos(), direction=direct, damage={is_crit = false, total = math.abs(v)}})

				-- 是否进入受击
				local formula = battle_const.DotFormula
				local env = { b=self.entity.combat_attr }
				setfenv(formula, env)()
				local ans = env.ans
				if v < ans then
					self.entity.hit = true
					now_battle:try_change_all_state_or_reenter(self.entity, nil)
				end
			end
		elseif k == 'mp' then
			local now_battle = director.get_cur_battle()
			now_battle.proxy:show_damage_effect({type=6, pos=self.entity:get_world_pos(), direction=0, damage={is_crit = false, total = v}})
		end
	end
end

function buff:append_temporary_buff( buff_string, caster_e, skill )
	-- 临时增益
	if buff_string == nil then
		return
	end

	local formula = loadstring(buff_string)
	local env = {a= caster_e and caster_e.src_combat_attr or nil, b=self.entity.src_combat_attr, s = skill}
	setfenv(formula,env)()
	for k, v in pairs(env) do
		self.entity.combat_attr:add_property(k, v)
	end
end
