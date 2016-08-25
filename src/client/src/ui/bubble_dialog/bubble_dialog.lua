
local battle_const = import('game_logic.battle_const')


bubble_dialog = lua_class('bubble_dialog')

function bubble_dialog:_init(  )
	

	self.node = cc.Node:create()
	--气泡的文字 大小，内容，字体颜色
	self.label = ccui.Text:create()
	self.label:setAnchorPoint(cc.p(0.5, 0.5))
	--self.label:setFontName(battle_const.BubbleDialogueFontType) 
	self.label:setFontSize(battle_const.BubbleDialogueFontSize)
	self.label:setString('勇士!')
	self.label:setColor(battle_const.BubbleDialogueFontColor)
	
	--获得所有字体形成的框大小
	local width  = self.label:getLayoutSize().width
	local height = self.label:getLayoutSize().height
	--设字体的位置
	self.label:setPosition((width+20)/2,(height+20)/2+5)

	--底图为九宫格图片，颜色，透明度
	self.imageView = cc.Scale9Sprite:create("gui/bubble.png")
	self.imageView:setCapInsets(cc.rect(14,14,2,2))
	self.imageView:setContentSize(cc.size(width+20, height+20))
	self.imageView:setColor(battle_const.BubbleDialogueFrameColor[1])
	self.imageView:setOpacity(battle_const.BubbleDialogueFrameColor[2])
	self.imageView:setAnchorPoint(cc.p(0, 0))

	self.node:addChild(self.imageView)
	self.node:addChild(self.label)
	

end


function bubble_dialog:get_dialog(  )
	return self.node
end

--设置文本的内容
function bubble_dialog:set_string( str )

	self.label:setAnchorPoint(cc.p(0.5, 0.5))
	--self.label:setFontName(battle_const.BubbleDialogueFontType)
	--更加/进行换行
	local label = string_split(str,'/')
	local temp_str = nil
	for k,v in pairs(label) do
		if temp_str == nil then
			temp_str = v
		else
			temp_str = temp_str .. '\n'..v
		end

	end
	self.label:setString(temp_str)
	self.imageView:setOpacity(battle_const.BubbleDialogueFrameColor[2])
	local width  = self.label:getLayoutSize().width
	local height = self.label:getLayoutSize().height
	
	self.imageView:setContentSize(width , height)
	self:set_bg_size(width+20, height+20)

	self.label:setPosition((width+20)/2,(height+20)/2+5)

end

--设置底图的大小

function bubble_dialog:set_bg_size( width , height )
	self.imageView:setPreferredSize(cc.size(width , height))
end


--设置底图方向
function bubble_dialog:set_Direction( dir,is_flip )

	if is_flip == true then
		if dir == false then
			if self.imageView ~= nil and self.label ~= nil then
				self.imageView:setScaleX(-1)
				self.label:setScaleX(1)
				self.label:setPositionX(-self.imageView:getContentSize().width/2)
			end

		else
			if self.imageView ~= nil and self.label ~= nil then
				self.imageView:setScaleX(-1)
				self.label:setScaleX(-1)
				self.label:setPositionX(-self.imageView:getContentSize().width/2)
			end

		end
	else

		if dir == false then
			if self.imageView ~= nil and self.label ~= nil then
				self.imageView:setScaleX(1)
				self.label:setScaleX(1)
				self.label:setPositionX(self.imageView:getContentSize().width/2)
			end
		else

			if self.imageView ~= nil and self.label ~= nil then
				self.imageView:setScaleX(1)
				self.label:setScaleX(-1)
				self.label:setPositionX(self.imageView:getContentSize().width/2)
			end

		end

	end
end

