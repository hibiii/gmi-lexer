---@enum TypeId
local TypeId = {
    Text = "text",
    Link = "link",
    PreToggle = "pre-toggle",
    PreLine = "pre-line",
}

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

return TypeId