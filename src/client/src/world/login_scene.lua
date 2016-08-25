local scene				= import( 'world.scene' )
local layer				= import( 'world.layer' )
local ui_mgr			= import( 'ui.ui_mgr' )
local login_layer			= import( 'ui.login.login_layer' )

login_scene = lua_class( 'login_scene', scene.scene )


function login_scene:_init()
	super(login_scene, self)._init()

	-- self.layer = login_layer.login_layer()
	-- self.layer.cc:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	-- self.cc:addChild( self.layer.cc )
end

function login_scene:enter_scene()
	super(login_scene, self).enter_scene()

	self.layer = ui_mgr.create_ui(login_layer, 'login_layer')
end

function login_scene:scene_tick()
	self.layer:tick()
end

function login_scene:scene_release()
	self.layer:release()
end
