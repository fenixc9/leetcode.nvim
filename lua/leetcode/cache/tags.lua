local config = require("leetcode.config")
local problems_api = require("leetcode.api.problems")

local suffix = config.is_cn and "_cn" or ""
local topics_file = config.storage.cache:joinpath("topic_tags" .. suffix)
local questions_file = config.storage.cache:joinpath("tagged_questions" .. suffix)
local interval = config.user.cache.update_interval

local topics_hist
local questions_hist
local topics_pending = {}
local topics_fetching = false
local questions_pending = {}

local Tags = {}

local function read(file)
    if not file:exists() then
        return
    end

    local contents = file:read()
    if not contents or type(contents) ~= "string" then
        return
    end

    local ok, payload = pcall(vim.json.decode, contents)
    if not ok or type(payload) ~= "table" or payload.version ~= config.version then
        return
    end
    return payload
end

local function write(file, payload)
    payload.version = config.version
    file:write(vim.json.encode(payload), "w")
end

local function is_stale(updated_at)
    return not updated_at or os.time() - updated_at > interval
end

local function fetch_topics(cb)
    if cb then
        topics_pending[#topics_pending + 1] = cb
    end

    if topics_fetching then
        return
    end
    topics_fetching = true

    problems_api.topic_tags(function(topics, err)
        if not err and topics then
            topics_hist = { version = config.version, updated_at = os.time(), data = topics }
            write(topics_file, topics_hist)
        end

        local callbacks = topics_pending
        topics_pending = {}
        topics_fetching = false
        for _, callback in ipairs(callbacks) do
            callback(topics, err)
        end
    end)
end

---@param cb fun(res: { name: string, slug: string, translated_name: string|nil }[]|nil, err: lc.err|nil)
function Tags.topics(cb)
    topics_hist = topics_hist or read(topics_file)
    if topics_hist and topics_hist.data then
        cb(topics_hist.data, nil)
        if is_stale(topics_hist.updated_at) then
            fetch_topics()
        end
        return
    end

    fetch_topics(cb)
end

local function tags_key(tags)
    local sorted = vim.deepcopy(tags)
    table.sort(sorted)
    return table.concat(sorted, ",")
end

local function fetch_questions(key, tags, cb)
    local pending = questions_pending[key]
    if pending then
        if cb then
            pending[#pending + 1] = cb
        end
        return
    end

    questions_pending[key] = cb and { cb } or {}
    problems_api.by_tags(tags, function(questions, err)
        if not err and questions then
            questions_hist = questions_hist or {
                version = config.version,
                data = {},
            }
            questions_hist.data[key] = {
                updated_at = os.time(),
                data = questions,
            }
            write(questions_file, questions_hist)
        end

        local callbacks = questions_pending[key]
        questions_pending[key] = nil
        for _, callback in ipairs(callbacks) do
            callback(questions, err)
        end
    end)
end

---@param tags string[]
---@param cb fun(res: { title_slug: string }[]|nil, err: lc.err|nil)
function Tags.questions(tags, cb)
    questions_hist = questions_hist or read(questions_file) or {
        version = config.version,
        data = {},
    }

    local key = tags_key(tags)
    local cached = questions_hist.data and questions_hist.data[key]
    if cached and cached.data then
        cb(cached.data, nil)
        if is_stale(cached.updated_at) then
            fetch_questions(key, tags)
        end
        return
    end

    fetch_questions(key, tags, cb)
end

return Tags
