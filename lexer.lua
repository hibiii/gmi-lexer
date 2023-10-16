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
        local content = data
        ---@type TextLine
        return {
            type = TypeId.Text,
            content = content,
        }
    end
end

return Lexer
