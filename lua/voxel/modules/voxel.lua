AddCSLuaFile()

module("voxel", package.seeall)

Models = Models or {}

-- Used for generating meshes
local vertices = {
	Vector(-0.5, -0.5, -0.5),
	Vector(0.5, -0.5, -0.5),
	Vector(0.5, 0.5, -0.5),
	Vector(-0.5, 0.5, -0.5),
	Vector(-0.5, -0.5, 0.5),
	Vector(0.5, -0.5, 0.5),
	Vector(0.5, 0.5, 0.5),
	Vector(-0.5, 0.5, 0.5)
}

local normals = {
	Vector(0, 0, 1),
	Vector(0, 0, -1),
	Vector(1, 0, 0),
	Vector(-1, 0, 0),
	Vector(0, 1, 0),
	Vector(0, -1, 0)
}

local indices = {
	{6, 5, 7, 7, 5, 8}, -- up
	{1, 2, 4, 4, 2, 3}, -- down
	{2, 6, 3, 3, 6, 7}, -- front
	{5, 1, 8, 8, 1, 4}, -- back
	{4, 3, 8, 8, 3, 7}, -- right
	{5, 6, 1, 1, 6, 2}, -- left
}

function Load(index, size, grid, offset, angle, attachments)
	offset = offset or Vector()
	angle = angle or Angle()

	local data = {
		Size = size,
		Angle = angle,
		Mins = LocalToWorld(offset, Angle(), Vector(), angle) + Vector(-0.5, -0.5, 0.5),
		Maxs = LocalToWorld(size + offset, Angle(), Vector(), angle) + Vector(-0.5, -0.5, 0.5),
		Attachments = attachments
	}

	if CLIENT then
		data.Mesh = GenerateMesh(index, size, grid, offset)
	end

	Models[index] = data
end

function GenerateMesh(index, size, grid, center)
	local fill = {}
	local colors = {}

	-- Set up an empty array the same size as the model
	for x = 1, size.x do
		fill[x] = {}

		for y = 1, size.y do
			fill[x][y] = {}
		end
	end

	local i = 1

	-- Flood fill the outside for face culling, also generate a color atlas
	for x = 1, size.x do
		for y = 1, size.y do
			for z = 1, size.z do
				if grid[x][y][z] then
					local color = tostring(grid[x][y][z]:ToVector()) -- Messy but it works

					if not colors[color] then
						colors[color] = i

						i = i + 1
					end
				end

				if (x > 1 and x < size.x) and
					(y > 1 and y < size.y) and
					(z > 1 and z < size.z) then
					continue
				end

				local function flood(vec)
					if grid[vec.x][vec.y][vec.z] or fill[vec.x][vec.y][vec.z] then
						return
					end

					fill[vec.x][vec.y][vec.z] = true

					for _, v in pairs(normals) do
						local check = vec + v

						if check:WithinAABox(Vector(1, 1, 1), size) then
							flood(check)
						end
					end
				end

				flood(Vector(x, y, z))
			end
		end
	end

	-- Write the color atlas to a render target and create our mesh's material
	local rendertarget = GetRenderTarget("voxel_" .. index, 256, 256, false)

	render.PushRenderTarget(rendertarget)

	cam.Start2D()
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(1, 1, 256, 256)

		for k, v in pairs(colors) do
			local color = Vector(k):ToColor()

			surface.SetDrawColor(color)
			surface.DrawLine(v, 1, v, 256)
		end
	cam.End2D()

	render.PopRenderTarget()

	local material = CreateMaterial("voxel_" .. index, "VertexLitGeneric", {
		["$basetexture"] = "Models/props_c17/FurnitureFabric003a",
		["$halflambert"] = 1
	})

	timer.Simple(0, function()
		material:SetTexture("$basetexture", rendertarget)
	end)

	-- Set up vertices by iterating over the grid made earlier
	local verts = {}

	for x = 1, size.x do
		for y = 1, size.y do
			for z = 1, size.z do
				-- Empty cells are always nil
				if not grid[x][y][z] then
					continue
				end

				-- Check all 6 faces
				for k, side in pairs(indices) do
					local vec = Vector(x, y, z)
					local check = vec + normals[k]

					-- If our neighbour is filled, ignore that direction's face
					if check:WithinAABox(Vector(1, 1, 1), size) and (grid[check.x][check.y][check.z] or not fill[check.x][check.y][check.z]) then
						continue
					end

					-- Push vertices onto the list
					for _, v in pairs(side) do
						local offset = vec - Vector(1, 1, 1)

						table.insert(verts, {
							pos = vertices[v] + offset + center,
							normal = normals[k],
							u = colors[tostring(grid[x][y][z]:ToVector())] / 256 + (0.5 / 256), -- Look up our uv coordinates and add half a pixel to fix some weird rounding errors
							v = 0.5 -- Just grab the middle
						})
					end
				end
			end
		end
	end

	local obj = Mesh()

	obj:BuildFromTriangles(verts)

	return obj
end

function GetRenderBounds(index, scale)
	local data = Models[index]

	if not data then
		return
	end

	return data.Mins * scale, data.Maxs * scale
end

function GetConvexHull(index, scale)
	local data = Models[index]

	if not data then
		return
	end

	return {
		Vector(data.Mins.x, data.Mins.y, data.Mins.z) * scale,
		Vector(data.Mins.x, data.Mins.y, data.Maxs.z) * scale,
		Vector(data.Mins.x, data.Maxs.y, data.Mins.z) * scale,
		Vector(data.Mins.x, data.Maxs.y, data.Maxs.z) * scale,
		Vector(data.Maxs.x, data.Mins.y, data.Mins.z) * scale,
		Vector(data.Maxs.x, data.Mins.y, data.Maxs.z) * scale,
		Vector(data.Maxs.x, data.Maxs.y, data.Mins.z) * scale,
		Vector(data.Maxs.x, data.Maxs.y, data.Maxs.z) * scale
	}
end

local convar_fov = GetConVar("fov_desired")

function GetAttachment(index, pos, ang, size, attachment, fov)
	local data = Models[index]

	if not data then
		return
	end

	local attdata = data.Attachments[attachment]

	if not attdata then
		return pos, ang
	end

	local scale = 1

	if fov then
		scale = fov / convar_fov:GetFloat()
	end

	return LocalToWorld(attdata.Pos * size * scale, attdata.Angle, pos, ang)
end

function Draw(index, pos, ang, size, dev, parent)
	local data = Models[index]

	if not data then
		return
	end

	local matrix = Matrix()
	local pos1, ang1 = LocalToWorld(Vector(), data.Angle, pos, ang)

	matrix:SetTranslation(pos1)
	matrix:SetAngles(ang1)
	matrix:SetScale(Vector(size, size, size))

	render.SetMaterial(Material("!voxel_" .. index))

	cam.PushModelMatrix(matrix)
		data.Mesh:Draw()
	cam.PopModelMatrix()

	if dev then
		DrawDebug(index, pos, ang, size, parent)
	end
end

function DrawDebug(index, pos, ang, size, parent)
	local data = Models[index]

	if not data then
		return
	end

	if not IsValid(parent) or halo.RenderedEntity() != parent then
		render.DrawLine(pos, pos + (ang:Forward() * 5), Color(255, 0, 0), true)
		render.DrawLine(pos, pos + (ang:Right() * 5), Color(0, 255, 0), true)
		render.DrawLine(pos, pos + (ang:Up() * 5), Color(0, 0, 255), true)

		for k, v in pairs(data.Attachments) do
			local pos2, ang2 = LocalToWorld(v.Pos * size, v.Angle, pos, ang)

			render.DrawLine(pos2, pos2 + (ang2:Forward() * 5), Color(255, 0, 0), true)
			render.DrawLine(pos2, pos2 + (ang2:Right() * 5), Color(0, 255, 0), true)
			render.DrawLine(pos2, pos2 + (ang2:Up() * 5), Color(0, 0, 255), true)

			local camang = (LocalPlayer():EyePos() - pos2):Angle()

			camang:RotateAroundAxis(camang:Forward(), 90)
			camang:RotateAroundAxis(camang:Right(), -90)

			cam.Start3D2D(pos2 + Vector(0, 0, 3), camang, 0.1)
				render.PushFilterMag(TEXFILTER.POINT)
				render.PushFilterMin(TEXFILTER.POINT)

				draw.DrawText(k, "BudgetLabel", 0, 0, color_white, TEXT_ALIGN_CENTER)

				render.PopFilterMin()
				render.PopFilterMag()
			cam.End3D2D()
		end
	end
end