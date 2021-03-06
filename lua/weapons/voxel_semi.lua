AddCSLuaFile()

SWEP.Base 					= "voxel_base"

SWEP.PrintName 				= "Rifle"

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 3

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.DrawCrosshair 			= true

SWEP.Primary.ClipSize 		= 10
SWEP.Primary.DefaultClip 	= 50
SWEP.Primary.Ammo 			= "357"
SWEP.Primary.Automatic 		= true

SWEP.Model 					= "semi"
SWEP.ModelScale 			= 1

SWEP.MuzzleEffect 			= "voxel_muzzle_smg"
SWEP.TracerEffect 			= "voxel_tracer_smg"

SWEP.HoldType 				= "ar2"
SWEP.HoldTypeLower 			= "passive"

SWEP.Damage 				= 49
SWEP.DamageType 			= DMG_BULLET

SWEP.Spread 				= 0.006

SWEP.Delay 					= 0.5
SWEP.Recoil 				= Vector(0.05, 0.0255, 0)
SWEP.RecoilMult 			= 3

SWEP.AimDistance 			= 10

SWEP.Sound = {
	Fire 	= Sound("voxel/semi_shoot.wav"),
	Reload 	= Sound("voxel/semi_reload.wav")
}

SWEP.ReloadTime 			= 2.5

SWEP.VMOffset = {
	Pos = Vector(12, -6, -8)
}