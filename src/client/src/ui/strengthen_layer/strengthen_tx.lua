local layer					= import( 'world.layer' )

strengthen_tx = lua_class('strengthen_tx',layer.layer)
local _json_file 	= 'gui/ui_QiangHuaTx/QiangHuaTx.ExportJson'
local _btn_json_file = 'gui/ui_strengthen_tx/UI_streng_tx.ExportJson'

local _btn_anim_time = 5
local _icon_anim_time = 10

function strengthen_tx:_init(  )
	super(strengthen_tx,self)._init(true)
	
end

function strengthen_tx:play_anim( x,y,x3,y3 )
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature = ccs.Armature:create('QiangHuaTx')
	self.cc:addChild(self.armature)
	self.armature:setLocalZOrder(1000)
	self.armature:setPosition(x,y)
	self.armature:getAnimation():play('Stand',20, 0)
	
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand" then
				self:play_anim3( x3,y3 )
				self.armature:removeFromParent()
			end
		end
	end
	self.armature:getAnimation():setMovementEventCallFunc(animationEvent)
end

--按钮特效
function strengthen_tx:play_anim2( x,y,x2,y2,x3,y3)
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_btn_json_file)
	self.armature2 = ccs.Armature:create('UI_streng_tx')
	self.cc:addChild(self.armature2)
	self.armature2:setLocalZOrder(1000)
	self.armature2:setPosition(x,y)
	self.armature2:getAnimation():play('Stand',_btn_anim_time, 0)
	
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand" then
				-- self.armature2:setPosition(x2,y2)
				-- self.armature2:getAnimation():play('Stand2',15, 0)
				self.armature2:removeFromParent()
				self:play_anim3(x3,y3)
			end
		end
	end
	self.armature2:getAnimation():setMovementEventCallFunc(animationEvent)
end

function strengthen_tx:play_anim3( x,y )
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_btn_json_file)
	self.armature2 = ccs.Armature:create('UI_streng_tx')
	self.cc:addChild(self.armature2)
	self.armature2:setLocalZOrder(1000)
	self.armature2:setPosition(x,y)
	self.armature2:getAnimation():play('Stand2',_icon_anim_time, 0)
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Stand2" then
				self.armature2:removeFromParent()
				self:release()
			end
		end
	end
	self.armature2:getAnimation():setMovementEventCallFunc(animationEvent)
end

function strengthen_tx:release(  )
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_btn_json_file)
	super(strengthen_tx,self).release()
	self.cc:removeFromParent()
end
