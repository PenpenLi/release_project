local socket = require "socket"

local socket_methods = { }
local buffer = ''

function socket_methods.connect( host, port )
	local sock = {}
	sock._s = socket.connect( host, port )
	sock._s:settimeout(0)

	sock.receive = function ( self, size )
		local res=0
		local msg=''
		while true do
			res, msg, buffer = self._s:receive( size, buffer )
			if res == nil then
				if msg == 'closed' then
					syslog('db', 'RECEIVE ERROR!!!!', size, msg, buffer)
					return res, msg, str
				elseif msg == 'timeout' then
					coroutine.yield()
				end
			else
				return res, msg, str
			end
		end
		return res, msg, str
	end

	sock.send = function ( self, data )
		local res=0
		local msg=''
		local idx=0
		local len = string.len(data)
		while true do
			res, msg, idx = self._s:send( data, idx )
			if res == nil then
				if msg == 'closed' then
					syslog('db', 'SEND ERROR!!!!', data, msg, idx, len)
					return res, msg, idx
				elseif msg == 'timeout' then
					syslog('db', 'SEND SLOW...', data, msg, idx, len)
					coroutine.yield()
				end
			else
				if res < len then
					idx = res
					syslog('db', 'SEND SLOW...', data, msg, idx, len)
					coroutine.yield()
				else
					return len
				end
			end
		end
		return res, msg, len
	end

	return sock
end

return socket_methods
