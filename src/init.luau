local output = require(script.output)

local random = Random.new()

local function user()
	return output.users[random:NextInteger(1, #output.users)]
end

local function universe()
	return output.universes[random:NextInteger(1, #output.universes)]
end

local function group()
	return output.groups[random:NextInteger(1, #output.groups)]
end

return {
	user = user,
	universe = universe,
	group = group,
}
