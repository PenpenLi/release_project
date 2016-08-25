local director			= import( 'world.director' )
local char				= import( 'world.char' )
local model 			= import( 'model.interface' )
local entity			= import( 'world.entity' )
local layer				= import( 'world.layer' )
local ui_const			= import( 'ui.ui_const' )

boss_dia = lua_class('boss_dia', layer.ui_layer)

function boss_dia:_init(ui_layer)

	self.ui_layer = ui_layer
	super(boss_dia, self)._init();
	self.skin = 'gui/battle/Ui_duihua.ExportJson'
	self.model = model.get_player()
	self.model:unbound_entity()  

end 

function boss_dia:finish_init()

	self.black_root = ccs.GUIReader:getInstance():widgetFromJsonFile('gui/battle/Ui_Black.ExportJson')
	self.cc:addChild(self.black_root,0,0)
	self.black_root:setPosition(0,0)
	--self.black_root:addChild(self.defeated_root,1,1)

	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,0)

	self.pos = self:get_widget('Image_2')
	self.pos:setVisible(true)
	self:touch_event()
	self.boss = self:add_boss()
	self.boss.cc:setAnchorPoint(cc.p(0,0))
	--print('123', self.pos:getPositionX(), self.pos:getPositionY())
	self.boss.cc:setPosition(cc.p(10, 20))
	self.boss.cc:setScale(1.2)
	self.pos:addChild(self.boss.cc)

	self:add_ttf()
end 

function boss_dia:on_enter()
	director.get_scene():pause()
end

function boss_dia:on_exit()
  
end

function boss_dia:touch_event()

	 local function touchEvent(sender,eventType)
	    if eventType == ccui.TouchEventType.began then
	       
	    elseif eventType == ccui.TouchEventType.moved then
	        
	    elseif eventType == ccui.TouchEventType.ended then
	            self.cc:setVisible(false)
	            director.get_scene():resume()
	            self.ui_layer:setVisible(true)
	    elseif eventType == ccui.TouchEventType.canceled then

	    end
	    
	end    

	self.black_root:addTouchEventListener(touchEvent)
	--local dispatchder

	local function onTouchBegan(touch, event)

	    --self.cc:getEventDispatcher():removeEventListener(listener)
	    self.cc:removeFromParent()
	    director.get_scene():resume()
	    self.ui_layer:setVisible(true)

	 	return true
	end

	local function onTouchMove()
	   -- print('boss dia touch move')
	end

	local function onTouchEnded()
	    --listener:removeEventListener()
	end 

	--self.cc:getEventDispatcher():removeAllEventListeners();
	--self.cc:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self.cc)
	--self.cc:getEventDispatcher():addEventListenerWithFixedPriority(listener, -128)

end 

function  boss_dia:add_boss()
    --self.model:init_combat_attr()
    local conf = import('char.role02') 
    local boss = char.char(conf)
    boss.cc:setLocalZOrder(888)

    self.animset = {}
	self.cur_anim_key = '' 
	self.first_key = 'idle'
	self.first_anim = nil
	for k, v in pairs(conf) do
		if type(v) == 'table' and  k == 'idle' then
	
			self.animset[k] = v.anim
			self.cur_anim_key = k
		end
	end
	boss:play_anim(self.animset[self.cur_anim_key])     
    return boss
end 

function boss_dia:add_ttf()
	self.label  = self:get_widget('Label_4')
	self.label2 =self:get_widget('Label_3')
	--self.label:setFontName('fonts/msyh.ttf')
	self.label:enableOutline(ui_const.UilableStroke, 2)
	--self.label2:setFontName('fonts/msyh.ttf')
	self.label2:enableOutline(ui_const.UilableStroke, 2)
end 
