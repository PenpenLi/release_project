local scene					= import( 'world.scene' )
local layer					= import( 'world.layer' )
local main_map				= import( 'ui.main_map' )
local guider            	= import( 'ui.guider.guider')
local guider_trigger    	= import( 'ui.guider.guider_trigger')
local camera_mgr        	= import( 'game_logic.camera_mgr')
local msg_queue 			= import( 'ui.msg_ui.msg_queue' )
local ui_mgr 				= import( 'ui.ui_mgr' ) 
local music_mgr					= import( 'world.music_mgr' )

main_scene = lua_class( 'main_scene', scene.scene )


local eicon_set = 'icon/e_icons.plist'
local sicon_set = 'icon/s_icons.plist'

function main_scene:_init()
	--cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	-- cc.SpriteFrameCache: getInstance(): addSpriteFrames( sicon_set )
	super(main_scene, self)._init()
	-- self.layer = main_map.main_map()
	-- self.cc:addChild( self.layer.cc )
end

function main_scene:enter_scene()
	super(main_scene, self).enter_scene()
	_extend.motion_stop()
	-- self.layer = main_map.main_map()
	self.layer = ui_mgr.create_ui(main_map, 'main_map')
	--self.main_surface_layer = import('ui.main_ui.main_surface_layer').main_surface_layer()
	ui_mgr.create_ui(import('ui.main_ui.main_surface_layer'), 'main_surface_layer')
	-- self.cc:addChild(self.layer.cc)
	-- self.cc:addChild(self.main_surface_layer.cc)
	if cc.UserDefault:getInstance():getBoolForKey('bg_music_on', true) then
		music_mgr.play_normal_bg_music()
	end
end

function main_scene:scene_tick()
	self.layer:tick()
end

function main_scene:scene_release()
	--cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( eicon_set )
	-- cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( sicon_set )
	self.layer:release()
	--self.main_surface_layer:release()
end

