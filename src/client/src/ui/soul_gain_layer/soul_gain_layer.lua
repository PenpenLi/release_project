local layer					= import( 'world.layer' )
local ui_const 				= import( 'ui.ui_const' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local char					= import( 'world.char' )
local soul_gain_tx  		= import( 'ui.soul_gain_layer.soul_gain_tx' )

soul_gain_layer = lua_class('soul_gain_layer',layer.ui_layer)

local _jsonfile = 'gui/main/ui_soul_gain.ExportJson'
local _jsonname = 'ui_soul_gain.ExportJson'

function soul_gain_layer:_init( )
	super(soul_gain_layer,self)._init(_jsonfile,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)


	self.lbl_soul_name = self:get_widget('lbl_soul_name')
	self.lbl_soul_tips = self:get_widget('lbl_soul_tips')
	self.lbl_soul_tips:setVisible(false)
	--self.lbl_soul_name:setFontName(ui_const.UiLableFontType)
	self.lbl_soul_name:enableOutline(ui_const.UilableStroke, 2)
	self.lbl_soul_tips:enableOutline(ui_const.UilableStroke, 2)
	self.can_touch = true
	self.is_remove = false
	self:add_tx()
end

--加入背景特效
function soul_gain_layer:add_tx(  )
	self.soul_gain_tx = soul_gain_tx.soul_gain_tx()
	self.cc:addChild(self.soul_gain_tx.cc,-10)
	self.soul_gain_tx.cc:setPosition(VisibleSize.width/2 ,VisibleSize.height/2)
	self.soul_gain_tx:play_anim()
end

function soul_gain_layer:play_start_anim(  )

	local function callFunc(  )
		self:play_action(_jsonname,'light')
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	
	self:play_action(_jsonname,'up',callFuncObj)
	self:play_action(_jsonname,'light1')
end


function soul_gain_layer:set_end_callback( cb )
	self.cb = cb
end

function soul_gain_layer:play_end_anim(  )
	local function callFunc(  )
		--self.cc:setVisible(false)
		
		--anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
		if self.cb ~= nil then
			self.cb()

		end
		self.is_remove = true 
	end
	local callFuncObj=cc.CallFunc:create(callFunc)

	self:play_action(_jsonname,'down',callFuncObj)
end

--设置名字
function soul_gain_layer:set_name( str )
	self.lbl_soul_name:setString(str)
end

function soul_gain_layer:set_tips( tips )
	self.lbl_soul_tips:setVisible(true)
	self.lbl_soul_tips:setString(tips)
end

function soul_gain_layer:init_skill_with_id(id)
	dir(data.skill[id])
	self:set_anim(data.skill[id][1].anim)
	self:set_name(data.skill[id][1].name)
end

--设置动画
function soul_gain_layer:set_anim( file )
	local shadow_widget = self:get_widget('shadow')
	self.conf = import('char.' .. file)
	self.entity_anim = char.char(self.conf)
	self.entity_anim.cc:setLocalZOrder(3)
	self.animset = {}			--用来放不同状态名字key对应的动画table
	self.cur_anim_key = '' 
	self.first_key = 'idle'
	self.first_anim = nil

	for k, v in pairs(self.conf) do
		if type(v) == 'table' and v.anim ~= nil
	   and (k == 'idle' or k == 'attack' or  k == 'run') then
			if self.first_key == k then
				self.first_key = k
				self.first_anim = v.anim
			end
			self.animset[k] = v.anim
			self.cur_anim_key = k

		end
	end

	self.entity_anim:play_anim(self.animset[self.first_key])
	if self.conf.boss == true then
		self.entity_anim.cc:setScale(0.55)
	else
		self.entity_anim.cc:setScale(0.8)
	end

	self.entity_anim.cc:ignoreAnchorPointForPosition(true)
	shadow_widget:setAnchorPoint(cc.p(0.5, 0.5))	--设置阴影的锚点
	self.entity_anim.armature:setAnchorPoint(cc.p(0.5, 0))	
	local shadow_size = shadow_widget:getLayoutSize()	--获取阴影的大小
	self.entity_anim.cc:setPosition(shadow_size.width/2,shadow_size.height*2/4)	--设置玩家位置
	shadow_widget:addChild(self.entity_anim.cc)
end

--触摸事件
function soul_gain_layer:touch_begin_event( touch, event )
	-- body
	if self.can_touch == true then
		self.can_touch = false
		self:play_end_anim()
	end

end

function soul_gain_layer:reload(  )
	super(soul_gain_layer,self).reload()
end

function soul_gain_layer:release(  )

	self.is_remove = false
	self.entity_anim:release()
	self.soul_gain_tx:release()
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName(_jsonname)
	super(soul_gain_layer, self).release()
end
