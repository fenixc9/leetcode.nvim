local log = require("leetcode.logger")
local t = require("leetcode.translator")
local tag_picker = require("leetcode.picker.tag")
local picker = require("mini.pick")

return function(topics, opts)
    local items = vim.tbl_map(function(tag)
        return { entry = tag_picker.entry(tag), text = tag_picker.ordinal(tag), value = tag }
    end, topics)
    local ns_id = vim.api.nvim_create_namespace("MiniPick LeetCode Topic Tags Picker")
    local completed = false

    local result = picker.start({
        source = {
            items = items,
            name = t("Select a Topic Tag"),
            choose = function(item)
                completed = true
                vim.schedule(function()
                    tag_picker.select(item.value, nil, opts)
                end)
            end,
            show = function(buf_id, source_items)
                require("leetcode.picker.mini_pick_utils").show_items(buf_id, ns_id, source_items)
            end,
        },
        window = {
            config = {
                width = tag_picker.width,
                height = math.floor(vim.o.lines * tag_picker.height),
            },
        },
    })

    if result == nil and not completed then
        log.warn("No selection")
    end
end
