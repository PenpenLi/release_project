
msg_queue = lua_class('msg_queue')

local queue = {}
local id = 0

function get_queue(  )
	return queue
end

function clean_queue(  )
	queue = {}
	id = 0
end

function add_msg( str )
	
	if str ~= nil then
		id = id + 1 
		table.insert(queue, id  ,str)
	end

end

function add_item_msg( idx ,num  )

	if idx ~= nil and num ~= nil then
		id = id + 1
		table.insert(queue, id ,{['item_id']=idx,['item_num']=num})

	end


end

--战斗力提升
function add_battle_msg( value ) 
	if value ~= nil then
		id = id + 1
		table.insert(queue, id, {['strength_lift'] = value})
	end
end


function clean( idx )
	if idx ~= nil  then
		queue[idx] = nil
	end
end


