local math_ext		= import( 'utils.math_ext' )

function in_range( caster, owner, buff_id, args )
	if caster == nil then
		return false
	elseif owner == nil then
		return true
	end
	local cur_dist = math_ext.p_get_distance(caster.physics, owner.physics)
	return cur_dist <= args.dist
end

