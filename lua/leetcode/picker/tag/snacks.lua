local log = require("leetcode.logger")
local t = require("leetcode.translator")
local tag_picker = require("leetcode.picker.tag")
local picker = require("snacks.picker")

return function(topics, opts)
    local items = vim.tbl_map(function(tag)
        return { entry = tag_picker.entry(tag), text = tag_picker.ordinal(tag), value = tag }
    end, topics)
    local completed = false

    picker.pick({
        items = items,
        format = function(item)
            local result = {}
            for _, col in ipairs(item.entry) do
                result[#result + 1] = col
                result[#result + 1] = { "  " }
            end
            return result
        end,
        title = t("Select a Topic Tag"),
        layout = {
            preset = "select",
            preview = false,
            layout = { height = tag_picker.height, width = tag_picker.width },
        },
        actions = {
            confirm = function(p, item)
                if completed then
                    return
                end
                completed = true
                p:close()
                vim.schedule(function()
                    tag_picker.select(item.value, nil, opts)
                end)
            end,
        },
        on_close = function()
            if not completed then
                completed = true
                log.warn("No selection")
            end
        end,
    })
end
