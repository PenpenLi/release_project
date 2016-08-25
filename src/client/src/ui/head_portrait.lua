local ui_const			= import( 'ui.ui_const' )

head_portrait = lua_class('head_portrait')

local _bar_length = 134

function  head_portrait:_init( widget,name )
	-- body

 	local size = cc.Director:getInstance():getVisibleSize()
	self.imgbg=widget:getChildByName('Panel_3')
	self.imgbgt = self.imgbg:getChildByName('Image_25')
	--self.imgbg:setPosition(size.width/2,size.height-self.imgbgt:getLayoutSize().height/2)
	--widget:setPosition(VisibleSize.width/2,VisibleSize.height-self.imgbgt:getLayoutSize().height/2)
	
	self.hp = self.imgbg:getChildByName('人物生命条'):getChildByName('Image_31')
	
	
	self.mp = self.imgbg:getChildByName('人物能量条'):getChildByName('Image_27')
	self.mp_p = self.mp:getPositionX()
	self.hp_p = self.hp:getPositionX()

	self.hp_label = self.imgbg:getChildByName('人物生命条'):getChildByName('Label_32_0')
	self.mp_label = self.imgbg:getChildByName('人物能量条'):getChildByName('Label_32')

	--self.mp_label:setFontName('fonts/msyh.ttf')
	--self.hp_label:setFontName('fonts/msyh.ttf')
	self.hp_label:enableOutline(ui_const.UilableStroke,2)
	self.mp_label:enableOutline(ui_const.UilableStroke,2)


end

function head_portrait:set_red_bar( number,cur_hp )
	-- body
	if number <=0 then
		number=0
	end 
	if number >=100 then
		number = 100
	end

	self.hp:setPositionX(self.hp_p-(_bar_length*((100-number)/100)))

	--self.hp:setPercent(number)
	cur_hp = self:getIntPart(cur_hp)

	self.hp_label:setString(cur_hp)

end


function head_portrait:set_blue_bar( number ,cur_mp)
	-- body
	if number <=0 then
		number=0
	end 
	if number >=100 then
		number = 100
	end
	self.mp:setPositionX(self.mp_p-(_bar_length*((100-number)/100)))
	--self.mp:setPercent(number)
	cur_mp = self:getIntPart(cur_mp)
	self.mp_label:setString(cur_mp)
end

--取整数
function head_portrait:getIntPart( x )
	-- body
	if x <= 0 then
		return math.ceil(x)
	end

	if math.ceil(x) == x then
		x = math.ceil(x)
	else
		x = math.ceil(x) - 1
	end
	return x
end
