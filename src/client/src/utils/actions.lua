
function shake_action(duration, strength_x, strength_y, offset_x, offset_y)

    strength_y = strength_y or strength_x
	local cur_x, cur_y = 0, 0
	local actions = {}
	local min_interval = math.min(1 / 30, duration / 2)
	local next_tick = 0
	-- 震动方向
	if next_tick < duration and (offset_x ~= 0 or offset_y ~= 0) then
		table.insert(actions, cc.DelayTime:create(min_interval))
		table.insert(actions, cc.MoveBy:create(0.01, {x = offset_x, y = offset_y}))
	    table.insert(actions, cc.DelayTime:create(min_interval + 0.025))
		table.insert(actions, cc.MoveBy:create(0.02, {x = -offset_x, y = -offset_y}))
	end
	while next_tick < duration do 
		local dt = next_tick / duration
		local shake_var = (1 - dt) 
		--local shake_var = 1
		local randx = math.random(-strength_x * shake_var, strength_x * shake_var)
		local randy = math.random(-strength_y * shake_var, strength_y * shake_var)
		if next_tick > 0 then 
			table.insert(actions, cc.DelayTime:create(min_interval))
		end 
		table.insert(actions, cc.MoveBy:create(0, {x = randx - cur_x, y = randy - cur_y}))
		cur_x, cur_y = randx, randy
		next_tick = next_tick + min_interval
	end 
	--print('delay', duration - (next_tick - min_interval))
	table.insert(actions, cc.DelayTime:create(duration - (next_tick - min_interval)))
	table.insert(actions, cc.Place:create({x = initial_x, y = initial_y}))
	--return 	cc.EaseSineOut:create(
	return 	cc.EaseExponentialOut:create(
		cc.Sequence:create(unpack(actions))
	)
	--cc.EaseBackOut:create(
	--cc.EaseExponentialOut:create(
end 

function shake(node, duration, strength_x, strength_y)
	node = node._ins or node
	local action = shake_action(duration, strength_x, strength_y, 0, 0)
	node:runAction(action)
end 

function fast_zoom(scale)
	local actions = {}
	local min_interval = 1/20
	table.insert(actions, cc.DelayTime:create(min_interval))
	table.insert(actions, cc.ScaleBy:create(0.01, scale))
	table.insert(actions, cc.DelayTime:create(min_interval))
	table.insert(actions, cc.ScaleTo:create(0.01, 1))
	return 	cc.EaseSineOut:create(
		cc.Sequence:create(unpack(actions))
	)
end
