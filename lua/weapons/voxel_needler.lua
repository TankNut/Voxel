AddCSLuaFile()

SWEP.Base 					= "voxel_base"

SWEP.PrintName 				= "Needler"

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 2

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.DrawCrosshair 			= true

SWEP.Primary.ClipSize 		= 24
SWEP.Primary.DefaultClip 	= 72
SWEP.Primary.Ammo 			= "AR2"
SWEP.Primary.Automatic 		= true

SWEP.Model 					= "needler"
SWEP.ModelScale 			= 1

SWEP.HoldType 				= "pistol"
SWEP.HoldTypeLower 			= "normal"

SWEP.Damage 				= 29
SWEP.DamageType 			= DMG_BULLET

SWEP.Spread 				= 0.1

SWEP.DelayRamp 				= 0.8

SWEP.MinDelay 				= 0.083
SWEP.MaxDelay 				= 0.125

SWEP.Recoil 				= Vector(0.0125, 0.01275, 0)
SWEP.RecoilMult 			= 2

SWEP.AimDistance 			= 5

SWEP.Sound = {
	Fire 	= {
		Sound("voxel/needler_fire1.wav"),
		Sound("voxel/needler_fire2.wav"),
		Sound("voxel/needler_fire3.wav")
	},
	Reload 	= Sound("voxel/needler_reload.wav")
}

SWEP.ReloadTime 			= 1.6

SWEP.VMOffset = {
	Pos = Vector(18, -7, -9)
}

SWEP.WMOffset = {
	Pos = Vector(-0.5, 0, 0.5),
	Ang = Angle(0, 0, 10)
}

SWEP.VMLower = {
	Pos = Vector(0, 0, -5),
	Ang = Angle(20, 0, 0)
}

SWEP.ReloadLower = {
	Pos = Vector(0, 1, -3),
	Ang = Angle(20, 20, 0)
}

SWEP.Attachments = {}

SWEP.ActivityOverrides = {
	pistol = {
		[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1,
		[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
	}
}

function SWEP:GetDelay()
	return self:GetFireDuration() > self.DelayRamp and self.MinDelay or self.MaxDelay
end

function SWEP:FireWeapon(ply)
	if SERVER then
		local cone = self:GetSpread()
		local aimcone = Angle(math.Rand(-cone, cone) * 25, 0, 0)

		aimcone:RotateAroundAxis(Vector(1, 0, 0), math.Rand(0, 360))

		local pos = ply:GetShootPos()
		local targets = ents.FindInCone(pos, self:GetAimAngle():Forward(), 2048, math.cos(math.rad(15)))

		local target
		local maxdist = math.huge

		for _, v in pairs(targets) do
			if not IsValid(v) or not (v:IsNPC() or v:IsPlayer()) then
				continue
			end

			if v:Health() <= 0 then
				continue
			end

			local center = v:WorldSpaceCenter()

			if not self.Owner:VisibleVec(center) then
				continue
			end

			local dist = pos:DistToSqr(center)

			if dist >= maxdist then
				continue
			end

			target = v
			maxdist = dist
		end

		local ang = (self:GetAimAngle() + aimcone):Forward():Angle()
		local ent = ents.Create("voxel_proj_needler")

		ent:SetPos(pos)
		ent:SetAngles(ang)

		ent:SetOwner(ply)

		if IsValid(target) then
			ent:SetTarget(target)
		end

		ent:Spawn()
		ent:Activate()
	end

	self:PlaySound(self.Sound.Fire)
end

function SWEP:SetupNeedles()
	for k in ipairs(voxel.GetAttachments(self.Model)) do
		self.Attachments[k] = {
			Model = "needle",
			Ang = Angle(180, 0, math.Rand(0, 360)),
			Attachment = k,
			Scale = self.ModelScale * 0.3
		}
	end
end

function SWEP:Initialize()
	self.BaseClass.Initialize(self)
	self:SetupNeedles()
end

function SWEP:OnReloaded()
	self:SetupNeedles()
end