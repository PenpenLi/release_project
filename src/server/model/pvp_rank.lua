local db				= import('db')
local const				= import('const')
local pvp_const			= import('const.pvp_const')
local avatar			= import('entities.avatar')

pvp_rank_result = {}
rank_oid_id = {}

function pvp_rank_find()
	pvp_rank_result = {}

	for oid, e in pairs(all_avatars_oid) do
		if e.db.pvp_point >= pvp_const.PointLimit and e.db.lv >= pvp_const.LevelLimit then
			local ins = {}
			ins.pvp_point = e.db.pvp_point
			ins.oid = oid
			table.insert(pvp_rank_result, ins)
		end
	end
	rank_sort()
end

function rank_sort()
	rank_oid_id = {}

	local function comp( info1, info2 )
		return info1.pvp_point > info2.pvp_point
	end
	table.sort(pvp_rank_result, comp)

	for i, v in ipairs(pvp_rank_result) do
		rank_oid_id[v.oid] = i
	end
end

function built_struct_copy(e)
	local t = table_deepcopy( const.MiniInfo )
	for k,v in pairs(t) do
		t[k] = e.db[k]
	end
	t._id = e.db._id
	--t.pvp_def_skills = e.db.pvp_def_skills
	t.loaded_skills = e.db.pvp_def_skills
	return t
end

function built_struct(e)
	local t = {} 
	for k,v in pairs( const.MiniInfo ) do
		t[k] = e.db[k]
	end
	t._id = e.db._id
	--t.pvp_def_skills = e.db.pvp_def_skills
	t.loaded_skills = e.db.pvp_def_skills
	return t
end
