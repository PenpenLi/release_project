
function table_update( source, data )
	for k, v in pairs( data ) do
		source[ k ] = v
	end
end

function table_copy( t )
	local copy = {}
	for k, v in pairs(t) do 
		copy[k] = v
	end 
	return copy
end 

function table_deepcopy( t )
	local copy = {}
	for k, v in pairs(t) do 
		if type(v) ~= "table" then 
			copy[k] = v
		else 
			copy[k] = table_deepcopy(v)
		end 
	end 
	return copy
end 

-- TODO: object copy function 
function object_deepcopy( t )
	local copy = {}
	for k, v in pairs(t) do 
		if type(v) ~= "table" then 
			copy[k] = v
		else 
			copy[k] = object_deepcopy(v)
		end 
	end 
	local type_obj = { _name = t._name }
	type_obj.__index = t.__index
	setmetatable( copy, type_obj )

	return copy
end

function table_find( t, e )
	for k, v in pairs(t) do
		if v == e then
			return k, v
		end
	end
	return nil
end

function table_map(t, map_func)
	local mt = {}
	for k, v in pairs(t) do 
		mt[k] = map_func(v)
	end 
	return mt
end 

function table_slice(t, i, j)
	i = i or 1
	j = j or #t
	local slice = {}
	for k = i, j do 
		table.insert(slice, t[k])
	end 
	return slice 
end 

function table_keys(t)
	local keys = {}
	for k, v in pairs(t) do 
		table.insert(keys, k)
	end 
	return keys
end 

function table_join(str, t)
	local res = ''
	for k, v in ipairs(t) do
		res = res..tostring(v)
	end
	return res
end

local function array_tostring(t)
	local strs = {}
	for i, v in ipairs(t) do 
		table.insert(strs, table_tostring(v))
	end 
	local s = '{'..table.concat(strs, ', ')..'}'
	return s
end 

function table_tostring(t)
	if type(t) ~= 'table' then 
		return tostring(t)
	end

	local keys = {}
	for k, v in pairs(t) do 
		table.insert(keys, k)
	end 

	if #keys == #t then 
		return array_tostring(t)
	end 

	local kvs = {}
	table.sort(keys, function (k1, k2) 
		if type(k1) ~= type(k2) then 
			if type(k1) == 'number' then return true end -- 数字总是最小
			if type(k2) == 'number' then return false end 
			if type(k1) == 'userdata' then return false end -- userdata总是最大
			if type(k2) == 'userdata' then return true end 
			return type(k1) < type(k2)
		else
			if type(k1) ~= 'userdata' then 
				return k1 < k2
			else
				return tostring(k1) < tostring(k2) 
			end 
		end 
	end )

	local expected_index = 1
	for _, k in ipairs(keys) do 
		v = table_tostring( t[k] )
		if type(k) == 'number' then 
			if k == expected_index then 
				table.insert(kvs, v) 
				expected_index = expected_index + 1
			else
				table.insert(kvs, tostring(k)..'='..v) 
			end 
		else
			table.insert(kvs, tostring(k)..'='..v) 
		end 
	end 
	return '{' .. table.concat(kvs, ', ') .. '}'
end 
