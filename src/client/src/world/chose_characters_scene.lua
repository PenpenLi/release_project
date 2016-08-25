local scene						= import( 'world.scene' )
local layer						= import( 'world.layer' )
local chose_characters_layer	= import( 'ui.chose_characters_layer.chose_characters_layer' )
local ui_mgr					= import( 'ui.ui_mgr' )

chose_characters_scene = lua_class( 'chose_characters_scene', scene.scene )


function chose_characters_scene:_init()

	super(chose_characters_scene, self)._init()
	-- self.layer = chose_characters_layer.chose_characters_layer()
	-- self.cc:addChild( self.layer.cc )
	


end

function chose_characters_scene:enter_scene()
	super(chose_characters_scene, self).enter_scene()
	self.layer = ui_mgr.create_ui(chose_characters_layer, 'chose_characters_layer')
end


function chose_characters_scene:scene_release()
	self.layer:release()
end
