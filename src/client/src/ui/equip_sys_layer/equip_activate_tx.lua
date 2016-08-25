local layer					= import( 'world.layer' )

equip_activate_tx = lua_class('equip_activate_tx',layer.layer)
local _json_file 	= 'gui/ui_reload_tx/UI_reload_tx.ExportJson'

function equip_activate_tx:_init(  )
	super(equip_activate_tx,self)._init(true)
		--加入宝箱动画
end

function equip_activate_tx:play_anim( x,y )
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature = ccs.Armature:create('UI_reload_tx')
	self.cc:addChild(self.armature)
	self.armature:setLocalZOrder(1000)
	self.armature:setPosition(x,y)
	self.armature:getAnimation():play('Stand',22, 0)
	
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand" then
				self.armature:removeFromParent()
				self:release()
			end
		end
	end
	self.armature:getAnimation():setMovementEventCallFunc(animationEvent)
end

function equip_activate_tx:release(  )
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_btn_json_file)
	super(equip_activate_tx,self).release()
	self.cc:removeFromParent()
end
