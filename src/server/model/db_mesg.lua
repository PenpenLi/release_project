
offline_mesg = {}

function add_offline_mesg(player_id, _func, ...)
	if offline_mesg[ player_id ] == nil then
		offline_mesg[ player_id ] = {}
	end

	local t = {}
	t.func = _func
	t.arg = {...}
	
	table.insert( offline_mesg[ player_id ], t )
end

function check_offline_mesg(self)
	local player_id = self.db._id
	if offline_mesg[ player_id ] == nil then
		return
	end

	for k,v in pairs( offline_mesg[ player_id ] ) do
		--v.func( self, unpack(v.arg)
		self[v.func](self, unpack(v.arg) )
	end
	offline_mesg[ player_id ] = nil
end

--使用例子
--local db_mesg			= import('model.db_mesg')
--db_mesg.add_offline_mesg(self.db._id, 'test_offline', 1, 2, 3, 4, 5, 6)

--function avatar:test_offline(a1, a2, a3)
--	print('test_offline', a1, a2, a3)    -- 输出 1,2,3
--	dir(self.db)
--end
























