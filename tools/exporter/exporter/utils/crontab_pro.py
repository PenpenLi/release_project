# -*- coding: GBK -*-

from collections import namedtuple
import datetime
import time

_number_types = (int, long, float)

_ranges = [
	(0, 59),
	(0, 59),
	(0, 23),
	(1, 31),
	(1, 12),
	(0, 6),
	(1970, 2099),
]
_attribute = [
	'second',
	'minute',
	'hour',
	'day',
	'month',
	'isoweekday',
	'year'
]
_alternate = {
	4: {'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
		'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov':11, 'dec':12},
	5: {'sun': 0, 'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4, 'fri': 5, 'sat': 6},
}

SECOND = datetime.timedelta(seconds=1)
MINUTE = datetime.timedelta(minutes=1)
HOUR = datetime.timedelta(hours=1)
DAY = datetime.timedelta(days=1)
WEEK = datetime.timedelta(days=7)
MONTH = datetime.timedelta(days=28)
YEAR = datetime.timedelta(days=365)

def _end_of_month(dt):
	ndt = dt + DAY
	while dt.month == ndt.month:
		dt += DAY
	return ndt.replace(day=1) - DAY

def _month_incr(dt, m):
	odt = dt
	dt += MONTH
	while dt.month == odt.month:
		dt += DAY
	# get to the first of next month, let the backtracking handle it
	dt = dt.replace(day=1)
	return dt - odt

def _year_incr(dt, m):
	# simple leapyear stuff works for 1970-2099 :)
	mod = dt.year % 4
	if mod == 0 and (dt.month, dt.day) < (2, 29):
		return YEAR + DAY
	if mod == 3 and (dt.month, dt.day) > (2, 29):
		return YEAR + DAY
	return YEAR

_increments = [
	lambda *a: SECOND,
	lambda *a: MINUTE,
	lambda *a: HOUR,
	lambda *a: DAY,
	_month_incr,
	lambda *a: DAY,
	_year_incr,
	lambda dt,x: dt.replace(second=0),
	lambda dt,x: dt.replace(minute=0),
	lambda dt,x: dt.replace(hour=0),
	lambda dt,x: dt.replace(day=1) if x > DAY else dt,
	lambda dt,x: dt.replace(month=1) if x > DAY else dt,
	lambda dt,x: dt,
]

Matcher = namedtuple('Matcher', 'second, minute, hour, day, month, weekday, year')

def _assert(condition, message, *args):
	if not condition:
		raise ValueError(message%args)

class _Matcher(object):
	__slots__ = 'allowed', 'end', 'any', 'input', 'which', 'split'
	def __init__(self, which, entry):
		_assert(0 <= which <= 6,
			"improper number of cron entries specified")
		self.input = entry.lower()
		self.split = self.input.split(',')
		self.which = which
		self.allowed = set()
		self.end = None
		self.any = '*' in self.split or '?' in self.split
		for it in self.split:
			al, en = self._parse_crontab(which, it)
			if al is not None:
				self.allowed.update(al)
			self.end = en
		_assert(self.end is not None,
			"improper item specification: %r", entry.lower()
		)
	def __call__(self, v, dt):
		if 'l' in self.split:
			if v == _end_of_month(dt).day:
				return True
		elif any(x.startswith('l') for x in self.split):
			okay = dt.month != (dt + WEEK).month
			if okay and (self.any or v in self.allowed):
				return True
		return self.any or v in self.allowed
	def __lt__(self, other):
		if self.any:
			return self.end < other
		return all(item < other for item in self.allowed)
	def __gt__(self, other):
		if self.any:
			return _ranges[self.which][0] > other
		return all(item > other for item in self.allowed)
	def _parse_crontab(self, which, entry):
		# this handles day of week/month abbreviations
		def _fix(it):
			if which in _alternate and not it.isdigit():
				if it in _alternate[which]:
					return _alternate[which][it]
			_assert(it.isdigit(),
				"invalid range specifier: %r (%r)", it, entry)
			return int(it, 10)

		# this handles individual items/ranges
		def _parse_piece(it):
			if '-' in it:
				start, end = map(_fix, it.split('-'))
			elif it == '*':
				start = _start
				end = _end
			else:
				start = _fix(it)
				end = _end
				if increment is None:
					return set([start])
			_assert(_start <= start <= _end_limit,
				"range start value %r out of range [%r, %r]",
				start, _start, _end_limit)
			_assert(_start <= end <= _end_limit,
				"range end value %r out of range [%r, %r]",
				end, _start, _end_limit)
			_assert(start <= end,
				"range start value %r > end value %r", start, end)
			return set(range(start, end+1, increment or 1))

		_start, _end = _ranges[which]
		_end_limit = _end
		# wildcards
		if entry in ('*', '?'):
			if entry == '?':
				_assert(which in (3, 5),
					"cannot use '?' in the %r field", _attribute[which])
			return None, _end

		# last day of the month
		if entry == 'l':
			_assert(which == 3,
				"you can only specify a bare 'L' in the 'day' field")
			return None, _end

		# last day of the week
		elif entry.startswith('l'):
			_assert(which == 5,
				"you can only specify a leading 'L' in the 'weekday' field")
			entry = entry.lstrip('l')

		increment = None
		# increments
		if '/' in entry:
			entry, increment = entry.split('/')
			increment = int(increment, 10)
			_assert(increment > 0,
				"you can only use positive increment values, you provided %r",
				increment)

		# allow Sunday to be specified as weekday 7
		if which == 5:
			_end_limit = 7

		# handle all of the a,b,c and x-y,a,b entries
		good = set()
		for it in entry.split(','):
			good.update(_parse_piece(it))

		# change Sunday to weekday 0
		if which == 5 and 7 in good:
			good.discard(7)
			good.add(0)

		return good, _end

class CronTab(object):
	__slots__ = 'matchers',
	def __init__(self, crontab):
		self.matchers = self._make_matchers(crontab)

	def _make_matchers(self, crontab):
		matchers = [_Matcher(which, entry)
						for which, entry in enumerate(crontab.split())]
		if len(matchers) == 6:
			matchers.append(_Matcher(6, '*'))
		_assert(len(matchers) == 7,
			"improper number of cron entries specified")
		matchers = Matcher(*matchers)
		if not matchers.day.any:
			_assert(matchers.weekday.any,
				"missing a wildcard specifier for weekday")
		if not matchers.weekday.any:
			_assert(matchers.day.any,
				"missing a wildcard specifier for day")
		return matchers

	def _test_match(self, index, dt):
		at = _attribute[index]
		attr = getattr(dt, at)
		if at == 'isoweekday':
			attr = attr() % 7
		return self.matchers[index](attr, dt)

	def next(self, now):
		if isinstance(now, _number_types):
			now = datetime.datetime.fromtimestamp(now)
		future = now.replace(microsecond=0) + _increments[0]()
		_test = lambda: self.matchers.year < future.year

		to_test = 6
		while to_test >= 0:
			if not self._test_match(to_test, future):
				inc = _increments[to_test](future, self.matchers)
				future += inc
				for i in xrange(0, to_test):
					future = _increments[7+i](future, inc)
				if _test():
					return None
				to_test = 6
				continue
			to_test -= 1

		return time.mktime(future.timetuple())

