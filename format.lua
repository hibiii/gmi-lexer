local Format = {}

local Lexer = require './lexer'
local TypeId = Lexer.TypeId

local width = 80

local widthBoundPrinter = function(str, prefix, options)
    if not prefix then prefix = "" end
    if options == nil then options = {} end
    local out = prefix
    local pad = (" "):rep(assert(utf8.len(prefix)))
    for word in str:gmatch("(%g+)") do
        if utf8.len(out) + utf8.len(word) + 1 < width then
            if out == "" then
                out = word
            elseif out == prefix or out == pad then
                out = out .. word
            else
                out = out .. " " .. word
            end
        else
            print(out)
            if options.prefix_once then
                out = pad .. word
            else
                out = prefix .. word
            end
        end
    end
    if options.new_line then
        print(out .. "\n")
    else
        print(out)
    end
end

local printers = {
    ---@param text TextLine
    [TypeId.Text] = function(text)
        widthBoundPrinter(text.content, nil, {new_line = true})
    end,

    ---@param link LinkLine
    [TypeId.Link] = function(link)
        if link.friendly_name then
            widthBoundPrinter(link.friendly_name, "--> ", {prefix_once = true})
            print("   <" .. link.link .. "> \n")
        else
            print("-> <" .. link.link .. "> \n")
        end
    end,

    ---@param toggle PreformatToggle
    [TypeId.PreToggle] = function(toggle)
        if toggle.meta then
            print ("    ~~~~ " .. toggle.meta .. " ~~~~")
        else
            print()
        end
    end,

    ---@param line PreformatLine
    [TypeId.PreLine] = function(line)
        print("    " .. line.content)
    end,

    ---@param item ListItem
    [TypeId.ListItem] = function(item)
        widthBoundPrinter(item.content, " • ",
            {new_line = true, prefix_once = true})
    end,

    ---@param quote QuoteLine
    [TypeId.Quote] = function (quote)
        widthBoundPrinter(quote.content, " │ ", {new_line = true})
    end,

    ---@param heading HeadingLine
    [TypeId.Heading] = function (heading)
        widthBoundPrinter(heading.content, "    ", {new_line = true})
    end
}

---@param line Element
Format.prettyPrintElement = function(line)
    ---@diagnostic disable-next-line: param-type-mismatch
    printers[line.type](line)
end

return Format
