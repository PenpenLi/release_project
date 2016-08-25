
local ui_const			= import( 'ui.ui_const' )

boss_hp = lua_class('boss_hp')

local boss_hp_view = nil
local boss_hide_count = 0
local boss_show_count = 0

function  boss_hp:_init( widget,name )

	self.imgbg=widget:getChildByName(name)
	self.hp = self.imgbg:getChildByName('boss生命条'):getChildByName('Image_37')
	self.hp_label = self.imgbg:getChildByName('boss生命条'):getChildByName('Label_32_0')
	self.hp_p = self.hp:getPositionX()
	self.bar_length = self.hp:getContentSize().width
	--self.hp_label:setFontName('fonts/msyh.ttf')
	self.hp_label:enableOutline(ui_const.UilableStroke,2)
	boss_hp_view = self.imgbg
	boss_hide_count = 0
	boss_show_count = 0
end

function boss_hp:set_red_bar( number,cur_hp )
	-- body
	if number <=0 then
		number=0
	end 
	if number >=100 then
		number = 100
	end

	self.hp:setPositionX(self.bar_length*(number/100))

	--self.hp:setPercent(number)
	cur_hp = self:getIntPart(cur_hp)

	self.hp_label:setString(cur_hp)

end

function boss_hp:getIntPart( x )
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

function get_boss_hp_view(  )
	-- body

	return boss_hp_view
end

function set_show_count( count )
	-- body
	boss_show_count = count
end

function set_hide_count( count )
	-- body
	boss_hide_count = count
end

function get_show_count(  )
	-- body
	return boss_show_count
end

function get_hide_count(  )
	-- body
	return boss_hide_count
end

function set_visible( isvisible )
	boss_hp_view:setVisible( isvisible )		
end
