local utils = {}

function utils.getLineNumber()
    function script_path()
        local str = debug.getinfo(3, "S").source:sub(2)
        -- return str:match("(.*/)")
        return str
     end
     
    return script_path() .. " " .. debug.getinfo(2).currentline .. ":1"

end

return utils