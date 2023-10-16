local Lexer = require './lexer'
local Format = require './format'
local TypeId = Lexer.TypeId

local printLineTypes = function(iter)
for line in iter do
    ---@cast line Element
    if line.type == TypeId.Text then
        ---@cast line TextLine
        print("TextLine :: content: \"" .. line.content .. "\"")

    elseif line.type == TypeId.Link then
        ---@cast line LinkLine
        local friendly =
            line.friendly_name and "\"" .. line.friendly_name .. "\""
            or "nil"
        print("LinkLine :: friendly_name: " .. friendly .. ", link: <".. line.link .. ">")

    elseif line.type == TypeId.PreLine then
        ---@cast line PreformatLine
        print("PreformatLine :: content: \"" .. line.content .. "\"")

    elseif line.type == TypeId.PreToggle then
        ---@cast line PreformatToggle
        local meta =
            line.meta and "\"" .. line.meta .. "\""
            or "nil"
        print("PreformatToggle :: meta: " .. meta)

    elseif line.type == TypeId.Heading then
        ---@cast line HeadingLine
        print("HeadingLine :: level: " .. line.level .. ", content: \"" .. line.content .. "\"")

    elseif line.type == TypeId.ListItem then
        ---@cast line ListItem
        print("ListItem :: content: \"" .. line.content .. "\"")

    elseif line.type == TypeId.Quote then
        ---@cast line QuoteLine
        print("QuoteLine :: content: \"" .. line.content .. "\"")

    end
end
end

local raw_lexer_output = false
local files = {}

local help = function()
print [[usage: <command> <options> file [more_files [...] ]
options:
--help:     show this
--lexer:    show only the output of the lexer
--no-style: don't use terminal styles
]]
end

if #arg == 0 then
    help()
    return
end

for _, argv in ipairs(arg) do
    if argv == "--lexer" then
        raw_lexer_output = true
    elseif argv == "--help" then
        help()
        return
    elseif argv == "--no-style" then
        Format.setStyle(Styles.none)
    else
        files[#files+1] = argv
    end
end

if raw_lexer_output then
    for _, file in ipairs(files) do
        printLineTypes(Lexer.iterFromIter(io.lines(file)))
    end
else
    for _, file in ipairs(files) do
        print()
        for line in Lexer.iterFromIter(io.lines(file)) do
            Format.prettyPrintElement(line)
        end
    end
end
