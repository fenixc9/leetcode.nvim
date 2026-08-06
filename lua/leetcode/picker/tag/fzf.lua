local fzf = require("fzf-lua")
local t = require("leetcode.translator")
local tag_picker = require("leetcode.picker.tag")
local Picker = require("leetcode.picker")

local deli = " "

return function(topics, opts)
    local items = {}
    for _, tag in ipairs(topics) do
        items[#items + 1] = Picker.normalize({ { entry = tag_picker.entry(tag) } })[1]
            .. deli
            .. tag.slug
    end

    fzf.fzf_exec(items, {
        prompt = t("Select a Topic Tag") .. "> ",
        winopts = { height = tag_picker.height, width = tag_picker.width },
        fzf_opts = { ["--delimiter"] = deli, ["--nth"] = "1..-2" },
        actions = {
            ["default"] = function(selected)
                local slug = Picker.hidden_field(selected[1], deli)
                local tag = vim.tbl_filter(function(item)
                    return item.slug == slug
                end, topics)[1]
                if tag then
                    tag_picker.select(tag, nil, opts)
                end
            end,
        },
    })
end
