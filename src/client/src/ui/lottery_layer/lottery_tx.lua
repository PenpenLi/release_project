
local layer					= import( 'world.layer' )

lottery_tx = lua_class('lottery_tx',layer.ui_layer)

function lottery_tx:_init(  )
	super(lottery_tx,self)._init('gui/main/ui_lottery_tx.ExportJson',true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2,VisibleSize.height/2)

	self.is_remove = false
	self:set_is_gray(true)
end

function lottery_tx:play_anim( callback )

	local function callFunc(  )
		self:play_action('ui_lottery_tx.ExportJson','Animation1')
		callback()
	end
	local callFuncObj=cc.CallFunc:create(callFunc)
	self:play_action('ui_lottery_tx.ExportJson','Animation0',callFuncObj)
	
	
end

function lottery_tx:set_remove( )
	self.is_remove = true
end

function lottery_tx:release(  )
	-- body
	self.is_remove = false
	--ccs.ActionManagerEx:getInstance():releaseActionsByJsonName('ui_lottery_tx.ExportJson')
	super(lottery_tx,self).release()
end

function lottery_tx:reload(  )
	super(lottery_tx,self).reload()
end