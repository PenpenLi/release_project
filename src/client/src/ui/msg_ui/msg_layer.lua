
local layer				= import( 'world.layer' )
local msg_queue 		= import( 'ui.msg_ui.msg_queue' )
local ui_const 				= import( 'ui.ui_const' )
msg_layer = lua_class( 'msg_layer' , layer.ui_layer)
local locale				= import( 'utils.locale' )

--停留时间
local _stop_time = 1.2
--渐现时间
local _fade_time = 0.3
--向上移动时间
local _move_time = 0.4
--文本字体大小
local _font_size = 30 

local _edge = 1

local _json_path = 'gui/global/ui_msg.ExportJson'
local _json_name = 'ui_msg.ExportJson'
local _json_plist = 'gui/ui_msg/ui_msg0.plist'

function msg_layer:_init(  )
	-- body
	super(msg_layer,self)._init(_json_path)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)

	msg_queue.clean_queue()
	self.frame_count = 0
	self.id = 1
end

function msg_layer:tick(  )

	self.frame_count = self.frame_count + 1
	if self.frame_count % 40 == 0 then 
		local queue = msg_queue.get_queue()
		if queue[self.id] == nil then
			return
		end
		local temp = queue[self.id]
		--创建文本
		if type(temp) == 'string' then
			local msg = self:create_with_str(temp)
			
		end

		--创建物品提示
		if temp.item_id ~= nil then
			self:create_with_item(temp)
		end
		--战斗力提升
		if temp.strength_lift ~= nil then
			self:create_with_num(temp.strength_lift)
		end

		msg_queue.clean( self.id )
		self.id = self.id + 1
	end
end

function msg_layer:create_with_num( value )
	
	self:reload_json()
	local battle_f = self:get_widget('battle_msg')
	local battle_msg = battle_f:clone()
	battle_msg:setName('battle')
	local lbl_num = battle_msg:getChildByName('lbl_num')
	if value < 0 then
		battle_msg:getChildByName('str_cont'):setString(locale.get_value('msg_fc_decline'))
		lbl_num:setString(tostring(-value))
	elseif value ~= 0 then
		lbl_num:setString(tostring(value))
	end
	lbl_num:enableOutline(ui_const.UilableStroke, _edge)
	--以node原点加到场景中心
	battle_msg:setOpacity(0)
	battle_msg:setCascadeOpacityEnabled(true)
	battle_msg:setPosition(0,0)
	self.cc:addChild(battle_msg)

	local fade = cc.FadeTo:create(_fade_time,255)
	local move = cc.MoveBy:create(_move_time,cc.p(0,50))
	local function callFunc( )
		--恢复触摸
		
		battle_msg:removeFromParent()
	end
	local callFuncObj=cc.CallFunc:create(callFunc)

	battle_msg:runAction( cc.Sequence:create( cc.Spawn:create(fade, move),cc.DelayTime:create(_stop_time),callFuncObj))

end


function msg_layer:create_with_str( str )
	
	self:reload_json()
	local str_f = self:get_widget('str_msg')
	local  str_msg = str_f:clone()
	str_msg:setName('str')
	local str_cont = str_msg:getChildByName('str_cont')
	str_cont:setString(str)
	str_cont:enableOutline(ui_const.UilableStroke, _edge)
	--以node原点加到场景中心
	str_msg:setOpacity(0)
	str_msg:setCascadeOpacityEnabled(true)
	str_msg:setPosition(0,0)
	self.cc:addChild(str_msg)

	local fade = cc.FadeTo:create(_fade_time,255)
	local move = cc.MoveBy:create(_move_time,cc.p(0,50))
	local function callFunc( )
		--恢复触摸
		
		str_msg:removeFromParent()
	end
	local callFuncObj=cc.CallFunc:create(callFunc)

	str_msg:runAction( cc.Sequence:create( cc.Spawn:create(fade, move),cc.DelayTime:create(_stop_time),callFuncObj))

end


function msg_layer:create_with_item( it_data )
	self:reload_json()
	local item_f = self:get_widget('item_msg')
	local item_msg = item_f:clone()
	item_msg:setName('item')
	local item_act = item_msg:getChildByName('item_act')
	local item_name = item_msg:getChildByName('item_name')
	local item_num = item_msg:getChildByName('item_num')
	item_act:enableOutline(ui_const.UilableStroke, _edge)
	item_name:enableOutline(ui_const.UilableStroke, _edge)
	item_num:enableOutline(ui_const.UilableStroke, _edge)
	local it_id = it_data.item_id
	if data[data.item_id[it_id]][it_id] ~= nil then
		local name = data[data.item_id[it_id]][it_id].name
		local color = data[data.item_id[it_id]][it_id].color
		local num = it_data.item_num
		if name ~= nil then
			item_name:setString('['..name ..']')
			item_name:setPositionX(item_act:getPositionX()+item_act:getContentSize().width/2)
		end
		if color ~= nil then
			item_name:setColor(Color[color])
		end
		if num ~= nil then
			item_num:setVisible(true)
			item_num:setString('X'..num)
			item_num:setPositionX(item_name:getPositionX()+item_name:getContentSize().width)

		else
			item_num:setVisible(false)
		end

		--以node原点加到场景中心
		item_msg:setOpacity(0)
		item_msg:setCascadeOpacityEnabled(true)
		item_msg:setPosition(0,0)
		self.cc:addChild(item_msg)

		local fade = cc.FadeTo:create(_fade_time,255)
		local move = cc.MoveBy:create(_move_time,cc.p(0,50))
		local function callFunc( )
			--恢复触摸
			
			item_msg:removeFromParent()
		end
		local callFuncObj=cc.CallFunc:create(callFunc)

		item_msg:runAction( cc.Sequence:create( cc.Spawn:create(fade, move),cc.DelayTime:create(_stop_time),callFuncObj))
	end
end




function msg_layer:release(  )
	
	super(msg_layer, self).release()
end