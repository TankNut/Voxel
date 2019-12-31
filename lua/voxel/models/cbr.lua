RegisterVoxel("cbr", {
	Mesh = "voxel/meshes/cbr.lua",
	Offset = Vector(-1, -12, -6),
	Angle = Angle(180, -90, 0),
	Attachments = {
		Muzzle = {
			Pos = Vector(15.5, 0, 4),
			Ang = Angle()
		},
		Aim = {
			Pos = Vector(3.5, 0, 6),
			Ang = Angle()
		},
		Aimpoint = {
			Pos = Vector(3.5, 0, 6),
			Ang = Angle()
		}
	}
})