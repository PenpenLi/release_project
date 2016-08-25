local scene						= import( 'world.scene' )
local layer						= import( 'world.layer' )
local chose_characters_layer	= import( 'ui.chose_characters_layer.chose_characters_layer' )
local ui_mgr					= import( 'ui.ui_mgr' )
local loading_layer				= import( 'ui.loading_layer.loading_layer' )

loading_scene = lua_class( 'loading_scene', scene.scene )
local _json = 'res/login/Ui-landing_checkupdate.ExportJson'

function loading_scene:_init()
	--super(loading_scene, self)._init()
	self.cc = cc.Scene:create()
	self.loading_layer = loading_layer.loading_layer()
	self.cc: addChild( self.loading_layer.cc )
	self.loading_layer.cc: setLocalZOrder( ZUILoading )
end

function loading_scene:enter_scene()
	super(loading_scene, self).enter_scene()
	self.bg_layer = ccs.GUIReader:getInstance():widgetFromJsonFile(_json)
	self.bg_layer: setAnchorPoint(0, 0)
	self.bg_layer: setPosition(cc.Director:getInstance():getVisibleSize().width/2, cc.Director:getInstance():getVisibleSize().height/2)
	self.cc:addChild( self.bg_layer )
end


function loading_scene:scene_release()
	print('loading_scene scene_release')
	cc.Director:getInstance():getTextureCache():removeTextureForKey('res/login/login0.png')
	cc.Director:getInstance():getTextureCache():removeTextureForKey('res/login/login1.png')
end
