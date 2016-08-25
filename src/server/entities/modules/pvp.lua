local avatar			= import('entities.avatar').avatar
local timer				= import('model.timer')
local utils				= import('utils')
local db				= import('db')
local const				= import('const')
local pvp_rank			= import('model.pvp_rank')
local pvp_const			= import('const.pvp_const')
local db_mesg			= import('model.db_mesg')
local const				= import('const')

local offline_pvp_record = {}

function avatar:pvp_ticket_recover()
	local now = timer:get_now()

	--票满了
	if self.db.pvp_ticket.count >= pvp_const.Ticket then
		return
	end
	
	local sub = now - self.db.pvp_ticket.time
	local con = pvp_const.TicketRecoverTime
	if sub >= con then
		self.db.pvp_ticket.count = self.db.pvp_ticket.count + math.floor(sub/con)
		if self.db.pvp_ticket.count >= pvp_const.Ticket then
			self.db.pvp_ticket.count = pvp_const.Ticket
		end
		self.db.pvp_ticket.time = math.floor( now/60 ) * 60
		--print('recover ticket sub, ticket.count is', sub, self.db.pvp_ticket.count)
	else
		return
	end

	self.client.sync_pvp_ticket( self.db.pvp_ticket )
	self:_writedb()
end

function avatar:pvp_battle_begin(battle_id)
	local now = timer:get_now()

	if self.db.pvp_ticket.count <= 0 then
		return
	end	

	if self.db.pvp_ticket.count >= pvp_const.Ticket then
		self.db.pvp_ticket.time = math.floor( now/60 ) * 60
	end

	self.db.pvp_ticket.count = self.db.pvp_ticket.count - 1
	self.client.sync_pvp_ticket( self.db.pvp_ticket )

	self.pvp_token = math.random(99999999999999)

	self.client.pvp_battle(battle_id, self.pvp_token)
	self:_writedb()
end

function avatar:pvp_battle_end(battle_id, status)
	if status.pt ~= self.pvp_token then
		return
	end

	local is_revenge = status.is_revenge

	-- vs type		
	local his_e = all_avatars_oid[status.his_id]
	if his_e == nil then print('对战的玩家是不活跃用户') return end
	local bb = his_e.db
	--calc point
	local formula = self:select_formula( self.db.pvp_point, bb.pvp_point, status.result ) 
	local env = {b = bb, a = self.db}
	setfenv(formula, env)()
	local ans = self:check_max_min(env.s)
	if status.result < 1 then
		ans = -ans
	end
	self.db.pvp_point = self.db.pvp_point + ans 
	self.db.rank = utils.get_random()	
	self.client.sync_pvp_point( self.db.pvp_point )	
	-- 对方 calc point
	local ans2 = ans * -1
	
	local e = his_e 
	print('e online')
	e.db.pvp_point = e.db.pvp_point + ans2
	e.db.rank = utils.get_random()
	e.client.sync_pvp_point( e.db.pvp_point )
	e:_writedb()

	--calc honor
	local ho = nil
	if status.result >= 1 then
		local formula2 = pvp_const.HonorFormula
		local env2 = {b = bb, a = self.db}
		setfenv(formula2, env2)()
		ho = self:check_max_min(env2.s)
		self.db.pvp_honor = self.db.pvp_honor + ho
		self.client.sync_pvp_honor( self.db.pvp_honor )
	end

	--add record
	self:_add_pvp_record( status.result, status.his_id, is_revenge )

	self.pvp_token = math.random(99999999999999)
	self:_trigger_quest_event('jingJiChang') 
	self.client.pvp_battle_finish(status.result, ans, ho)
	self:_writedb()
end

function avatar:check_max_min(s)
	local ans = math.floor(s)
	ans = math.abs(ans)
	if ans > pvp_const.Point_abs_max then
		ans = pvp_const.Point_abs_max
	end
	if ans < pvp_const.Point_abs_min then
		ans = pvp_const.Point_abs_min
	end
	return ans
end

function avatar:select_formula(a_point, b_point, result)
	--local formula = pvp_const.PointFormula
	if result >= 1 then
		if a_point >= b_point then
			return pvp_const.Point_h_win
		else
			return pvp_const.Point_l_win
		end
	else
		if a_point >= b_point then
			return pvp_const.Point_h_fail
		else
			return pvp_const.Point_l_fail
		end
	end
end

function avatar:refresh_pvp_candidate()
	self.db.pvp_candidate = {}
	self.db.pvp_candidate_flag = {}
	
	local function not_exist(r_oid)
		if self.db.pvp_candidate[1] == nil then
			return true
		end

		local flag = true
		for i, oid in ipairs(self.db.pvp_candidate) do
			if r_oid == oid then
				flag = false
				break
			end
		end
		return flag
	end
	
	local self_point = self:_get_pvp_point()
	for k,v in ipairs( pvp_const.CandidateList ) do
	
		local rt = {}
		local point = self_point * v

		for oid, e in pairs( all_avatars_oid ) do
			if e.db.pvp_point <= point and e.db._id ~= self.db._id and not_exist(oid)  then
				local ins = oid
				table.insert(rt, ins)
			end					
		end	

		if rt[1] ~= nil then
			local r	= math.random(#rt)
			table.insert(self.db.pvp_candidate, rt[r])
			self.db.pvp_candidate_flag[#self.db.pvp_candidate] = 0
		else
			print('随机对手 == nil')
		end
	end

	self:revert_pvp_candidate()
end

function avatar:revert_pvp_candidate()

	local oid_data = {}
	for i, oid in ipairs(self.db.pvp_candidate) do
		local e = all_avatars_oid[oid]
		if e ~= nil then
			local t = pvp_rank.built_struct(e)
			oid_data[oid] = t
		end
	end	

	local oid_flag = {}
	for i, f in ipairs(self.db.pvp_candidate_flag) do
		oid_flag[ self.db.pvp_candidate[i] ] = f	
	end

	self.client.sync_pvp_candidate( oid_data, oid_flag )
end

function avatar:_update_pvp_candidate()
	local flag = false
	for k,v in pairs( self.db.pvp_candidate ) do
		flag = true
		break
	end
	
	if flag then
		self:revert_pvp_candidate()
	else
		self:refresh_pvp_candidate()
	end
end

function avatar:_refresh_pvp_checkbox_ui(cb_id)
	--同步数据，刷新战斗选人UI
	if cb_id == 1 then
		-- 算刷新时间
		local now = timer.get_now()
		local last = self.db.pvp_candidate_refresh_time

		-- cd到了 or 第一次按刷新
		if now >= last or last == 0 then
			local next_time = now + pvp_const.RefreshCandidateTime
			self.db.pvp_candidate_refresh_time = next_time 	
			self.client.sync_pvp_candidate_refresh_time( next_time )
		else
			self.client.message('food_target')
			return
		end
	
		self:refresh_pvp_candidate()
	elseif cb_id == 2 then
		self:refresh_pvp_record(true)
	end
end

function avatar:_get_pvp_point()
	return self.db.pvp_point
end

-- pvp_record = {time,challenge,result,his_data{}}
-- pvp_record = {time,challenge,result,his_oid}
-- 战斗记录
function avatar:_add_pvp_record( result, his_id, is_revenge )
	local now_time = timer.get_now()
	local me = {time = now_time, challenge = 1}
	local he = {time = now_time, challenge = 0}

	if result >= 1 then					-- 自己赢了
		me.result = 1
		he.result = 0
	else
		me.result = 0
		he.result = 1
	end

	if is_revenge ~= nil then
		--应增加复仇成功删除记录
		table.remove(self.db.pvp_record, is_revenge)
	else 
		if result >= 1 then -- 挑战胜利的加标记
			local id = 1
			for i, oid in ipairs(self.db.pvp_candidate) do
				if his_id == oid then
					id = i
					break
				end
			end
			self.db.pvp_candidate_flag[id] = 1
			self:revert_pvp_candidate()
		end
	end
	me.his_oid = his_id
	table.insert( self.db.pvp_record, 1, me)
	--保留前n条记录
	self:reserve_front( self.db.pvp_record, pvp_const.RecordCount )

	--对方记录处理
	he.his_oid = self.db._id

	local e = all_avatars_oid[his_id]
	if e ~= nil then
		print('------ e online -------')
		table.insert( e.db.pvp_record, 1, he )
		e:reserve_front( e.db.pvp_record, pvp_const.RecordCount )
		e:refresh_pvp_record()
		e:_writedb()
	else
		print('对方存记录，不是活跃')
	end 
	self:refresh_pvp_record()
	self:_writedb()
end

function avatar:refresh_pvp_record(refresh_ui)
	
	local send_record = {}
	for i, data in ipairs(self.db.pvp_record) do
		local e = all_avatars_oid[ data.his_oid ]
		if e ~= nil then
			send_record[i] = table_deepcopy(data)
			send_record[i].his_data = pvp_rank.built_struct(e)
		end
	end
	self.client.sync_pvp_record( send_record, refresh_ui )
end

-- 同步pvp防守技能
function avatar:_sync_pvp_def_skills( pvp_def_skills )
	self.db.pvp_def_skills = pvp_def_skills
	self:_writedb()
	self.client.message('msg_successfully_saved')
end

function avatar:_update_pvp_all()
	--更新pvp选人
	self:_update_pvp_candidate()
	self:refresh_pvp_record()
	self:_sync_pvp_rank()
	self:pvp_ticket_recover()
end

function avatar:_sync_pvp_rank()
	local rank = pvp_rank.pvp_rank_result --table_deepcopy
	local oid_id = pvp_rank.rank_oid_id

	-- rank = {oid, pvp_point}

	local count = pvp_const.RankCount
	local send_rank = {}	
	for i=1,count do
		if rank[i] == nil then
			break
		end
		send_rank[i] = rank[i].oid
	end

	local rank_id = oid_id[self.db._id]
	if rank_id ~= nil then -- 在排行榜集合中 
		if rank_id <= count then -- 在前N名
			self:_sync_built_pvp_rank(send_rank)
		else
			send_rank[ count + 1 ] = rank[rank_id].oid
			self:_sync_built_pvp_rank(send_rank, rank_id)
		end
	else
		self:_sync_built_pvp_rank(send_rank)
	end
end

function avatar:_sync_built_pvp_rank(send_rank, rank_id)
	
	local send_obj_rank = {}
	for i, oid in ipairs(send_rank) do
		local e = all_avatars_oid[oid]
		if e ~= nil then
			local t = pvp_rank.built_struct(e)
			send_obj_rank[i] = t
		else
			print('排行榜有不活跃用户')
		end		
	end
	
--	self.client.sync_pvp_rank(send_obj_rank, rank_id)

	for i, v in ipairs(send_obj_rank) do
		if i == 1 then
			self.client.sync_pvp_rank(i, v, rank_id)
		else
			self.client.sync_pvp_rank(i, v)
		end
	end
end

-- 保留前N条数据
function avatar:reserve_front(t, count)
	for i=count+1, 100 do
		if t[i] ~= nil then
			t[i] = nil			
		else
			break
		end
	end
end




