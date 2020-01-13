RegisterVoxel("needler", {
	Mesh = "voxel/meshes/needler.kv6",
	Offset = Vector(-1, -8, -7),
	Angle = Angle(180, -90, 0),
	Attachments = {
		Muzzle = {
			Pos = Vector(12.5, 0, 0),
			Ang = Angle()
		},
		[1] = {
			Pos = Vector(7, 0, 5),
			Ang = Angle(-50, 170, 0)
		},
		[2] = {
			Pos = Vector(7, 0, 5),
			Ang = Angle(-50, 190, 0)
		},
		[3] = {
			Pos = Vector(6.5, 1, 4),
			Ang = Angle(-50, 150, 0)
		},
		[4] = {
			Pos = Vector(6.5, -1, 4),
			Ang = Angle(-50, 210, 0)
		},
		[5] = {
			Pos = Vector(4, 0, 6),
			Ang = Angle(-55, 180, 0)
		},
		[6] = {
			Pos = Vector(4, 1, 5),
			Ang = Angle(-55, 160, 0)
		},
		[7] = {
			Pos = Vector(4, -1, 5),
			Ang = Angle(-55, 200, 0)
		},
		[8] = {
			Pos = Vector(0, 0, 7),
			Ang = Angle(-50, 170, 0)
		},
		[9] = {
			Pos = Vector(0, 0, 7),
			Ang = Angle(-50, 190, 0)
		},
		[10] = {
			Pos = Vector(-0.5, 1, 6),
			Ang = Angle(-50, 150, 0)
		},
		[11] = {
			Pos = Vector(-0.5, -1, 6),
			Ang = Angle(-50, 210, 0)
		},
		[12] = {
			Pos = Vector(-2.5, 0, 7),
			Ang = Angle(-45, 180, 0)
		},
		[13] = {
			Pos = Vector(-3, 1, 7),
			Ang = Angle(-45, 160, 0)
		},
		[14] = {
			Pos = Vector(-3, -1, 7),
			Ang = Angle(-45, 200, 0)
		}
	}
})