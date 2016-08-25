
function string_split( s, p )
	p = p or '%s'
	p = string.format( '[^%s]+', p )
	local result = {}
 	for m in string.gmatch( s, p ) do
		table.insert( result, m )
	end
	return result
end

function string_strip(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string_startswith(s, p)
	p = '^' .. p
	return s:find(p) ~= nil
end 

function string_endswith(s, p)
	p = p .. '$'
	return s:find(p) ~= nil
end 
