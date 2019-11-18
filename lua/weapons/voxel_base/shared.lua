AddCSLuaFile()

SWEP.DrawWeaponInfoBox 		= false
SWEP.DrawAmmo 				= false

SWEP.PrintName 				= "SMG"

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 2

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.ViewModel 				= Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel 			= Model("models/weapons/w_smg1.mdl")

SWEP.DrawCrosshair 			= false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= ""
SWEP.Primary.Automatic 		= true

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= ""
SWEP.Secondary.Automatic 	= false

SWEP.MatOverride 			= Material("engine/occlusionproxy")

SWEP.Model 					= "smg"

SWEP.HoldType 				= "smg"
SWEP.HoldTypeLower 			= "passive"

SWEP.VMOffset = {
	Pos = Vector(16, -6, -8),
	Scale = 1.2
}

SWEP.VMLower = {
	Pos = Vector(0, 5, -3),
	Ang = Angle(20, 45, 0)
}

AddCSLuaFile("cl_vm.lua")

if CLIENT then
	include("cl_vm.lua")
end

function SWEP:Initialize()
	if SERVER then
		self:PhysicsInitConvex(voxel.GetConvexHull(self.Model, 1))
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:EnableCustomCollisions(true)
	end

	if CLIENT then
		self:SetRenderBounds(voxel.GetRenderBounds(self.Model, 1))

		self.StorePos = self.VMLower.Pos
		self.StoreAng = self.VMLower.Ang

		self.LastVMTime = CurTime()
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "FireDuration")
end

function SWEP:Deploy()
	if game.SinglePlayer() then
		self:CallOnClient("Deploy")
	end

	self:SetHoldType(self.HoldType)

	if CLIENT then
		self.StorePos = self.VMLower.Pos
		self.StoreAng = self.VMLower.Ang

		self.LastVMTime = CurTime()
	end
end

function SWEP:PrimaryAttack()
	if self:ShouldLower() then
		return
	end

	local ply = self.Owner

	math.randomseed(ply:GetCurrentCommand():CommandNumber())

	if IsFirstTimePredicted() then
		local ed = EffectData()

		ed:SetEntity(self)
		ed:SetScale(0.6)
		ed:SetOrigin(self:GetPos())

		util.Effect("voxel_muzzle_ar2", ed)
	end

	ply:SetAnimation(PLAYER_ATTACK1)

	ply:FireBullets({
		Src = ply:GetShootPos(),
		Dir = self:GetAimAngle():Forward(),
		Attacker = self.Owner,
		Spread = Vector(0.014, 0.014, 0),
		TracerName = "voxel_tracer_ar2",
		Tracer = 2,
		Damage = 11
	})

	self:EmitSound("NPC_FloorTurret.ShotSounds")
	self:SetNextPrimaryFire(CurTime() + 0.07)
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
	if self:ShouldLower() then
		self:SetHoldType(self.HoldTypeLower)
	else
		self:SetHoldType(self.HoldType)
	end

	self:SetFireDuration(self.Owner:KeyDown(IN_ATTACK) and self:GetFireDuration() + FrameTime() or 0)
end

function SWEP:GetAimAngle()
	local ply = self.Owner

	return ply:EyeAngles() + ply:GetViewPunchAngles()
end

function SWEP:ShouldLower()
	local ply = self.Owner

	if self:IsSprinting() or not ply:OnGround() then
		return true
	end

	return false
end

function SWEP:IsSprinting()
	local ply = self.Owner
	local vel = ply:GetVelocity():Length2D()
	local walk = ply:GetWalkSpeed()

	if not ply:OnGround() then
		return false
	end

	local limit = ply:KeyDown(IN_SPEED) and (walk * 1.2) or (walk * 3)

	return vel > limit
end