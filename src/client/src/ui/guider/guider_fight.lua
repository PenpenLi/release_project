---是战斗的划屏指导
--修改
local layer             = import('world.layer')
local director          = import( 'world.director' )
local command       = import( 'game_logic.command' )
local command_mgr   = import( 'game_logic.command_mgr' )


guider_fight = lua_class('guider', layer.layer)

_real_cmd = nil 
function set_real_cmd(cmd)
    _real_cmd = cmd
    --init()
end

function guider_fight:_init()
     super(guider_fight, self)._init()

     self.cc:registerScriptHandler(function(event_type)
        if event_type == "enter" then 
           --  director.get_scene():pause()
           --self:on_enter()
        elseif event_type == "exit" then 
        end
    end);
    self:add_tip()
end

function guider_fight:on_enter()
    -- body
    print('************************')
    director.get_scene():pause()
end

function guider_fight:on_exit()

end 

--掩盖层
function guider_fight:mask_layer(direction)

    --吞噬层
    self.listener = cc.EventListenerTouchOneByOne:create();
    --local listener = cc.EventListenerTouchAllAtOnce:create();
    self.listener:setSwallowTouches(true)

    local function onTouchBegan(touch, event)
       print("begin")
       self.touch_begin = touch:getLocation()
       return true
    end

    local function onTouchMove(touch, event)
     
    end

    local function onTouchEnded(touch, event)
        self.touch_end = touch:getLocation()
        if direction == 'right' then 
            if self.touch_begin.x < self.touch_end.x - 50 then 
                print('doing remove')

                local guider_trigger    = import( 'ui.guider.guider_trigger')

                --触发事件
                guider_trigger.trigger_event(guider_trigger.FIGHT_SLIDE_RIGHT)
            end 
        elseif direction == 'left' then 

        end 
       -- print("ended")
    end 
    self.listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.listener:registerScriptHandler(onTouchMove,  cc.Handler.EVENT_TOUCH_MOVED)
    self.listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    --self.swallow_touch_layer:getEventDispatcher():addEventListenerWithFixedPriority(listener, -128)
    self.cc:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener, self.cc)
end

function guider_fight:add_tip()

    local color = cc.c4b(0, 0, 0, 180);
   
    self.touch_layer = cc.LayerColor:create(color, VisibleSize.width, VisibleSize.height);       

    self.cc:addChild(self.touch_layer, 1)

    self.tip = cc.Sprite:create('gui/guider/fin.png')
    --tip:setScale(1.2);
    self.tip:setRotation(-90)
    self.tip:setScale(0.5)
    self.tip:setPosition(VisibleSize.width/2, VisibleSize.height/3)
    self.cc:addChild(self.tip,2)


    local function reset()
        self.tip:setPosition(VisibleSize.width/2, VisibleSize.height/3)
    end 
    local move = cc.MoveTo:create(1,cc.p(VisibleSize.width/2 + 200,  VisibleSize.height/3))

    local seq = cc.Sequence:create(move, cc.CallFunc:create(reset))

    self.tip:runAction(cc.RepeatForever:create(seq))

    self:mask_layer('right')
end 



function guider_fight:onTouchMove()
  -- body
end

function guider_fight:remove_all_node()
    self.cc:removeAllChildren()
    self.cc:removeFromParent()
end 

function guider_fight:remove_event( )
    ---local eventDispatcher =self.cc:getEventDispatcher()
    ---eventDispatcher:removeEventListener(self.listener)
end