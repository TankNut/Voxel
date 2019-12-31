AddCSLuaFile()

SWEP.Base 					= "voxel_base"

SWEP.PrintName 				= "SMG"

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 2

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.DrawCrosshair 			= true

SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip 	= 120
SWEP.Primary.Ammo 			= "SMG1"
SWEP.Primary.Automatic 		= true

SWEP.Model 					= "smg"
SWEP.ModelScale 			= 1

SWEP.MuzzleEffect 			= "voxel_muzzle_smg"
SWEP.TracerEffect 			= "voxel_tracer_smg"

SWEP.HoldType 				= "ar2"
SWEP.HoldTypeLower 			= "passive"

SWEP.Damage 				= 29
SWEP.DamageType 			= DMG_BULLET

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