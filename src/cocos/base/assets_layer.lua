local am

local _locale = {
	cn = { 
		btn_up = '更新', btn_start = '进入游戏', 
		lbl_latest = '已是最新版', lbl_server_maintain = '服务器维护中',
	},
	tw = {
		btn_up = '更新', btn_start = '進入遊戲', 
		lbl_latest = '已是最新版', lbl_server_maintain = '伺服器維護中',
	},
	en = { 
		btn_up = 'Update', btn_start = 'Enter', 
		lbl_latest = 'This is the latest version', lbl_server_maintain = 'Server is under maintenance ...',
	},
}

local _update_status
local _update_progress
local _ui_layer
local _ui_progress
local _ui_circle
local _tick_schedule

function init()
	create_update_layer()
	check_first_run()
	--check_update()
end

function unzip_tick()
	percent = _extend.get_unzip_file_percentage()
	print('...', percent)
	set_up_prg(percent)
	if percent == 100 then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_tick_schedule)
		set_up_str('正在更新资源...')
		set_up_prg(0)
		check_update()
	end
end

function check_first_run()
	local unzipped_data = cc.UserDefault:getInstance():getIntegerForKey("client_unzipped_data")
	if unzipped_data ~= 1 then
	--if true then
		set_up_str('首次打开解压中...')
		local zip_path = cc.FileUtils:getInstance():fullPathForFilename('data.zip')
		_extend.unzip_file(zip_path, cc.FileUtils:getInstance():getWritablePath())
		cc.UserDefault:getInstance():setIntegerForKey("client_unzipped_data", 1)
		_tick_schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(unzip_tick, 0, false)
	else
		check_update()
	end

end

function check_update()
	if nil == am then
		am = cc.AssetsManagerEx:create("project.manifest", cc.FileUtils:getInstance():getWritablePath())
		am:retain()
		if not am:getLocalManifest():isLoaded() then
		    set_up_str('本地资源列表错误...')
			set_up_prg(0)
		else
		print('local version ',am:getLocalManifest():getVersion(), am:getLocalManifest():getPackageUrl(), am:getLocalManifest():getVersionFileUrl())
		    local function onUpdateEvent(event)
		    	print(event:getAssetsManagerEx(), 
		    		event:getAssetId(), 
		    		event:getCURLECode(), 
		    		event:getMessage(), 
		    		event:getCURLMCode(), 
		    		event:getPercentByFile(), 
		    		event:getEventCode(), 
		    		event:getPercent())
		        local eventCode = event:getEventCode()
		        if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
				    set_up_str('资源列表错误...')
					set_up_prg(0)
		        elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
		            local assetId = event:getAssetId()
		            local percent
		            local strInfo = ""

		            if assetId == cc.AssetsManagerExStatic.VERSION_ID then
							--print('remote version ',am:getRemoteManifest():getVersion())
						percent = event:getPercent()
		                strInfo = string.format("Version file: %d%%", percent)
						set_up_str('更新版本信息...')
		            elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
						percent = event:getPercent()
		                strInfo = string.format("Manifest file: %d%%", percent)
						set_up_str('更新资源列表...')
		            else
		            	percent = event:getPercentByFile()
		                strInfo = string.format("Download file %d%%", percent)
						set_up_str('下载资源文件...')
		            end
		            print("update", strInfo)
					set_up_prg(percent)
		        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
		        	print('ASSET_UPDATED')
		        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then
		        	set_up_str('连接更新服务器失败...')
					set_up_prg(0)
					set_circle_visible( false )
		        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
		        	set_up_str('资源列表错误...')
					set_up_prg(0)
					set_circle_visible( false )
		        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE or 
		               eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
					print("Update finished.")

					ccs.ActionManagerEx:getInstance():releaseActions()
					cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
					cc.Director: getInstance(): getTextureCache(): removeUnusedTextures()

					local d = import('run')
					d.run()
					--set_up_str(_locale[Locale].lbl_latest)
					--set_up_prg(100)
		        elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
		        	set_up_str('资源更新失败.'..error_msg)
		        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
		        	local error_msg = event:getAssetId() .. event:getMessage() .. tostring(event:getCURLECode()) .. tostring(event:getCURLMCode())
					print("ERROR_UPDATING ", error_msg)
		        	set_up_str('更新失败.'..error_msg)
		        end
		    end
		    local listener = cc.EventListenerAssetsManagerEx:create(am,onUpdateEvent)
		    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
		    am:update()
		end
	end
end

function create_update_layer()
	local visible_size = cc.Director:getInstance():getVisibleSize()

	local scene = cc.Scene:create()
	local layer = cc.Layer:create()

	local progress_json = 'res/login/ui_loading_res.ExportJson'
	_ui_layer = ccs.GUIReader:getInstance():widgetFromJsonFile( progress_json )
	_ui_layer: setAnchorPoint(0, 0)
	_ui_layer: setPosition((visible_size.width/2), (visible_size.height/2))
	layer:addChild( _ui_layer, 99999 )
	--local action = ccs.ActionManagerEx: getInstance(): playActionByName('ui_loading_res.ExportJson', '2o')
	_ui_progress = ccui.Helper:seekWidgetByName( _ui_layer, 'Image_4' )
	_update_status = ccui.Helper:seekWidgetByName( _ui_layer, 'Label_8' )
	_update_progress = ccui.Helper:seekWidgetByName( _ui_layer, 'Label_5' )
	_ui_circle = ccui.Helper:seekWidgetByName( _ui_layer, 'Image_9' )
	_ui_circle:runAction( cc.RepeatForever: create(cc.RotateBy: create( 2, 540 )))

	local landing_json = 'res/login/Ui-landing_checkupdate.ExportJson'
	local bg = ccs.GUIReader:getInstance():widgetFromJsonFile( landing_json )
	layer:addChild( bg )
	scene:addChild( layer )
	bg:setAnchorPoint(0, 0)
	bg:setPosition((visible_size.width/2),(visible_size.height/2))

	--_update_status = ccui.Helper:seekWidgetByName( bg, 'Label_29' )
	--_update_progress = ccui.Helper:seekWidgetByName( bg, 'ProgressBar_28' )
	--_update_progress: setPercent(1)
	set_up_prg( 0 )

	if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(scene)
--		cc.Director:getInstance():pushScene(scene)
		collectgarbage("collect")
	else
		cc.Director:getInstance():runWithScene(scene)
--		cc.Director:getInstance():pushScene(scene)
	end
end

function set_up_str( message )
	if _update_status then
		_update_status: setString( message )
	end
end
function set_up_prg( percent )
	--[[
	if _update_progress and percent > 0 and percent < 101 then
		_update_progress: setPercent( percent )
	end
	--]]
	if percent > 0 and percent < 101 then
		if _ui_progress ~= nil then
			_ui_progress: setPosition( percent * 4.27, 0 )
		end
		if _update_progress ~= nil then
			_update_progress: setString( math.floor(percent) .. '%' )
		end
	end
end

function set_circle_visible( vis )
	if _ui_circle then
		_ui_circle: setVisible( vis )
	end
end
