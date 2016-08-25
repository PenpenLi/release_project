local ui_const 			= import( 'ui.ui_const' )
local layer 			= import('world.layer')
local vir_item 			= import('ui.victory_layer.vir_item')	
local director			= import( 'world.director' )

vir_list = lua_class( 'vir_list',layer.ui_layer )
local _json_file = 'gui/battle/ui_achieve.ExportJson'
local _json_name = 'ui_achieve.ExportJson'
local eicon_set 	= 'icon/e_icons.plist'
local iicon_set 	= 'icon/item_icons.plist'
local soul_set 		= 'icon/soul_icons.plist'

function vir_list:_init(  )
	super(vir_list,self)._init(_json_file,true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self:play_action(_json_name,'Animation0')
	self.list = self:get_widget('ListView_5')
	self.lbl_title = self:get_widget('lbl_title')
	--self.lbl_title:setFontName(ui_const.UiLableFontType)
	self.touch_count  = 0
	self.remove = false
	self.is_remove = false
	
end
function vir_list:play_anim( call_back )
	local function callFunc(  )
		call_back()
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action(_json_name,'Animation0',callFuncObj)
end

function vir_list:add_items( items )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( eicon_set )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( iicon_set )
	cc.SpriteFrameCache:getInstance():addSpriteFrames( soul_set )
	for i, v in pairs(items) do
		local item = vir_item.vir_item(self)
		local img_file = data[v.type][v.id].icon
		local name = data[v.type][v.id].name
		local color = data[v.type][v.id].color
		item:set_img(img_file)
		item:set_name(name,color)
		item:set_color(color)
		self.list:addChild(item:get_cell())
	end
end

--触摸事件
function vir_list:touch_begin_event( touch, event )
	-- body
	if self.remove == true and self.touch_count <= 0 then
		self.touch_count = self.touch_count + 1
		self.remove = false
		self.cc:setVisible(false)
		director.get_scene():resume()
		self.is_remove = true 
		self.call_back()
	end

end

--到那个地方，回调一个函数
function vir_list:go_to_destination( func )
	self.call_back = func
end



function vir_list:can_remove( )
	self.remove = true
end

function vir_list:release(  )
	self.is_remove = false
	super(vir_list,self).release()
end

function vir_list:reload(  )
	super(vir_list,self).reload()
end
