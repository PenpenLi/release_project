local char					= import( 'world.char' )

role_model = lua_class('role_model')
local scale = 1

function role_model:_init(info)
	local conf = import('char.'..info.role_type) 
	self.entity = char.char(conf)
	self.entity.conf = conf
	self.entity.cc:setLocalZOrder(10000)
	local wear = info.wear
	if wear ~= nil then 
		self.entity:change_equip(self.entity.equip_conf.weapon, info.equips[tostring(wear.weapon)])
		self.entity:change_equip(self.entity.equip_conf.helmet, info.equips[tostring(wear.helmet)])
		self.entity:change_equip(self.entity.equip_conf.armor, info.equips[tostring(wear.armor)])
	end
	self.entity.animset = {}

	for k, v in pairs(conf) do
		if type(v) == 'table' and v.anim ~= nil and (k == 'attack' or k == 'idle') then
			self.entity.animset[k] = v.anim
			for id, anim in pairs(self.entity.animset[k]) do
				if type(id) == 'number' then
					self.entity.animset[k] = anim
					break
				end
			end
		end
	end

	self:set_scale(scale)
end

function role_model:play_secected_anim( )
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID
		
		if movementType == 1 then
			if id == self.entity.animset['attack'].name then
				--self.entity.armature:getAnimation(): play(self.entity.animset['idle'].name, self.entity.animset['idle'].framecount or 1, -1)
				--self.entity:play_anim({self.entity.animset['idle'].name, self.entity.animset['idle'].framecount, self.entity.animset['idle'].loop})
				--print(self.entity.animset['idle'].name, self.entity.animset['idle'].framecount, self.entity.animset['idle'].loop)
				--self:play_anim('idle', self.entity.animset['idle'].framecount, -1)
				self:play_anim('idle')
			end
		end
	end
	self.entity.armature:getAnimation(): play(self.entity.animset['attack'].name, self.entity.animset['attack'].framecount or 1, 0)
	self.entity.armature:getAnimation():setMovementEventCallFunc(animationEvent)
end

function role_model:play_anim(anim_name)
	--self.entity:play_anim({name = self.entity.animset[anim_name].name, framecount = framecount or self.entity.animset[anim_name].framecount, loop = loop or self.entity.animset[anim_name].loop})
	self.entity.armature:getAnimation(): play(self.entity.animset[anim_name].name, self.entity.animset[anim_name].framecount or 1, -1)
end

function role_model:stop( )
	self.entity:play_anim(self.entity.animset['idle'])
	self.entity.armature:getAnimation():stop()
end

function role_model:set_scale(scale)
	self.entity.cc:setScale(scale)
end

function role_model:set_position(x, y)
	self.entity.cc:setPosition(x, y)
end

function role_model:add_tx(tx, zorder)
	self.entity.cc:addChild(tx.armature, zorder)
end