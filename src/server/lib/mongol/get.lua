local strsub = string.sub
local t_insert = table.insert
local t_concat = table.concat

local function get_from_string ( s , i )
	i = i or 1
	return function ( n, terminators )
		if not n then -- Rest of string
			if not terminators then
				n = #s - i + 1
			else
				local it = string.find(s, terminators, i)
				n = i
				i = it + 1
				return strsub ( s , n , i-2 )
			end
		end
		i = i + n
		assert ( i-1 <= #s , "Unable to read enough characters" )
		return strsub ( s , i-n , i-1 )
	end , function ( new_i )
		if new_i then i = new_i end
		return i
	end
end

local function string_to_array_of_chars ( s )
	local t = { }
	for i = 1 , #s do
		t [ i ] = strsub ( s , i , i )
	end
	return t
end

local function read_terminated_string ( get , terminators )
	return get(nil, terminators or "\0")
end

return {
	get_from_string = get_from_string ;
	read_terminated_string = read_terminated_string ;
}
