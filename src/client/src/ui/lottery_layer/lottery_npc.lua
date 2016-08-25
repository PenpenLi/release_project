local layer					= import( 'world.layer' )

lottery_npc = lua_class('lottery_npc',layer.layer)
local _json_file 	= 'skeleton/NPC_Princess/NPC_Princess.ExportJson'


function lottery_npc:_init(  )
	super(lottery_npc,self)._init()
		--加入宝箱动画
	self.is_remove = false
end

function lottery_npc:play_anim( x,y )
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature = ccs.Armature:create('NPC_Princess')
	self.cc:addChild(self.armature)
	self.armature:setLocalZOrder(1000)
	self.armature:setPosition(x,y)
	self.armature:getAnimation():play('Stand2',30, 1)
	self.armature:setScale(2.5)
	
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

function lottery_npc:reload(  )
	super(lottery_npc,self).reload()
end


function lottery_npc:release(  )
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	super(lottery_npc,self).release()
end
