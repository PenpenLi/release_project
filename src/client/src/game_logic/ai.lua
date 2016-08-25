Sequence				= 1
Selector				= 2
ParallelSequence		= 3
ParallelSelector		= 4
RandomChoose			= 5
WeightChoose			= 6
Action					= 7

local run_node

local handle_sequence = function( node, entity )
	for _, child in ipairs(node.childs) do
		if run_node(child, entity) == false then
			return false
		end
	end
	return true
end

local handle_selector = function( node, entity )
	for _, child in ipairs(node.childs) do
		if run_node(child, entity) == true then
			return true
		end
	end
	return false
end

local handle_parallel_sequence = function( node, entity )
	local flag = true
	for _, child in ipairs(node.childs) do
		if run_node(child, entity) == false then
			flag = false
		end
	end
	return flag
end

local handle_parallel_selector = function( node, entity )
	local flag = false
	for _, child in ipairs(node.childs) do
		if run_node(child, entity) == true then
			flag = true
		end
	end
	return flag
end

local handle_random_choose = function( node, entity )
	local childs = node.childs
	return run_node(childs[_extend.random(#childs)], entity)
end

local handle_weight_choose = function( node, entity )
	local total = 0
	local weight_table = {}
	for _, child in ipairs(node.childs) do
		local weight = child.weight
		if weight == nil then
			print('警告！某权重节点子节点没有标注权重！')
		else
			total = total + weight
			table.insert(weight_table, {total, child})
		end
	end
	local slot = _extend.random(total)
	for _, info in ipairs(weight_table) do
		if slot <= info[0] then
			return run_node(info[1], entity)
		end
	end
	return false
end

local handle_action = function( node, entity )
	local f = entity[node.func]
	if f == nil then
		print('警告！entity %d 缺少action', node.func)
		return false
	end
	return f(entity, node.args)
end

local _handler = {}
table.insert(_handler, handle_sequence)
table.insert(_handler, handle_selector)
table.insert(_handler, handle_parallel_sequence)
table.insert(_handler, handle_parallel_selector)
table.insert(_handler, handle_random_choose)
table.insert(_handler, handle_weight_choose)
table.insert(_handler, handle_action)

run_node = function( node, entity )
	local res = _handler[node.type](node, entity)
	if node.dec ~= nil then
		if node.dec == 1 then
			res = true
		elseif node.dec == 2 then
			res = false
		elseif node.dec == 3 then
			res = not res
		end
	end
	if entity.debug_ai then
		cclog('ai debug: %d, %5s, %s', node.type, res, node.title)
	end
	return res
end

function tick( entity )
	local ai = entity:get_ai()
	if ai == nil then
		return true
	end
	run_node(ai.tree, entity)
end
