local TypeId = require "./types"

local Lexer = {}

---@param iter function
---@return function
Lexer.iterFromIter = function(iter)
    local preformatting = false
    ---@return Element | nil
    return function()
        local data = iter()
        if data == nil then return nil end
        if data:match("^```") then
            local meta = data:match("^```+(.*)")
            if meta == "" then meta = nil end
            preformatting = not preformatting
            ---@type PreformatToggle
            return {
                type = TypeId.PreToggle,
                meta = meta
            }
        end
        if preformatting then
            local content = data
            ---@type PreformatLine
            return {
                type = TypeId.PreLine,
                content = content,
            }
        end
        if data:match("^=>") then
            local link, friendly_name = data:match("^=>%s*(%g+)%s*(.*)")
            if friendly_name == "" then friendly_name = nil end
            ---@type LinkLine
            return {
                type = TypeId.Link,
                link = link,
                friendly_name = friendly_name,
            }
        end
        if data:match("^#+") then
            local level =
                   data:match("^###") and 3
                or data:match("^##[^#]") and 2
                or data:match("^#[^#]") and 1
            local content = data:match("^##?#?%s*(.*)")
            ---@type HeadingLine
            return {
                type = TypeId.Heading,
                level = level,
                content = content,
            }
        end
        if data:match("^%* ") then
            local content = data:sub(3)
            ---@type ListItem
            return {
                type = TypeId.ListItem,
                content = content,
            }
        end
        if data:match("^>") then
            local content = data:sub(2)
            ---@type QuoteLine
            return {
                type = TypeId.Quote,
                content = content,
            }
        end
        local content = data
        ---@type TextLine
        return {
            type = TypeId.Text,
            content = content,
        }
    end
end

return Lexer
