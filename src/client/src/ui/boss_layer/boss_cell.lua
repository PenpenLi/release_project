local ui_const			= import( 'ui.ui_const' )
local shader 			= import( 'utils.shaders' )

boss_cell	= lua_class( 'boss_cell' )
local eicon_set = 'icon/s_icons.plist'
local load_texture_type = TextureTypePLIST

function boss_cell:_init( layer, battle_id )
	if battle_id == nil then
		return
	end
	self.layer	= layer
	self.data = data.boss_battle[battle_id]
	self.boss_id = data.boss_battle[battle_id].boss_id
	self.unlock_id = data.boss_battle[battle_id].unlock
	self.battle_id = battle_id
	self:create_cell( )
	self:set_type_icon()
	self:set_boss_icon(self.data.icon)
end

function boss_cell:create_cell()
	
	self.cell = self.layer:get_widget( 'pal_boss' ):clone( )
	self.btn  = self.cell:getChildByName('btn_boss')
	self.boss_icon = self.btn:getChildByName('boss_icon')
end

function boss_cell:set_type_icon()
	local boss_type = self.data.property
	local types = {'n', 'f', 'i'}
	for k, t in pairs(types) do
		if boss_type == t then
			self.type_icon = self.btn:getChildByName('img_type_' .. t)
			self.type_icon:setVisible(true)
			self.type_icon:setLocalZOrder(100)
		else
			self.btn:getChildByName('img_type_'..t):setVisible(false)
		end
	end
end

function boss_cell:set_boss_icon(icon_path)
	cc.SpriteFrameCache: getInstance(): addSpriteFrames( eicon_set )
	print(icon_path)	
	self.boss_icon:loadTexture(icon_path, load_texture_type)
end

function boss_cell:get_cell()
	return self.cell
end

function boss_cell:get_btn()
	return self.btn
end

function boss_cell:get_widgth()
	return self.btn:getContentSize().width
end

function boss_cell:get_height()
	return self.btn:getContentSize().heigth
end

function boss_cell:get_boss_icon()
	return self.boss_icon
end

function boss_cell:set_boss_gray(gray)
	shader.SpriteSetGray(self.boss_icon:getVirtualRenderer(), gray)
	shader.SpriteSetGray(self.type_icon:getVirtualRenderer(), gray)
end

function boss_cell:set_finish()
	--self:set_boss_icon(self.data.icon)
	self.boss_icon:setVisible(true)
	self.btn:getChildByName('death_icon'):setVisible(true)
	self.btn:setTouchEnabled(false)
	self.boss_icon:setVisible(true)
	self.type_icon:setVisible(true)
	self:set_boss_gray(0)
end

function boss_cell:set_cur()
	--self:set_boss_icon(self.data.icon)
	self.boss_icon:setVisible(true)
	self.btn:getChildByName('death_icon'):setVisible(false)
	self.btn:setTouchEnabled(true)
	self.boss_icon:setVisible(true)
	self.type_icon:setVisible(true)
	self:set_boss_gray(1)
end

function boss_cell:set_not_cur()
	--self:set_boss_icon(self.data.icon)
	self.boss_icon:setVisible(true)
	self.btn:getChildByName('death_icon'):setVisible(false)
	self.btn:setTouchEnabled(false)
	self.boss_icon:setVisible(true)
	self.type_icon:setVisible(true)
	self:set_boss_gray(0)
end

function boss_cell:set_unknow()
	self.boss_icon:setVisible(false)
	self.btn:getChildByName('death_icon'):setVisible(false)
	self.btn:setTouchEnabled(false)
	self.boss_icon:setVisible(false)
	self.type_icon:setVisible(false)
	self:set_boss_gray(1)
end

function boss_cell:get_battle_id()
	return self.battle_id
end