local config = require("leetcode.config")

local arguments = {}

local topics = require("leetcode.picker.tag.topics")

arguments.list = {
    difficulty = { "easy", "medium", "hard" },
    status = { "ac", "notac", "todo" },
}

arguments.tags = {
    difficulty = { "easy", "medium", "hard" },
    status = { "ac", "notac", "todo" },
}

arguments.random = {
    difficulty = { "easy", "medium", "hard" },
    status = { "ac", "notac", "todo" },
    tags = topics,
}

arguments.session_change = {
    name = config.sessions.names,
}

arguments.session_create = {
    name = {},
}

return arguments
