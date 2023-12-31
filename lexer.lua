local Lexer = {}

Lexer.version = "0.1"

---@enum TypeId
Lexer.TypeId = {
    Text = "text",
    Link = "link",
    PreToggle = "prefmt-toggle",
    PreLine = "prefmt-line",
    Heading = "heading",
    ListItem = "list-item",
    Quote = "quote",
}
local TypeId = Lexer.TypeId

---@class Element
---@field type TypeId

---@class TextLine: Element
---@field type TypeId Text
---@field content string

---@class LinkLine: Element
---@field type TypeId Link
---@field link string
---@field friendly_name string | nil

---@class PreformatToggle: Element
---@field type TypeId PreToggle
---@field meta string | nil

---@class PreformatLine: Element
---@field type TypeId PreLine
---@field content string

---@class HeadingLine: Element
---@field type TypeId Heading
---@field level integer
---@field content string

---@class ListItem: Element
---@field type TypeId ListItem
---@field content string

---@class QuoteLine: Element
---@field type TypeId Quote
---@field content string

local matchPreformattingToggle = function(line)
    if line:match("^```") then
        local meta = line:match("^```+(.*)")
        if meta == "" then meta = nil end
        ---@type PreformatToggle
        return {
            type = TypeId.PreToggle,
            meta = meta
        }
    end
end

local matchPreformattedLine = function(line)
    ---@type PreformatLine
    return {
        type = TypeId.PreLine,
        content = line,
    }
end

local matchLinkLine = function(line)
    if line:match("^=>") then
        local link, friendly_name = line:match("^=>%s*(%g+)%s*(.*)")
        if friendly_name == "" then friendly_name = nil end
        ---@type LinkLine
        return {
            type = TypeId.Link,
            link = link,
            friendly_name = friendly_name,
        }
    end
end

local matchHeadingLine = function(line)
    if line:match("^#+") then
        local level =
               line:match("^###") and 3
            or line:match("^##[^#]") and 2
            or line:match("^#[^#]") and 1
        local content = line:match("^##?#?%s*(.*)")
        ---@type HeadingLine
        return {
            type = TypeId.Heading,
            level = level,
            content = content,
        }
    end
end

local matchListItemLine = function(line)
    if line:match("^%* ") then
        local content = line:sub(3)
        ---@type ListItem
        return {
            type = TypeId.ListItem,
            content = content,
        }
    end
end

local matchQuoteLine = function(line)
    if line:match("^>") then
        local content = line:sub(2)
        ---@type QuoteLine
        return {
            type = TypeId.Quote,
            content = content,
        }
    end
end

local matchTextLine = function(line)
    ---@type TextLine
    return {
        type = TypeId.Text,
        content = line,
    }
end

---@param iter function
---@return function
Lexer.iterFromIter = function(iter)
    local preformatting = false
    ---@return Element | nil
    return function()
        local line = iter()
        if line == nil then return nil end
        local out = nil
        out = matchPreformattingToggle(line)
        if out then
            preformatting = not preformatting
            return out
        end
        out = preformatting and matchPreformattedLine(line)
           or matchLinkLine(line)
           or matchHeadingLine(line)
           or matchListItemLine(line)
           or matchQuoteLine(line)
           or matchTextLine(line)
        return out
    end
end

Lexer.iterFromString = function(str)
    return Lexer.iterFromIter(str:gmatch("\n?([^\n]*)\n?"))
end

Lexer.iterFromLines = function(lines)
    local i = 1
    local iter = function()
        local out = lines[i]
        i = i + 1
        return out
    end
    return Lexer.iterFromIter(iter)
end

return Lexer
