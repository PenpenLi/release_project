
local id_count = 1

local timers = {}

function comps( a,b )

	print('进入排序')
	return a[1] < b[1]

end

function set_timer(cd, cb)
 	--print('加入di',id_count)
	timers[id_count] = {os.time()+cd, cb}
	id_count = id_count + 1
	print('时间长短：',os.time()+cd)
	
	-- if table_length( ) >= 2 then
	-- 	print('进入了')
	-- 	table.sort(timers,comps)
	-- end

	
	return id_count-1
end

-- timer.set_timer(10, function () print() end)

--打印一下
function print_table(  )
	print('---------加入排序后-----------------------')

	for id,tb in pairs(timers) do
		print('时间cd：',id,tb[1],tb[2])
	end
end

function table_length(  )
	
	local count = 0
	for id,tb in pairs(timers) do
		count = count + 1 
	end
	return count
end

function tick()
	--print_table()
	for id, tb in pairs(timers) do
		if tb[1] <= os.time() then

			tb[2]()
			timers[id] = nil
		end
		--id_count = id_count-1
	end
end

function remove_time( id )
	timers[id] = nil
end

function remove_all_time(  )
	id_count = 1
	timers = {}
end

function schedule_once(time, e, cal_back, ...)
	time = time or 0
	local func_once = nil
	local args = {...}
	local function func()
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(func_once)
		if e == nil then
			cal_back(unpack(args))
		else
			cal_back(e, unpack(args))
		end
		
	end
	func_once = cc.Director:getInstance():getScheduler():scheduleScriptFunc(func, time, false)
end