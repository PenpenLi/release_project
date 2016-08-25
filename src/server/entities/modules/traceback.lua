local avatar			= import('entities.avatar').avatar
local db				= import('db')

local traceback_flag = {}

function avatar:traceback(mesg, tra)
	local key = mesg .. tra

	if traceback_flag[key] ~= nil then
		return
	else
		traceback_flag[key] = 1
	end
	
	local ins = {}
	ins.mesg = mesg
	ins.traceback = tra

	db.traceback_save(ins)
end
