local avatar			= import('entities.avatar').avatar


function avatar:sommon_skill(skill_id)
	-- cost
	local frag_cost = self:_get_skill_active_cost(skill_id)
	if frag_cost == math.huge then
		self.client.server_method_failed()
		return
	end
	if self:_get_soul_frag(skill_id) < frag_cost then
		self.client.message( 'msg_more_soul_frag' )
		self.client.server_method_failed()
		return
	end
	self:_add_soul_frag(skill_id, -frag_cost)

	-- gain
	if self:_gain_skill(skill_id) == false then
		self:_add_soul_frag(skill_id, frag_cost)
		self.client.message( 'msg_soul_gain_failed' )
		self.client.server_method_failed()
		return
	end
	
	self:_writedb()

	-- client
	local s = self.db.skills[tostring(skill_id)]
	self.client.update_skill(s)
	self.client.gain_skill(skill_id)
end

function avatar:skill_up_star(skill_id)
	-- skill exist?
	local s = self.db.skills[tostring(skill_id)]
	if s == nil then
		return
	end

	-- cost
	local to_star = s.star + 1
	local frag_cost = data.soul_evolution[to_star].piece
	if frag_cost == nil then
		self.client.server_method_failed()
		return
	end
	if self:_get_soul_frag(skill_id) < frag_cost then
		self.client.message( 'msg_more_soul_frag' )
		self.client.server_method_failed()
		return
	end
	self:_add_soul_frag(skill_id, -frag_cost)

	-- skill change
	s.star = to_star
	self:_writedb()

	-- client sync
	self.client.update_skill(s)
	self.client.up_star_finish()
end

function avatar:_get_soul_exp(skill_id_str)
	local s = self.db.skills[skill_id_str]
	if s == nil then
		return 0
	end

	return s.exp
end

function avatar:_add_soul_exp(skill_id_str, num)
	if type(num) ~= 'number' then
		return
	end

	local s = self.db.skills[skill_id_str]
	if s == nil then
		return
	end

	s.exp = s.exp + num
	self:_try_soul_levelup(skill_id_str)

	self:_writedb()
	self.client.update_skill(s)
end

function avatar:_try_soul_levelup(skill_id_str)
	local s = self.db.skills[skill_id_str]
	for i = s.lv, 80 do
		if s.exp >= data.soul_upgrade[i].sum_exp then
			if s.lv >= self:_get_level() then
				s.exp = data.soul_upgrade[i].sum_exp - 1
			else
				self:_soul_level_up(skill_id_str)
			end
		else
			break
		end
	end
end
	
function avatar:_soul_level_up(skill_id_str)
	local s = self.db.skills[skill_id_str]
	s.lv = s.lv + 1
	--TODO: recalc?
end

function avatar:_gain_skill(skill_id)
	skill_id = tonumber(skill_id)
	if data.skill[skill_id] == nil then
		return false
	end
	local skill_str = tostring(skill_id)
	if self.db.skills[skill_str] ~= nil then
		self:_regain_skill_to_frags(skill_id)
		return true
	end
	local init_star = data.skill_initstar[skill_id] or 1
	local s = {id=skill_id, lv=1, star=init_star, exp=0}
	self.db.skills[skill_str] = s
	self:_trigger_quest_event('moLing')
end

function avatar:free_skill(skill_id)
	--新手永久技能
	skill_id = tonumber(skill_id)
	if data.skill[skill_id] == nil then
		return false
	end
	local skill_str = tostring(skill_id)
	if self.db.skills[skill_str] ~= nil then
		return false
	end
	local s = {id=skill_id, lv=1, star=1, exp=0}
	self.db.skills[skill_str] = s
end

function avatar:_sync_loaded_skills( loaded_skills )
	self.db.loaded_skills = loaded_skills
	self:_writedb()
end

function avatar:_get_skill_active_cost( skill_id )
	local init_star = data.skill_initstar[skill_id] or 1
	local frag_cost = data.soul_evolution[init_star].sum_piece
	if frag_cost == nil then
		return math.huge
	else
		return frag_cost
	end
end

function avatar:_regain_skill_to_frags( skill_id )
	local init_star = data.skill_initstar[skill_id] or 1
	local refund_piece = data.soul_evolution[init_star].refund
	if refund_piece ~= nil then
		self:_add_soul_frag(skill_id, refund_piece)
	end
end
