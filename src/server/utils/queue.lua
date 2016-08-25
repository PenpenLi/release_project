local queue_methods = { }

function queue_methods.new()
	local q = {_b = -1, _e = 0}
	q.push = function ( self, data )
		local b = q._b + 1
		q._b = b
		q[b] = data
	end

	q.pop = function ( self )
		local e = q._e
		if q._b < e then return end
		local data = q[e]
		q[e] = nil
		q._e = e + 1
		return data
	end

	q.size = function ( self )
		return q._b - q._e + 1
	end

	return q
end

return queue_methods
