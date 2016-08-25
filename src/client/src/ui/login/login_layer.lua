local layer					= import( 'world.layer' )
local director				= import( 'world.director'  )
local music_mgr				= import('world.music_mgr')
local model					= import('model.interface')
local net_model 			= import('network.interface')
local server_list 			= import( 'server_list' )
local ui_mgr 				= import( 'ui.ui_mgr' )
local msg_queue 			= import( 'ui.msg_ui.msg_queue' )

login_layer					= lua_class('login_layer', layer.ui_layer)

function login_layer:_init()
	super(login_layer, self)._init('base/res/login/Ui-landing.ExportJson')

	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	--self.black_root:setLocalZOrder(-100)
	self.layer0 = self:get_widget('layer0')
	self.layer1 = self:get_widget('layer1')
	self.layer2 = self:get_widget('layer2')
	self.layer3 = self:get_widget('layer3')
	self.layer4 = self:get_widget('layer4')
	
	local offline_buttom = self:get_widget('Button_24_0')
	self:set_handler("Button_24_0", self.offline_game)
	music_mgr.play_normal_bg_music()

	--加入叶子
	local ye = cc.ParticleSystemQuad:create("particles/Ye_1.plist")
	self.layer1:addChild(ye)
	ye:setPosition(-VisibleSize.width/2,VisibleSize.height/2)

	--选区
	self.select_btn = self:get_widget('select_button_0')
	self:set_handler('select_button_0', self.select_button_event)

	--登陆
	self.login_btn = self:get_widget('loading_button_0')
	self:set_handler('loading_button_0', self.login_button_event)

	self.lbl_sever_name = self:get_widget('lbl_sever_name')
	self:set_sever_number()

	self.last_server_id = net_model.get_server_id()
end

function login_layer:set_sever_number(  )
	local num = net_model.get_server_id()
	self.sever_number = num

	if server_list.list[num] == nil then
		num = #server_list.list
	end

	local id = server_list.list[num].id
	local name = server_list.list[num].name
	self.lbl_sever_name:setString(id .. '区 ' .. name)
end

function login_layer:select_button_event( sender, eventype )
	if eventype == ccui.TouchEventType.ended then
		sender:setTouchEnabled(false)
		local select_panel = ui_mgr.create_ui(import('ui.login.select_panel'), 'select_panel')
		select_panel:set_last_sever_id( self.last_server_id )
		sender:setTouchEnabled(true)
	end
end

function login_layer:login_button_event( sender, eventype )
	if eventype == ccui.TouchEventType.ended then
		if login_server() ~= true then
			msg_queue.add_msg('连接失败,请检查网络后重试！')
		end
	end
end

function login_layer:offline_game(sender, eventype)
	if eventype == ccui.TouchEventType.ended then
		model.offline()
		local director = import('world.director')
		local text = self:get_widget('TextField_13'):getStringValue()

		if text == '' then
			-- director.enter_battle_scene(999)
			director.enter_battle_scene(1001)
		else
			director.enter_battle_scene(tonumber(text))
		end
	end
end

function login_layer:tick()
	local yaw, roll, pitch = _extend.get_motion()
	roll = roll + 45
	if roll > 90 then
		roll = 90
	end
	if roll < -90 then
		roll = -90
	end
		local x_dis = 57*yaw/30.0
	local y_dis = 85*(roll)/90.0
	if x_dis > 57 then
		x_dis = 57
	end
	if x_dis < -57 then
		x_dis = -57
	end
	self.layer0:setPosition(cc.p(x_dis*1.2,y_dis*1.2))  --1.2
	self.layer1:setPosition(cc.p(x_dis*0.9,y_dis*0.9))  
	self.layer2:setPosition(cc.p(x_dis*0.4,y_dis*0.4))  --0.8
	self.layer3:setPosition(cc.p(x_dis*0.2,y_dis*0.2))  --0.6
	self.layer4:setPosition(cc.p(x_dis*0.0,y_dis*0.0))  --0.4
end

function login_layer:release(  )
	self.is_remove = true
	super(login_layer,self).release()
end
