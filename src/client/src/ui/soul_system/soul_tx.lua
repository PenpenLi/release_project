local layer					= import( 'world.layer' )

soul_tx = lua_class('soul_tx',layer.layer)
local _json_file 	= 'gui/ui_evolution_tx/ui_evolution_tx.ExportJson'


function soul_tx:_init(  )
	super(soul_tx,self)._init(true)
	--加入宝箱动画
	self.is_remove = false
end


function soul_tx:play_star_anim( s_pos,e_pos,cb)

	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature1 = ccs.Armature:create('ui_evolution_tx')
	self.cc:addChild(self.armature1)
	self.armature1:setLocalZOrder(1000)
	self.armature1:setPosition(s_pos.x,s_pos.y)
	self.armature1:getAnimation():play('Stand',24, 0)
	self.armature2 = ccs.Armature:create('ui_evolution_tx')
	self.cc:addChild(self.armature2)
	self.armature2:setLocalZOrder(1000)
	self.armature2:setVisible(false)
	self.armature1:setVisible(true)
	self.armature2:setPosition(e_pos.x,e_pos.y)
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand" then
				self.armature2:setVisible(true)
				self.armature2:getAnimation():play('Stand2',28, 0)
				self.armature1:removeFromParent()
				cb()
			end


		end
	end
	self.armature1:getAnimation():setMovementEventCallFunc(animationEvent)


	local function animation2Event(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand2" then
				self.armature2:removeFromParent()
				self:release()

			end

		end
	end
	self.armature2:getAnimation():setMovementEventCallFunc(animation2Event)
end

function soul_tx:release(  )
	print('remove_tx')
	self.is_remove = false
	self.armature1=nil
	self.armature2=nil
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	self.cc:removeFromParent()
end
