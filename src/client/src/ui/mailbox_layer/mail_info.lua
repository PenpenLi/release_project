local combat_conf			= import( 'ui.avatar_info_layer.avatar_info_ui_conf' )
local layer					= import( 'world.layer' )
local model 				= import( 'model.interface' )
local locale				= import( 'utils.locale' )
local music_mgr				= import( 'world.music_mgr' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const 				= import( 'ui.ui_const' )
local mailbox_cell			= import( 'ui.mailbox_layer.mailbox_cell' )

mail_info = lua_class('mail_info',layer.ui_layer)
local _jsonfile = 'gui/main/mailbox_2.ExportJson'
local eicon_set = 'icon/e_icons.plist'
local load_texture_type = TextureTypePLIST

local max_item_num = 16

function mail_info:_init( )

	super(mail_info,self)._init(_jsonfile,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	self:set_handler("btn_get_mail", self.get_mail)
	self:set_handler("btn_close", self.close_button_event)
	self.is_remove = false
end

function mail_info:set_mail(cell)
	self:reload_json()
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	local eid = cell:get_eid()
	local d = data.email[eid]
	self.content_list = self:get_widget('content_list')
	
	--正文
	self.mail_content = self:get_widget('mail_content'):clone()
	self.mail_content:ignoreAnchorPointForPosition(true)
	self.body = cc.Label:create()
	self.body:setAnchorPoint(0, 1)
	self.body:setPosition(0, -46)
	self.body:setColor(Color.Brown)
	self.body:setWidth(350)
	self.body:setSystemFontSize(20)
	self.body:setString(d.body)
	self.mail_content:addChild(self.body)
	--标题
	self.title = self.mail_content:getChildByName('mail_title')
	self.title:setString(d.title)
	--设置高度
	local siz = self.body:getContentSize()
	self.mail_content:setContentSize(siz.width, siz.height + 70)

	self.content_list:pushBackCustomItem(self.mail_content)
	--附件
	if d.with_items == 1 or d.with_items == true then
		self.detail = self:get_widget('pal_detail'):clone()
		self.background_view = self.detail:getChildByName('Image_7')
		local background_view_hight = 100

		local items = d.items
		local index = 1
		if items ~= nil then 
			for id, num in pairs(items) do
				local view = self.detail:getChildByName('item_icon_'..index)
				local num_view = self.detail:getChildByName('item_num_'..index)
				local item_type = data.item_id[id]
 				if item_type ~= nil then
					local item_data = data[item_type]
					if item_data ~= nil then 
						local item_icon = item_data[id].icon
						if item_icon ~= nil then
							view:loadTexture(item_icon, load_texture_type)
							num_view:setString(tostring(num))
							--num_view:setFontSize(22)
						end
					end
				end
				index = index + 1
			end
		end

		background_view_hight = math.ceil((index-1)/4)*100 + background_view_hight
		self.background_view:setContentSize(self.background_view:getContentSize().width, background_view_hight)

		for i = index, max_item_num do
			local view = self.detail:getChildByName('item_icon_'..index)
			local num_view = self.detail:getChildByName('item_num_'..index)
			view:setVisible(false)
			num_view:setVisible(false)
			index = index + 1
		end

		self.detail:setContentSize(self.background_view:getContentSize())
		self.detail:ignoreAnchorPointForPosition(true)
		self.money = self.detail:getChildByName('lbl_money')
		self.money:setString(d.money)
		self.diamond = self.detail:getChildByName('lbl_diamond')
		self.diamond:setString(d.diamond)
		self.content_list:pushBackCustomItem(self.detail)
	else
		self:get_widget("btn_get_mail"):setVisible(false)
	end
	self.cell = cell
	self.cell:read_mail()
end

function mail_info:get_mail_cell()
	return self.cell
end

function mail_info:close_button_event( sender, eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			self:play_down_anim()
		elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function mail_info:get_mail( sender, eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			server.gain_email_items(self.cell:get_id())
		elseif eventtype == ccui.TouchEventType.canceled then
	end
end

function mail_info:play_up_anim(  )
	self:play_action('mailbox_2.ExportJson','up')
end

--播放收起动画
function mail_info:play_down_anim( )
	local function callFunc(  )
		self.is_remove = true
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('mailbox_2.ExportJson','down',callFuncObj)
end

function mail_info:release( )
	self.is_remove = false
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('mailbox_2.ExportJson')
	super(mail_info,self).release()
end

--根据str长度、宽度获到高度
function mail_info:get_text_hight(widget, temp_str ,width ,font_size )
	local LB = cc.Label:create()
	LB:setSystemFontName(ui_const.UiLableFontType)
	LB:setWidth(width)
	LB:setSystemFontSize(font_size)
	LB:setString(temp_str)	
	widget:addChild(LB)

	local height = LB:getBoundingBox().height
	local width  = LB:getBoundingBox().width
	LB:removeFromParent()
	return height ,width
end
