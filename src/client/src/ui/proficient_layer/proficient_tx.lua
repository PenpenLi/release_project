local layer					= import( 'world.layer' )

proficient_tx = lua_class('proficient_tx',layer.layer)
local _json_file 	= 'gui/ui_proficient_tx/ui_proficient_tx.ExportJson'


function proficient_tx:_init(  )
	super(proficient_tx,self)._init(true)
	--加入宝箱动画

end

function proficient_tx:play_jj_anim( star_pos,icon_pos ,btn_pos)
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature1 = ccs.Armature:create('ui_proficient_tx')
	self.cc:addChild(self.armature1)
	self.armature1:setLocalZOrder(1000)
	self.armature1:setPosition(star_pos.x,star_pos.y)
	self.armature1:getAnimation():play('Stand',32, 0)
	self.armature2 = ccs.Armature:create('ui_proficient_tx')
	self.cc:addChild(self.armature2)
	self.armature2:setVisible(false)
	self.armature1:setVisible(true)

	
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand" then
				--self.is_remove = true
				self.armature1:setVisible(false)
				self.armature2:setVisible(true)
				self.armature2:setLocalZOrder(1000)
				self.armature2:setPosition(icon_pos.x,icon_pos.y)
				self.armature2:getAnimation():play('Stand2',44, 0)

			end


		end
	end
	self.armature1:getAnimation():setMovementEventCallFunc(animationEvent)


	local function animation2Event(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand2" then
				self.armature2:setVisible(false)			
				self:release()
			end

		end
	end
	self.armature2:getAnimation():setMovementEventCallFunc(animation2Event)
end


function proficient_tx:play_sj_anim( star_pos)
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature1 = ccs.Armature:create('ui_proficient_tx')
	self.cc:addChild(self.armature1)
	self.armature1:setLocalZOrder(1000)
	self.armature1:setPosition(star_pos.x,star_pos.y)
	self.armature1:getAnimation():play('Stand',32, 0)
	self.armature1:setVisible(true)

	
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand" then
				
				self.armature1:setVisible(false)
				self:release()
			end


		end
	end
	self.armature1:getAnimation():setMovementEventCallFunc(animationEvent)
end



function proficient_tx:release(  )
	
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	super(proficient_tx,self).release()
	self.cc:removeFromParent()
end
