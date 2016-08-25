local queue				= require 'utils/queue'

local routine_pool = {}
local routines = {}
local current = {}
local pending = {}
local scheduler_methods = {}

local function pop_routine()
	local r = table.remove(routine_pool)
	if r == nil then
		r = {}
		r.obj = {}
		r.status = 'wait'
		r.routine = coroutine.create(function ()
			xpcall(function()
				while true do
					local args = coroutine.yield()
					r.status = 'alive'
					r.func(unpack(args))
					r.status = 'wait'
					--print(r.routine, 'finish')
					for _, obj in pairs(r.obj) do
						current[obj] = nil
						local next_r = pending[obj]:pop()
						--print(r.routine, 'returnning ', obj, next_r)
						if next_r ~= nil then
							routines[next_r].obj[obj] = obj
							current[obj] = next_r
						end
						r.obj[obj] = nil
					end
					table.insert(routine_pool, r)
				end
			end, __G__TRACKBACK__)
		end)
		routines[r.routine] = r
		coroutine.resume(r.routine)
	end
	return r
end

function scheduler_methods.create_routine(func)
	local r = pop_routine()
	r.func = func
	return function (...)
		coroutine.resume(r.routine, {...})
	end
end

function scheduler_methods.claim_obj(obj)
	local cur = current[obj]
	local pnd = pending[obj]
	local c = coroutine.running()
	if c == nil then
		print('claim_obj error!!!!')
	end
	if cur == c then
		return
	end
	if pnd == nil then
		pending[obj] = queue.new()
	end

	if cur == nil then
		routines[c].obj[obj] = obj
		current[obj] = c
	else
		--print(c, 'is pending')
		pending[obj]:push(c)
		coroutine.yield()
	end
end


function scheduler_methods.resume()
	--print('---------------')
	for obj, c in pairs(current) do
		local r = routines[c]
		if r.status == 'alive' and coroutine.status(c) == 'suspended' then
			--print(c, 'resume')
			coroutine.resume(c)
		end
	end
end

return scheduler_methods
