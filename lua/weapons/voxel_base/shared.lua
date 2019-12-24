AddCSLuaFile()

SWEP.DrawWeaponInfoBox 		= false

SWEP.PrintName 				= "SMG"

SWEP.Category 				= "Ace of Spades"
SWEP.Author 				= "TankNut"

SWEP.Slot 					= 2

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= true

SWEP.ViewModel 				= Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel 			= Model("models/weapons/w_smg1.mdl")

SWEP.DrawCrosshair 			= true

SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip 	= 120
SWEP.Primary.Ammo 			= "SMG1"
SWEP.Primary.Automatic 		= true

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= ""
SWEP.Secondary.Automatic 	= false

SWEP.Model 					= "smg"

SWEP.HoldType 				= "ar2"
SWEP.HoldTypeLower 			= "passive"

SWEP.Damage 				= 29

SWEP.Spread 				= 0.012

SWEP.Delay 					= 0.1
SWEP.Recoil 				= Vector(0.00005, 0.0125, 0)
SWEP.RecoilMult 			= 2

SWEP.AimDistance 			= 10

SWEP.FireSound 				= Sound("voxel/smgshoot.wav")
SWEP.ReloadSound 			= Sound("voxel/smgreload.wav")

SWEP.ReloadTime 			= 2.5

SWEP.Attachments 			= {}

SWEP.VMOffset = {
	Pos = Vector(12, -6, -8),
	Scale = 1.2
}

SWEP.WMOffset = Vector(0, 1, 0)

SWEP.VMLower = {
	Pos = Vector(0, 3, -1),
	Ang = Angle(20, 45, 0)
}

SWEP.ReloadLower = {
	Pos = Vector(0, 0, -1),
	Ang = Angle(30, 0, 0)
}

AddCSLuaFile("cl_draw.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_model.lua")

if CLIENT then
	include("cl_draw.lua")
	include("cl_hud.lua")
	include("cl_model.lua")
end

include("sh_helpers.lua")
include("sh_recoil.lua")

include("sv_npc.lua")

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

	self:SetHoldType(self.HoldType)

	self.LastThink = CurTime()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "FireDuration")
	self:NetworkVar("Float", 1, "FinishReload")
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

function SWEP:Holster()
	if self:IsReloading() then
		return false
	end

	return true
end

function SWEP:CanAttack()
	if self:ShouldLower() then
		return false
	end

	if self:IsReloading() then
		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	if not self:CanAttack() then
		return
	end

	if self:Clip1() <= 0 then
		self:EmitSound("voxel/empty.wav")
		self:SetNextPrimaryFire(CurTime() + self.Delay * 2)

		return
	end

	local ply = self.Owner

	if self:GetFireDuration() == -1 and IsFirstTimePredicted() then
		self:SetFireDuration(0)
		self:StartFiring()
	end

	if ply:IsPlayer() then
		math.randomseed(ply:GetCurrentCommand():CommandNumber())
	end

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
		Damage = self.Damage
	})

	self:TakePrimaryAmmo(1)

	if ply:IsPlayer() then
		self:DoRecoil()
	end

	self:EmitSound(self.FireSound)
	self:SetNextPrimaryFire(CurTime() + self.Delay)
end

function SWEP:SecondaryAttack()
end

function SWEP:CanReload()
	if self:GetFinishReload() > CurTime() then
		return false
	end

	if self:GetReserveAmmo() <= 0 then
		return false
	end

	if self:Clip1() == self.Primary.ClipSize then
		return false
	end

	return true
end

function SWEP:Reload()
	if not self:CanReload() then
		return
	end

	self.Owner:SetAnimation(PLAYER_RELOAD)

	self:EmitSound(self.ReloadSound)
	self:SetFinishReload(CurTime() + self.ReloadTime)
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

	self:ReloadThink()

	self.LastThink = CurTime()
end

function SWEP:ReloadThink()
	local finish = self:GetFinishReload()

	if finish != 0 and finish <= CurTime() then
		self:SetFinishReload(0)

		local clip = self:Clip1()
		local ammo = math.min(self.Primary.ClipSize - clip, self:GetReserveAmmo())

		self:SetClip1(clip + ammo)

		self.Owner:RemoveAmmo(ammo, self:GetPrimaryAmmoType())
	end
end

function SWEP:StartFiring()
end

function SWEP:StopFiring()
end

function SWEP:SetupMove(ply, mv)
	if self:IsReloading() then
		mv:SetMaxClientSpeed(ply:GetWalkSpeed())
	elseif self:AimingDownSights() then
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