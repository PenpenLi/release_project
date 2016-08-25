local battle		= import( 'game_logic.battle' )
local model			= import( 'model.interface' )
local tutor			= import( 'game_logic.tutor' )

tutorial = lua_class( 'tutorial', battle.battle )

function tutorial:_init( id, proxy )
	super(tutorial, self)._init( id, proxy )
	local player = model.get_player()
	player:set_tutor_done( false )
	self.proxy:hide_fuben_cnt()
	self.proxy:hide_auto_battle()
end

function tutorial:release()
	tutor.trigger('finish_tutor')
	local player = model.get_player()
	player:set_tutor_done( true )
	super(tutorial, self).release()
end

local _mana_cycle = 0
function tutorial:special_tick()
	if self.frame_count == 2 then
		tutor.trigger('enter_scene')
	end
	-- 每秒回复10点MP（平滑化：每0.1秒回复1点）
	_mana_cycle = _mana_cycle + 1
	if _mana_cycle * 2 % Fps == 0 then
		if self.main_player ~= nil then
			self.main_player.combat_attr:add_mp( 1 )
			self.main_player.combat_attr:add_hp( 10 )
		end
		_mana_cycle = 0
	end

end

function tutorial:create_player(tmp_id, player)
	tutor.init_tutor()

	local e = self.proxy:create_avatar(tmp_id, {type = 'player', role_type = 'tutor_' .. player.role_type} )
	e:init_player(player)

	return e
end

