local layer 	 	= import( 'world.layer' );
local camera_mgr	= import( 'game_logic.camera_mgr' )

blade_light	= lua_class("blade_light", layer.layer)

local png_path = 'bladelight.png'

function blade_light:_init()
	super(blade_light, self)._init()
	self.light_texture = cc.Director: getInstance(): getTextureCache(): addImage( png_path )
	self.light_texture:retain()
	self.lights = {}
	self.id_seq = 0
end

function blade_light:grab_id()
	self.id_seq = self.id_seq + 1
	return self.id_seq
end

function blade_light:generate_light(x, y, scale, time_to_live)
	local temp_light = cc.Sprite: createWithTexture( self.light_texture )
	temp_light: setPosition( camera_mgr.world_to_screen( {x = x, y = y} ) )
	self.lights[self:grab_id()] = {
		cc = temp_light,
		ttl = time_to_live 
	}

	local rotate = math.random(360)
	temp_light: setRotation( rotate )
	temp_light: setScale( scale )

	self.cc: addChild( temp_light )
end

function blade_light:new_light(x, y, scale, time_to_live)
	local temp_light = cc.Sprite: createWithTexture( self.light_texture )
	temp_light: setPosition( camera_mgr.world_to_screen( {x = x, y = y} ) )
	local temp_id = self:grab_id()
	self.lights[temp_id] = { cc = temp_light, x = x, y = y }
	temp_light: setScaleX( 0.5 )
	temp_light: setScaleY( 0.2 )
	local rotate = math.random(360)
	temp_light: setRotation( rotate )

	temp_light: setBlendFunc(770, 1)
	self.cc: addChild( temp_light )

	local function finish_action_cb( )
		temp_light:removeFromParent()
		self.lights[temp_id] = nil
	end

	temp_light: setOpacity( 0 )
	-- local scale_init = cc.ScaleBy:create(0.001, 0.5, 0.2)
	local opacity1 = cc.FadeIn:create( 0.10 )
	local opacity2 = cc.FadeOut:create( 0.16 )
	temp_light:runAction( cc.Sequence:create( opacity1, opacity2, cc.CallFunc:create(finish_action_cb) ) )
	local zoom1 = cc.ScaleBy:create( 0.26, 3, 7 )
	temp_light:runAction( cc.Sequence:create( zoom1 ))

end

function blade_light:tick()
	for id, l in pairs(self.lights) do
		l.cc: setPosition( camera_mgr.world_to_screen( { x=l.x, y=l.y } ))
	end
end

function blade_light:release()
	for id, l in pairs(self.lights) do
		l.cc: removeFromParent()
		self.lights[id] = nil
	end
	self.light_texture: release()
	cc.Director: getInstance(): getTextureCache(): removeTexture( self.light_texture )
end
