
local layer					= import( 'world.layer' )
local director				= import( 'world.director'  )
local main_map				= import( 'ui.main_map' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local model 				= import( 'model.interface' )
local math_ext				= import( 'utils.math_ext')
local shaders				= import( 'utils.shaders' )
local map_arrow 			= import( 'ui.map_layer.map_arrow' )

elite_map_page = lua_class('elite_map_page',layer.ui_layer)

function elite_map_page:_init( layer,map_id ,chapter_id )
	self.parent = layer
	super(elite_map_page,self)._init('gui/main'.. '/Ui-map_'..map_id ..'.ExportJson',false)
	
	self.id = map_id
	self.cur_chapter = chapter_id
	self.fuben_count = 0
	--self.widget = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/main'..'/Ui-map_'..map_id ..'.ExportJson')
	self.widget:setPosition(0,-4)
	--self.cc:addChild(self.widget)
	self:create_button( chapter_id )
	self:set_permit_btn()

end

function elite_map_page:get_widget(name)
	return ccui.Helper:seekWidgetByName(self.widget, name)
end

function elite_map_page:create_button( chapter_id )
	--print('进来了',chapter_id)
	if chapter_id == nil then
		return
	end
	self.cur_chapter = chapter_id
	--print('进来了')
	local count = 0
	self.big_btns = {}

	local function replace_scene( sender, eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			local lbl=string_split(sender:getName(),'_')
			local get_event_arg = tonumber(lbl[1])
			if self.cur_chapter ~= nil then
				local fuben_def = data.fuben_entrance[self.cur_chapter][get_event_arg]
				if fuben_def ~= nil then
					--sender:setTouchEnabled(false)
					ui_mgr.create_ui(import('ui.fuben_detail.fuben_detail_layer'), 'fuben_detail_layer')
					ui_mgr.get_ui('fuben_detail_layer'):set_fuben_id(fuben_def)
					ui_mgr.get_ui('fuben_detail_layer'):set_fuben_img()
					ui_mgr.get_ui('fuben_detail_layer'):add_entity_img()
					ui_mgr.get_ui('fuben_detail_layer'):add_item_img()
				end
			end
		elseif eventtype == ccui.TouchEventType.canceled then
		end
	end

	local i = 1
	for k, v in pairs(data.fuben_entrance[chapter_id]) do
		-- k: fuben id
		local name = tostring(k)
		local temp_btn = self:get_widget(name..'_big')
		if temp_btn ~= nil then
			local key= 'btn_'..k ..'_big'
			self[key] = temp_btn 
			self.big_btns[i] = k
			i = i+1
			self:set_widget_handler(self[key], replace_scene)


		end
		temp_btn = self:get_widget(name)
		if temp_btn ~= nil then
			local key= 'btn_'..k
			self[key] = temp_btn 
			--self:set_handler(self[key], self.replace_scene)
			--print('数字：',k)
			self:set_Gray(k)
		end
		count = count + 1
	end
	self.fuben_count = count
end





function elite_map_page:set_btns_state(  )
	local player =  model.get_player()

end


function elite_map_page:set_permit_btn(  )
	local player =  model.get_player()
	local cur_id = player:get_elite_fuben()
	if cur_id == 0 then
		local max_id = 1
		local start = 1
		local end_num	= self.fuben_count
		local start_num = start+1
		for i=start_num, end_num do
			self:set_Gray( i )
		end
		for i=start, max_id do
			self:set_light( i, true )
		end
		if max_id < end_num then
			self:set_light(max_id, false)
		end
	else
		local end_num	= self.fuben_count
		local instance_id = data.fuben[cur_id].instance_id
		local c_id = data.fuben[cur_id+1].chapter_id
		local start_num = instance_id+1
		if c_id > self.cur_chapter then
			
			for i=1, self.fuben_count do
				local temp_btn = self:get_widget(i..'_big')
				if temp_btn ~= nil then
					self:set_light( i, true )
				else
					self:set_Gray(i)
				end
			end
		else
			--print('打到第几关',instance_id)
			if instance_id >= self.fuben_count then
			 	instance_id = 0
			end
			local key = 'btn_'..instance_id ..'_big'

			local start = 0 
			local length = #self.big_btns
			--dir(self.big_btns)
			--print('长度：',length)
			for i = 1,length do
				local id = self.big_btns[i]
				--print('灰',id)
				self:set_Gray( id )
			end
			for i,v in pairs(self.big_btns) do
				local k = 'btn_'..v ..'_big'
				if k == key then
					start = i
				end
			end
			--print('开始：',start)
			for i = 1,start do
				local id = self.big_btns[i]
				self:set_light(id,true)
			end
			local next_id = self.big_btns[start + 1]
			
			if  next_id ~= nil and next_id <= end_num then

		 		self:set_light(next_id, false)
			end

		end

	end

	return max_id
end

function elite_map_page:set_light( i, open )
	i = i%15
	if i == 0 then
		i = 15
	end
	--普通按钮
	local sprite = self['btn_'..i]
	if sprite ~= nil then

		
		shaders.SpriteSetGray(sprite:getVirtualRenderer(), 1)
		sprite:setBright(true)
		if open then
			sprite:setTouchEnabled(false)
			sprite:loadTextureNormal('map (16).png',1)
		else
			sprite:setTouchEnabled(true)
			sprite:loadTextureNormal('map (15).png',1)
			self.map_arrow = map_arrow.map_arrow(self.id)
			local pos = sprite:getWorldPosition()
			self.map_arrow.cc:setPosition(pos.x,pos.y+sprite:getContentSize().height)
			local zord = sprite:getLocalZOrder()+1
			self.map_arrow.cc:setLocalZOrder(zord)
			self.widget:addChild(self.map_arrow.cc)
		end
		return
	end

	--大按钮
	sprite = self['btn_'..i ..'_big']
	if sprite ~= nil then

		sprite:setTouchEnabled(true)
		shaders.SpriteSetGray(sprite:getVirtualRenderer(), 1)
		if open == false then
			self.map_arrow = map_arrow.map_arrow(self.id)
			local pos = sprite:getWorldPosition()
			self.map_arrow.cc:setPosition(pos.x,pos.y+sprite:getContentSize().height/2+34)
			local zord = sprite:getLocalZOrder()+1
			self.map_arrow.cc:setLocalZOrder(zord)
			self.widget:addChild(self.map_arrow.cc)
		end
		return

	end


end

function elite_map_page:set_Gray( i )

	i = i%15
	if i == 0 then
		i = 15
	end
	--普通按钮
	local sprite = self['btn_'..i]
	if sprite ~= nil then
		sprite:setTouchEnabled(false)
		sprite:setBright(false)
		--shaders.SpriteSetGray(sprite:getVirtualRenderer(), 0.3)
		return
	end
	--大按钮
	sprite = self['btn_'..i ..'_big']
	if sprite ~= nil then
		sprite:setTouchEnabled(false)
		shaders.SpriteSetGray(sprite:getVirtualRenderer(), 0.3)
		return
	end
end

function elite_map_page:release()
	if self.map_arrow ~= nil then
		self.map_arrow:release()
	end
	--cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_map_'.. self.id .. '/Ui-map_'..self.id ..'0.plist' )
	super(elite_map_page,self).release()
end
