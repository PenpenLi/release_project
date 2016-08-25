local _overall = {}	--存储已经存在的变量名
local _tick_time=5  --定时检查全局变量时间
local _i = 1        --判断第一次遍历全局变量是否输出

show_global = lua_class( 'show_global' )

function show_global:_init()
	self.cc = cc.Node:create();
	
	local function onNodeEvent( event )
		if event == "enter" then
			schedulerTick = cc.Director:getInstance():getScheduler():scheduleScriptFunc( tick , _tick_time , false )
		elseif event == "exit" then
			-- cc.Director:getInstance():getScheduler():unscheduleScriptEntry( tick )
		end
	end

	self.cc:registerScriptHandler( onNodeEvent )
	return self
end

function tick( dt )

	traversal_global( )		--打印显示全局变量

end

local function show_table( t , sort )
	--print( '~~~~~~~~~~~~~~~~~~~~~Global variables~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' )

	local keys = {}

	for k, _ in pairs( t ) do
		table.insert( keys , k )
	end

	if sort then
		table.sort( keys )
	end
	--遍历keys 和_overall
	local isSame = false	--标记现有_G 和 储存已有全局 是否有相同名变量

	for _, k in ipairs( keys ) do
		
		local key = k
		--if	(string.byte('A') > string.byte(string.sub(k,1,1)) or string.byte(string.sub(k,1,1)) > string.byte('Z'))	then
		if	string.byte( k )~=string.byte( 'G' )	then
			for _, k in ipairs( _overall ) do

				if	k == key	then
					isSame = true	--有相同就标记为true
					break
				end
			end
			
			if isSame == false	and type( t[key] ) ~= 'function'	then	
			--不相同,并类型不是函数，就打印，并插入
					if _i > 1 then	
						print( '\tError: name and type/value.' , key , t[key] )
					end
					table.insert( _overall , key )
			end
		end
	end

	if	_i <= 1 or isSame == true then
		--print( '\tNo Error.' )
	end

	_i = _i + 1

	--print( '~~~~~~~~~~~~~~~~~~~Global variables end~~~~~~~~~~~~~~~~~~~~~~~~~~~~' )
end

function traversal_global( sort )

	if sort == nil then
		sort = true
	end
		show_table( _G , sort )
end
