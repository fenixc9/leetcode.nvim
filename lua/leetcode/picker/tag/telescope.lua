local log = require("leetcode.logger")
local t = require("leetcode.translator")
local tag_picker = require("leetcode.picker.tag")

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

local displayer = entry_display.create({
    separator = "  ",
    items = {
        { remaining = true },
        { remaining = true },
    },
})

local function entry_maker(tag)
    return {
        value = tag,
        display = function()
            return displayer(tag_picker.entry(tag))
        end,
        ordinal = tag_picker.ordinal(tag),
    }
end

local theme = require("telescope.themes").get_dropdown({
    layout_config = {
        width = tag_picker.width,
        height = tag_picker.height,
    },
})

return function(topics, opts)
    pickers
        .new(theme, {
            prompt_title = t("Select a Topic Tag"),
            finder = finders.new_table({ results = topics, entry_maker = entry_maker }),
            sorter = conf.generic_sorter(theme),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    if not selection then
                        return log.warn("No selection")
                    end
                    tag_picker.select(selection.value, function()
                        actions.close(prompt_bufnr)
                    end, opts)
                end)
                return true
            end,
        })
        :find()
end
