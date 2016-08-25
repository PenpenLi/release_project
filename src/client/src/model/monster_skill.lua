local combat			= import( 'model.combat' )
local command			= import( 'game_logic.command' )

skill = lua_class( 'skill' )

function skill:_init(id, data)
	self.id = id
	self.state = data.state
	--self.conf = {}
	self.bullets = {}
	self.data = data
	self.formula = loadstring(self.data.formula)

	self:reload_module()
end

function skill:reload_module()
	local conf = import('char.'..data.monster_model[self.id].state)
	local bullets = {}
	if self.data.bullet ~= nil then
		for _, bname in pairs(self.data.bullet) do
			bullets[bname] = conf[bname]
		end
	end
	self.bullets = bullets
end

function skill:get_bullet_conf(bullet_name)
	return self.bullets[bullet_name]
end

function skill:get_formula()
	return self.formula
end

function skill:get_self_buff()
	return self.data.s_buff
end

function skill:get_enemy_buff()
	return self.data.e_buff
end
