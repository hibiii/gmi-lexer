local Format = {}

local Lexer = require './lexer'
local TypeId = Lexer.TypeId

local printers = {
    ---@param text TextLine
    [TypeId.Text] = function(text)
        print(text.content .. "\n")
    end,
    ---@param link LinkLine
    [TypeId.Link] = function(link)
        if link.friendly_name then
            print("-> " .. link.friendly_name)
            print("   <" .. link.link .. "> \n")
        else
            print("-> <" .. link.link .. "> \n")
        end
    end,
    [TypeId.PreToggle] = function()
        print()
    end,
    ---@param line PreformatLine
    [TypeId.PreLine] = function(line)
        print("    " .. line.content)
    end,
    ---@param item ListItem
    [TypeId.ListItem] = function(item)
        print(" • " .. item.content .. "\n")
    end,
    ---@param quote QuoteLine
    [TypeId.Quote] = function (quote)
        print(" | " .. quote.content .. "\n")
    end,
    ---@param heading HeadingLine
    [TypeId.Heading] = function (heading)
        print("    " .. heading.content .. "\n")
    end
}

---@param line Element
Format.prettyPrintElement = function(line)
    ---@diagnostic disable-next-line: param-type-mismatch
    printers[line.type](line)
end

return Format
