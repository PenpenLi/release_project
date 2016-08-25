local battle			= import( 'game_logic.battle' )
local combat_attr 		= import( 'model.combat' )
local model 			= import( 'model.interface' )
local director			= import( 'world.director')
local music_mgr			= import( 'world.music_mgr' )
local operate_cmd 		= import( 'ui.operate_cmd')

warriortest = lua_class( 'warriortest', battle.battle )

function warriortest:_init( id, proxy )
	super(warriortest, self)._init( id, proxy )

end

function warriortest:begin(  )
	super(warriortest,self).begin()

	for i, e in pairs(self.entities) do
		if e.battle_group == 2 then
			e.buff:apply_buff( 9996 )
		end
	end
	-- _avatar = model.get_player()
end

function warriortest:victory( )
	local cast_skill = model.get_player():get_loaded_skills()  --装备的技能
	self.player_bef_skills = {}
	for idx = 1, 3 do
		local sk = cast_skill[idx]
		if sk ~= nil then
			self.player_bef_skills[idx] = sk.lv
		end
	end
	local account_data = {
		bef_lv	= self.player_bef_lv,
		gold = 0,
		diamond = 0,
		gain_exp = 0,
		soul_exp = 0,
		items = {},
		bef_skills = self.player_bef_skills
	}
	self.proxy:show_victory( account_data )
end

function warriortest:show_victory( args )
	local player = model.get_player()
	director.get_scene():pause()
	operate_cmd.enable(false)
	self.player_bef_lv = player:get_level()
	server.warriortest_battle_finish(self.id, tonumber(cc.UserDefault:getInstance():getStringForKey('battle_token')))
	self.proxy:down_battle_ui()
	director.show_loading()
	music_mgr.stop_bg_music()
	music_mgr.victory_music()
	return true
end
