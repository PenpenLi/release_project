local avatar			= import( 'model.avatar' )
local item				= import( 'model.item' )
local skill				= import( 'model.skill' )
local math_ext			= import( 'utils.math_ext' )

local _main_player = nil
local _players = {}

function get_players()
	return _players
end

function get_player(id)
	if id == nil then
		return _main_player
	end
	return _players[id]
end

function offline( offline_player_id )
	offline_player_id = offline_player_id or 1
	local server_data = data.offline[offline_player_id]
	server_data._id  = { _ = 'debug_user_id' }
	server_data.user_name = 'debug_user'
	server_data.password = ''
	server_data.fuben = 30000
	server_data.elite_fuben = 30000
	server_data.td_fuben = 0
	server_data.fuben_daily = {}
	server_data.loaded_skills = {}
	server_data.pvp_def_skills = {}
	server_data.proxy_money = {1000, 1000}

	--skills
	local skills = {}
	for i = 1, 3 do
		local skill_id = server_data['skill'..i]
		if skill_id ~= nil then
			skills[tostring(skill_id)] = {
				exp = 0,
				id = tonumber(skill_id),
				lv = server_data['skill'..i..'_lv'] or 1,
				star = server_data['skill'..i..'_star'] or 1,
			}
			server_data.loaded_skills[i] = skill_id
		end
	end
	server_data.skills = skills

	server_data.equips = {}
	server_data.wear = {}
	local function load_test_bag( item_type )
		local item_id = server_data[item_type]
		if item_id == nil then
			cclog(debug.traceback())
			return
		end
		local item_level = server_data[ item_type .. '_lv' ] or 1
		server_data.equips[tostring(item_id)] = {id=item_id, lv=item_level}
		server_data.wear[item_type] = item_id
	end

	load_test_bag('weapon')
	load_test_bag('armor')
	load_test_bag('helmet')
	load_test_bag('ring')
	load_test_bag('necklace')
	load_test_bag('shoe')

	server_data.strength_lv = {
		server_data.proficient1,
		server_data.proficient2,
		server_data.proficient3,
		server_data.proficient4,
		server_data.prokicient5,
		server_data.proficient6,
	}
	dir(server_data.strength_lv)

	local player = avatar.avatar()

	player:init_server_data(server_data)
	set_main_player(player)

	-- player:add_items(bag)
	player:finish_server_data()

	player:set_offline()
	player:add_pvp_candidate(player)
	player:set_pvp_player(player.id)
	return player
end


function add_player(p)
	_players[p.id] = p
end

function set_main_player(p)
	_main_player = p
	add_player(p)
end
