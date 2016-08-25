
res_mgr = res_mgr or {}

if cc == nil then
	res_mgr.open = function (name)
		print('load file :', name)
		local file = io.open(name, 'r')
		local s = file:read('*a')
		file:close()
		return s
	end
else
	res_mgr.open = function (name)
		print('load file :', name)
		local fullpath = cc.FileUtils:getInstance():fullPathForFilename(name)
		return _extend.loadfile(fullpath)--cc.FileUtils:getInstance():getStringFromFile(fullpath)
    end
end

function res_mgr.load_config( path )
	local content = _res_mgr.open( path )
	if not content then
		return nil
	end

	local loader, msg = loadstring( content, path )
	if not loader then
		print( path, msg )
		return nil
	end

	local result = {}
	setfenv( loader, result )

	local ret, msg = pcall( loader )
	if ret then
		return result
	end

	print( 'error loading config ', path )
	print( '\t', msg )
	return nil
end
