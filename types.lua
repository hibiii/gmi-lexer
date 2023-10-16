---@enum TypeId
local TypeId = {
    Text = "text",
    Link = "link",
    PreToggle = "pre-toggle",
    PreLine = "pre-line",
    Heading = "heading",
    ListItem = "list-item",
    Quote = "quote",
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

return TypeId