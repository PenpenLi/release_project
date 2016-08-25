local scheduler			= require 'network/scheduler'

local t = os.time()
local date = os.date('*t', t)

local crontab = {}
local crontab_count = 1

HOUR_PER_DAY		= 24
DAY_START_HOUR		= 6
SECONDS_PER_MONTH = 2592000
SECONDS_PER_WEEK = 604800
SECONDS_PER_DAY	= 86400
SECONDS_PER_HOUR = 3600
SECONDS_PER_MIN	= 60
TIME_ALTZONE = -28800

-- 注册定时任务,ever = false时,任务只执行一次
function register_crontab( _time_string, _func, _ever )
	local f = loadstring('return ' .. _time_string)
	crontab[crontab_count] = {formula = f, func = _func, ever = _ever}
	print('Register: ', crontab_count)
	dir (crontab[crontab_count])
	crontab_count = crontab_count + 1
	return crontab_count - 1
end

function cancel_crontab( count )
	crontab[count] = nil
	print('Cancel_crontab:', count)
end

function tick()
	local new_t = os.time()
	if new_t <= t then
		return
	end
	t = new_t

	local old_date = date
	date = os.date('*t', t)
	if date.min ~= old_date.min then
		tick_min()
		broadcast_avatars(import('entities.avatar').avatar._tick_min)
	end
	-- 竞技场排行榜刷新
	if date.hour ~= old_date.hour then
		local pvp_rank = import('model.pvp_rank')
		pvp_rank.pvp_rank_find()
		broadcast_avatars(import('entities.avatar').avatar._sync_pvp_rank)
	end
end

function tick_min()
	
	-- 定时任务
	for i, v in pairs(crontab) do
		if setfenv(v.formula, date)() then
			print(i .. ',' .. ' execute!')
			--v.func()
			--迭代中执行coroutine，必须保证coroutine内不对table插入元素
			scheduler.create_routine(v.func)()
			
			-- ever
			if v.ever == false then
				crontab[i] = nil
			end
		end
	end
end

function get_now()
	return t
end

function get_date()
	return date
end

function is_same_day(t1, t2)
	if t1 == 0 or t2 == 0 then
		return false
	end
	return os.date('*t', t1-21600).day == os.date('*t', t2-21600).day
end

function is_same_month(t1, t2)
	if t1 == 0 or t2 == 0 then
		return false
	end
	local d1 = os.date('*t', t1 - 21600)
	local d2 = os.date('*t', t2 - 21600)
	
	if d1.year ~= d2.year or d1.month ~= d2.month then
		return false
	end

	return true
end

function get_signin_date() 
	return os.date('*t', get_now() - 21600)
end


function count_end_timestamp(timestamp,day)
    return timestamp + day * SECONDS_PER_DAY
end

function count_day(start_timestamp,end_timestamp)
    local new_end_time  = end_timestamp+ (165600 - end_timestamp % SECONDS_PER_DAY) % SECONDS_PER_DAY
    local day_num = math.floor((new_end_time - start_timestamp) / SECONDS_PER_DAY)
    return day_num
end

function compare_two_date(timestamp1,timestamp2)
    local time  = timestamp1 + (165600 - timestamp1 % SECONDS_PER_DAY) % SECONDS_PER_DAY
    local day_num = math.floor((time - timestamp2) / 86400)
    if day_num < 0 then
        return -1
    elseif day_num == 0 then
        return 0
    else
        return 1
    end 
end

function set_now(year, month, day, hour, min, sec)
	local now_date	= {['year'] = year, ['month'] = month, ['day'] = day, ['hour'] = hour, ['min'] = min, ['sec'] = sec }
	local timestamp	= os.time(now_date)
	t				= timestamp
	date			= os.date('*t',t)
end

function recover_time()
	t		= os.time()
	date	= os.date('*t',t)
end

function get_week_day()
	return os.date('%w',t)
end

function get_day_pass_sec( d )
	if d == nil then
		d = date
	elseif type(d) == 'number' then
		d = os.date('*t',d)
	end
	local hour_pass = ( d.hour - DAY_START_HOUR + HOUR_PER_DAY ) % HOUR_PER_DAY
	return hour_pass * SECONDS_PER_HOUR + d.min * 60 + d.sec
end

function get_day_zero_sec( d )
	
	if d == nil then
		d	= date
	elseif type(d) == 'number' then
		d = os.date('*t',d) 
	end
	local second	= os.time(d)
	return second - get_day_pass_sec( d )
end

function get_cur_week_zero_sec()
	local week_day = get_week_day()
	return t - week_day * SECONDS_PER_DAY - get_day_pass_sec()
end


