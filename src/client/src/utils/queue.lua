
queue = lua_class('queue')

function queue:_init(  )
	self.base = 0
	self.top = self.base
	self._s = {}
end

function queue:push(item)
	self.top = self.top + 1
	self._s[self.top] = item
end

function queue:front()
	if self:size() <= 0 then
		return nil
	end
	return self._s[self.base+1]
end

function queue:pop()
	if self:size() <= 0 then
		return
	end
	self.base = self.base + 1
	local del = self._s[self.base]
	self._s[self.base] = nil
	return del
end

function queue:clear()
	for i = 1, self:size() do
		self:pop()
	end
	self.base = 0
	self.top = self.base
	self._s = {}
end

function queue:size()
	local siz = self.top - self.base
	if siz <= 0 then
		return 0
	end
	return siz
end

function queue:empty()
	return self.top <= self.base
end
