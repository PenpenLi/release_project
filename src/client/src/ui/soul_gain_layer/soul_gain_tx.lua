local layer					= import( 'world.layer' )

soul_gain_tx = lua_class('soul_gain_tx',layer.layer)
local _json_file 	= 'gui/ui_soul_gain_tx/ui_soul_gain_tx.ExportJson'

local _anim_time = 88
local _anim_z= 1000
local _loop = -1
local _anim_name= 'Stand'

function soul_gain_tx:_init(  )
	super(soul_gain_tx,self)._init(false)
	
end

function soul_gain_tx:play_anim( )
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(_json_file)
	self.armature = ccs.Armature:create('ui_soul_gain_tx')
	self.cc:addChild(self.armature)
	self.armature:setLocalZOrder(_anim_z)
	self.armature:getAnimation():play(_anim_name,_anim_time, _loop)

end

function soul_gain_tx:release(  )
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(_json_file)
	super(soul_gain_tx,self).release()
	self.cc:removeFromParent()
end
