local cjson		= require 'cjson'

local _plist_list = {}
-- for reference count

local function _res_log( ... )
	if MonitorResource == true then
		print( '[plist]', ... )
	end
end

-- 获取文件路径与文件名
local function _split_path( path )
	-- last / pos
	local path_pattern = '[^/]+$'
	local pos = path:find(path_pattern)

	-- return path, filename
	if pos >= 1 then
		return string.sub(path, 1, pos-1), string.sub(path, pos)
	else
		return '', path
	end
end

local function _add_cache( plist )
	--cc.SpriteFrameCache: getInstance(): addSpriteFrames( plist )
	_res_log( '    ...[+] ', plist )
end

local function _del_cache( plist )
	--cc.SpriteFrameCache: getInstance(): removeSpriteFramesFromFile( plist )
	_res_log( '    [x]... ', plist )
end

function retain( plist )
	_res_log(' >>>>>> ', plist)
	if _plist_list[ plist ] == nil then
		_add_cache( plist )
		_plist_list[ plist ] = 1
	else
		_plist_list[ plist ] = _plist_list[ plist ] + 1
	end
end

function release( plist )
	_res_log(' <<<<<< ', plist )
	if _plist_list[ plist ] == nil then
	elseif _plist_list[ plist ] == 1 then
		_del_cache( plist )
		_plist_list[ plist ] = nil
	else
		_plist_list[ plist ] = _plist_list[ plist ] - 1
	end
end

function retain_UIjson( json )
	_res_log(' >> ', json )
	local temp_path = _split_path( json )
	local temp_json = cc.FileUtils: getInstance(): getStringFromFile( json )
	local temp_obj = cjson.decode( temp_json )
	for idx, plst in pairs(temp_obj.textures) do
		local plst_path = temp_path .. plst
		retain( plst_path )
	end
end


function release_UIjson( json )
	_res_log(' << ', json )
	local temp_path = _split_path( json )
	local temp_json = cc.FileUtils: getInstance(): getStringFromFile( json )
	local temp_obj = cjson.decode( temp_json )
	for idx, plst in pairs(temp_obj.textures) do
		local plst_path = temp_path .. plst
		release( plst_path )
	end
end

