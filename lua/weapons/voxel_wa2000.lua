AddCSLuaFile()

SWEP.Base 					= "voxel_base"

SWEP.PrintName 				= "WA 2000"

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 3

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.DrawCrosshair 			= false

SWEP.Primary.ClipSize 		= 6
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Ammo 			= "357"
SWEP.Primary.Automatic 		= true

SWEP.Model 					= "wa2000"
SWEP.ModelScale 			= 1

SWEP.MuzzleEffect 			= "voxel_muzzle_smg"
SWEP.TracerEffect 			= "voxel_tracer_smg"

SWEP.HoldType 				= "ar2"
SWEP.HoldTypeLower 			= "passive"

SWEP.Damage 				= 49
SWEP.DamageType 			= DMG_BULLET

SWEP.Spread 				= 0.002

SWEP.Delay 					= 0.5
SWEP.Recoil 				= Vector(0.05, 0.0255, 0)
SWEP.RecoilMult 			= 3

SWEP.AimDistance 			= 2

SWEP.Scope = {
	Enabled = true,
	Zoom = {2.5, 5, 10, 20}
}

SWEP.Sound = {
	Fire 	= Sound("voxel/semi_shoot.wav"),
	Reload 	= Sound("voxel/semi_reload.wav")
}

SWEP.ReloadTime 			= 2.5

SWEP.VMOffset = {
	Pos = Vector(10, -5, -10)
}