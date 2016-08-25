local avatar			= import('entities.avatar').avatar
local item				= import('model.item')
local db				= import('db')
local utils				= import('utils')

function avatar:finish_guide( guide_ids )
	if guide_ids == nil then
		return
	end
	for _, v in pairs(guide_ids) do
		self:_finish_single_guide(v)
	end
end

function avatar:save_guide_state( state_id )
	if data.guide_state[state_id] == nil then
		return
	end

	if type(self.db.guide_state) ~= 'table' then
		self.db.guide_state = {}
	end
	local exists = false
	for _, v in pairs(self.db.guide_state) do
		if v == state_id then
			exists = true
			break
		end
	end

	if exists == false then
		table.insert(self.db.guide_state, state_id)
	end
end

function avatar:_sync_ui_guide()
	if self:_check_all_done() == true then
		self.client.ui_guide_all_done()
	else
		self.client.sync_guide_done(self.db.guide_done)
		self.client.sync_guide_state(self.db.guide_state)
	end
end

function avatar:_check_all_done()
	local all_done = true
	for k, v in pairs(data.guide) do
		local done_step = false
		for _, vv in pairs(self.db.guide_done) do
			if vv == k then
				done_step = true
				break
			end
		end
		if done_step == false then
			all_done = false
			break
		end
	end
	return all_done
end

function avatar:_finish_single_guide( guide_id )
	local d = data.guide[guide_id]
	if d == nil then
		return
	end
	for _, v in pairs(self.db.guide_done) do
		if v == guide_id then
			return
		end
	end
	table.insert(self.db.guide_done, guide_id)
end
