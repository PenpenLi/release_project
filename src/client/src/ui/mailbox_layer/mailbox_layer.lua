local combat_conf			= import( 'ui.avatar_info_layer.avatar_info_ui_conf' )
local layer					= import( 'world.layer' )
local model 				= import( 'model.interface' )
local locale				= import( 'utils.locale' )
local ui_mgr				= import( 'ui.ui_mgr' )
local anim_trigger 			= import( 'ui.main_ui.anim_trigger')
local ui_const 				= import( 'ui.ui_const' )
local mailbox_cell			= import( 'ui.mailbox_layer.mailbox_cell' )

mailbox_layer = lua_class('mailbox_layer',layer.ui_layer)
local _jsonfile = 'gui/main/mailbox_1.ExportJson'

function mailbox_layer:_init( )

	super(mailbox_layer,self)._init(_jsonfile,true)
	self.widget:ignoreAnchorPointForPosition(true)
	self.widget:setPosition(VisibleSize.width/2, VisibleSize.height/2)
	self:set_handler("btn_close", self.close_button_event)


	self.list_mail = self:get_widget('list_mail')
	self.list_mail:ignoreAnchorPointForPosition(true)
	self.emails = {}
	self.is_remove = false

	ui_mgr.schedule_once(0, self, self.update_mail_list)
end

function mailbox_layer:update_mail_list()
	self.list_mail:removeAllItems()
	self.emails = {}
	local player = model.get_player()
	local emails = {}
	local index = 1
	for _, e in pairs(player:get_emails()) do
		emails[index] = e
		index = index + 1
	end
	local function cmp(a,b)
		if a.has_read == b.has_read then
			local time_a = 0
			local time_b = 0
			local da = data.email[a.eid].date
			local db = data.email[b.eid].date
			if da == nil or db == nil then
				return da == nil
			else
				local date_a = string_split(data.email[a.eid].date, '-')
				local date_b = string_split(data.email[b.eid].date, '-')
				if date_a[1] ~= nil and date_a[2] ~= nil and date_a[3] ~= nil then
					time_a = date_a[1] * 10000 + date_a[2] * 100 + date_a[3]
				end
				if date_b[1] ~= nil and date_b[2] ~= nil and date_b[3] ~= nil then
					time_b = date_b[1] * 10000 + date_b[2] * 100 + date_b[3]
				end
				return (time_a > time_b)
			end
		else
			return (a.has_read == false)
		end
	end
	table.sort(emails, cmp)
	self:add_mails( emails )
end

function mailbox_layer:add_mails(mails)
	for _, e in pairs(mails) do
		local d = data.email[e.eid]
		if d == nil then 
			return
		end
		if d.with_items == false or (d.with_items == true and e.has_get_items == false) then
			local cell = mailbox_cell.mailbox_cell(self, e)
			self:set_cell_handel(cell)
			self.list_mail:pushBackCustomItem(cell.cell)
		end
	end
end

--设置框框按钮事件
function mailbox_layer:set_cell_handel( cell )


	local function button_event( sender,eventtype )
		if eventtype == ccui.TouchEventType.began then
			
		elseif eventtype == ccui.TouchEventType.moved then
		
		elseif eventtype == ccui.TouchEventType.ended then
			dir(sender)
			local mail_info = ui_mgr.create_ui(import('ui.mailbox_layer.mail_info'),'mail_info')
			mail_info:play_up_anim()
			mail_info:set_mail(cell)
			--print("cur select index: ", )
			--cell:read_mail()
			--local index = self.list_mail:getCurSelectedIndex()
		elseif eventtype == ccui.TouchEventType.canceled then
			
		end
	end
	cell:get_cell():addTouchEventListener(button_event)

end

function mailbox_layer:close_button_event( sender, eventtype )
		if eventtype == ccui.TouchEventType.began then
		
		elseif eventtype == ccui.TouchEventType.moved then
	  
		elseif eventtype == ccui.TouchEventType.ended then
			anim_trigger.trigger_event(anim_trigger.MAIN_SURFACE_UP_ANIM,false)
			self.cc:setVisible(false)
			self.is_remove = true
		elseif eventtype == ccui.TouchEventType.canceled then
	end
end