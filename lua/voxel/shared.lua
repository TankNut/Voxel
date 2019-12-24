include("modules/kv6.lua")
include("modules/voxel.lua")

function string.Filename(path)
	return string.StripExtension(string.GetFileFromFilename(path))
end

for _, v in pairs(file.Find("voxel/models/*", "LUA")) do
	AddCSLuaFile("models/" .. v)

	local index = string.Filename(v)
	local data = include("models/" .. v)

	AddCSLuaFile(data.Mesh)

	local f = file.Open(data.Mesh, "rb", "LUA")
	local size, grid = kv6.Import(f)

	f:Close()

	voxel.Load(index, size, grid, data.Offset, data.Angle, data.Attachments)
end

hook.Add("SetupMove", "voxel", function(ply, mv)
	local weapon = ply:GetActiveWeapon()

	if IsValid(weapon) and weapon.SetupMove then
		weapon:SetupMove(ply, mv)
	end
end)

list.Add("NPCUsableWeapons", {class = "voxel_base", title = "Voxel"})