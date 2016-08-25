local socket = require "socket"
local debugger = {}
local host
local cid = 1
local clients = {}

--[[
--不阻塞游戏进程
--拥有独立环境，使用全局变量不污染_G
--print不污染log，并正常打印log
--在调试端输出语法错
--在调试端输出脚本错
--使用coroutine执行指令
--按行输出，以Done.结束。
--]]

function evaluate(chunk, print_error)
	local function __DEBUG__TRACKBACK__(msg)
		print_error("----------------------------------------")
		print_error("DEBUG ERROR: " .. tostring(msg) .. "\n")
		print_error(debug.traceback())
		print_error("----------------------------------------")
	end
    local ok, err = xpcall(chunk, __DEBUG__TRACKBACK__)
end

function eval_lua(closure, line)
    local chunk, err = loadstring(line)
    if not chunk then
        closure.g.print(err)
		return
	end

	local scheduler = require 'network/scheduler'
	scheduler.create_routine(evaluate)(setfenv(chunk, closure.g), closure.g.print)
	closure.g.print('Done.')
end

function debugger.start()
	host = socket.bind('127.0.0.1', DebugPort)
	host:settimeout(0)
end

function debugger.tick()
	if host == nil then
		return
	end
	local client = host:accept()
	if client ~= nil then
		syslog('debugger', client, 'connected')
		local closure = {}
		closure.g = {}
		local cg = closure.g
		for key, val in pairs(_G) do
			cg[key] = val
		end
		closure.g.print = function (...)
			if client then
				local data = {}
				for _, val in pairs({...}) do
					table.insert(data, tostring(val))
				end
				client:send(table.concat(data,' ')..'\n')
			end
		end
		client:settimeout(0)
		closure.client = client
		clients[cid] = closure
		cid = cid + 1
	end

	for id, c in pairs(clients) do
		local msg, status = c.client:receive('*l')
		if status == 'closed' then
			clients[id] = nil
			syslog('debugger', c.client, 'closed')
		elseif type(msg) == 'string' and string.len(msg) > 0 then
			--syslog('debugger', c.client, 'execute', msg)
			eval_lua(c, msg)
			--syslog('debugger', c.client, 'finish', msg)
		end
	end
end

return debugger
