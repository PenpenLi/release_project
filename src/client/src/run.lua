
_G['applicationDidEnterBackground'] = function ()
	local music = import('world.music_mgr')
	music.pause_bg_music()
	network_applicationDidEnterBackground()
end

_G['applicationWillEnterForeground'] = function ()
	local music = import('world.music_mgr')
	music.resume_bg_music()
	network_applicationWillEnterForeground()
end

function run()

	print("开始")
	require 'config'
	require 'network/interface'

	local d = import('world.director')
	d.init()
	print("你妹")
end
