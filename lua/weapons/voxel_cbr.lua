AddCSLuaFile()

SWEP.Base 					= "voxel_base"

SWEP.PrintName 				= "Continuous Beam Rifle"

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 2

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.DrawCrosshair 			= false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= ""
SWEP.Primary.Automatic 		= true

SWEP.Model 					= "cbr"
SWEP.ModelScale 			= 1

SWEP.MuzzleEffect 			= false
SWEP.TracerEffect 			= "voxel_tracer_beam"

SWEP.HoldType 				= "smg"
SWEP.HoldTypeLower 			= "passive"

SWEP.Damage 				= 2
SWEP.DamageType 			= DMG_ENERGYBEAM

SWEP.Spread 				= 0.005

SWEP.Delay 					= 0.02
SWEP.Recoil 				= Vector(0.005, 0.003, 0)
SWEP.RecoilMult 			= 3
SWEP.ConstantRecoil 		= true

SWEP.AimDistance 			= 10

SWEP.Sound = {
	Loop = Sound("ambient/energy/force_field_loop1.wav")
}

SWEP.FireAnimation 			= false

SWEP.VMOffset = {
	Pos = Vector(12, -6, -8)
}

function SWEP:StartFiring()
	self:PlaySound(self.Sound.Loop)
end

function SWEP:StopFiring()
	self:StopSound(self.Sound.Loop)
end

function SWEP:OnRemove()
	self:StopSound(self.Sound.Loop)
end

function SWEP:DoImpactEffect()
	return true
end