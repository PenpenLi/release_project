local layer					= import( 'world.layer' )
local ui_mgr 				= import(  'ui.ui_mgr' )
local model 				= import( 'model.interface' )
local combat_conf			= import( 'ui.lottery_layer.lottery_ui_conf' )
local locale				= import( 'utils.locale' )
local ui_const				= import( 'ui.ui_const' )
local msg_queue				= import( 'ui.msg_ui.msg_queue' )

lottery_items_panel = lua_class('lottery_items_panel',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local eicon_set = 'icon/e_icons.plist'
local iicon_set = 'icon/item_icons.plist'
local soul_set 	= 'icon/soul_icons.plist'
local sicon_set = 'icon/s_icons.plist'
local json_path = 'gui/main/ui_lottery_item.ExportJson'
local json_name = 'ui_lottery_item.ExportJson'
local _molingzhili_id = 90002
local _molingzhixin_id = 90003

function lottery_items_panel:_init(  )
	super(lottery_items_panel,self)._init(json_path,true)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self:init_lbl_font()
	self.count_type = true --true 为抽一次，false为抽十次
	self.is_gold = true --true 为金币抽，false为砖石抽
	self.one_panel = self:get_widget('cell_0')
	self.ten_panel = self:get_widget('Panel_56')
	self.price_panel = self:get_widget('Panel_2')
	self.ten_button = self:get_widget('again_ten_button')
	self.lbl_button = self:get_widget('lbl_again_ten_button')
	self:set_handler("again_ten_button", self.ten_button_event)
	self.yes_button = self:get_widget('yes_button')
	self:set_handler('yes_button',self.yes_button_event)

	self.cur_anim = 1
	self:set_is_gray(false)
	self.is_remove = false
end


--对文字的描边
function lottery_items_panel:init_lbl_font(  )
	for name, val in pairs(combat_conf.item_panel_lbl) do
		self['lbl_' .. name] = self:get_widget('lbl_' .. name)
		local temp_label = self['lbl_' .. name]
		if temp_label ~= nil then
			if locale.get_value('lottery_' .. name) ~= ' ' then
				temp_label:setString(locale.get_value('lottery_' .. name))		--如果传入的name在languane是没有的，就会返回以个空字符串
			end
			if val.edge ~= nil and val.edge > 0 then 					--edge的值大于0就描边
				temp_label:enableOutline(ui_const.UilableStroke, val.edge)  ---，描边，厚度 role_ui_conf.lua中role_ui_label的edge
			end
		end
	end
end



function lottery_items_panel:update_ten_gl( item_ids,exists, idx )

	if idx == nil then
		idx = 1
	end
	if idx > 10 then
		return
	end

	local i = idx

	local l_id = item_ids[i]
	self:get_widget('cell_'..i):setVisible(true)
	self:set_item_data( i, l_id )
	local it_id 
	if self.is_gold == true then
		--获得魔灵之力
		it_id = data.lottery[l_id].goods_id
	else

		it_id = data.lottery2[l_id].goods_id
	end
	local function callFunc(  )
		self:play_action('ui_lottery_item.ExportJson','L'..i)
		if data.item_id[it_id] == 'soul' then
			
			local skill_id = data[data.item_id[it_id]][it_id].soul_id
			local ui_lv = ui_mgr.create_ui(import('ui.soul_gain_layer.soul_gain_layer'), 'soul_gain_layer')
			ui_lv:init_skill_with_id(skill_id)
			ui_lv:play_start_anim()
			if exists[tostring(l_id)] ~= nil then
				self:set_skill_data( i, it_id )
				ui_lv:set_tips(locale.get_value('lottery_soul_tips'))
			end
			local function cb()
				self:update_ten_gl(item_ids,exists, i+1)
			end
			ui_lv:set_end_callback(cb)
		else
			self:update_ten_gl(item_ids,exists, i+1)
		end
		local is_end = i
		if is_end == 10 then
			self.price_panel:setVisible(true)
			self.yes_button:setVisible(true)
			self.ten_button:setVisible(true)
			self:play_action('ui_lottery_item.ExportJson','B')
		end
		
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('ui_lottery_item.ExportJson','G'..i,callFuncObj)

	if data.item_id[it_id] == 'soul' then
		return
	end

end

function lottery_items_panel:update_one_gl( item_id,exist )
	self.price_panel:setVisible(false)
	self.yes_button:setVisible(false)
	self.ten_button:setVisible(false)
	self:get_widget('cell_0'):setVisible(true)
	local it_id 
	if self.is_gold == true then
		
		it_id = data.lottery[item_id].goods_id
	else
		
		it_id = data.lottery2[item_id].goods_id
	end

	local function callFunc(  )
		self:play_action('ui_lottery_item.ExportJson','L0')

		if data.item_id[it_id] == 'soul' then

			local skill_id = data[data.item_id[it_id]][it_id].soul_id
			local ui_lv = ui_mgr.create_ui(import('ui.soul_gain_layer.soul_gain_layer'), 'soul_gain_layer')
			ui_lv:init_skill_with_id(skill_id)
			ui_lv:play_start_anim()
			if exist ~= nil then
				self:set_skill_data( 0, it_id )
				ui_lv:set_tips(locale.get_value('lottery_soul_tips'))
			end
			local function cb()
				self.price_panel:setVisible(true)
				self.yes_button:setVisible(true)
				self.ten_button:setVisible(true)
				self:play_action('ui_lottery_item.ExportJson','B')
			end
			ui_lv:set_end_callback(cb)
		else
			self.price_panel:setVisible(true)
			self.yes_button:setVisible(true)
			self.ten_button:setVisible(true)
			self:play_action('ui_lottery_item.ExportJson','B')
		end
	end
	local callFuncObj=cc.CallFunc:create(callFunc)

	self:play_action('ui_lottery_item.ExportJson','G0',callFuncObj)
	self:set_item_data( 0, item_id )
end

function lottery_items_panel:play_anim( )
	--待定
	-- if self.type == true then
	-- 	local function callFunc(  )
	-- 		self:play_action('ui_lottery_item.ExportJson','L0')
	-- 	end
	-- 	local callFuncObj=cc.CallFunc:create(callFunc)

	-- 	self:play_action('ui_lottery_item.ExportJson','G0',callFuncObj)
	-- 	self:play_action('ui_lottery_item.ExportJson','B')
	-- 	self:set_item_data( 0, 10016 )
	-- else
		
	-- 	for i=1,10 do
	-- 		--self:get_widget('light_'..i):setScale(0)
	-- 		self:set_item_data( i, 10016 )
	-- 		local function callFunc(  )
	-- 			self:play_action('ui_lottery_item.ExportJson','L'..i)
	-- 		end
	-- 		local callFuncObj=cc.CallFunc:create(callFunc)
	-- 		self:play_action('ui_lottery_item.ExportJson','G'..i,callFuncObj)
	-- 	end
	-- end
end




function lottery_items_panel:set_item_data( i, id )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( sicon_set )
	local img = self:get_widget('item_'.. i ..'_img')
	--print('物品id：',id)
	local it_id
	local it_count
	local is_light = false
	if self.is_gold == true then
		it_id = data.lottery[id].goods_id
		it_count =  data.lottery[id].count
		is_light = data.lottery[id].precious
	else
		it_id = data.lottery2[id].goods_id
		it_count =  data.lottery2[id].count
		is_light = data.lottery2[id].precious
	end
	local file = data[data.item_id[it_id]][it_id].icon
	local name = self['lbl_item_'.. i ..'_name']
	img:loadTexture( file ,load_texture_type)
	name:setString(data[data.item_id[it_id]][it_id].name)
	
	--设置数量
	local item_count = self:get_widget('lbl_count_'..i)
	item_count:enableOutline(ui_const.UilableStroke,1)
	item_count:setString('X'.. it_count)
	self:set_cell_level(name,img,data[data.item_id[it_id]][it_id].color,data.item_id[it_id],i)
	--设置是否显示光
	if is_light == true then
		local l_img = self:get_widget('light_'..i)
		l_img:setVisible(true)
	else
		local l_img = self:get_widget('light_'..i)
		l_img:setVisible(false)
	end

end

function lottery_items_panel:set_skill_data( i, it_id )
	
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( sicon_set )
	local img = self:get_widget('item_'.. i ..'_img')

	local it_count
	local is_light = false
	local skill_id = data.soul[it_id].soul_id
	local stone_id = data.soul_stone_map[skill_id]
	local evolution_id =  data.skill_initstar[skill_id]
	it_count =  data.soul_evolution[evolution_id].refund
	is_light = true
	local file = data.soul_stone[stone_id].icon
	local name = self['lbl_item_'.. i ..'_name']
	img:loadTexture( file ,load_texture_type)
	name:setString(data.soul_stone[stone_id].name)
	
	--设置数量
	local item_count = self:get_widget('lbl_count_'..i)
	item_count:enableOutline(ui_const.UilableStroke,1)
	item_count:setString('X'.. it_count)
	self:get_widget('lbl_count_'..i):setVisible(true)
	self:set_cell_level(name,img,data.soul_stone[stone_id].color,data.item_id[stone_id],i)
	--设置是否显示光
	--提示--
	
	msg_queue.add_item_msg(stone_id,it_count)
	if is_light == true then
		local l_img = self:get_widget('light_'..i)
		l_img:setVisible(true)
	else
		local l_img = self:get_widget('light_'..i)
		l_img:setVisible(false)
	end

end


--设置等级
function lottery_items_panel:set_cell_level( name,cell,level ,item_type,i)
	if item_type == 'soul' then
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
		self:get_widget('lbl_count_'..i):setVisible(false)
		
		return
	end

	if level == EnumLevel.White then
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	elseif level == EnumLevel.Green then
		cell:getChildByName('green'):setVisible(true)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
		
	elseif level == EnumLevel.Blue then
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(true)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
		
	elseif level == EnumLevel.Purple then
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(true)
		cell:getChildByName('orange'):setVisible(false)
		
	elseif level == EnumLevel.Orange then
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(true)
		
	else
		cell:getChildByName('green'):setVisible(false)
		cell:getChildByName('blue'):setVisible(false)
		cell:getChildByName('purple'):setVisible(false)
		cell:getChildByName('orange'):setVisible(false)
	end
end


function lottery_items_panel:set_lottery_count(is_one)
	self.count_type = is_one
	if is_one == true then
		self.one_panel:setVisible(true)
		self.ten_panel:setVisible(false)
		self.lbl_button:setString('再买一次')
		self.lbl_number:setString(''..100)
	else
		self.one_panel:setVisible(false)
		self.ten_panel:setVisible(true)
		self.lbl_button:setString('再买十次')
		self.lbl_number:setString(''..900)
	end

end

function lottery_items_panel:set_lottery_type( l_type )
	self.is_gold = l_type
	if l_type == true then
		self:get_widget('gold_img'):setVisible(true)
		self:get_widget('diamond_img'):setVisible(false)
	else
		self:get_widget('gold_img'):setVisible(false)
		self:get_widget('diamond_img'):setVisible(true)
	end
end

function lottery_items_panel:ten_button_event( sender, event_type )
	if self.is_gold == true then --金币抽
		if self.count_type == true then --一次
			if event_type == ccui.TouchEventType.ended then
				server.lottery_draw_one_by_money( )
			end
		else							--十次
			if event_type == ccui.TouchEventType.ended then
				server.lottery_draw_ten_by_money( )
			end

		end
	else 					--砖石抽
		if self.count_type == true then --一次
			if event_type == ccui.TouchEventType.ended then
				server.lottery_draw_one_by_diamond( )
			end
		else							--十次
			if event_type == ccui.TouchEventType.ended then
				server.lottery_draw_ten_by_diamond( )
			end
		end
	end
end

function lottery_items_panel:yes_button_event( sender, event_type )

	if event_type == ccui.TouchEventType.ended then
		ui_mgr.get_ui('lottery_tx'):set_remove()
		ui_mgr.get_ui('lottery_layer'):set_button_touch(true)
		self.is_remove = true

	end
end

function lottery_items_panel:set_remove(  )
	self.is_remove = true
end

function lottery_items_panel:release(  )
	self.is_remove  = false 
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(json_name)
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( soul_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( sicon_set )
	super(lottery_items_panel,self).release()
end

function lottery_items_panel:reload(  )
	super(lottery_items_panel,self).reload()
end
