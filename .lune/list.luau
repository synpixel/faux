local process = require("@lune/process")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")
local stdioUtil = require("stdio-util")

local types = table.clone(process.args)
local input = serde.decode("json", fs.readFile("output.json"))

if table.find(types, "*") then
	local keys = {}

	for key in input do
		table.insert(keys, key)
	end

	types = keys
end

for _, type in types do
	if not input[type] then
		error(`failed to find {type} in output.json`)
	end

	if #types > 1 then
		stdio.write(`{stdioUtil.color(stdioUtil.style(type:upper(), "bold"), "cyan")}\n`)
	end

	for _, entry in input[type] do
		stdio.write(`{if type == "users" then "@" else ""}{entry.name} {stdioUtil.color("#" .. entry.id, "black")} \n`)
	end

	stdio.write("\n")
end
