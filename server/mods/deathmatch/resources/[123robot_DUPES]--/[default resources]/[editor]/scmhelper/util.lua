function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function string:starts(start)
   return self:sub(1,string.len(start))==start
end

function tail(array)
	result = {}
	for key,value in ipairs(array) do
		if key > 2 then
			result[key-1] = value
		end
	end
	outputConsole(result[1])
	return result
end
