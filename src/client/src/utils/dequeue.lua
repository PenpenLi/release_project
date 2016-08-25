
dequeue = lua_class('dequeue')

function dequeue:_init(  )
	self.base = 0
	self.top = self.base
	self._s = {}
end

function dequeue:push_back(item)
	self.top = self.top + 1
	self._s[self.top] = item
end

function dequeue:push_front(item)
	self._s[self.base] = item
	self.base = self.base - 1
end

function dequeue:front()
	if self:size() <= 0 then
		return nil
	end
	return self._s[self.base+1]
end

function dequeue:back()
	if self:size() <= 0 then
		return nil
	end
	return self._s[self.top]
end

function dequeue:pop_front()
	if self:size() <= 0 then
		return
	end
	self.base = self.base + 1
	local del = self._s[self.base]
	self._s[self.base] = nil
	return del
end

function dequeue:pop_back()
	if self:size() <= 0 then
		return
	end
	local del = self._s[self.top]
	self._s[self.top] = nil
	self.top = self.top - 1
	return del
end

function dequeue:clear()
	for i = 1, self:size() do
		self:pop_back()
	end
	self.base = 0
	self.top = self.base
	self._s = {}
end

function dequeue:size()
	local siz = self.top - self.base
	if siz <= 0 then
		return 0
	end
	return siz
end

function dequeue:empty()
	return self.top <= self.base
end
