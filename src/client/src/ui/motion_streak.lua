
local ui_const			= import( 'ui.ui_const' )
local layer 			=  import('world.layer')
motion_streak = lua_class('motion_streak',layer.layer)

local _motion_pool = {}
local _layer		= nil 						--拖尾层
local _time			= 0.5						--拖尾渐现时间
local _width		= 20						--拖尾宽
local _height		= 20						--拖尾长
local _red			= cc.c4b(255, 0, 0, 255)	--拖尾颜色
local _file_path	= 'gui/streak1.png'			--拖尾文件路径
local _index_map	= {}
local _max_num		= 5

function motion_streak:_init(  )
	-- body
	super(motion_streak,self)._init()
	self:create_layer()
	for i = 1, _max_num do
		local motion = cc.MotionStreak:create(_time,_width,_height,_red,_file_path)
		local quad = cc.ParticleSystemQuad:create('particles/streak_p.plist')
		_layer:addChild(motion)
		_layer:addChild(quad)
		motion:setVisible(false)
		quad:setVisible(false)
		table.insert(_motion_pool, {[1] = motion, [2] = quad, id = nil})
	end
end

function motion_streak:create_layer(  )
	-- body
	_layer = self.cc
end

function setPosition(id,x,y)
	for _, v in pairs(_motion_pool) do
		if v.id == id then
			local motion = v[1]
			local quad = v[2]
			motion:setPosition(x, y)
			quad:setPosition(x, y)
		end
	end
end

function setStartingPositionInitialized(id, isset )
	-- body
	--_motions[id]:setStartingPositionInitialized(isset)
end

function setVisible(id, isVisible )
	-- body
	--_motions[id]:setVisible(isVisible)
end

--移除手势拖尾
function remove_motion(id)
	for _, v in pairs(_motion_pool) do
		if v.id == id then
			local motion = v[1]
			local quad = v[2]
			v.id = nil
			motion:setVisible(false)
			quad:setVisible(false)
		end
	end
end
function remove_all_motion(  )
	_motion_pool = {}
end

--加入手势拖尾
function add_motion( id, x, y )
	for _, v in pairs(_motion_pool) do
		if v.id == nil then
			local motion = v[1]
			local quad = v[2]
			v.id = id
			motion:reset()
			quad:resetSystem()
			motion:setPosition(x, y)
			quad:setPosition(x, y)
			motion:setVisible(true)
			quad:setVisible(true)
			break

		end
	end
	-- body
--_motions[id]:setStartColor(cc.c4f(1,0,0,1))
 --   _motions[id]:setBlendAdditive(true)
end
