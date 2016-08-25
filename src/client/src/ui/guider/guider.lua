---是地图那个，新手指导
--修改
local layer  = import('world.layer')

guider = lua_class('guider', layer.layer)

function guider:_init(guider_pos)
     super(guider, self)._init()

     self.pos = guider_pos

     self:set_new_guider()
end

function guider:touch_listener()
  -- body
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true)

    local function onTouchBegan(touch, event)
           local possition  = touch:getLocation() 
           if cc.rectContainsPoint(self.rect, possition) then 
              print('doing here!~')  
              return false
           end
        return true
    end

    local function onTouchMove(touch, event)
    end

    local function onTouchEnded(touch, event)   
    end 
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove,  cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self.cc:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.cc)

end

function guider:onTouchMove()
  -- body
end

function guider:set_new_guider()

    -- self.cc:removeAllChildren()

     self.clip = cc.ClippingNode:create();
     self.clip:setInverted(true)            --绘不绘制模板，true就是不绘制模板
     self.clip:setAlphaThreshold(0)         --设置模板的透明值

     self.cc:addChild(self.clip, 100)       --加入模板
     --local mask_layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 180))
     --self.swallow_touch_layer = swallow_touch_layer.swallow_touch_layer(nil, self.clip, 2, nil)
     local size = cc.Director:getInstance():getWinSize();
     local color = cc.c4b(0, 0, 0, 50);
     self.mask_layer = cc.LayerColor:create(color, size.width, size.height);		--遮罩层 
   --self.mask_layer:setTouchEnabled(true);	
     self.clip:addChild(self.mask_layer, 99)                  --把遮罩用颜色层加到模板上

     local node = cc.Node:create();
     local circle = cc.Sprite:create("gui/guider/back.png")
    -- circle:getTexture():setAliasTexParameters()            --官方解释：调用本方法会导致额外的纹理内存开销。实际没有什么效果
     --circle:setScale(1.25)
    -- print(dir(circle:getBoundingBox()))
     node:addChild(circle)
     node:setPosition(self.pos.x, self.pos.y)
     self.clip:setStencil(node)                 --要显示的黑色圆底图片加入到clip中
     --self.clip:setPosition(cc.p(0, 0))

     --print(node:getPosition())
    
    local tip = cc.Sprite:create('gui/guider/circle.png')   --显示在播放缩放动作的圆
    --tip:setScale(1.2);
    tip:setRotation(60)
    tip:setPosition(self.pos.x, self.pos.y)
    self.cc:addChild(tip)
    tip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.25,0.9),cc.ScaleTo:create(0.25,1),NULL)))

    --test
    local content_size =  circle:getContentSize()
    print('circle')
   -- dir(content_size)
    self.rect = cc.rect(self.pos.x - content_size.width/2, self.pos.y - content_size.height/2, content_size.width, content_size.height)
   	self:touch_listener()

    return true;  
end 

function guider:first_guider()

end 

function guider:on_exit()
    
end 

function guider:on_enter()
    
end 


function guider:second_guider()

end

function guider:remove()
     self.cc:removeFromParent()
end 