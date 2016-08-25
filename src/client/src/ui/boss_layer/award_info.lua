local layer 				= import('world.layer')
local ui_const 				= import( 'ui.ui_const' )

award_info = lua_class('award_info',layer.ui_layer)
local load_texture_type = TextureTypePLIST
local first = true
local renwu_set = 'icon/renwu.plist'
local iicon_set = 'icon/item_icons.plist'
local eicon_set = 'icon/e_icons.plist'
local soul_set = 'icon/soul_icons.plist'

function award_info:_init(  )
	super(award_info,self)._init('gui/main/task_tips.ExportJson',true)

	self.is_remove = false
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)


	--文本字体
	self.lbl_reward_img_1 = self:get_widget('lbl_reward_img_1')
	--self.lbl_reward_img_1:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_img_1:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_reward_img_2 = self:get_widget('lbl_reward_img_2')
	--self.lbl_reward_img_2:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_img_2:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_reward_img_3 = self:get_widget('lbl_reward_img_3')
	--self.lbl_reward_img_3:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_img_3:enableOutline(ui_const.UilableStroke, 1)
	self.lbl_yes_button = self:get_widget('lbl_yes_button')
	--self.lbl_yes_button:setFontName(ui_const.UiLableFontType)
	self.lbl_yes_button:enableOutline(ui_const.UilableStroke, 1)


	self.reward_img_1 = self:get_widget('reward_img_1')
	self.reward_img_2 = self:get_widget('reward_img_2')
	self.reward_img_3 = self:get_widget('reward_img_3')
	self.reward_img_1:setVisible(false)
	self.lbl_reward_img_1:setVisible(false)
	self.reward_img_2:setVisible(false)
	self.lbl_reward_img_2:setVisible(false)
	self.reward_img_3:setVisible(false)
	self.lbl_reward_img_3:setVisible(false)
	self.lbl_title = self:get_widget('lbl_title')
	--self.lbl_title:setFontName(ui_const.UiLableFontType)

	self.yes_button = self:get_widget('yes_button')
	self:set_handler('yes_button',self.yes_button_event)

	self:play_up_anim()

end

function award_info:set_yes_button_handel( func )
	local function button_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
		elseif eventtype == ccui.TouchEventType.moved then
		elseif eventtype == ccui.TouchEventType.ended then
			func()
		elseif eventtype == ccui.TouchEventType.canceled then
		end
	end
	self.yes_button:addTouchEventListener(button_event)
end

--弹出动画
function award_info:play_up_anim(  )

	self:play_action('task_tips.ExportJson','up')
	self:play_action('task_tips.ExportJson','anim')


end

--收回动画
function award_info:play_down_anim(  )
	local function callFunc(  )

		self.is_remove = true
		
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
   self:play_action('task_tips.ExportJson','down',callFuncObj)
	

end


--设置

function award_info:release(  )
	-- body
	self.is_remove = false
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('task_tips.ExportJson')
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( renwu_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( iicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( eicon_set )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile( soul_set )
	super(award_info,self).release()
end

function award_info:reload(  )
	super(award_info,self).reload()
end



function award_info:set_reward( rwd_data )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( renwu_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( iicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( soul_set )

	local index = 1
	for _, item in pairs(rwd_data) do
		if type(item) == 'table' then
			local item_type = data.item_id[item.id]
			local icon = data[item_type][item.id].icon
			local img = self['reward_img_' .. index]
			local number = self['lbl_reward_img_'..index]
			img:loadTexture(icon,load_texture_type)
			img:setVisible(true)
			img:setScale(0.35)
			number:setString('x' .. item.number)
			number:setVisible(true)
		else
			local img = self['reward_img_' .. index]
			local number = self['lbl_reward_img_'..index]
			img:loadTexture(rwd_data[index].k ..'.png',load_texture_type)
			img:setVisible(true)

			number:setString('x' .. item.number)
			number:setVisible(true)

		end
		index = index + 1
	end
end