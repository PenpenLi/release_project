local combat			= import( 'model.combat' )
local math_ext			= import( 'utils.math_ext' )

quest = lua_class( 'quest' )

function quest:_init(quest_type, id)
	self.id = id
	self.type = quest_type
	self.data = data[quest_type][id]
end

function quest:init_server_data(quest_data)
	self.complete_count = quest_data.cnt
	self.server_data = quest_data
end

function quest:get_icon(  )
	return self.data.icon_id
end

function quest:get_title()
	return self.data.title
end

function quest:get_desc()
	return self.data.desc
end

function quest:is_complete()
	return self.data.condition_count <= self.complete_count
end

function quest:get_quest_counter()
	return self.complete_count, self.data.condition_count
end

function quest:get_complete_count()
	return self.complete_count
end

function quest:get_quest_time_limit()
	return self.data.time_limit
end

function quest:get_quest_condition()
	return self.data.condition
end

function quest:get_items_count(  )
	if self.data.items_count == nil then
		return 0
	end
	return self.data.items_count
end

function quest:get_reward()
	local reward = {}
	if self.data.gold then
		reward.gold = self.data.gold
	end
	if self.data.diamond then
		reward.diamond = self.data.diamond
	end
	if self.data.exp then
		reward.exp = self.data.exp
	end
	if self.data.items then
		reward.items = table_deepcopy(self.data.items)
	end
	if self.data.energy then
		reward.energy = self.data.energy
	end
	return reward
end

function quest:get_ui_type(  )
	return self.data.ui_type
end