local layer 	 = import('world.layer');
local camera_mgr = import( 'game_logic.camera_mgr' )
shadow_layer     = lua_class("shadow_layer", layer.layer);

local _path 	 = "gui/shadow.png";
local _zorder	 = ZShadow
local _layer 	 = nil
local entities	 = {}
local shadows	 = {}
function shadow_layer:_init()
	super(shadow_layer, self)._init();
	self.shadow_texture  = cc.Director:getInstance():getTextureCache():addImage(_path)
	entities = {}
	shadows	 = {}
	_layer = self
end

function shadow_layer:add_shadow(entity, id)
	entities[id] = entity
	local shadow = cc.Sprite:createWithTexture(self.shadow_texture)
	self.cc:setLocalZOrder(_zorder)
	self.cc:addChild(shadow)
	shadows[id] = shadow
end

function shadow_layer:tick_pos()
	for id, e in pairs(entities) do 
		local pos = camera_mgr.world_to_screen(e:get_world_pos())
		if e:on_ground() then
			if shadows[id] ~= nil then 
				shadows[id]:setVisible(true)
				shadows[id]:setPosition(cc.p(pos.x , pos.y+e.y_axis_offset))
			end
		else
			if shadows[id] ~= nil then
				shadows[id]:setVisible(false);
			end
		end
	end 
end

function shadow_layer:remove_shadow(id)
	shadows[id]:removeFromParent()
	entities[id] = nil
	shadows[id] = nil
end 

function fade_shadow_with_id( id , t , op  )
	local action = cc.FadeTo:create(t/Fps,op)
	shadows[id]:runAction(action)
end
