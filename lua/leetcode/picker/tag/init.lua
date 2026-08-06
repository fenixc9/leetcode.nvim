local Picker = require("leetcode.picker")

---@class leet.Picker.Tag: leet.Picker
local P = {}

P.width = 70
P.height = 0.6
local function title(slug)
    return slug:gsub("-", " "):gsub("(%a)([%w']*)", function(first, rest)
        return first:upper() .. rest
    end)
end

---@return { name: string, slug: string }[]
function P.fallback_topics()
    local topics = vim.tbl_map(function(slug)
        return { name = title(slug), slug = slug }
    end, require("leetcode.picker.tag.topics"))
    table.sort(topics, function(a, b)
        return a.name < b.name
    end)
    return topics
end

---@param tag { name: string, slug: string, translated_name?: string }
function P.entry(tag)
    return {
        { tag.translated_name or tag.name, "leetcode_normal" },
        { tag.slug, "leetcode_ref" },
    }
end

---@param tag { name: string, slug: string, translated_name?: string }
function P.ordinal(tag)
    return ("%s %s %s"):format(tag.translated_name or "", tag.name, tag.slug)
end

---@param tags string[]
---@param opts? table<string, string[]>
function P.open_questions(tags, opts)
    local problems = require("leetcode.cache.problemlist").get()
    local spinner = require("leetcode.logger.spinner"):start("fetching tagged questions", "points")

    require("leetcode.cache.tags").questions(tags, function(tagged, err)
        if err then
            return spinner:error(err.msg)
        end

        local slugs = {}
        for _, question in ipairs(tagged or {}) do
            if question.title_slug then
                slugs[question.title_slug] = true
            end
        end

        local filtered = vim.tbl_filter(function(question)
            return slugs[question.title_slug] == true
        end, problems)

        if vim.tbl_isempty(filtered) then
            return spinner:error("No questions found for the selected tags")
        end

        spinner:success(("Found %d questions"):format(#filtered))
        Picker.question(filtered, opts or {})
    end)
end

---@param selection { name: string, slug: string, translated_name?: string }
---@param close? function
---@param opts? table<string, string[]>
function P.select(selection, close, opts)
    if close then
        close()
    end
    P.open_questions({ selection.slug }, opts)
end

return P
