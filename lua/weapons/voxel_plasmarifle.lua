AddCSLuaFile()

SWEP.Base 					= "voxel_base"

SWEP.PrintName 				= "Plasma Rifle"

SWEP.RenderGroup 			= RENDERGROUP_BOTH

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 2

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.DrawCrosshair 			= true

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= ""
SWEP.Primary.Automatic 		= true

SWEP.Model 					= "plasmarifle"
SWEP.ModelScale 			= 1.2

SWEP.MuzzleEffect 			= "voxel_muzzle_ar2"

SWEP.HoldType 				= "pistol"
SWEP.HoldTypeLower 			= "normal"

SWEP.Spread 				= 0.012

SWEP.Delay 					= 0.133
SWEP.Recoil 				= Vector(0.0075, 0.006, 0)
SWEP.RecoilMult 			= 2

SWEP.AimDistance 			= 10

SWEP.FireSound 				= Sound("voxel/plasmashoot.wav")

SWEP.ReloadTime 			= 2.5

SWEP.VMOffset = {
	Pos = Vector(16, -8, -7)
}

SWEP.WMOffset = {
	Pos = Vector(0, -0.5, 0),
	Ang = Angle(0, 0, 10)
}

SWEP.VMLower = {
	Pos = Vector(0, 0, -5),
	Ang = Angle(20, 0, 0)
}

SWEP.ActivityOverrides = {
	pistol = {
		[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1,
		[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
	}
}

function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", 0, "MuzzleIndex")
end

if CLIENT then
	function SWEP:GetMuzzlePos(pos, ang)
		return voxel.GetPos(self.Model, pos, ang, self.ModelScale, "Muzzle" .. (self:GetMuzzleIndex() and 1 or 2))
	end

	function SWEP:DrawVoxelModel(pos, ang, wm)
		self.BaseClass.DrawVoxelModel(self, pos, ang)

		if not wm then
			self:DrawBeam(pos, ang)
		end
	end

	local beam = Material("effects/voxel/plasma_beam")

	function SWEP:DrawBeam(pos, ang)
		local pos1 = voxel.GetPos(self.Model, pos, ang, self.ModelScale, 1)
		local pos2 = voxel.GetPos(self.Model, pos, ang, self.ModelScale, 2)

		render.SetMaterial(beam)
		render.DrawBeam(pos1, pos2, 1.5, 0, 2)
	end

	function SWEP:DrawWorldModelTranslucent()
		local pos, ang = self:GetWorldPos()

		self:DrawBeam(pos, ang)
	end
end

function SWEP:FireWeapon(ply)
	if SERVER then
		local cone = self:GetSpread()
		local aimcone = Angle(math.Rand(-cone, cone) * 25, 0, 0)

		aimcone:RotateAroundAxis(Vector(1, 0, 0), math.Rand(0, 360))

		local pos = ply:GetShootPos()
		local ang = (self:GetAimAngle() + aimcone):Forward():Angle()

		local ent = ents.Create("voxel_proj_plasma")

		ent:SetPos(pos)
		ent:SetAngles(ang)

		ent:SetOwner(ply)

		ent:Spawn()
		ent:Activate()
	end

	if IsFirstTimePredicted() then
		self:SetMuzzleIndex(not self:GetMuzzleIndex())
	end
end