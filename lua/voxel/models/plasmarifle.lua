RegisterVoxel("plasmarifle", {
	Mesh = "voxel/meshes/plasmarifle.lua",
	Offset = Vector(-2, -6, -5),
	Angle = Angle(180, -90, 0),
	Attachments = {
		Muzzle1 = {
			Pos = Vector(10.5, 0, 2.5),
			Ang = Angle()
		},
		Muzzle2 = {
			Pos = Vector(10.5, 0, -2.5),
			Ang = Angle(0, 0, 180)
		},
		[1] = {
			Pos = Vector(10, 0, 1.5),
			Ang = Angle()
		},
		[2] = {
			Pos = Vector(10, 0, -1.5),
			Ang = Angle()
		}
	}
})