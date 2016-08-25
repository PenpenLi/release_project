local am

function init()
    --http://192.168.16.105:8888/


    --[[local function onError(errorCode)
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            print("no new version")
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            print("network error")
        end
    end

    local function onProgress( percent )
        local progress = string.format("downloading %d%%",percent)
        print(progress)
    end

    local function onSuccess()
        print("downloading ok")
    end
        assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
        assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
        assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
        assetsManager:setConnectionTimeout(3)]]

    print(cc.FileUtils:getInstance():getWritablePath())
    if nil == am then
        -- dir(cc.EventListenerAssetsManagerEx)
        am = cc.AssetsManagerEx:create("res/project.manifest", cc.FileUtils:getInstance():getWritablePath())
        am:retain()

        if not am:getLocalManifest():isLoaded() then
            print('not am:getLocalManifest():isLoaded()')
        else
            print('am:getLocalManifest():isLoaded()')
            local function onUpdateEvent(event)
                local eventCode = event:getEventCode()
                if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
                    print('ERROR_NO_LOCAL_MANIFEST')
                elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
                    local assetId = event:getAssetId()
                    local percent = event:getPercent()
                    local strInfo = ""

                    if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                        strInfo = string.format("Version file: %d%%", percent)
                    elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                        strInfo = string.format("Manifest file: %d%%", percent)
                    else
                        strInfo = string.format("%d%%", percent)
                    end
                    print('UPDATE_PROGRESSION', strInfo)
                elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
                       eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
                    print("Fail to download manifest file, update skipped.")
                elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE or 
                       eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
                        print("Update finished.")
                elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
                        print("Asset ", event:getAssetId(), ", ", event:getMessage())
                end
            end
            local listener = cc.EventListenerAssetsManagerEx:create(am,onUpdateEvent)
            cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
			dir(am:getState())
            am:update()
        end
    end


    --assetsManager:update()
end
