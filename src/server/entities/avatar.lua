local db				= import('db')
local config			= import('config')
local item				= import('model.item')
local player_mgr		= import('model.player_mgr')
local utils				= import ('utils')
local pvp_const			= import('const.pvp_const')
local db_mesg			= import('model.db_mesg')

avatar = lua_class( 'avatar' )
import('entities.modules.property')
import('entities.modules.skill')
import('entities.modules.item')
import('entities.modules.quest')
import('entities.modules.shop')
import('entities.modules.chat')
import('entities.modules.battle')
import('entities.modules.gm')
import('entities.modules.strengthen')
import('entities.modules.equipment')
import('entities.modules.email')
import('entities.modules.lottery')
import('entities.modules.sign_in')
import('entities.modules.mall')
import('entities.modules.exchange_mall')
import('entities.modules.pvp')
import('entities.modules.boss_battle')
import('entities.modules.midas_touch')
import('entities.modules.guide')
import('entities.modules.vip')
import('entities.modules.traceback')
import('entities.modules.td_battle')
import('entities.modules.warriortest_battle')

default_db = {
	password		= '',
	role_type		= 'cike',
	nick_name		= '',
	lv				= 1,
	money			= 1000,
	diamond			= 0,
	energy			= 100,
	exp				= 0,
	energy_buy_daily = 0,
	fuben_reset_daily = 0,
	month_card		= 0,
	equip_stone		= {},
	equip_frag		= {}, -- for activation,  key format: 'Color_type'
	equip_qh_stone	= {}, -- for strengthen,  key format: 'Color'
	equips			= {},
	wear			= {},
	soul_frag		= {},
	skills			= {},
	loaded_skills	= {},
	fuben			= 0,
	elite_fuben		= 0,
	td_fuben		= 0,
	td_chests		= {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
	td_home_hp		= -1,
	fuben_daily		= {},
	quest			= {},
	quest_complete	= {},
	quest_daily		= {},
	latest_sign_time = 0,
	sign_in_times   = 0,
	mall			= {},
	vip				= {lv = 0,diamond = 0},
	daily_timestamp = 0,
	strength_lv		= {1,1,1,1,1,1},  --1.power 2.courage 3.technique 4.life 5.strong 6.tenacity 
	emails			= {},
	exchange_goods	= {},
	next_refresh_time = {0,0},
	fc				= 0,
	lottery			= {m_free = 5, m_time = 0, d_time = 0, m_total = 0, d_total = 0 },
	pvp_point		= 1100,
	rand			= utils.get_random(),
	pvp_honor		= 100,
	pvp_ticket		= { count = pvp_const.Ticket, time = 0},
	pvp_candidate	= {},
	pvp_candidate_flag = {},
	pvp_candidate_refresh_time = 0,
	pvp_record		= {},
	pvp_def_skills	= {},
	proxy_money		= {0,0},  -- index: 1|pvp; 2|td 
	sweep_ticket    = 0,
	cur_boss		= {},
	finish_boss		= {},
	boss_award		= {0, 0, 0},
	midas_touch_cnt = 0,
	midas_con_cnt   = 0,
	guide_done		= {},
	last_login		= 0,
	guide_state		= {},
	last_tili_recover_time = 0,
	wing			= {id=1},
}


function avatar:_init(pid)
	self.pid = pid
	self.is_new_user = false
	self.fuben_token = 0
	self.client_attr = {
		'_id',
		'username',
		'role_type',
		'nick_name',
		'lv',
		'money',
		'diamond',
		'energy',
		'exp',
		'energy_buy_daily',
		'fuben_reset_daily',
		'equip_frag',
		'equip_qh_stone',
		'equips',
		'wear',
		'soul_frag',
		'skills',
		'loaded_skills',
		'fuben',
		'elite_fuben',
		'td_fuben',
		'td_chests',
		'td_home_hp',
		'fuben_daily',
		'shop_f5_times',
		'strength_lv',
		'emails',
		'fc',
		'lottery',
		'sign_in_times',
		'latest_sign_time',
		'proxy_money',
		'vip',
		'mall',
		'pvp_point',
		'rand',
		'pvp_honor',
		'pvp_ticket',
		'pvp_candidate',
		'pvp_candidate_flag',
		'pvp_candidate_refresh_time',
		'pvp_record',
		'pvp_def_skills', 
		'cur_boss',
		'finish_boss',
		'boss_award',
		'midas_touch_cnt',
		'midas_con_cnt',
		'sweep_ticket',
		'last_login',	
		'wing',
	}
	self.quest_event = {}
	--syslog('avatar', 'init', self.pid)
end

--此方法内有协程切换
function avatar:_login(username, token)
	self.username = username

	player_mgr.login(username, self.pid)
	--Warning: 协程切换
	self:_init_player()

	local status, pid = player_mgr.check_status(username)
	--如果此账号并非正在登陆，则退出
	if status ~= 'login_begin' or pid ~= self.pid then
		return
	end
	player_mgr.login_finish(username)

	--self:_log('normal_login', self.pid)
	self:_login_ok()
end

function avatar:_replace_login(pid)
	self:_log('replace_login', pid, self.pid)
	self.pid = pid
	player_mgr.replace_login(self.username, pid)
	self:_login_ok()
end

function avatar:_login_ok()
	db.set_default_db(self.db, default_db)
	self.client.login_ok('ok')
	local sync_attr = {}
	for k, v in pairs(self.client_attr) do
		sync_attr[v] = self.db[v]
	end
	self.client.player_online(sync_attr)
	self:_init_quest()
	self:_init_quest_daily()
	self:_update_food()
	self:_time_str_to_sec()
	self:_update_exchange_mall()
	self:_sync_exchange_mall()
	self:_sync_mc_left_day()
	self:_sync_items()
	self:_sync_shops()
	self:_sync_chat_his() --获取聊天记录
	self:_sync_emails()  --获取邮件
	self:_sync_time()
	self:_update_pvp_all()
	self:_daily_update()
	self:_sync_midas_touch()
	self:_sync_midas_con_cnt()
	self:_sync_quests() 
	self:_sync_ui_guide()
	db_mesg.check_offline_mesg(self)	-- 玩家登陆时，处理离线时的数据
	self:_recalc_fc()
	self:_set_last_login()
	self.client.finish_login(self.is_new_user)
end

--此方法内有协程切换
function avatar:_create_avatar()
	local mdb = db.get_mongo()
	--创建基础信息
	self.db = {
		_id				= db.gen_oid(),
		username		= self.username,
	}
	db.set_default_db(self.db, default_db)

	--初始化任务
	self:_init_quest()
	self:_refresh_normal_shop()

	-- 添加所有技能测试用
	--for i,_ in pairs(data.skill) do
	--	self:_gain_skill(i)
	--end

	local oid = self.db._id

	for i = 1, 6 do
		local e_id = tonumber(i .. '0003')
		self:_gain_equip(e_id)
		self:_wear_equip(e_id)
	end

	--写db
	--Warning: 协程切换
	--mdb:insert(db.TBL_USER, {self.db}, false)
	
	self:_recalc_fc()
end

--此方法内有协程切换
function avatar:_init_player()
	local mdb = db.get_mongo()

	--初始化基础信息
	--Warning: 协程切换
	--local cur = mdb:find(db.TBL_USER, {username = self.username}, {})
	--local idx, tbl = cur:pairs()(cur)
	local _, tbl = mdb:query(db.TBL_USER, {username = self.username}, {}, 0, 1)
	self.db = tbl[1]

	self.bag = {}
	self.item_map = {}
	self.shop1 = {}
	self.shop2 = {}

	if self.db == nil then
		--Warning: 协程切换
		self:_create_avatar()
		self.is_new_user = true
	end
	
	if self.db.nick_name == nil or self.db.nick_name == '' then
		self.is_new_user = true
	end
	--初始化背包
	--Warning: 协程切换
	--require("jit.p").start('3si4m1', 'jitprof.log')
	local cur = mdb:find(db.TBL_ITEM, {owner_oid = self.db._id}, {})
	for _, it in cur:pairs() do
		local bag = it.bag
		if bag == 'bag' then
			self.bag[it._id] = it
			self:_add_item_map(it)
		elseif bag == 'shop1' then
			self.shop1[it._id] = it
		elseif bag == 'shop2' then
			self.shop2[it._id] = it
		end
	end
	--require("jit.p").stop()
	self.garbage = {}
end

--此方法内有协程切换
function avatar:_logout()
	local status, pid = player_mgr.check_status(self.username)
	if status ~= 'online' or pid ~= self.pid then
		return
	end

	--下线过程不可被破坏
	--player_mgr.logout_begin(self.username)

	self:_log('logout')
	--db.user_save_now(self.db._id)
	self:_writedb()

	for key,obj in pairs(self.bag) do
		db.item_save(obj)
	end
	for key,obj in pairs(self.garbage) do
		db.item_save(obj)
	end

	player_mgr.logout(self.username)
end

function avatar:_log(sys, ...)
	print('['..os.date()..']['..db.oid_to_str(self.db._id)..']['..tostring(sys)..']', ...)
end

