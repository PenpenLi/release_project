function get_cost_by_id( id )
    local cost_data = data.rmb_cost[id]
    if cost_data ~= nil then
     	return cost_data.cost
    end
    return 0               
 end