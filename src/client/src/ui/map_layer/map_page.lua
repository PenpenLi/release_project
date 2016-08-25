
local layer					= import( 'world.layer' )
local director				= import( 'world.director'  )
local main_map				= import( 'ui.main_map' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local model 				= import( 'model.interface' )
local math_ext				= import( 'utils.math_ext')
local shaders				= import( 'utils.shaders' )
local map_arrow 			= import( 'ui.map_layer.map_arrow' )

map_page = lua_class('map_page',layer.ui_layer)

function map_page:_init( layer,id )
	self.parent = layer
	super(map_page,self)._init('gui/main'.. '/Ui-map_'..id ..'.ExportJson',false)
	
	self.id = id
	self.cur_chapter = id
	self.fuben_count = 0
	-- self.widget = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/ui_maps'.. '/Ui-map_'..id ..'.ExportJson')
	-- self:record_plist_from_json( 'gui/ui_maps'.. '/Ui-map_'..id ..'.ExportJson' )
	self.widget:setPosition(0,-4)
	self:create_button( id )
	self:set_permit_btn()

end

function map_page:get_widget(name)
	return ccui.Helper:seekWidgetByName(self.widget, name)
end

function map_page:create_button( chapter_id )
	if chapter_id == nil then
		return
	end
	self.cur_chapter = chapter_id
	
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

	local count = 0
	for k, v in pairs(data.fuben_entrance[chapter_id]) do
		-- k: fuben id
		local name = tostring(k)
		local temp_btn = self:get_widget(name..'_big')
		if temp_btn ~= nil then
			local key= 'btn_'..k ..'_big'
			self[key] = temp_btn 
			self.parent:set_widget_handler(self[key], replace_scene)
		end
		temp_btn = self:get_widget(name)
		if temp_btn ~= nil then
			local key= 'btn_'..k
			self[key] = temp_btn 
			self.parent:set_widget_handler(self[key], replace_scene)
		end
		count = count + 1
	end
	self.fuben_count = count
end


function map_page:set_btns_state(  )
	local player =  model.get_player()

end


function map_page:set_permit_btn(  )
	local player =  model.get_player()
	local cur_id = player:get_fuben()
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
		local max_id = 0
		local start = 1
		local end_num	= self.fuben_count
		local instance_id = data.fuben[cur_id].instance_id
		if data.fuben[cur_id+1] ~= nil then
			local c_id = data.fuben[cur_id+1].chapter_id
			local start_num = instance_id+1
			if c_id > self.cur_chapter then
				for i=1, self.fuben_count do
					self:set_light( i, true )
				end
			else
				if instance_id >= self.fuben_count then
				 	instance_id = 0
				end
				local start_num = instance_id+1
				max_id = instance_id
				for i=start_num, end_num do
					self:set_Gray( i )
				end
				for i=start, max_id do
					self:set_light( i, true )
				end
				if max_id < end_num then
					self:set_light(max_id + 1, false)
				end
			end
		else
			--到最后一关就设置为全亮
			max_id = instance_id
			for i=start, max_id do
				self:set_light( i, true )
			end

		end
	end




	return max_id
end

function map_page:set_light( i, open )
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

function map_page:set_Gray( i )

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

function map_page:release()
	if self.map_arrow ~= nil then
		self.map_arrow:release()
	end
	super(map_page,self).release()
	--cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( 'gui/ui_maps'.. '/Ui-map_'..self.id ..'0.plist' )
end
