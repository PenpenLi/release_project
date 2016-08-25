-- cclog
cclog = function(...)
	print(string.format(...))
end

local _error_dict = {}

function applicationDidEnterBackground()
end

function applicationWillEnterForeground()
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
	if _error_dict[msg] == nil then

		local tra = debug.traceback()

		if DebugShowBox then -- 错误信息弹窗

			local  function closeErrorMesg(  )
				cc.Director:getInstance():popScene()
			end

			local scene = cc.Scene:create()
			local layer = cc.Layer:create()

			local label = cc.LabelTTF:create()
			label:setString("LUA ERROR: " .. tostring(msg) .. "\n\n".. tra)

			label:setFontSize(20)
			label:setAnchorPoint(0.5,0.5)
			local visibleSize = cc.Director:getInstance():getVisibleSize()
			label:setPosition(cc.p(visibleSize.width/2,visibleSize.height/2))

			local button = ccui.Button:create()
			button:loadTextures("res/close_button.png","",'')
			button:setPosition(cc.p(visibleSize.width-100,visibleSize.height-100))
			button:addTouchEventListener(closeErrorMesg)

			layer:addChild(label)
			layer:addChild(button)
			scene:addChild(layer)

			cc.Director:getInstance():pushScene(scene)
		end

		cclog("------------------------------------------\\/")
		cclog("LUA ERROR: " .. tostring(msg) .. "\n")
		cclog(tra)
		cclog("------------------------------------------/\\")

		if (string.len(msg) + string.len(tra)) <= 10000 then
			server.traceback(msg, tra)
		end
		_error_dict[msg] = 1
	end

end

--VisibleSize = cc.Director:getInstance():getVisibleSize()
local function handle_resolution()
	local director = cc.Director:getInstance()
	local win_width = director:getWinSize().width
	local win_height = director:getWinSize().height
	local design_width = 1136
	local design_height = 640
	local prolicy = cc.ResolutionPolicy.SHOW_ALL

	if win_width == 0 or win_height == 0 then
		win_width = 1136
		win_height = 640
	elseif win_width*640 > 960*win_height then
		win_width = win_height*1136/640
	else
		design_width = 960
		design_height = 640
		win_height = win_width*640/960
	end

	print(cc.Application:getInstance():getCurrentLanguage())

	local glview = director:getOpenGLView()
	if glview == nil then
		print('glview rect', win_width, win_height)
		glview = cc.GLView:createWithRect("MyLuaGame", cc.rect(0, 0, win_width, win_height))
		director:setOpenGLView(glview)
	end

	glview:setDesignResolutionSize(design_width, design_height, prolicy)
	director:setDisplayStats(true)
	director:setAnimationInterval(1.0 / Fps)
	VisibleSize = cc.Director:getInstance():getVisibleSize()
	print('=====resolution=====', win_width, win_height, design_width, design_height, VisibleSize.width, VisibleSize.height, prolicy)
end
local function main()
	collectgarbage("collect")
	--collectgarbage("stop")
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	require 'engine'
	require 'pack_config'

	local _fileUtils = cc.FileUtils:getInstance()
	_fileUtils:setPopupNotify(false)

	handle_resolution()

	if DevVersion then
		_fileUtils:addSearchPath( _fileUtils:fullPathForFilename('src') )
		_fileUtils:addSearchPath( _fileUtils:fullPathForFilename('cocos') )
		_fileUtils:addSearchPath( _fileUtils:fullPathForFilename('res') )

		_fileUtils:addSearchPath( _fileUtils:getWritablePath() )
		_fileUtils:addSearchPath( _fileUtils:getWritablePath()..'src' )
		_fileUtils:addSearchPath( _fileUtils:getWritablePath()..'res' )

		local d = import('src.run')
		d.run()
	else
		_fileUtils:addSearchPath( _fileUtils:getWritablePath() )
		_fileUtils:addSearchPath( _fileUtils:getWritablePath()..'src' )
		_fileUtils:addSearchPath( _fileUtils:getWritablePath()..'res' )

		_fileUtils:addSearchPath( _fileUtils:fullPathForFilename('src') )
		_fileUtils:addSearchPath( _fileUtils:fullPathForFilename('cocos') )
		_fileUtils:addSearchPath( _fileUtils:fullPathForFilename('res') )

		local d = import('assets_layer')
		d.init()
	end
end


xpcall(main, __G__TRACKBACK__)
