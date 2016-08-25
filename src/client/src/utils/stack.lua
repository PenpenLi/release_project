
stack = lua_class('stack')

function stack:_init(  )
	self.base = 0
	self.top = self.base
	self._s = {}
end

function stack:push(item)
	self.top = self.top + 1
	self._s[self.top] = item
end

function stack:front()
	if self.top <= self.base then
		--print('stack is nil...')
		return 
	end
	local data = self._s[self.top]
	return data
end

function stack:pop()
	if self.top <= self.base then
		--print('stack is nil...')
		return 
	end
	local data = self._s[self.top]
	self._s[self.top] = nil
	self.top = self.top - 1
	return data
end

function stack:clear()
	--print('stack clear...')
	for i = 1, self:size() do
		self:pop()
	end
end

function stack:size()
	return self.top - self.base
end

function stack:empty()
	return self.top == self.base
end

function stack:print()
	for i = self.top, self.base+1, -1 do
		dir(self._s[i])
	end
end