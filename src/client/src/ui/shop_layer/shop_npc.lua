local layer					= import( 'world.layer' )

shop_npc = lua_class('shop_npc',layer.layer)
local _json_file 	= 'skeleton/NPC_Oldman/NPC_Oldman.ExportJson'


function shop_npc:_init(  )
	super(shop_npc,self)._init()
		--加入宝箱动画
	self.is_remove = false
end

function shop_npc:play_anim( x,y )
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature = ccs.Armature:create('NPC_Oldman')
	self.cc:addChild(self.armature)
	self.armature:setLocalZOrder(1000)
	self.armature:setPosition(x,y)
	self.armature:getAnimation():play('Stand',40, 1)
	self.armature:setScale(2)
	
	-- local function animationEvent(armatureBack,movementType,movementID)
	-- 	local id = movementID

	-- 	if movementType == 1 then
	-- 		if id == "Attack" then
	-- 		self.armature:getAnimation():play('Stand',40, 1)
	-- 		end
	-- 	end
	-- end
	--self.armature:getAnimation():setMovementEventCallFunc(animationEvent)
end

function shop_npc:reload(  )
	super(shop_npc,self).reload()
end


function shop_npc:release(  )
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	super(shop_npc,self).release()
end
