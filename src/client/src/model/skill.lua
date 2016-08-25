local combat			= import( 'model.combat' )
local command			= import( 'game_logic.command' )
local battle_const		= import( 'game_logic.battle_const' )

skill = lua_class( 'skill' )

function skill:_init(conf)
	self.id = conf.id
	self.star = conf.star
	self.lv = conf.lv
	self.exp = conf.exp

	self.conf = {}
	self.bullets = {}
	self:reload_module()
end

function skill:update_server_data(conf)
	self.id = conf.id
	self.star = conf.star
	self.lv = conf.lv
	self.exp = conf.exp

	self:reload_module()
end

function skill:reload_module()
	self.data = data.skill[self.id][self.star]
	self.fc_factor = self.data.fc_factor
	local formula = self.data.formula
	if formula == nil then
		formula = 'd = 0'
	end
	self.formula = loadstring(formula)

	local f_att = self.data.f_att
	local i_att = self.data.i_att
	local n_att = self.data.n_att
	local f_def = self.data.f_def
	local i_def = self.data.i_def
	local n_def = self.data.n_def

	self.f_att = 0
	self.i_att = 0
	self.n_att = 0

	self.f_def = 0
	self.i_def = 0
	self.n_def = 0

	local env = {
		s = self,
	}
	
	if f_def ~= nil then
		setfenv(loadstring('s.f_def = '..f_def),env)()
	end
	if i_def ~= nil then
		setfenv(loadstring('s.i_def = '..i_def),env)()
	end
	if n_def ~= nil then
		setfenv(loadstring('s.n_def = '..n_def),env)()
	end

	if f_att ~= nil then
		setfenv(loadstring('s.f_att = '..f_att),env)()
	end
	if i_att ~= nil then
		setfenv(loadstring('s.i_att = '..i_att),env)()
	end
	if n_att ~= nil then
		setfenv(loadstring('s.n_att = '..n_att),env)()
	end

	self._ai_score = 0
	self.ai_score_formula = loadstring('s._ai_score = '..self.data.ai_score)

	local conf = import('skills.'..self.data.conf)
	local mod = {}
	for i = 1,self.star do
		for k, v in pairs( conf['star_'..tostring(i)] ) do
			if type(v) == 'table' then
				mod[ k ] = table_deepcopy(v)
			else
				mod[ k ] = v
			end
		end
	end

	local bullets = {}
	if self.data.bullet ~= nil then
		for _, bname in pairs(self.data.bullet) do
			local bullet = {}
			for i = 1,self.star do
				for k, v in pairs( conf[bname .. '_' .. tostring(i)] ) do
					if type(v) == 'table' then
						bullet[ k ] = table_deepcopy(v)
					else
						bullet[ k ] = v
					end
				end
			end
			bullets[bname] = bullet
		end
	end

	--更新已装载技能的command
	mod.command = self.conf.command

	self.conf = mod
	self.conf.skill_id = self.id
	self.bullets = bullets
end

function skill:get_element_type()
	return self.data.element_type
end

function skill:get_score()
	return self.id
end

function skill:get_command()
	return self.conf.command
end

function skill:change_command(cmd)
	self.conf.command = cmd
end

function skill:get_bullet_conf(bullet_name)
	return self.bullets[bullet_name]
end

function skill:get_formula()
	return self.formula
end

function skill:get_conf()
	return self.conf
end

function skill:get_state_name()
	return self.data.conf
end

function skill:get_f_def()
	return self.f_def
end

function skill:get_i_def()
	return self.i_def
end

function skill:get_n_def()
	return self.n_def
end

function skill:get_f_att()
	return self.f_att
end

function skill:get_i_att()
	return self.i_att
end

function skill:get_n_att()
	return self.n_att
end

function skill:get_mana_cost()
	local mana_cost = self.data.mana_cost
	if mana_cost == nil then
		return 0
	end
	return mana_cost
end

function skill:get_self_buff()
	return self.data.s_buff
end

function skill:get_enemy_buff()
	return self.data.e_buff
end

function skill:get_ai_area()
	return self.data.ai_area
end

function skill:get_pet_model()
	return self.data.pet_model_id
end

function skill:get_tips(  )
	return self.data.tips
end

function skill:get_cd(  )
	return self.data.cd
end

function skill:get_id(  )
	return self.id
end

function skill:get_exp(  )
	return self.exp
end

function skill:get_level(  )
	return self.lv
end

function skill:get_star(  )
	return self.star
end

function skill:get_ai_score_formula( )
	return self.ai_score_formula
end

function skill:get_fighting_capacity()
	local player = import( 'model.interface' ).get_player()
	local env = {
		s = self,
		a = player,
	}
	setfenv(battle_const.SkillFightingCapacityFormula,env)()
	return env.fc
end