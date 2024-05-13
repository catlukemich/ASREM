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

function utils.applyProperties(target, source)
    print("applyProperties")
    for name, property in pairs(source) do
        print(name)
        if target[name] and source[name] then
            error("The target already posses property: " .. name)
        end
        target[name] = property
    end
end


return utils