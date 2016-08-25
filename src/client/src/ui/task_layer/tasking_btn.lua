local ui_const 				= import( 'ui.ui_const' )

tasking_btn = lua_class( 'tasking_btn' )
local load_texture_type = TextureTypePLIST

function tasking_btn:_init( layer )
	self.layer = layer
	self:create_btn( )
	self:init_lbl()
end


function tasking_btn:create_btn(  )
	self.btn = self.layer:get_widget('tasking_button'):clone()
	self.btn:setName('hahaha')
	
end

function tasking_btn:get_btn(  )
	return self.btn
end

function tasking_btn:get_go_btn(  )
	return self.go_button
end

function tasking_btn:init_lbl(  )
	--任务标题
	self.lbl_task_title = self.btn:getChildByName('lbl_task_title')
	--self.lbl_task_title:setFontName(ui_const.UiLableFontType)
	self.lbl_task_title:enableOutline(ui_const.UilableStroke, 1)

	--任务内容
	self.lbl_task_cont = self.btn:getChildByName('lbl_task_cont')
	--self.lbl_task_cont:setFontName(ui_const.UiLableFontType)

	--目标文本
	self.lbl_target = self.btn:getChildByName('lbl_target')
	--self.lbl_target:setFontName(ui_const.UiLableFontType)


	--奖励1 
	self.lbl_reward_1 = self.btn:getChildByName('lbl_reward_1')
	--self.lbl_reward_1:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_1:enableOutline(ui_const.UilableStroke, 1)
	--奖励2 
	self.lbl_reward_2 = self.btn:getChildByName('lbl_reward_2')
	--self.lbl_reward_2:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_2:enableOutline(ui_const.UilableStroke, 1)
	--奖励3
	self.lbl_reward_3 = self.btn:getChildByName('lbl_reward_3')
	--self.lbl_reward_3:setFontName(ui_const.UiLableFontType)
	self.lbl_reward_3:enableOutline(ui_const.UilableStroke, 1)

	--前往按钮文本
	self.lbl_go_button = self.btn:getChildByName('go_button'):getChildByName('lbl_go_button')
	--self.lbl_go_button:setFontName(ui_const.UiLableFontType)
	self.lbl_go_button:enableOutline(ui_const.UilableStroke, 1)

	self.go_button = self.btn:getChildByName('go_button')

	self.reward_img_1 	= self.btn:getChildByName( 'reward_img_1' )
	self.reward_img_2	= self.btn:getChildByName( 'reward_img_2' )
	self.reward_img_3	= self.btn:getChildByName( 'reward_img_3' )
	self.task_img		= self.btn:getChildByName( 'task_img' )
	self.reward_img_1:setVisible(false)
	self.reward_img_2:setVisible(false)
	self.reward_img_3:setVisible(false)
	self.lbl_reward_1:setVisible(false)
	self.lbl_reward_2:setVisible(false)
	self.lbl_reward_3:setVisible(false)

end

--设置任务标题
function tasking_btn:set_task_title( t )
	self.lbl_task_title:setString(t)
end

--设置任务内容
function tasking_btn:set_task_cont( t )
	self.lbl_task_cont:setString(t)
end

--设置目标文本
function tasking_btn:set_target( z , w )
	self.lbl_target:setString(z .. '/' .. w)
end

function tasking_btn:set_target_food( s )
	self.lbl_target:setString( s )
end

function tasking_btn:set_task_img( route )
	
	self.task_img:loadTexture( route , load_texture_type )
end

function tasking_btn:set_reward( rwd_data )
	local count = #rwd_data
	for i=1,count do
		if rwd_data[i].k == 'items' then
			local item_type = data.item_id[rwd_data[i].v]
			local icon = data[item_type][rwd_data[i].v].icon
			local img = self['reward_img_' .. i]
			local number = self['lbl_reward_'..i]
			img:loadTexture(icon,load_texture_type)
			img:setVisible(true)
			img:setScale(0.35)
			number:setString('x' .. rwd_data[i].num)
			number:setVisible(true)
		else
			local img = self['reward_img_' .. i]
			local number = self['lbl_reward_'..i]
			img:loadTexture(rwd_data[i].k ..'.png',load_texture_type)
			img:setVisible(true)

			number:setString('x' .. rwd_data[i].v)
			number:setVisible(true)

		end

	end
end


--保存任务id
function tasking_btn:set_id( idx )
	self.id = idx
end

function tasking_btn:get_id(  )
	return self.id
end
