local avatar			= import('entities.avatar').avatar
local timer				= import ('model.timer')
local utils				= import ('utils')
local rmb_cost			= import('model.rmb_cost')

-- 10抽价格
local _m_price = 100
local _m_ten_price = 100 * 9

-- 满分必得贵重
local _m_total = 9
local _d_total = 3

-- 免费冷却时间
local _m_cd = 1 * 60
local _d_cd = 1 * 60

-- 经验书id
local book_id1 = 90002
local book_id2 = 90003

function avatar:lottery_draw_one_by_money( status )
	local d = data.lottery
	local idx = nil	

	if status and status == 'free' then
		
		if self.db.lottery.m_free <= 0 then
			-- 提示免费次数用完
			self.client.message('msg_free_chance_run_out')
			return
		end

		-- 时间比较
		local now_time = timer.get_now()
		if (now_time - self.db.lottery.m_time < _m_cd) then
			-- 提示免费时间未到 
			self.client.message('soul_skill_cd')
			return
		end
		--首次抽奖		
		if self.db.lottery.m_time == 0 then
			idx = 1	
		end
		
		self.db.lottery.m_free = self.db.lottery.m_free - 1
		self.db.lottery.m_time = now_time
	else
		-- 扣钱
		if _m_price > self:_get_money() then
			self.client.message('msg_more_gold')
			return
		end
		self:_add_money( -_m_price )
	end

	if idx == nil then
		-- 随机物品表中id
		idx = self:_m_rand_one()
	end
	local it = self:_gain_item( d[idx].goods_id, d[idx].count )

	-- 必得经验书
	self:_gain_item( book_id1, 1 )
	self:_trigger_quest_event('jiuGuan')
	self:_writedb()
	--self.client.sync_items( {it} )
	self.client.sync_lottery( self.db.lottery )
	self.client.lottery_money_one_result( idx, it.exist )
end

function avatar:lottery_draw_one_by_diamond( status )
	local d = data.lottery2
	local idx = nil
	
	if status and status == 'free' then
		
		--if self.db.lottery.d_free <= 0 then
			-- 提示免费次数用完
		--	self.client.message('msg_free_chance_run_out')
		--	return
		--end

		-- 时间比较
		local now_time = timer.get_now()
		if (now_time - self.db.lottery.d_time < _d_cd) then
			-- 提示免费时间未到 
			self.client.message('soul_skill_cd')
			return
		end
		--首次抽奖
		if self.db.lottery.d_time == 0 then
			idx = 1
		end	
		
		--self.db.lottery.d_free = self.db.lottery.d_free - 1
		self.db.lottery.d_time = now_time
	else
		-- 扣钻石
		if rmb_cost.get_cost_by_id( 3 ) > self:_get_diamond() then
			self.client.message('msg_more_diamond')
			return
		end
		self:_add_diamond( -rmb_cost.get_cost_by_id( 3 ) )

	end
	if idx == nil then
		idx = self:_d_rand_one()
	end
	local it = self:_gain_item( d[idx].goods_id, d[idx].count )

	-- 必得经验书
	self:_gain_item( book_id2, 1 )

	 self:_trigger_quest_event('jiuGuan')
	self:_writedb()
	--self.client.sync_items( {it} )
	self.client.sync_lottery( self.db.lottery )
	self.client.lottery_diamond_one_result( idx, it.exist )
end

function avatar:lottery_draw_ten_by_money()
	local d = data.lottery	

	if _m_ten_price > self:_get_money() then
		self.client.message('msg_more_gold')
		return
	end
	self:_add_money( -_m_ten_price )

	local idx_t = {}
	local exist = {}
	local items = {}
	for i=1,10 do
		local idx = self:_m_rand_one()
		table.insert(idx_t, idx)
		local it = self:_gain_item( d[idx].goods_id, d[idx].count )
		if it.exist ~= nil then exist[tostring(idx)] = 1 end
		table.insert(items, it)
		self:_trigger_quest_event('jiuGuan')
	end
	-- 必得经验书
	self:_gain_item( book_id1, 10 )

	--sync
	self:_writedb()
	--self.client.sync_items( items )
	self.client.sync_lottery( self.db.lottery )
	self.client.lottery_money_ten_result( idx_t, exist )
end

function avatar:lottery_draw_ten_by_diamond()
	local d = data.lottery2

	if rmb_cost.get_cost_by_id( 4 ) > self:_get_diamond() then
		self.client.message('msg_more_diamond')
		return
	end
	self:_add_diamond( -rmb_cost.get_cost_by_id( 4 ) )

	local idx_t = {}
	local exist = {}
	local items = {}
	for i=1,10 do
		local idx = self:_d_rand_one()
		table.insert(idx_t, idx)
		local it = self:_gain_item( d[idx].goods_id, d[idx].count )
		if it.exist ~= nil then exist[tostring(idx)] = 1 end
		table.insert(items, it)
		self:_trigger_quest_event('jiuGuan')
	end
	-- 必得经验书
	self:_gain_item( book_id2, 10 )
	
	--sync
	self:_writedb()
	--self.client.sync_items( items )
	self.client.sync_lottery( self.db.lottery )
	self.client.lottery_diamond_ten_result( idx_t, exist )
end

function avatar:_draw_precious(d)
	local idx = 1

	local weights = {}
	local key_value = {}

	for i,v in ipairs(d) do
		if v.precious then
			table.insert(weights, v.drop)
			key_value[#weights] = i
		end
	end
	local key = utils.weight_random(weights)
	idx = key_value[key]
	return idx
end

function avatar:_draw_normal(d)
	local idx = 1
	local weights = {}
	
	for i,v in ipairs(d) do
		table.insert(weights, v.drop)
	end
	idx = utils.weight_random(weights)
	return idx
end

function avatar:_m_rand_one()
	local d = data.lottery
	local idx = 1

	if self.db.lottery.m_total >= _m_total then
		idx = self:_draw_precious(d)
	else
		idx = self:_draw_normal(d)
	end
	
	self.db.lottery.m_total = self.db.lottery.m_total + d[idx].point
	if self.db.lottery.m_total < 0 then
		self.db.lottery.m_total = 0
	end
	return idx 
end

function avatar:_d_rand_one()
	local d = data.lottery2
	local idx = 1

	if self.db.lottery.d_total >= _d_total then
		idx = self:_draw_precious(d)
	else
		idx = self:_draw_normal(d)
	end
	
	self.db.lottery.d_total = self.db.lottery.d_total + d[idx].point
	if self.db.lottery.d_total < 0 then
		self.db.lottery.d_total = 0
	end
	return idx 
end

function avatar:_sync_time()
	self.client.sync_time(timer.get_now())
end
