local layer					= import( 'world.layer' )
local server_list 			= import( 'server_list' )
local net_model 			= import( 'network.interface' )
local ui_mgr 				= import( 'ui.ui_mgr' )

select_panel = lua_class( 'select_panel' , layer.ui_layer )


--选服列表
function select_panel:_init(   )
	
	super(select_panel,self)._init('base/res/login/Ui-landing_4.ExportJson',true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)

	--当前选中的服务器按钮
	self.cur_number = 1
	
	local function qu_btn_callback( _, sender, eventype )
		if eventype == ccui.TouchEventType.ended then
			local split = string_split(sender:getName(), '_')
			self:server_qu_btn_event(tonumber(split[3]))
		end
	end

	self.server_qu_btn = {}
	for i=1, 12 do
		self.server_qu_btn[i] = self:get_widget('btn_qu_' .. i)
		self:set_handler('btn_qu_' .. i, qu_btn_callback)
	end

	--创建服务器列表
	self.list = self:get_widget('list')
	self:create_list()
end

--设置当前已选中服务器的编号并显示
function select_panel:set_last_sever_id( last_sever_id )
	local last_sever_name = server_list.list[last_sever_id].id .. '区 ' .. server_list.list[last_sever_id].name
	self:get_widget('lbl_last_server_name'):setString(last_sever_name)
end

--创建服务器列表
function select_panel:create_list(  )
	for i=1, 12 do
		if server_list.list[i] == nil then
			self.server_qu_btn[i]:setVisible(false)
		else
			local qu_name = server_list.list[i].id .. '区 ' .. server_list.list[i].name
			self.server_qu_btn[i]:getChildByName('name'):setString(qu_name)
		end
	end
end

--当前选择的服务器按钮
function select_panel:server_qu_btn_event( i )
	net_model.set_server_id(i)
	cc.UserDefault:getInstance():flush()
	------------------------------------
	ui_mgr.get_ui('login_layer'):set_sever_number()
	self.is_remove = true
end

function select_panel:release( )
	self.is_remove = true
	super(select_panel, self).release()
end
