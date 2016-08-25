
-- prime utils

require 'socket'
--require 'mongol'
require 'engine/sys'
require 'engine/import'
require 'engine/lua_class'
require 'engine/string_utils'
require 'engine/table_utils'
require 'engine/res_mgr'

-- game data
_G['data'] = {}

local function dir_table( t, sort )
	local keys = {}
	for k, _ in pairs( t ) do
		table.insert( keys, k )
	end

	if sort then
		local function cmp( a,b )
			return tostring(a) < tostring(b)
		end
		table.sort( keys, cmp )
	end

	for _, k in ipairs( keys ) do
		if type(k) == 'string' and string.byte(k) == 0 then
			print( '\t', oid_to_str(k), t[k])
		else
			print( '\t', k, t[k] )
		end
	end
end

function oid_to_str(oid)
	local str = ''
	for i = 2, 13 do
		str = str .. string.format ( "%02x" , string.byte ( oid , i , i ) )
	end
	return str
end

function dir( t, msg, sort )
	msg = msg or 'dir'
	if sort == nil then
		sort = true
	end

	print( msg, tostring(t) )
	if (type(t) == 'table') then
		dir_table( t, sort )
	end
end

