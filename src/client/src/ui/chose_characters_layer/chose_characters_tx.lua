local layer					= import( 'world.layer' )

chose_characters_tx = lua_class('chose_characters_tx',layer.layer)

local json = ''
local default_speed = 0.8
local default_framecount = 25
local default_loop = 0

function chose_characters_tx:_init()
end


function load_json_file(_json)
	if _json == nil then
		return 
	end
	json = _json
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(json)
end

function chose_characters_tx:create_armature(armature_name, animation, framecount, loop, speed)
	if armature_name == nil then
		return 
	end
	self.armature_name = armature_name
	self.animation = animation
	self.framecount = framecount
	self.loop = loop
	self.armature = ccs.Armature:create(armature_name)
	self.speed = speed
	self:set_speed_scale(self.speed or default_speed)
	self:play_animation()
end

function chose_characters_tx:play_animation()
	self.armature:getAnimation():play(self.animation, self.framecount or default_framecount, self.loop or default_loop)
end

function chose_characters_tx:set_position(x, y)
	self.armature:setPosition(x, y)
end

function chose_characters_tx:release(  )
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(json)
end

function chose_characters_tx:set_zorder(zorder)
	self.armature:setLocalZOrder(zorder)
end

function chose_characters_tx:set_visible(flag)
	if flag == false then
		self.armature:getAnimation():stop(self.animation)
	else
		self.armature:getAnimation():play(self.animation, self.framecount or default_framecount, self.loop or default_loop)
	end
	self.armature:setVisible(flag)
end

function chose_characters_tx:set_speed_scale(speedscale)
	self.armature:getAnimation():setSpeedScale(speedscale)
end


function chose_characters_tx:play_with_callfunc( func )
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID
		
		if movementType == 1 then
			if id == self.animation then
				func()
			end
		end
	end
	self.armature:getAnimation():setMovementEventCallFunc(animationEvent)
end