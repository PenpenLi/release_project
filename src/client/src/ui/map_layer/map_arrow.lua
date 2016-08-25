local layer					= import( 'world.layer' )

map_arrow = lua_class('map_arrow',layer.ui_layer)

local _json_path = 1
function map_arrow:_init(id )
	self.json_path = 'gui/main' ..'/Ui-map_'..id ..'_arrow.ExportJson'
	self.json_name = 'Ui-map_'..id ..'_arrow.ExportJson'
	super(map_arrow,self)._init(self.json_path,false)
	self.id = id
	self.fuben_count = 0

	self.widget = ccs.GUIReader:getInstance():widgetFromJsonFile(self.json_path)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(0,0)
	self.cc:addChild(self.widget)
	self:play_anim( )
end

function map_arrow:play_anim(  )
	self:play_action(self.json_name,'jiantou')
end

function map_arrow:release(  )
	---ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(self.json_name)
	super(map_arrow,self).release()
end