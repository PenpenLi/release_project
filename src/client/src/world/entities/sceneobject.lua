local entity			= import( 'world.entity' )
local math_ext			= import( 'utils.math_ext' )
local model 			= import( 'model.interface' )
local command			= import( 'game_logic.command' )
local state_mgr			= import( 'game_logic.state_mgr' )
local director			= import( 'world.director' )

sceneobject  = lua_class( 'sceneobject', entity.entity )

function sceneobject:_init( id, conf_id )
	self.id = id
	self.conf_id = conf_id
	self.attr_data = data.monster[self.conf_id]
	self.model_id = self.attr_data.model_id
	self.data = data.monster_model[self.attr_data.model_id]
	self.type_id = self.data.type
	super(sceneobject, self)._init(id, conf_id)
end

function sceneobject:init_special_attr()
	self.conf = import('char.'..self.data.state)
	local id = self.model_id
	local ms = data.monster_skill[id]
	local skills = {}
	if ms ~= nil then
		for k, v in pairs(ms) do
			skills[k] = monster_skill.skill(id, v)
		end
	end
	self.skills = skills

	if self.data.ai ~= nil then
		self.ai = import('behavior.'..self.data.ai)
	end
	self.battle_group = 2

	-- self.x_speed = 10

	self.src_combat_attr: init_with_configdata( self.attr_data )
	if self.conf.default_run_speed ~= nil then
		self.src_combat_attr: set_speed_x( self.conf.default_run_speed )
	end
	self.combat_attr:copy_from_attr(self.src_combat_attr)

end


