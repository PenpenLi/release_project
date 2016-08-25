local avatar			= import('entities.avatar').avatar
local timer				= import('model.timer')

--self.db.quest里面的值为 1 时，表示任务已经完成

function avatar:_init_quest()
	for quest_id_str, q in pairs(self.db.quest) do
        if q ~= 1 then
			local quest_id = tonumber(quest_id_str)
			local quest = data.quest[q.id]
			if quest.condition ~= nil and quest.condition ~= 0 then
				self:_register_quest_event(quest_id, quest.condition, 'quest')
			end
		end
	end
	self:_add_quest()
end

function avatar:_init_quest_daily()
	for quest_id_str, q in pairs(self.db.quest_daily) do
		if q ~= 1 then
			local quest_id = q.id
			local quest = data.quest_daily[quest_id]
			if quest.condition ~= nil and quest.condition_count ~= 0 then
				self:_register_quest_event(quest_id, quest.condition, 'quest_daily')
			end
		end
	end
end

function avatar:_update_daily_quest()
	local now_time	= timer.get_now()
	local hour = timer.get_date().hour
	for quest_id, q in pairs(data.quest_daily) do
		local quest_id_str = tostring(quest_id)
		 self.db.quest_daily[quest_id_str] = nil
		if q.condition == 'yueKa' then
			local end_time	=  self.db.month_card 
			if 0 <= timer.compare_two_date( end_time,now_time )  then
				local remain_day = timer.count_day(now_time,end_time) + 1
				self.db.quest_daily[quest_id_str] = {id = quest_id, cnt = remain_day}
				self:_register_quest_event(quest_id, q.condition, 'quest_daily')
			end 
		elseif q.time_limit == nil or ( q.time_limit[1] <= hour and hour < q.time_limit[2] ) then
			if q.lv <= self.db.lv then
				if q.time_limit ~= nil and q.time_limit[2] - 2 <= hour then
					self.db.quest_daily[quest_id_str] = {id = quest_id,cnt = 1}
				else
					self.db.quest_daily[quest_id_str] = {id=quest_id, cnt=0}
				end
				if q.condition ~= nil and q.condition_count ~= 0 then
					self:_register_quest_event(quest_id, q.condition, 'quest_daily')
				end
			end
		else 
			self.db.quest_daily[quest_id_str] = nil
		end
	end
end

function avatar:_update_food()
	local now_time	= timer.get_now()
	local hour	= timer.get_date().hour
	local quests = {}
	for quest_id, q in pairs(data.quest_daily) do
		local quest_id_str = tostring(quest_id)
		local task = self.db.quest_daily[quest_id_str]
		if task ~= 1  then
			if q.time_limit ~= nil and (hour < q.time_limit[1] or q.time_limit[2] <= hour) then
				if task ~= nil then
					self.db.quest_daily[quest_id_str] = 1
					quests[quest_id_str] = 1
				end
			elseif q.time_limit ~= nil then
			 
				if q.time_limit[2] - 2 <= hour then
					self.db.quest_daily[quest_id_str] = {id = quest_id, cnt = 1}
				else
					self.db.quest_daily[quest_id_str] = {id = quest_id, cnt = 0}
				end
				quests[quest_id_str] = self.db.quest_daily[quest_id_str]
			elseif q.condition == 'yueKa' and task == nil then
				local end_time	=  self.db.month_card
				if 0 <= timer.compare_two_date( end_time,now_time ) then
					local remain_day = timer.count_day(now_time,end_time) + 1
					self.db.quest_daily[quest_id_str] = {id = quest_id, cnt = remain_day}
					quests[quest_id_str] = self.db.quest_daily[quest_id_str]
				end 
			end	 
		end
	end
	self:_writedb()
	self.client.sync_quest_daily(quests)
end

function avatar:_add_quest()
	local quests = {}
	local num = 0
	for quest_id, q in pairs(data.quest) do
		local quest_id_str = tostring(quest_id)
		if self.db.quest[quest_id_str] == nil and q.lv <= self.db.lv then
			if q.pre_quest ~= nil then 
				if self.db.quest[tostring(q.pre_quest)] == 1 then
					if q.condition == 'level' then
						self.db.quest[quest_id_str] = {id = quest_id, cnt = self.db.lv}
					elseif q.condition == 'moLing' then
						local num = 0
						for i,v in pairs(self.db.skills) do
							if v ~= nil then 
								num = num + 1
							end
						end
						self.db.quest[quest_id_str] = {id = quest_id, cnt = num }
					else
						local condition	 = string.match(q.condition,'%a+')
						if condition == 'PT' or condition == 'JY' then
							local battle_id
							if condition == 'PT' then
								battle_id = self:_get_fuben()
							else
								battle_id = self:_get_elite_fuben()
							end
							local chapter_str = string.match(q.condition,'%d+%.')
							local instance_str = string.match(q.condition,'%.%d+')
							local chapter	= tonumber(string.sub(chapter_str,1,-2))
							local instance	= tonumber(string.sub(instance_str,2,-1))
							local c_battle_id = data.fuben_entrance[chapter][instance]
							if c_battle_id <= battle_id then
								 self.db.quest[quest_id_str] = {id = quest_id, cnt = 1}
							else
								 self.db.quest[quest_id_str] = {id = quest_id, cnt = 0}
							end
						else
							self.db.quest[quest_id_str] = {id = quest_id, cnt = 0}
						end
					end
					quests[quest_id_str] = self.db.quest[quest_id_str]
					num = num + 1
					if q.condition ~= nil and q.condition_count ~= 0 and q.condition_count > quests[quest_id_str].cnt then
						self:_register_quest_event(quest_id, q.condition, 'quest')
					end
				end
			else
				if q.condition == 'level' then
					self.db.quest[quest_id_str] = {id = quest_id, cnt = self.db.lv}
				 elseif q.condition == 'moLing' then
                    local num = 0 
                    for i,v in pairs(self.db.skills) do
                        if v ~= nil then 
                            num = num + 1 
                        end 
                    end 
                    self.db.quest[quest_id_str] = {id = quest_id, cnt = num }
				else
					self.db.quest[quest_id_str] = {id = quest_id, cnt = 0}
				end
				quests[quest_id_str] = self.db.quest[quest_id_str]
				num = num + 1
				if q.condition ~= nil and q.condition_count ~= 0 then
					self:_register_quest_event(quest_id, q.condition, 'quest')
				end
			end
		end
	end
	return quests,num
end


function avatar:_levelup_update_quest( lv )
	local quests = {}
	local num = 0
	for quest_id, q in pairs(data.quest_daily) do 
		local quest_id_str = tostring(quest_id)
		if self.db.quest_daily[quest_id_str] == nil and q.lv == self.db.lv and q.condition ~= 'yueKa' then
			self.db.quest_daily[quest_id_str] = {id = quest_id, cnt = 0}
			quests[quest_id_str] = self.db.quest_daily[quest_id_str]
			num = num + 1
			if q.condition ~= nil and q.condition_count ~= 0 then
				self:_register_quest_event(quest_id, q.condition, 'quest_daily')
			end
		end
	end
	if 0 < num then
		self.client.sync_quest_daily(quests)
	end
	quests,num = self:_add_quest()
	if 0 < num then
		self.client.sync_quest(quests)
	end
	self:_writedb()
		
end

function avatar:_sync_quests()
	self:_writedb()
	self.client.sync_quest(self.db.quest)
	self.client.sync_quest_daily(self.db.quest_daily)
end

function avatar:_add_quest_counter(quest_type, quest_id, cnt)
	local quests = self.db[quest_type]
	local quest_id_str = tostring(quest_id)
	if quests[quest_id_str] == nil then
		return
	end
	local q = quests[quest_id_str]
	local q_data = data[quest_type][quest_id]
	if cnt == nil then
		q.cnt = q.cnt + 1
	else
		q.cnt = cnt
	end
	if quest_type == 'quest' then
		self.client.update_quest( quest_id_str, q.cnt )
	elseif quest_type == 'quest_daily' then
		self.client.update_quest_daily( quest_id_str, q.cnt )
	end
	self:_writedb()
end

function avatar:_trigger_quest_event(condition, cnt)
	if self.quest_event[condition] == nil then
		return
	end
	local qe = self.quest_event[condition]
	if qe == nil then
		return
	end
	for quest_id, quest_type in pairs(qe) do
		self:_add_quest_counter(quest_type, quest_id, cnt)	
	end
end

function avatar:_register_quest_event(quest_id, condition, quest_type)
	if self.quest_event[condition] == nil then
		self.quest_event[condition] = {}
	end
	self.quest_event[condition][quest_id] = quest_type
end

function avatar:_get_reward(task_type, quest_id)
	local task = data[task_type][quest_id]
	
	if task.gold ~= nil then
		self:_add_money(task.gold)
	end
	if task.exp ~= nil then
		self:_add_exp(task.exp)
	end
	if task.diamond ~= nil then
		self:_add_diamond(task.diamond)
	end
	if task.items ~= nil then
		for i, id in pairs(task.items) do
			self:_gain_item(id,task.items_count)
		end
	end 
	if task.energy ~= nil then
		self:_add_energy(task.energy)
	end
end
function avatar:finish_quest( quest_type, quest_id_str )
	local task_type 
	if quest_type == 1 then
		task_type = 'quest_daily'
	elseif quest_type == 2 then 
		task_type = 'quest'
	end

	local quest_id = tonumber(quest_id_str)
	if self.db[task_type][quest_id_str] ~= nil and self.db[task_type][quest_id_str].cnt < data[task_type][quest_id].condition_count then
		return 
	end 
	if self.db[task_type][quest_id_str] == nil or self.db[task_type][quest_id_str] == 1 then
		if quest_type == 1 then
			self.client.del_quest_daily(quest_id_str)
		elseif quest_type == 2 then
			self.client.del_quest(quest_id_str)
		end
		return
	end
	local condition = data[task_type][quest_id].condition
	if self.quest_event[condition] ~= nil then
		self.quest_event[condition][quest_id] = nil
	end

	if task_type == 'quest' then
		self.db.quest[quest_id_str] = 1
		local quests,num = self:_add_quest()
		quests[quest_id_str] = 1
		self.client.sync_quest(quests)
	elseif task_type == 'quest_daily' then
		self.db[task_type][quest_id_str] = 1
		self.client.del_quest_daily(quest_id_str)
	end
	self:_writedb()
	self:_get_reward( task_type, quest_id )
end
