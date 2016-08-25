
function weight_random( arr )
	-- math.randomseed(os.time())
	local sum = 0
	for i, v in pairs(arr) do
		sum = sum + v
	end
	local rand = math.random(sum)
	for i, v in pairs(arr) do
		if rand <= v then
			return i
		else
			rand = rand - v
		end
	end
end

function get_random()
	return math.random(1000000 - 1)
end

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
