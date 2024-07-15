local output = require(script.output)

local random = Random.new()

local function pickUser()
	return output.users[random:NextInteger(1, #output.users)]
end

local function pickUniverse()
	return output.universes[random:NextInteger(1, #output.universes)]
end

local function pickGroup()
	return output.groups[random:NextInteger(1, #output.groups)]
end

return {
	pickUser = pickUser,
	pickUniverse = pickUniverse,
	pickGroup = pickGroup,
}
