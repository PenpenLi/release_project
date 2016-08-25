
local decorators = import('utils.decorators')

local retrive_plist_frames_fast = decorators.cache(function (plist)
	local data = res_mgr.open(plist)
	local s1, e1 = data:find('<key>frames</key>%s*<dict>')
	local s2, e2 = data:find('</dict>%s*<key>metadata</key>', e1 + 1)
	data = data:sub(e1 + 1, s2 - 1):gsub('<dict>.-</dict>', '')

	local frames = {}
	for frame in string.gmatch (data, '<key>%s*(.-)%s*</key>') do 
		-- <key>010000.png</key>
		table.insert(frames, frame)
	end 
	return frames
end )

local function _array_concat(t1, t2)
	for _, v in ipairs(t2) do 
		table.insert(t1, v)
	end 
	return t1
end 

local function get_frame_names(plist)
	frame_names = {}
	for _, name in ipairs(plist) do 
		local _frame_names = retrive_plist_frames_fast(name)
		frame_names = _array_concat(frame_names, _frame_names) 
	end 
	if #plist > 1 then 
		table.sort(frame_names)
	end 
	return frame_names
end 

get_frame_names = decorators.cache(get_frame_names, function (plist) 
		return table.concat(plist, '+')
	end)

--[[ -- 使用merge sort的方式实现数组合并，从而提升get_frame_names的效率，但是如果使用了cache之后影响可以忽略不计
local function _merge_sorted_arrays(arrays)
	local result = {}
	local n = #arrays
	local index = {}
	local next_val = {}
	for i = 1, n do 
		table.insert(index, 1)
		table.insert(next_val, arrays[i][1])
	end 

	while true do 
		local min_val, min_index = nil, nil
		for i = 1, n do 
			local val = next_val[i]
			if val ~= nil and (min_val == nil or min_val > val) then 
				min_val = val
				min_index = i
			end 
		end 
		if min_val == nil then 
			break 
		end 

		table.insert(result, min_val)
		local next_index = index[min_index] + 1
		index[min_index] = next_index
		next_val[min_index] = arrays[min_index][next_index]
	end 
	return result
end 

function get_frame_names(plist)
	local frame_names_list = table_map(plist, retrive_plist_frames_fast)
	return _merge_sorted_arrays(frame_names_list)
end 

get_frame_names = decorators.cache(get_frame_names, function (plist) 
		return table.concat(plist, '+')
	end)
--]]

function get_sprite_frames(plist, frame_names, frame_prefix)
	if type(plist) == 'string' then plist = {plist} end

	--local stclock = os.clock()
	local frames = {}
	if not frame_names then
		local retrived_frame_names = get_frame_names(plist)
		frame_names = retrived_frame_names
	end 
	local sf_cache = cc.SpriteFrameCache:getInstance()
	for _, name in ipairs(plist) do 
		sf_cache:addSpriteFrames(name)
	end 
	for _, name in ipairs(frame_names) do
		if not frame_prefix or string_startswith(name, frame_prefix) then
			table.insert(frames, sf_cache:getSpriteFrame(name))
		end
	end
	--print("get_sprite_frames takes", os.clock() - stclock)
	return frames
end
