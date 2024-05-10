local utils = {}

function utils.getLineNumber()
    local function scriptPath()
        local str = debug.getinfo(3, "S").source:sub(2)
        -- return str:match("(.*/)")
        return str
     end
     
    return scriptPath() .. " " .. debug.getinfo(2).currentline .. ":1"

end

function utils.getDirpath(path, sep)
    sep = sep or '/'
    return path:match("(.*" .. sep .. ")")
end

function utils.getBasename(path)
    return path:match("[^/]*.lua$")
end


return utils