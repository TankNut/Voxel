AddCSLuaFile()

module("kv6", package.seeall)

local function TranslateColor(tab)
	return Color(tab[3] * 1.5, tab[2] * 1.5, tab[1] * 1.5)
end

function Import(f)
	if f:Read(4) != "Kvxl" then
		error("Invalid file signature")
	end

	local size = Vector(f:ReadULong(), f:ReadULong(), f:ReadULong())

	f:Skip(3 * 4)

	local blockcount = f:ReadULong()
	local blocks = {}

	for i = 0, blockcount - 1 do
		blocks[i] = {
			Color = {f:ReadByte(), f:ReadByte(), f:ReadByte(), f:ReadByte()},
			z = f:ReadUShort(),
			Faces = f:ReadByte(), -- Unused
			Lighting = f:ReadByte() -- Unused
		}
	end

	f:Skip(size.x * 4) -- Skip first set of offsets, we don't need them

	local offsets = {}

	for i = 0, (size.x * size.y) - 1 do
		offsets[i] = f:ReadUShort()
	end

	-- Verify that the offset and block list match
	local sum = 0

	for i = 0, #offsets - 1 do
		sum = sum + offsets[i]
	end

	if sum != blockcount then
		error("File corrupted: offset sum != blockcount")
	end

	-- Move the blocks and color data into a format we can easily work with
	local grid = {}
	local pos = 0

	for x = 1, size.x do
		grid[x] = {}

		for y = 1, size.y do
			grid[x][y] = {}
		end
	end

	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local span = offsets[x * size.y + y]
			local z = -1

			while (span - 1) >= 0 do
				local block = blocks[pos]

				z = block.z

				grid[x + 1][y + 1][z + 1] = TranslateColor(block.Color)

				pos = pos + 1
				span = span - 1
			end
		end
	end

	return size, grid
end