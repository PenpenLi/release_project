
local layer 			= import('world.layer')
local vir_list 			= import('ui.victory_layer.vir_list')

vir_box = lua_class('vir_box',layer.ui_layer)

local _json_file 	= 'gui/baoxiang/baoxiang.ExportJson'
local bg_file 		= 'gui/battle/Ui_Black.ExportJson' 
function vir_box:_init(  )

	super(vir_box,self)._init(bg_file)
	self.widget:ignoreAnchorPointForPosition(true)
	--self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	--加入宝箱动画
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature = ccs.Armature:create('baoxiang')
	self.cc:addChild(self.armature)
	self.armature:setLocalZOrder(1000)
	self.armature:setPosition(VisibleSize.width/2,VisibleSize.height/2)
	self.armature:getAnimation():play('Up',14, 0)
	

	self.can_open = false
	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

		if movementType == 1 then
			if id == "Up" then

			self.armature:stopAllActions()
			self.armature:getAnimation():play("Run",25, 1)
			self.can_open = true
			end
		end
	end
	self.armature:getAnimation():setMovementEventCallFunc(animationEvent)
	self.is_open = false
end

function vir_box:get_open(  )
	return self.can_open
end

function vir_box:open_box( call_back )
	-- body
	print('触摸开始')
	if self.is_open == true or self.can_open == false then
		return
	end
	self.is_open = true
	self.can_open = false
	self.armature:stopAllActions()
	self.armature:getAnimation():play("Attack",41, 0)
	self.armature:getAnimation():setSpeedScale(2.5)

	local function animationEvent(armatureBack,movementType,movementID)
		local id = movementID

			if movementType == 1 then
				if id == "Attack" then
                    call_back()
				end
			end
		end
	self.armature:getAnimation():setMovementEventCallFunc(animationEvent)


end
