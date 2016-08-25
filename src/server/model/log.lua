function syslog(key, ...)
	print('['..os.date()..'][sys]['..tostring(key)..']', ...)
end

function dbglog(key, ...)
	print('['..os.date()..'][dbg]['..tostring(key)..']', ...)
end
