local avatar			= import('entities.avatar').avatar
local email				= import('model.email')
local db				= import('db')
local timer				= import ('model.timer')
local utils				= import('utils')
local item				= import('model.item')

local max_num = 3
local boss_coin_type = 4
local function swap(q, p)
	local t = q
	q = p
	p = t
end
--刷新选中的BOSS
function avatar:_refresh_cur_boss()
	local unfinish_boss = {}
	local finish_boss = self:_get_finish_boss()
	local d = data.boss_battle
	local index = 0
	for id, v in pairs(d) do	
		if finish_boss[tostring(id)] == nil and self.db.fuben >= v.unlock then
			index = index + 1
			unfinish_boss[tostring(index)] = v
		end
	end

	math.randomseed(os.time())
	local finish_num = 0
	for _, v in pairs(finish_boss) do
		finish_num = finish_num + 1
	end

	local cur_boss = {}	
	local rand_index
	local rand_boss
	for i=0, (max_num-1-finish_num) do
		if index - i < 1 then
			break
		end
		rand_index = math.random(index-i)
		rand_boss = unfinish_boss[tostring(rand_index)]
		cur_boss[tostring(rand_boss.battle_id)] = rand_boss
		local q_index = tostring(rand_index)
		local p_index = tostring(index-i)
		unfinish_boss[p_index], unfinish_boss[q_index] = unfinish_boss[q_index], unfinish_boss[p_index]
	end
	self:_setdbc('cur_boss', cur_boss)
end

--重置已完成BOSS
function avatar:_refresh_finish_boss()
	self.db.finish_boss = {}
	--重置奖励
	local award = self.db.boss_award
	for k, v in pairs(award) do
		award[k] = 0
	end
	self:_setdbc('boss_award', award)
	self:_setdbc('finish_boss', self.db.finish_boss)
end

function avatar:_get_cur_boss()
	return self.db.cur_boss
end

function avatar:_get_finish_boss()
	return self.db.finish_boss
end

--玩家刷新BOSS
function avatar:refresh_boss(sys)
	local money = self:_get_money()
	local diamond = self:_get_diamond()	
	local cost_money = 0 
	local cost_diamond = data.rmb_cost[7].cost
	if sys then
		self:_refresh_cur_boss()
		return
	end
	if money < cost_money then
		return
	end
	if diamond < cost_diamond then
		self.client.message('msg_more_diamond')
		return 
	end
	self:_add_money(-cost_money)
	self:_add_diamond(-cost_diamond)
	self:_refresh_cur_boss()
end

--添加已完成BOSS
function avatar:_add_finish_boss(id)
	if id == nil then
		return
	end
	local boss = data.boss_battle[id]
	if boss == nil then 
		return
	end
--[[
	local cur_boss = self:_get_cur_boss()
	for _id, boss in pairs(cur_boss) do
		if tostring(_id) == tostring(id) then
			self.db.cur_boss[tostring(id)] = nil
			break		
		end
	end]]
	if self:_del_cur_boss(id) == false then
		return
	end
	self.db.finish_boss[tostring(id)] = boss
	self:_setdbc('finish_boss', self.db.finish_boss)
end

--删除选中的BOSS
function avatar:_del_cur_boss(id)
	if id == nil then
		return false
	end
	if self.db.cur_boss[tostring(id)] == nil then
		return false
	end
	self.db.cur_boss[tostring(id)] = nil
	self:_writedb()
	self.client.sync_cur_boss(self.db.cur_boss)
	return true
end

--获取奖励
function avatar:get_boss_award(index)
	if index == nil then
		return
	end
	if index > max_num then
		return 
	end
	local finish_boss = self:_get_finish_boss()
	local finish_num = self:_get_tbl_lgt(finish_boss)
	local award = self.db.boss_award
	local items = {}
	if index > finish_num then
		return
	end
	if award[index] ~= 0 then
		return
	end	
	award[index] = 1
	self:_setdbc('boss_award', award)
--发钱
	local box_id = 20000 + index
	local d = data.box_drop[box_id]
	if d == nil then 
		return
	end
	local proxy_coin_num = d.proxy_money
	if proxy_coin_num and proxy_coin_num > 0 then
		self:_add_proxy_money(boss_coin_type, proxy_coin_num)
		table.insert(items, {number = proxy_coin_num, i_type = 'proxy_money'})
	end
	local money = d.money
	if money and money > 0 then
		self:_add_money(money)
	end
--item
	if d.drop ~= nil then
		for i, v in pairs(d.drop) do
			local tmp_arr = {}
			for idx, dat in pairs(v) do
				table.insert(tmp_arr, idx, dat[1])
			end
			local drop_item = utils.weight_random(tmp_arr)
			if drop_item ~= 0 then
				local t_item = self:_gain_item(drop_item, v[drop_item][2])
				if t_item ~= nil then
					table.insert(items, t_item)
					if item.is_equipment(t_item.type) then
						self:_sync_eq_to_frag(drop_item)
					end
				end
			end
		end
	end
	self.client.finish_boss_award(items)	

end

function avatar:_get_tbl_lgt(table)
	local cnt = 0 
	for k, v in pairs(table) do
		cnt = cnt + 1	
	end
	return cnt
end

function avatar:boss_battle_end(id, token)
	if id == nil or token == nil then
		return
	end
	if token ~= self.fuben_token then
		return
	end  
	if self.db.cur_boss[tostring(id)] == nil then
		return
	end
	local d = data.boss_battle[id]
	self:_add_finish_boss(d.battle_id)	
	self:_trigger_quest_event('boss')
	self.fuben_token = math.random(99999999999999)

	self.client.boss_battle_finish()
end
