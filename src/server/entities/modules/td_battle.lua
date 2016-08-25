local avatar			= import('entities.avatar').avatar
local email				= import('model.email')
local db				= import('db')
local timer				= import ('model.timer')
local utils				= import('utils')
local item				= import('model.item')

local _td_award_begin = 10000
local _td_award_count = 10
local _td_coin_type = 2
--获取奖励
function avatar:get_td_award(index)

	if index == nil then
		return
	end

	if self.db.td_chests[index] ~= 1 then
		return
	end
	
	--扣东西
	self.db.td_chests[index] = 0
	self:_writedb()
	self:_sync_td_fuben_chests()

	--发东西

	local items = {}
	--发钱
	local box_id = _td_award_begin + index
	local d = data.box_drop[box_id]
	if d == nil then 
		return
	end
	local proxy_coin_num = d.proxy_money
	if proxy_coin_num and proxy_coin_num > 0 then
		self:_add_proxy_money(_td_coin_type, proxy_coin_num)
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
	self.client.sync_td_award(items)
end

function avatar:td_battle_end(battle_id, token, td_home_hp)
	if battle_id == nil or token == nil then
		print('1 return')
		return
	end

	if self.db.td_fuben ~= 0 and battle_id - 1 ~= self.db.td_fuben then
		print('2 return', self.db.td_fuben, battle_id)
		return
	end

	if token ~= self.fuben_token then
		print('3 return')
		return
	end  

	self:_handler_td_flag(battle_id, td_home_hp)

	self.fuben_token = math.random(99999999999999)
	self.client.td_battle_finish()
end

function avatar:_handler_td_flag(battle_id, td_home_hp)

	self.db.td_fuben = battle_id
	local c = math.floor(battle_id%10) + 1
	self.db.td_chests[c] = 1
	self.db.td_home_hp = td_home_hp

	self:_sync_td_fuben_chests()
	self:_writedb()
end

function avatar:_sync_td_fuben_chests()
	self.client.sync_td_fuben_chests(self.db.td_fuben, self.db.td_chests, self.db.td_home_hp)
end

function avatar:_reset_td()
	self.db.td_fuben = 0
	self.db.td_home_hp = -1
	for i=1,_td_award_count do
		self.db.td_chests[i] = -1
	end
end
