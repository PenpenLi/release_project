
local function index( t, k )
	return t
end

local function newindex( t, k, v )
	return t
end

local function do_call( t, ... )
	return t
end

local metatable = { __index = index, __newindex = newindex, __call = do_call }

swallow = {}
setmetatable( swallow, metatable )
