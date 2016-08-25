local layer					= import( 'world.layer' )
local map_page 				= import( 'ui.map_layer.map_page' )
local elite_map_page 		= import( 'ui.map_layer.elite_map_page' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local main_map				= import( 'ui.main_map' )
local ui_const 				= import( 'ui.ui_const' )
local math_ext				= import( 'utils.math_ext')
local model 				= import( 'model.interface' )
local locale				= import( 'utils.locale' )
local shaders  				= import( 'utils.shaders' )
map_layer = lua_class('map_layer',layer.ui_layer)

local _chapter_count = 10
local _elite_chapter_count = 10

function map_layer:_init(  )
	super(map_layer,self)._init('gui/main/ui_map.ExportJson',true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	--self.widget:addChild(self.map_page.cc,-1)
	self.widget:setLocalZOrder(100)
	self.is_remove = false
	self:set_handler("close_button", self.close_button_event)

	--下一页
	self.next_button = self:get_widget('next_button')
	self:set_handler("next_button", self.next_button_event)

	self.next_button:setVisible(false)

	--上一页 
	self.front_button = self:get_widget('front_button') 
	self:set_handler("front_button", self.front_button_event)
	self.front_button:setVisible(false)

	self.common_button = self:get_widget('common_button')
	self:set_handler('common_button',self.common_button_event)

	self.elite_button = self:get_widget('elite_button')
	self:set_handler('elite_button',self.elite_button_event)

	self.elite_map = self:get_widget('e_map')
	self.common_map = self:get_widget('c_map')

	--章节标题
	self.page_id = 1
	self.map_tile = self:get_widget('cmap_tile')
	--self.map_tile:setFontName(ui_const.UiLableFontType)
	self.map_tile:setString(locale.get_value('map_' .. self.page_id))
	--默认是普通关卡
	-- self.map_type = EnumMap.Common
	-- self.common_button:setSelectedState(true)
	-- self.common_button:setTouchEnabled(false)
	-- self:check_map_button()
	-- self:create_common_map()
	--self:open_elite_map(  )
	self:open_common_map()
end

function map_layer:open_common_map(  )
	self.map_type = EnumMap.Common
	self.common_button:setSelectedState(true)
	self.common_button:setTouchEnabled(false)
	self:check_map_button()
	self:set_map_type(self.map_type)
	self:create_common_map()
end

function map_layer:open_elite_map(  )
	self.map_tile = self:get_widget('map_tile')
	local player =  model.get_player()
	local common_id = player:get_fuben()
	if  common_id == nil or common_id <= 0 then
		self.map_type = EnumMap.Common
		self.common_button:setSelectedState(true)
		self.common_button:setTouchEnabled(false)
		shaders.SpriteSetGray(self.elite_button:getVirtualRenderer(), 0.1)
		self.elite_button:setTouchEnabled(false)
		self:set_map_type(self.map_type)
		self:check_map_button()
		self:create_common_map()
		return
	end
	
	if common_id ~= nil and common_id > 0 then
		local battle_chapter = data.fuben[common_id+1].chapter_id 
		
		if battle_chapter ~= nil and battle_chapter <= 1 then
			self.map_type = EnumMap.Common
			self.common_button:setSelectedState(true)
			self.common_button:setTouchEnabled(false)
			shaders.SpriteSetGray(self.elite_button:getVirtualRenderer(), 0.1)
			self.elite_button:setTouchEnabled(false)
			self:set_map_type(self.map_type)
			self:check_map_button()
			self:create_common_map()
			return
		end
	end
	self.map_type = EnumMap.Elite
	self:check_map_button()
	self.elite_button:setVisible(true)
	self.elite_button:setSelectedState(true)
	self.elite_button:setTouchEnabled(false)
	self.common_button:setSelectedState(false)
	self.common_button:setTouchEnabled(true)
	self:set_map_type(self.map_type)
	self:create_elite_map()
end

function map_layer:set_map_type( map_type )
	if map_type == EnumMap.Elite then
		self.elite_map:setVisible(true)
		self.common_map:setVisible(false)
	else
		self.elite_map:setVisible(false)
		self.common_map:setVisible(true)
	end
end

function map_layer:check_map_button(  )
	local player =  model.get_player()
	local common_id = player:get_fuben()
	--local battle_chapter = data.fuben[common_id].chapter_id 
	
	self.elite_button:setVisible(true)
	if  common_id < 1 then
		shaders.SpriteSetGray(self.elite_button:getVirtualRenderer(), 0.1)
		self.elite_button:setTouchEnabled(false)
		return
	end
	if common_id~=nil and common_id > 0 then
		--但章节少于等于1 就隐藏
		local temp_fuben = data.fuben[common_id+1]
		local temp_id = common_id+1
		if temp_fuben == nil then
			temp_id = common_id
		end
		
		local battle_chapter = data.fuben[temp_id].chapter_id
		if battle_chapter <= 1 then
			shaders.SpriteSetGray(self.elite_button:getVirtualRenderer(), 0.1)
			self.elite_button:setTouchEnabled(false)
		end
	end
end

function map_layer:create_common_map( )
	self.map_tile = self:get_widget('cmap_tile')
	local player =  model.get_player()
	local battle_id = player:get_fuben()

	if battle_id <1 then
		local fuben_type = data.fuben_type_entrance['normal']
		battle_id = data.fuben_entrance[fuben_type][1]
		self:turn_page(battle_id)
	else
		local next_id = battle_id+1
		
		if data.fuben[next_id] == nil then
			next_id = battle_id
		end
		
		if data.fuben[next_id].chapter_id <= _chapter_count then
			self:turn_page(next_id)
		else
			self:turn_page(battle_id)
		end
	end

	self:updata_page_btn(self.page_id)
end

function map_layer:create_elite_map(  )
	self.map_tile = self:get_widget('map_tile')
	local player =  model.get_player()
	local common_id = player:get_fuben()
	local battle_id = player:get_elite_fuben()+1
	local bef_id = player:get_elite_fuben()
	local battle_chapter = data.fuben[common_id].chapter_id 

	if battle_id == nil or battle_id <=1 then
		local fuben_type = data.fuben_type_entrance['JY']
		battle_id = data.fuben_entrance[fuben_type][1]
		self:elite_turn_page(battle_id)
	else
		if data.fuben[battle_id] == nil then
			return 
		end
		local pre_barrier = data.fuben[data.fuben_entrance[data.fuben[battle_id].chapter_id][1]].pre_barrier[1]
		
		if common_id >= pre_barrier then
			local next_id = battle_id +1
			if data.fuben[next_id] == nil then
				next_id = battle_id
			end
			local fuben_type = data.fuben_type_entrance['JY']
			if data.fuben[next_id].chapter_id < fuben_type+_elite_chapter_count then
				self:elite_turn_page(next_id)
			
			else
				self:elite_turn_page(battle_id)
			end
		else
			self:elite_turn_page(bef_id)

		end

	end

	self:updata_page_btn(self.page_id)
end

function map_layer:common_button_event(sender, eventtype)
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then

	elseif eventtype == ccui.TouchEventType.ended then
  		sender:setSelectedState(false)
  		sender:setTouchEnabled(false)
  		self.elite_button:setSelectedState(false)
  		self.elite_button:setTouchEnabled(true)
  		self.map_type = EnumMap.Common
  		self:set_map_type(self.map_type)
 		self:create_common_map()
  		
	elseif eventtype == ccui.TouchEventType.canceled then
		
	end

end

function map_layer:elite_button_event(sender, eventtype)
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then
  
	elseif eventtype == ccui.TouchEventType.ended then
  		sender:setSelectedState(false)
  		sender:setTouchEnabled(false)
  		self.common_button:setSelectedState(false)
  		self.common_button:setTouchEnabled(true)
  		self.map_type = EnumMap.Elite
  		self:set_map_type(self.map_type)
 		self:create_elite_map()

	elseif eventtype == ccui.TouchEventType.canceled then
		
	end

end

function map_layer:next_button_event(sender, eventtype)
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then
  
	elseif eventtype == ccui.TouchEventType.ended then

		if self.map_type == EnumMap.Common then
			local fuben_lenght = #data.fuben
			local chapter_lenght = _chapter_count
			if self.page_id == chapter_lenght then
				self.page_id = 0
			end
			self.page_id = self.page_id + 1
			self.chapter_id = self.chapter_id + 1
			if self.page_id <= chapter_lenght then
				self.map_page:release()
				self.map_page.cc:removeFromParent()
				self.map_page = nil
				self.map_page = map_page.map_page(self,self.page_id)
				self.widget:getChildByName('Panel_1'):addChild(self.map_page.cc)
				self.map_tile:setString(locale.get_value('map_' .. self.page_id))
				self:updata_page_btn(self.page_id)
			end
			
			return
		end

		if self.map_type == EnumMap.Elite then

			local fuben_lenght = #data.fuben
			local chapter_lenght = _chapter_count
			if self.page_id == chapter_lenght then
				self.page_id = 0
			end
			self.page_id = self.page_id + 1
			self.chapter_id = self.chapter_id + 1
			if self.page_id <= chapter_lenght then
				self.map_page:release()
				self.map_page.cc:removeFromParent()
				self.map_page = nil
				self.map_page = elite_map_page.elite_map_page(self,self.page_id,self.chapter_id)
				self.widget:getChildByName('Panel_1'):addChild(self.map_page.cc)
				self.map_tile:setString(locale.get_value('map_' .. self.page_id))
				self:updata_page_btn(self.page_id)
			end
			return
		end
	elseif eventtype == ccui.TouchEventType.canceled then
		
	end

end


function map_layer:front_button_event(sender, eventtype)
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then
  
	elseif eventtype == ccui.TouchEventType.ended then
		if self.map_type == EnumMap.Common then
			local fuben_lenght = #data.fuben
			local chapter_lenght = _chapter_count
			if self.page_id == 1 then
				self.page_id = chapter_lenght+1
			end
			self.page_id = self.page_id - 1
			self.chapter_id = self.chapter_id -1
			if self.page_id >= 1 then
				self.map_page:release()
				self.map_page.cc:removeFromParent()
				self.map_page = nil
				self.map_page = map_page.map_page(self,self.page_id )
				self.widget:getChildByName('Panel_1'):addChild(self.map_page.cc)
				self.map_tile:setString(locale.get_value('map_' .. self.page_id))
				self:updata_page_btn(self.page_id)
			end
			return
		end

		if self.map_type == EnumMap.Elite then
			local fuben_lenght = #data.fuben
			local chapter_lenght = _chapter_count
			if self.page_id == 1 then
				self.page_id = chapter_lenght+1
			end
			self.page_id = self.page_id - 1
			self.chapter_id = self.chapter_id -1
			if self.page_id >= 1 then
				self.map_page:release()
				self.map_page.cc:removeFromParent()
				self.map_page = nil
				self.map_page = elite_map_page.elite_map_page(self,self.page_id ,self.chapter_id )
				self.widget:getChildByName('Panel_1'):addChild(self.map_page.cc)
				self.map_tile:setString(locale.get_value('map_' .. self.page_id))
				self:updata_page_btn(self.page_id)
			end
			return

		end
	elseif eventtype == ccui.TouchEventType.canceled then
		
	end

end
function map_layer:close_button_event( sender, eventtype )
	if eventtype == 0 then
			print('press close')
			--music_mgr.ui_click()
	end
	if eventtype == ccui.TouchEventType.began then
	
	elseif eventtype == ccui.TouchEventType.moved then
  
	elseif eventtype == ccui.TouchEventType.ended then
			sender:setTouchEnabled(false)
			self.cc:setVisible(false)
			self.is_remove = true
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
	elseif eventtype == ccui.TouchEventType.canceled then
		
	end
end

function map_layer:updata_page_btn( id )

	if id <= 1 then
		local player =  model.get_player()
		local zhangjie_length =  #data.fuben_entrance[self.chapter_id]
		local end_fuben = data.fuben_entrance[self.chapter_id][zhangjie_length]
		self.next_button:setVisible(false)
		local cur_fuben = player:get_fuben()
		if self.map_type ==EnumMap.Elite then
			cur_fuben = player:get_elite_fuben()
			if cur_fuben >= end_fuben then
				local common_id = player:get_fuben()
				local battle_id = player:get_elite_fuben()+1 --取第二章第一个精英关卡前置关卡
				if data.fuben[battle_id] ~= nil then
					local pre_barrier = data.fuben[data.fuben_entrance[data.fuben[battle_id].chapter_id][1]].pre_barrier[1]
					if common_id >= pre_barrier then
						self.next_button:setVisible(true)
					end
				end
			end
			self.front_button:setVisible(false)
			return
		end
		if cur_fuben >= end_fuben then
			self.next_button:setVisible(true)
		end
		self.front_button:setVisible(false)
		return
	end

	if id > 1 and id <_chapter_count then
		local player =  model.get_player()
		local zhangjie_length =  #data.fuben_entrance[self.chapter_id]
		local end_fuben = data.fuben_entrance[self.chapter_id][zhangjie_length]
		local cur_fuben = player:get_fuben()
		if self.map_type ==EnumMap.Elite then
			cur_fuben = player:get_elite_fuben()
			self.next_button:setVisible(false)

			if cur_fuben >= end_fuben then
				local common_id = player:get_fuben()
				local battle_id = player:get_elite_fuben()+1
				if data.fuben[battle_id] ~= nil then
				local pre_barrier = data.fuben[data.fuben_entrance[data.fuben[battle_id].chapter_id][1]].pre_barrier[1]
					if common_id >= pre_barrier then
						self.next_button:setVisible(true)
					end
				end
			end
			self.front_button:setVisible(true)
			return
		end
		self.next_button:setVisible(false)

		if cur_fuben >= end_fuben then
			self.next_button:setVisible(true)
		end
		self.front_button:setVisible(true)
		return
	end

	if id >= _chapter_count then
		self.next_button:setVisible(false)
		self.front_button:setVisible(true)
		return
	end


end

--普通副本翻页功能
function map_layer:open_turn_commonPage( battle_id )
	self.map_type = EnumMap.Common
	self.common_button:setSelectedState(true)
	self.common_button:setTouchEnabled(false)
	self:set_map_type(self.map_type)
	self:check_map_button()
	local player =  model.get_player()
	local cur_id = player:get_fuben()
	local cur_chap
	if cur_id <= 0 and data.fuben[cur_id] == nil then
		local fuben_type = data.fuben_type_entrance['normal']
		cur_chap = fuben_type
		cur_id =  data.fuben_entrance[fuben_type][1]
	else
		cur_chap = data.fuben[cur_id].chapter_id
	end
	local open_chap = data.fuben[battle_id].chapter_id
	if open_chap > _chapter_count then
		open_chap = chapter_count
		battle_id = cur_id
	end
	if cur_chap <= open_chap then
		self:turn_page( battle_id )
	else
		self:turn_page( cur_id )
	end
end

--留个接口精英翻页功能
function map_layer:open_turn_elitePage( battle_id )

end

--翻到普通副本那一章
function map_layer:turn_page( battle_id )
	local temp_id
	if battle_id == nil or battle_id < 1 then
		temp_id = 1
	else
		temp_id = data.fuben[battle_id].chapter_id
	end
	self.page_id = temp_id
	self.chapter_id = temp_id
	if self.map_page ~= nil then
		self.map_page:release()
		self.map_page.cc:removeFromParent()
		self.map_page = nil
		self.map_page = map_page.map_page(self,self.page_id )
		self.widget:getChildByName('Panel_1'):addChild(self.map_page.cc)
		self.map_tile:setString(locale.get_value('map_' .. self.page_id))
		self:updata_page_btn(self.page_id)
	else
		self.map_page = map_page.map_page(self,self.page_id )
		self.widget:getChildByName('Panel_1'):addChild(self.map_page.cc)
		self.map_tile:setString(locale.get_value('map_' .. self.page_id))
		self:updata_page_btn(self.page_id)
	end
end

--翻到精英副本
function map_layer:elite_turn_page( battle_id )
	local count
	local ch_id
	if battle_id ==nil or battle_id < 1 then
		count = 1
		local fuben_type = data.fuben_type_entrance['JY']
		ch_id = fuben_type
	else
		count = data.fuben[battle_id].map_id
		ch_id = data.fuben[battle_id].chapter_id
	end
	self.chapter_id = ch_id
	self.page_id = count
	if self.map_page ~= nil then
		self.map_page:release()
		self.map_page.cc:removeFromParent()
		self.map_page = nil
		self.map_page = elite_map_page.elite_map_page(self,self.page_id,self.chapter_id )
		self.widget:getChildByName('Panel_1'):addChild(self.map_page.cc)
		self.map_tile:setString(locale.get_value('map_' .. self.page_id))
		self:updata_page_btn(self.page_id)
	else
		self.map_page = elite_map_page.elite_map_page(self,self.page_id,self.chapter_id )
		self.widget:getChildByName('Panel_1'):addChild(self.map_page.cc)
		self.map_tile:setString(locale.get_value('map_' .. self.page_id))
		self:updata_page_btn(self.page_id)
	end
end

function map_layer:release(  )
	self.map_page:release()
	super(map_layer,self).release()
end
