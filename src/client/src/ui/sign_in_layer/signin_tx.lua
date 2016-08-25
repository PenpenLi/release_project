
local layer					= import( 'world.layer' )

signin_tx = lua_class('signin_tx',layer.layer)
local _json_file 	= 'gui/ui_sign_tx/ui_sign_tx.ExportJson'


function signin_tx:_init(  )
	super(signin_tx,self)._init(false)
	--加入宝箱动画
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature = ccs.Armature:create('ui_sign_tx')
	self.cc:addChild(self.armature)
	self.armature:setLocalZOrder(1000)
	
end



function signin_tx:play_sel_anim( pos )
	
	self.armature:getAnimation():play('Stand',14, -1)
	
end

function signin_tx:remove(  )
	self:release()
end



function signin_tx:release(  )
	
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	super(signin_tx,self).release()
	self.cc:removeFromParent()
end
