local script_path = ''
--local script_path = 'src/'
local module_suffix = '.lua'

local function module_to_path( name )
	return script_path .. string.gsub( name, '%.', '/' ) .. module_suffix
end

local function create_module( name )
	local m = {}
	setmetatable( m, { __index = _G } )

	local file_name = module_to_path( name )
	local code_string = res_mgr.open( file_name )
	if not code_string then
		error( 'import error: can not open file: ' .. file_name )
		return false
	end

	local fun, msg = loadstring( code_string, file_name )
	if not fun then
		print( msg )
		error( 'import error: can not load the module:' .. name )
		return false
	end

	sys.modules[name] = m
	setfenv( fun, m )()
	return true
end

function import( name )
	local m = sys.modules[name]
	if m ~= nil then
		return m
	end

	create_module( name )

	return sys.modules[name]
end

local function replace_func(dst, src)
	assert(type(dst) == "table" and type(src) == "table", "table required")
	
	for k, _ in pairs(dst) do
		local src_type = type(src[k])
		local dst_type = type(dst[k])
		if src_type == "function" then
			setfenv(src[k], getfenv(dst[k]))
			dst[k] = src[k]
			
		elseif src_type == "table" then
			if dst_type == "table" then
				if k ~= "__index" and k ~= "_super" then
					replace_func(dst[k], src[k])
				end
			else
				-- new data is not a table while old data is a table
				local info = debug.getinfo(2)
				print("Warning different type replaced, %s:%d,%s %s %s %s %s %s",
					info["short_src"], info["currentline"], info["namewhat"], dst_type, src_type, tostring(dst[k]), tostring(src[k]), tostring(k))

				--dst[k] = src[k]
			end
		end
	end

	-- add
	for k,v in pairs(src) do
		-- rawget requied!!!!
		if rawget(dst, k) == nil then
			dst[k] = v
		end
	end

	--[[
	local mt = getmetatable(src)
	if mt then
		setmetatable(dst, mt)
	end]]
end

function reload_all()
	print('engine', '-----------reload_begin---------------')

	--clean
	local old_modules = {}
	for name, old_module in pairs(sys.modules) do
		old_modules[name] = old_module
		sys.modules[name] = nil
	end

	--import new
	local ok = true
	local function _reload_all()
		for name, old_module in pairs(old_modules) do
			if import(name) == nil then
				ok = false
				break
			end
		end
	end

	local function reload_error(msg)
		print("----------------------------------------")
		print("LUA ERROR: " .. tostring(msg) .. "\n")
		print(debug.traceback())
		print("----------------------------------------")
		ok = false
	end
	xpcall(_reload_all, reload_error)

	--roll back
	if ok == false then
		sys.modules = old_modules
		print('engine', '-----------reload_error---------------')
		return false
	end

	--swap
	local new_modules = sys.modules
	sys.modules = old_modules

	--replace_func
	for name, _ in pairs(new_modules) do
		if old_modules[name] == nil then
			old_modules[name] = new_modules[name]
		else
			replace_func(old_modules[name], new_modules[name])
		end
	end

	print('engine', '-----------reload_finish--------------')
	return true
end

