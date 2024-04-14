local process = require("@lune/process")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local net = require("@lune/net")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")
local util = require("util")

local ROBLOSECURITY = process.args[1] or roblox.getAuthCookie(true)
local PLACE_DETAILS_REQUEST_CHUNK_SIZE = 50

local input = serde.decode("json", fs.readFile("input.json"))
local output = {
	users = {},
	universes = {},
	groups = {},
}

local function merge(...: { [any]: any }): { [any]: any }
	local tables = { ... }
	local first = table.clone(tables[1])

	for i = 2, #tables do
		for key, value in tables[i] do
			first[key] = value
		end
	end

	return first
end

local function splitArray(array: { any }, chunkSize: number)
	local newArray = {}
	for i = 1, #array, chunkSize do
		table.insert(newArray, { unpack(array, i, math.min(i + chunkSize - 1, #array)) })
	end
	return newArray
end

local function getUniverseIds(placeIds: { number })
	local universeIds = {}

	if ROBLOSECURITY then
		local placeIdsChunks = splitArray(placeIds, PLACE_DETAILS_REQUEST_CHUNK_SIZE)

		for _, placeIds in placeIdsChunks do
			local response = net.request({
				method = "GET",
				url = `https://games.roblox.com/v1/games/multiget-place-details?placeIds={table.concat(
					placeIds,
					"&placeIds="
				)}`,
				headers = {
					["Cookie"] = `.ROBLOSECURITY={ROBLOSECURITY}`,
				},
			})
			local places = net.jsonDecode(response.body)

			for _, place in places do
				table.insert(universeIds, place.universeId)
			end
		end
	else
		for _, placeId in placeIds do
			local response = net.request(`https://apis.roblox.com/universes/v1/places/{placeId}/universe`)
			local universe = net.jsonDecode(response.body)
			table.insert(universeIds, universe.universeId)
		end
	end

	return universeIds
end

stdio.write(`{util.color(util.style("USERS", "bold"), "cyan")}\n`)

do
	local response = net.request({
		method = "POST",
		url = "https://users.roblox.com/v1/users",
		body = net.jsonEncode({
			userIds = input.users,
			excludeBannedUsers = false,
		}),
		headers = {
			["Content-Type"] = "application/json",
		},
	})
	local users = net.jsonDecode(response.body).data

	output.users = merge(output.users, users)

	for _, user in users do
		stdio.write(`{util.color("Registered user", "cyan")} {user.name} {util.color("#" .. user.id, "black")}\n`)
	end
end

stdio.write("\n")
stdio.write(`{util.color(util.style("UNIVERSES", "bold"), "cyan")}\n`)

do
	local universeIds = getUniverseIds(input.universes.places)
	local response = net.request(`https://games.roblox.com/v1/games?universeIds={table.concat(universeIds, ",")}`)
	local universes = net.jsonDecode(response.body).data

	output.universes = merge(output.universes, universes)

	for _, universe in universes do
		stdio.write(
			`{util.color("Registered universe", "cyan")} {universe.name} {util.color("#" .. universe.id, "black")}\n`
		)
	end
end

stdio.write("\n")
stdio.write(`{util.color(util.style("GROUPS", "bold"), "cyan")}\n`)

do
	local response = net.request(`https://groups.roblox.com/v2/groups?groupIds={table.concat(input.groups, ",")}`)
	local groups = net.jsonDecode(response.body).data

	output.groups = merge(output.groups, groups)

	for _, group in groups do
		stdio.write(`{util.color("Registered group", "cyan")} {group.name} {util.color("#" .. group.id, "black")}\n`)
	end
end

stdio.write("\n")

fs.writeFile("output.json", serde.encode("json", output))
