local Format = {}

local Lexer = require './lexer'
local TypeId = Lexer.TypeId

Styles = {
    none = {
        HeadingPrefixes = {"", "", ""},
        LinkArrowPrefix = "",
        LinkPrefix = "",
        PrefmtTogglePaddingPrefix = "",
        PrefmtToggleMetaPrefix = "",
        BulletPrefix = "",
        QuoteBarPrefix = "",
        QuotePrefix = "",
        Reset = "",
    },
    default = {
        HeadingPrefixes = {"\x1b[97;1;4m", "\x1b[97;4m", "\x1b[4m"},
        LinkArrowPrefix = "\x1b[34m",
        LinkPrefix = "\x1b[34m",
        PrefmtTogglePaddingPrefix = "\x1b[2m",
        PrefmtToggleMetaPrefix = "\x1b[1m",
        BulletPrefix = "\x1b[34;1m",
        QuoteBarPrefix = "\x1b[32m",
        QuotePrefix = "\x1b[0m\x1b[3m",
        Reset = "\x1b[0m",
    }
}

local width = 80

local current_style = Styles.default

local widthBoundPrinter = function(str, prefix, options)
    if not prefix then prefix = "" end
    if not options then options = {} end
    if not options.prefix_style then options.prefix_style = "" end
    if not options.text_style then options.text_style = "" end
    if not options.end_style then options.end_style = "" end
    local out = options.prefix_style .. prefix
    local logical = prefix
    local pad = (" "):rep(assert(utf8.len(prefix)))
    for word in str:gmatch("(%g+)") do
        if utf8.len(logical) + utf8.len(word) + 1 < width then
            if logical == "" then
                logical = word
                out = options.text_style .. word
            elseif logical == prefix or logical == pad then
                logical = logical .. word
                out = out .. options.text_style .. word
            else
                logical = logical .. " " .. word
                out = out .. " " .. word
            end
        else
            print(out .. options.end_style)
            if options.prefix_once then
                logical = pad .. word
                out = pad .. options.text_style .. word
            else
                logical = prefix .. word
                out = options.prefix_style .. prefix
                   .. options.text_style .. word
            end
        end
    end
    if options.new_line then
        print(out .. options.end_style .."\n")
    else
        print(out .. options.end_style)
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
            widthBoundPrinter(link.friendly_name, "--> ", {
                prefix_once = true,
                prefix_style = current_style.LinkArrowPrefix,
                text_style = current_style.Reset
            })
            print("   ".. current_style.LinkPrefix .. "<" .. link.link
                .. ">" .. current_style.Reset .. " \n")
        else
            print(current_style.LinkArrowPrefix .. "-> "
                .. current_style.Reset .. current_style.LinkPrefix .. "<"
                .. link.link .. ">" .. current_style.Reset .. " \n")
        end
    end,

    ---@param toggle PreformatToggle
    [TypeId.PreToggle] = function(toggle)
        if toggle.meta then
            print ("    " .. current_style.PrefmtTogglePaddingPrefix .. "~~~~ "
                .. current_style.Reset
                .. current_style.PrefmtToggleMetaPrefix .. toggle.meta
                .. current_style.Reset
                .. current_style.PrefmtTogglePaddingPrefix .. " ~~~~"
                .. current_style.Reset)
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
        widthBoundPrinter(item.content, " • ", {
            new_line = true,
            prefix_once = true,
            prefix_style = current_style.BulletPrefix,
            text_style = current_style.Reset,
        })
    end,

    ---@param quote QuoteLine
    [TypeId.Quote] = function (quote)
        widthBoundPrinter(quote.content, " │ ", {
            new_line = true,
            prefix_style = current_style.QuoteBarPrefix,
            text_style = current_style.QuotePrefix,
            end_style = current_style.Reset,
        })
    end,

    ---@param heading HeadingLine
    [TypeId.Heading] = function (heading)
        widthBoundPrinter(heading.content, "    ", {
            new_line = true,
            text_style = current_style.HeadingPrefixes[heading.level],
            end_style = current_style.Reset,
        })
    end
}

Format.setStyle = function(style)
    current_style = style
end

---@param line Element
Format.prettyPrintElement = function(line)
    ---@diagnostic disable-next-line: param-type-mismatch
    printers[line.type](line)
end

return Format
