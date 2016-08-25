local avatar			= import('entities.avatar').avatar
local item				= import('model.item')
local email				= import('model.email')
--[[
$tili int							--增加体力[tili 100]
$exp int							--增加经验[exp 100]
$item item_id						--获得item_id的物品[item 10001]
$skill skill_id star lv				--修改或获得skill_id的技能，star星级，lv等级 [107 3 12]
$qh type lv							--设置武器的强化等级[qh weapon 12]

--]]
local _star_space = 1000

function avatar:_gm_vip()
	self.db.vip = {lv = 1,diamond = 0}
	self:_writedb()
end

function avatar:_gm_sweep( num )
	self:_setdbc('sweep_ticket',self.db.sweep_ticket + num)
end

function avatar:_gm_fuben_daily(id,num)
    local fuben_data = data.fuben[tonumber(id)]
    local fuben_id  = fuben_data.instance_id
    local chapter_id    = fuben_data.chapter_id
    star_id = chapter_id * _star_space + fuben_id
    local bid   = tostring(star_id)
	self.db.fuben_daily[bid] = tonumber(num)
	self.client.sync_one_fuben_daily(bid,tonumber(num))
	self:_writedb()
	self.client.server_method_finished()
end

function avatar:_gm_reset_time(num)
	 self:_setdbc('fuben_reset_daily',tonumber(num))
end

function avatar:_gm_mall()
	self.db.mall = {}
	self:_writedb()
end

function avatar:_gm_proxy_money( proxy_type, num)
	proxy_type	= tonumber(proxy_type)
	num			= tonumber(num)
	self.db.proxy_money[proxy_type] = self.db.proxy_money[proxy_type] + num 
end

function avatar:_gm_month_card()
	self.db.month_card = 10
	self:_writedb()
end

function avatar:_gm_clear_quest()
	self.db.quest = {}
	self:_init_quest()
	self.client.sync_quest(self.db.quest)
end
function avatar:_gm_quest()
	local j = 0
	for i, v in pairs(self.db.quest_daily) do
		if self.db.quest_daily[i] ~= 1 then
			self.db.quest_daily[i].cnt = data.quest_daily[tonumber(i)].condition_count 
			j = j + 1
		end
		if j == 3 then
			break
		end
	end
	
	self.client.sync_quest_daily(self.db.quest_daily)
end

function avatar:_gm_lottery(m_free)
	self.db.lottery.m_free = tonumber(m_free)
	self.client.sync_lottery(self.db.lottery)
end
function avatar:_gm_char(char)
	self:_setdbc('role_type', char)
end

function avatar:_gm_lv(level)
	self:_setdbc('lv', tonumber(level))
end

function avatar:_gm_tili(tili)
	self:_add_energy(tonumber(tili))
end

function avatar:_gm_qh(item_type, lv)
	if not item.is_equipment(item_type) then
		return
	end
	self:_set_item_level(self.db.wear[item_type], tonumber(lv))
end

function avatar:_gm_exp(exp)
	self:_add_exp(tonumber(exp))
end

function avatar:_gm_money(money)
	self:_add_money(tonumber(money))
end

function avatar:_gm_gem(gem)
	self:_add_diamond(tonumber(gem))
end

function avatar:_gm_item(item_id, item_num)
	self:_gain_item(tonumber(item_id), tonumber(item_num))
end

function avatar:_gm_shop_sx(val)
	self:_add_shop_f5_times(tonumber(val))
end

function avatar:_gm_suipian(skillid, num)
	self:_add_soul_frag(skillid, num)
end

function avatar:_gm_skill(skill_id, star, lv)
	skill_id = tonumber(skill_id)
	local skill_str = tostring(skill_id)
	if data.skill[skill_id] == nil then
		return
	end

	if self.db.skills[skill_str] == nil then
		self:_gain_skill(skill_id)
	end

	local s = self.db.skills[skill_str]
	if s == nil then
		return
	end

	if star ~= nil then
		star = tonumber(star)
		if data.skill[skill_id][star] ~= nil then
			s.star = star
		end
	end

	if lv ~= nil then
		lv = tonumber(lv)
		if type(lv) == 'number' then
			s.lv = lv
		end
	end
	self.client.update_skill(s)
	self:_writedb()
end

function avatar:_gm_eq_frag(color, position, num)
	color = string.upper(string.sub(color,1,1)) .. string.sub(color, 2)
	self:_add_equip_frag(color, position, tonumber(num))
end

function avatar:_gm_eq_stone(color, num)
	color = string.upper(string.sub(color,1,1)) .. string.sub(color, 2)
	self:_add_equip_qh_stone(color, tonumber(num))
end

function avatar:_gm_eq_gain(equip_id_str)
	local equip_id = tonumber(equip_id_str)
	self:_gain_equip(equip_id)
	self:_sync_equips( {equip_id_str} )
end

function avatar:_gm_eq_wear(equip_id_str)
	local equip_id = tonumber(equip_id_str)
	if self:_wear_equip(equip_id) == true then
		self:_sync_wearing(equip_id)
	end
end

function avatar:_gm_eq_qh(equip_id_str)
	self:_equip_levelup(equip_id_str)
	self:_sync_equips( {equip_id_str} )
end

function avatar:_gm_gain_item(item_id, item_number)
	item_id = tonumber(item_id)
	item_number = tonumber(item_number)
	local it = self:_gain_item(item_id, item_number)
	for _, it in pairs(self.bag) do
		local num = it.number or 1
		print(it.id, num, type(it.id), type(num))
	end
	self.client.sync_items({it})
end

function avatar:_gm_strength(type_id, lv)
	type_id = tonumber(type_id)
	lv = tonumber(lv)
	if lv > 80 or type_id > 6 then 
		return 
	end
	local strength_lv = self:_get_strength_lv()
	strength_lv[type_id] = lv
	self:_setdbc('strength_lv', strength_lv)		
end

function avatar:_gm_email(eid)
	eid = tonumber(eid)
	email.send_email(eid, entities)
end

function avatar:_gm_gain_email()
	self:_sync_emails()
end

function avatar:_gm_read_email(id)
	self:read_email(tonumber(id))
end

function avatar:_gm_daily_update()
	self.db.daily_timestamp = 0
	self:_daily_update()
	self:_sync_quests()
end

function avatar:_gm_fb_last( battle_id )
	self.db.fuben = tonumber(battle_id)
	self:_setdbc('fuben', self.db.fuben)
end

function avatar:_gm_reff()
	self:_refresh_finish_boss()
end

function avatar:_gm_fb_elast( battle_id )
	self.db.elite_fuben = tonumber(battle_id)
	self:_setdbc('elite_fuben', self.db.elite_fuben)
end

function avatar:gm_cmd(cmd, args)
	-- need auth
	self['_gm_'..cmd](self, unpack(args))
end

function avatar:_gm_pvp_ticket(n)
	self.db.pvp_ticket.count = tonumber(n)
	self.client.sync_pvp_ticket(self.db.pvp_ticket)
end
