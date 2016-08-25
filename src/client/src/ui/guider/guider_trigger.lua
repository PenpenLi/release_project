CLICK_EQUIP_EVENT = 1

FIGHT_SLIDE_RIGHT = 2

ZZZ_EVENT		  = 3

XXX_EVENT 		  = 4

MAIN_SURFACE_UP_ANIM	= 5

MAIN_SURFACE_DOWN_ANIM	= 6

local flag = 0
local call_backs = {}

function regist_event(event_num, call_back)
	
	if call_backs[event_num] == nil then 
		call_backs[event_num] = {}
	end 

	table.insert(call_backs[event_num], call_back)

end

function trigger_event(event_num,is_remove)
	
	if call_backs[event_num] ~= nil then 
		for i, call_back in pairs(call_backs[event_num]) do 
			if call_back ~= nil and type(call_back) == 'function'then 
				call_back()
				if is_remove == true then
					call_backs[event_num][i] = nil 
				end
			end 
		end
	end 
end

function remove_event( event_num )
	if call_backs[event_num] ~= nil then 
		for i, call_back in pairs(call_backs[event_num]) do 
			if call_back ~= nil and type(call_back) == 'function'then 

				call_backs[event_num][i] = nil 

			end 
		end
	end 
end
