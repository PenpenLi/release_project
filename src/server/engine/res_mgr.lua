
res_mgr = res_mgr or {}

if cc == nil then
	res_mgr.open = function (name)
		print('load file :', name)
		local file = io.open(name, 'r')
		if file == nil then
			return file
		end
		local s = file:read('*a')
		file:close()
		return s
	end
else
	res_mgr.open = function (name)
		print('load file :', name)
		local fullpath = cc.FileUtils:getInstance():fullPathForFilename(name)
		return cc.FileUtils:getInstance():getStringFromFile(fullpath)
    end
end
