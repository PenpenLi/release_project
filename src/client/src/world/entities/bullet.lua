local entity			= import( 'world.entity' )
local math_ext			= import( 'utils.math_ext' )
local model 			= import( 'model.interface' )
local command			= import( 'game_logic.command' )
local state_mgr			= import( 'game_logic.state_mgr' )
local director			= import( 'world.director' )

bullet  = lua_class( 'bullet', entity.entity )

function bullet:_init( id, conf, skill )
	self.conf = conf
	super(bullet, self)._init(id, 1) --顺序不要变。。。
	self.active_skill = skill
end

function bullet:init_special_attr()
	self.battle_group = 2
	-- self.x_speed = 10
end

function bullet:is_bullet(  )
	return true
end