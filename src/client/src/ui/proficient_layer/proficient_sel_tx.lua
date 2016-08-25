local layer					= import( 'world.layer' )

proficient_sel_tx = lua_class('proficient_sel_tx',layer.layer)
local _json_file 	= 'gui/ui_proficient_tx/ui_proficient_tx.ExportJson'


function proficient_sel_tx:_init(  )
	super(proficient_sel_tx,self)._init(nil,false)
	--加入宝箱动画
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature = ccs.Armature:create('ui_proficient_tx')
	self.cc:addChild(self.armature)
	self.armature:setLocalZOrder(1000)
	
end



function proficient_sel_tx:play_sel_anim( x,y )
	
	self.armature:setPosition(x,y)
	self.armature:getAnimation():play('Stand3',30, -1)
	
end

function proficient_sel_tx:remove(  )
	self.release()
end



function proficient_sel_tx:release(  )
	
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	super(proficient_sel_tx,self).release()
	self.cc:removeFromParent()
end
