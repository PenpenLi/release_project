
local command			= import( 'game_logic.command' )

cmd = lua_class( 'cmd' )

function cmd:_init()
	self.command = {}
	for _, com in ipairs(command.commands) do
		self.command[com] = 0
	end
	self.direction = command.none
end

function cmd:tick()
	--desc remain_time
	for _, com in ipairs(command.commands) do
		if self.command[com] > 0 then
			self.command[com] = self.command[com] - 1
		end
	end
end

function cmd:check_command( req_command )
	if req_command ~= nil and self.command[req_command] == 0 then
		return false
	end
	return true
end

function cmd:match_command( req_command )
	if req_command ~= nil then
		self.command[req_command] = 0
	end
end

function cmd:get_stick_direction()
	return self.direction
end
