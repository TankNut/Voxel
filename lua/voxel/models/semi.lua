RegisterVoxel("semi", {
	Mesh = "voxel/meshes/semi.lua",
	Offset = Vector(-1, -6, -5),
	Angle = Angle(180, -90, 0),
	Attachments = {
		Muzzle = {
			Pos = Vector(27.5, 0, 3),
			Ang = Angle()
		},
		Aim = {
			Pos = Vector(1.5, 0, 5),
			Ang = Angle()
		},
		Aimpoint = {
			Pos = Vector(1.5, 0, 5),
			Ang = Angle()
		}
	}
})