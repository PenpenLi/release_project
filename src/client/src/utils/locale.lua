local _cur_locale = 'cn'

function set_locale( new_locale )
	_cur_locale = new_locale
end

function get_value( locale_key )
	if data.language[locale_key] == nil or data.language[locale_key][_cur_locale] == nil then
		return ' '
	end
	return data.language[locale_key][_cur_locale]
end

function get_value_with_var( locale_key, vars )
	local temp_string = get_value( locale_key )
	if vars ~= nil then
		for k, v in pairs(vars) do
			local temp_key = '%%{' .. k .. '}'
			temp_string = string.gsub(temp_string, temp_key, v)
		end
	end
	return temp_string
end
