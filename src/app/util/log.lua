
local log = {}

local function logt(data, max_level, prefix)
    max_level = max_level or 5
    if type(prefix) ~= "string" then  
        prefix = ""  
    end  
    if type(data) ~= "table" then  
        print(prefix .. tostring(data))  
    else  
        print("(table)")  
        if max_level ~= 0 then  
            local prefix_next = prefix .. "    "  
            print(prefix .. "{")  
            for k,v in pairs(data) do  
                io.stdout:write(prefix_next .. k .. " = ")  
                if type(v) ~= "table" or (type(max_level) == "number" and max_level <= 1) then
                	if type(v) == "string" then
                		print("\"" .. v .. "\"")
                	elseif type(v) == "function" then
                        print(v .. "(fuction)")
                    else 
                        print(v)
                	end 
                else  
                    if max_level == nil then  
                        logt(v, nil, prefix_next)  
                    else  
                        logt(v, max_level - 1, prefix_next)  
                    end  
                end  
            end  
            print(prefix .. "}")  
        end  
    end  
end

--logv(1)
--logv("string")
--logv({})
--logv("--", 2, "abc")
local function logv(...)
	if select("#", ...) == 1 then
		if type(...) == "table" then
			logt(...)
		else
			print(tostring((...)))
		end
	else
        print(...)
	end
end

--log.debug 调试log
function log.d(...)
	logv(...)
end

--log.error 记录日志的log
function log.e(...)
	logv(...)
end

return log