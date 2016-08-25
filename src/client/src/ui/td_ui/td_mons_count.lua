local command			= import( 'game_logic.command' )
local interface			= import( 'model.interface' )
local director			= import( 'world.director')
local math_ext			= import( 'utils.math_ext')

td_mons_count 	= lua_class('td_mons_count')

local _size				= cc.Director:getInstance():getVisibleSize()	--屏幕大小
local _view_len			= 0
local _zero_x			= 0
local _image			= nil
local _label			= nil

function td_mons_count:_init( widget )

	self.mons_count_view = widget:getChildByName('td_ScrollView')
	self.view_len = self.mons_count_view:getContentSize().width

	self.Image_count = self.mons_count_view:getChildByName('Image_count')
	self.Image_count_x = self.Image_count:getPositionX()

	self.Label_count = widget:getChildByName('Label_count')
	
	-- print("mons_count_view width is -----Image_count_x-----", self.view_len, self.Image_count_x)
	self:init_view()
end

function td_mons_count:init_view(  )
	self.Label_count:setString("0%")
	_zero_x = self.Image_count_x - self.view_len
	self.Image_count:setPositionX(_zero_x)

	-- set
	_view_len = self.view_len
	_image = self.Image_count
	_label = self.Label_count
end

function update_td_mons_count( precent )
	local add_x = precent * _view_len
	_image:setPositionX(_zero_x + add_x)
	_label:setString(""..math.ceil(precent*100).."%")
end

--移除触摸事件
function td_mons_count:remove_touch_event(  )
	-- body
	self.cc:getEventDispatcher():removeAllEventListeners()
end
