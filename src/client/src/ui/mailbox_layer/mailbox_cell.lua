local ui_const 				= import( 'ui.ui_const' )
local model 				= import( 'model.interface' )

mailbox_cell = lua_class('mailbox_cell')

function mailbox_cell:_init( layer, mail )
	self.layer = layer
	self.has_read = mail.has_read
	self.eid = mail.eid
	self.id = mail._id
	self.cell = self:create_mailbox_cell(self.eid, self.has_read)
end

function mailbox_cell:create_mailbox_cell(eid)
	local cell = self.layer:get_widget('mail_cell'):clone()
	self.img_is_new = cell:getChildByName('img_is_new')
	self.icon = cell:getChildByName('img_cell_icon')
	if self.has_read == true then
		self.img_is_new:setVisible(false)
	else
		self.img_is_new:setVisible(true)
	end
	local d = data.email[eid]
	if d == nil then
		return 
	end
	cell:getChildByName('lbl_date'):setString(d.date)
	cell:getChildByName('lbl_cell_body'):setString(d.body)
	cell:getChildByName('lbl_cell_title'):setString(d.title)
	return cell
end

function mailbox_cell:get_cell()
	return self.cell
end

function mailbox_cell:get_eid()
	return self.eid
end

function mailbox_cell:get_id()
	return self.id
end

function mailbox_cell:read_mail()
	self.has_read = true
	self.img_is_new:setVisible(false)
	server.read_email(self.id)
end