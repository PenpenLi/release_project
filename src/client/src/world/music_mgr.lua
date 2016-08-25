_snd_ui_click 	= 'sound/click.wav'
_snd_victory	= 'sound/victory1.wav'
_snd_fail		= 'sound/fail1.wav'

_music_normal_bg= 'music/normalbg.mp3'
_is_normal_bg_playing = false
_is_bg_enable = true
_is_ef_enable = true
_last_ef_volume = 0.0

-- preload 音乐
--
function preload_ui_sound()
	AudioEngine.preloadEffect(_snd_ui_click)
end

function preload_bg_music(scene_data)
	AudioEngine.preloadMusic(scene_data.bg_music)
end

function preload_normal_bg_music()
	AudioEngine.preloadMusic(_music_normal_bg)
end

function preload_role_sound(model)
	if model == nil or model.role_sound == nil then
		return
	end
	for k, v in pairs(model.role_sound) do
		-- print('preload', v)
		AudioEngine.preloadEffect(v)
	end
end

-- 背景音乐控制
function play_normal_bg_music()
	if MuteMode == true then
		return
	end

	if _is_bg_enable == false then
		return
	end
	if _is_normal_bg_playing == false then
		AudioEngine.playMusic(_music_normal_bg, true)
		_is_normal_bg_playing = true
	end
end
function pause_bg_music()
	AudioEngine.pauseMusic()
end
function resume_bg_music()
	if _is_bg_enable == false then
		return
	end
	AudioEngine.resumeMusic()
end
function stop_bg_music()
	AudioEngine.stopMusic()
end
function alter_bg_music_enable()
	if _is_bg_enable == true then
		_is_bg_enable = false
		AudioEngine.stopMusic()
	else
		_is_bg_enable = true
		AudioEngine.resumeMusic()
	end
end

function fade_to_new_music( bg_music )
	if MuteMode == true then
		return
	end
--	local temp_vol = AudioEngine.getMusicVolume()
--	for i = 1, 1000 do
--		temp_vol = temp_vol - 0.001
--		AudioEngine.setMusicVolume(temp_vol)
--	end
--	AudioEngine.playMusic(bg_music, true)
--	for i = 1, 1000 do
--		temp_vol = temp_vol + 0.001
--		AudioEngine.setMusicVolume(temp_vol)
--	end
	AudioEngine.playMusic(bg_music, true)
end

-- 音效
function alter_ef_sound_enable()
	if _is_ef_enable == true then
		_is_ef_enable = false
		_last_ef_volume = AudioEngine.getEffectsVolume()
		AudioEngine.setEffectsVolume(0)
	else
		_is_ef_enable = true
		AudioEngine.setEffectsVolume(_last_ef_volume)
	end
end

-- ui 音效
function ui_click()
	if MuteMode == true then
		return
	end
	AudioEngine.playEffect(_snd_ui_click)
end

-- 播放音效
function playEffect(effect_path)
	if MuteMode == true then
		return
	end
	if _is_ef_enable == false then
		return
	end
	AudioEngine.playEffect(effect_path)
end

function victory_music()
	if MuteMode == true then
		return
	end
	AudioEngine.playEffect(_snd_victory)
end

function fail_music()
	if MuteMode == true then
		return
	end
	AudioEngine.playEffect(_snd_fail)
end
