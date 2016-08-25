local entity			= import( 'world.entity' )
local math_ext			= import( 'utils.math_ext' )
local model 			= import( 'model.interface' )
local command			= import( 'game_logic.command' )
local state_mgr			= import( 'game_logic.state_mgr' )
local director			= import( 'world.director' )

pet  = lua_class( 'pet', entity.entity )

function pet:_init( id, model_id )
	print('create_pet', id, conf_id)
	self.id = id
	self.conf_id = nil
	self.attr_data = nil
	self.model_id = model_id
	self.data = data.monster_model[self.model_id]
	self.type_id = self.data.type

	super(pet, self)._init(id, 1)
end

function pet:init_special_attr()
	self.conf = import('char.'..self.data.state)
	if self.data.ai ~= nil then
		self.ai = import('behavior.'..self.data.ai)
	end
	self.battle_group = 1
end


------------ 宠物ai 开始 --------------
function pet:aim_player_target(args)
	--获得玩家
	self.nearest_enemy = model.get_player().entity
	return true
end

function pet:move_to_player( args )
	-- body
	if self.nearest_enemy == nil then
		return false
	end
	--待定：玩家站到地面，才开始跟踪
	-- if self.nearest_enemy:on_ground() == false then
	-- 	return false
	-- end
	self:face_target(args)
	local pet_x ,pet_y = self.physics:get_pos()
	local player = 	self.nearest_enemy
	local player_x = 0
	local player_y = 0
	--根据玩家朝向设置宠物到达的位置
	if player.final_flipped == true then
		--玩家右边120像素的位置
		player_x ,player_y = player:get_world_pos().x+args.leave_player_dis,player:get_world_pos().y
	else
		--玩家左边120像素的位置
		player_x ,player_y = player:get_world_pos().x-args.leave_player_dis,player:get_world_pos().y
	end
	local f_x ,f_y = math_ext.p_sub(player_x,player_y,pet_x,pet_y)
	--归一向量
	local n_f_x,n_f_y = math_ext.p_normalize(f_x,f_y)
	local enemy_pos = self.nearest_enemy:get_world_pos()
	--范围
	if ((pet_x>=player_x-10) and (pet_x<=player_x+10)) and (pet_y>=player_y) and (pet_y<=player_y+10)then
		self:set_velocity(0,0)
		return false
	end
	--获取距离向量的百分之多少为速度，达到减速效果
	self.physics:set_speed(f_x*args.speed_percent/100,f_y*args.speed_percent/100)


	return true
end

