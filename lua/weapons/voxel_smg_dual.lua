AddCSLuaFile()

SWEP.Base 					= "voxel_base"

SWEP.PrintName 				= "Twin-linked SMG"

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 2

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.DrawCrosshair 			= true

SWEP.Primary.ClipSize 		= 60
SWEP.Primary.DefaultClip 	= 240
SWEP.Primary.Ammo 			= "SMG1"
SWEP.Primary.Automatic 		= true

SWEP.Model 					= "smg"
SWEP.ModelScale 			= 1

SWEP.MuzzleEffect 			= "voxel_muzzle_smg"
SWEP.TracerEffect 			= "voxel_tracer_smg"

SWEP.HoldType 				= "ar2"
SWEP.HoldTypeLower 			= "passive"

SWEP.Damage 				= 29

SWEP.Spread 				= 0.012

SWEP.Delay 					= 0.1
SWEP.Recoil 				= Vector(0.0125, 0.01275, 0)
SWEP.RecoilMult 			= 2

SWEP.AimDistance 			= 10

SWEP.FireSound 				= Sound("voxel/smgshoot.wav")
SWEP.ReloadSound 			= Sound("voxel/smgreload.wav")

SWEP.ReloadTime 			= 2.5

SWEP.VMOffset = {
	Pos = Vector(12, -6, -8)
}

SWEP.Attachments = {
	{
		Model = "smg",
		Pos = Vector(0, 1, 0)
	}, {
		Model = "smg",
		Pos = Vector(0, -1, 0)
	}
}

if CLIENT then
	function SWEP:GetMuzzlePos(pos, ang)
		local index = tobool(self:Clip1() % 2 == 1)

		local v = self.Attachments[index and 1 or 2]
		local origin = {voxel.GetPos(self.Model, pos, ang, self.ModelScale, v.Attachment, v.Pos, v.Ang)}

		return voxel.GetPos(v.Model, origin[1], origin[2], self.ModelScale, "Muzzle")
	end

	function SWEP:DrawVoxelModel(pos, ang)
		if voxel.HasAttachment(self.Model, "Aimpoint") then
			self:DrawAimpoint(pos, ang)
		end

		self:DrawAttachments(pos, ang)
	end
end