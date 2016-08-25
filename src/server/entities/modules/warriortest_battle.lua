local avatar			= import('entities.avatar').avatar

function avatar:warriortest_battle_finish(battle_id, token)
	if battle_id == nil or token == nil then
		return
	end

	if token ~= self.fuben_token then
		return
	end  

	self.fuben_token = math.random(99999999999999)
	self.client.warriortest_battle_finish()
end
