local battle		= import( 'game_logic.battle' )
local combat_attr   = import( 'model.combat' )
local ui_touch_layer  = import( 'ui.ui_touch_layer' )

goldgetting = lua_class( 'goldgetting', battle.battle )

function goldgetting:_init( id, proxy )
	super(goldgetting, self)._init( id, proxy )
	self.proxy:show_time_counter()
end

function goldgetting:special_tick()
end

function goldgetting:begin()
	timer_count = 30
	super(goldgetting,self).begin()
end

function goldgetting:create_monsters(args)
	print("timer_count      create  ", timer_count)
	if timer_count < 0 then
		return false
	end

	local tmp;
	self.proxy:set_timer_counter(timer_count)
	timer_count = timer_count - 1;

	for i=1, 2 do
		tmp = _extend.random(4)
		--self:create_monster({conf_id=19,battle_group=2,pos={_extend.random(1000), _extend.random(300)+900}, gravity=true, velocity = {0, _extend.random(50)-90}, })
		if tmp <= 3 then
			self:create_monster({conf_id=200001,battle_group=2,pos={_extend.random(1000), _extend.random(300)+900}, gravity=false, velocity = {0, _extend.random(50)-90},})
		else
			self:create_monster({conf_id=200000,battle_group=2,pos={_extend.random(1000), _extend.random(300)+900}, gravity=false, velocity = {0, _extend.random(50)-90},  attack_times=1, duration = 200})
		end
		--self:create_monster(args)
	end
	return true
end

function goldgetting:is_end(args)
	if timer_count <= 0 then
		return true
	end
	return false
end