function draw_box(box, color, anim_flipped)
	local draw = cc.DrawNode:create()
	--Draw polygons
	local points = nil
	if anim_flipped then
		points = { cc.p(-box[1], box[2]), cc.p(-box[1], box[4]), cc.p(-box[3], box[4]), cc.p(-box[3], box[2]) }
	else
		points = { cc.p(box[1], box[2]), cc.p(box[1], box[4]), cc.p(box[3], box[4]), cc.p(box[3], box[2]) }
	end

	if color == nil then
		color = cc.c4f(0,0,0.5,0.5)
	end
	draw:drawPolygon(points, table.getn(points), cc.c4f(0,0,0,0), 1, color)
	return draw
end