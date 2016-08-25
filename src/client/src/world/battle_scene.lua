local layer				= import( 'world.layer' )
local battle_layer		= import( 'world.battle_layer' )
local fast_actions		= import( 'utils.actions' )
local camera_mgr		= import( 'game_logic.camera_mgr' )
local command_mgr		= import( 'game_logic.command_mgr' )
local battle			= import( 'game_logic.battle' )
local show_global		= import('utils.show_global')
local battle_const		= import( 'game_logic.battle_const' )
local motion_streak 	= import( 'ui.motion_streak' ) 
local scene				= import( 'world.scene' )

battle_scene = lua_class( 'battle_scene', scene.scene)


function battle_scene:_init(id)
	self.pause_flag = false
	super(battle_scene, self)._init()

	self.begin_id = id	self:enter_battle(id)
end

function battle_scene:enter_battle( id )
	self.goto_id = id
end

function battle_scene:scene_tick()

	if self.goto_id ~= nil then
		self.id = self.goto_id
		id = self.id
		self.goto_id = nil
		if self.layer ~= nil then
			self.logic:release()
			self.layer:release()
			ccs.ActionManagerEx:getInstance():releaseActions()
			self.layer.cc:removeFromParent()
			self.layer = nil
		end

		camera_mgr.init()
		motion_streak.remove_all_motion()

		self.id = id
		local fuben_data = data.fuben[id]
		local layer = battle_layer.battle_layer( fuben_data.scene_id, id )
		self.layer = layer
		local battle_type = fuben_data.type
		if battle_type ~= nil then
			self.logic = import( 'game_logic.battles.'..battle_type )[battle_type](id, layer)
		else
			self.logic = battle.battle( id, layer )
		end
		self.logic:begin()

		self.cc:addChild( layer.cc )

		collectgarbage("collect")
		collectgarbage("stop")
	end

	if self.pause_flag == false then
		camera_mgr.tick()
		self.logic:tick()
		self.layer:tick()
	end
end

function battle_scene:scene_release()
	self.logic:release()
	self.layer:release()
end

function battle_scene:pause()
	self.pause_flag = true
	self.layer:pause()
end

function battle_scene:resume()
	self.pause_flag = false
	self.layer:resume()
end

function battle_scene:is_pause()
	return self.pause_flag
end

function battle_scene:get_begin_id()
	return self.begin_id
end