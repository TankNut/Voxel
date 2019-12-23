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

SWEP.DrawCrosshair 			= true

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= ""
SWEP.Primary.Automatic 		= true

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= ""
SWEP.Secondary.Automatic 	= false

SWEP.Model 					= "smg"

SWEP.HoldType 				= "smg"
SWEP.HoldTypeLower 			= "passive"

SWEP.Spread 				= 0.012

SWEP.Delay 					= 0.1
SWEP.Recoil 				= Vector(0.00005, 0.0125, 0)
SWEP.RecoilMult 			= 1

SWEP.AimDistance 			= 10

SWEP.VMOffset = {
	Pos = Vector(16, -6, -8),
	Scale = 1.2
}

SWEP.VMLower = {
	Pos = Vector(0, 5, -3),
	Ang = Angle(20, 45, 0)
}

AddCSLuaFile("cl_draw.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_vm.lua")

if CLIENT then
	include("cl_draw.lua")
	include("cl_hud.lua")
	include("cl_vm.lua")
end

include("sh_recoil.lua")

function SWEP:Initialize()
	local mins, maxs = voxel.GetHull(self.Model, self.VMOffset.Scale)

	self.PhysCollide = CreatePhysCollideBox(mins, maxs)
	self:SetCollisionBounds(mins, maxs)

	if SERVER then
		self:PhysicsInitBox(mins, maxs)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end
	end

	if CLIENT then
		self:SetRenderBounds(mins, maxs)
	end

	self:DrawShadow(false)
	self:EnableCustomCollisions(true)

	self.LastThink = CurTime()
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

function SWEP:CanAttack()
	if self:ShouldLower() then
		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	if not self:CanAttack() then
		return
	end

	local ply = self.Owner

	if self:GetFireDuration() == -1 and IsFirstTimePredicted() then
		self:SetFireDuration(0)
		self:StartFiring()
	end

	math.randomseed(ply:GetCurrentCommand():CommandNumber())

	if IsFirstTimePredicted() then
		local ed = EffectData()

		ed:SetEntity(self)
		ed:SetScale(0.6)
		ed:SetOrigin(self:GetPos())

		util.Effect("voxel_muzzle_ar2", ed)
	end

	ply:SetAnimation(PLAYER_ATTACK1)

	local cone = self:GetSpread()
	local aimcone = Angle(math.Rand(-cone, cone) * 25, 0, 0)

	aimcone:RotateAroundAxis(Vector(1, 0, 0), math.Rand(0, 360))

	ply:FireBullets({
		Src = ply:GetShootPos(),
		Dir = (self:GetAimAngle() + aimcone):Forward(),
		Attacker = self.Owner,
		Spread = Vector(0, 0, 0),
		TracerName = "voxel_tracer_ar2",
		Tracer = 1,
		Damage = 11
	})

	self:DoRecoil()

	self:EmitSound("NPC_FloorTurret.ShotSounds")
	self:SetNextPrimaryFire(CurTime() + self.Delay)
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
	local delta = CurTime() - self.LastThink

	if self:ShouldLower() then
		self:SetHoldType(self.HoldTypeLower)
	else
		self:SetHoldType(self.HoldType)
	end

	local duration = self:GetFireDuration()

	if duration != -1 and self.Owner:KeyDown(IN_ATTACK) and self:CanAttack() then
		self:SetFireDuration(duration + delta)
	else
		if duration != -1 then
			self:StopFiring()
		end

		self:SetFireDuration(-1)
	end

	self.LastThink = CurTime()
end

function SWEP:AimingDownSights()
	local ply = self.Owner

	if self:ShouldLower() then
		return false
	end

	if ply:KeyDown(IN_USE) then
		return false
	end

	return ply:KeyDown(IN_ATTACK2)
end

function SWEP:StartFiring()
end

function SWEP:StopFiring()
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

function SWEP:SetupMove(ply, mv)
	if self:AimingDownSights() then
		mv:SetMaxClientSpeed(ply:GetWalkSpeed() * 0.7)
	end
end

function SWEP:TestCollision(start, delta, isbox, extends)
	if not IsValid(self.PhysCollide) then
		return
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), start, start + delta, min, max)

	if not hit then
		return
	end

	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac
	}
end