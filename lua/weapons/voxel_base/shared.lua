AddCSLuaFile()

SWEP.DrawWeaponInfoBox 		= false

SWEP.Author 				= "TankNut"

SWEP.Slot 					= 2

SWEP.AdminOnly 				= false
SWEP.Spawnable 				= false

SWEP.DrawCrosshair 			= true

SWEP.ViewModel 				= Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel 			= Model("models/weapons/w_smg1.mdl")

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= ""
SWEP.Primary.Automatic 		= true

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= ""
SWEP.Secondary.Automatic 	= false

SWEP.Model 					= "smg"
SWEP.ModelScale 			= 1

SWEP.MuzzleEffect 			= false
SWEP.TracerEffect 			= "voxel_tracer_ar2"

SWEP.HoldType 				= "ar2"
SWEP.HoldTypeLower 			= "passive"

SWEP.Damage 				= 29
SWEP.DamageType 			= DMG_BULLET

SWEP.Spread 				= 0.012

SWEP.Delay 					= 0.1
SWEP.Recoil 				= Vector(0.00005, 0.0125, 0)
SWEP.RecoilMult 			= 2
SWEP.ConstantRecoil 		= false

SWEP.AimDistance 			= 10

SWEP.Scope 					= {}
SWEP.Sound 					= {}

SWEP.FireAnimation 			= true

SWEP.ReloadTime 			= 2.5

SWEP.VMOffset = {
	Pos = Vector(12, -6, -8),
}

SWEP.WMOffset = {
	Pos = Vector(2, 0.5, 0),
	Ang = Angle()
}

SWEP.VMLower = {
	Pos = Vector(0, 3, -1),
	Ang = Angle(20, 45, 0)
}

SWEP.ReloadLower = {
	Pos = Vector(0, 0, -1),
	Ang = Angle(30, 0, 0)
}

SWEP.Attachments = {}

SWEP.ActivityOverrides = {}

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

if SERVER then
	include("sv_npc.lua")
end

function SWEP:Initialize()
	local mins, maxs = voxel.GetHull(self.Model, self.ModelScale)

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

		self.StorePos = self.VMLower.Pos
		self.StoreAng = self.VMLower.Ang

		self.LastVMTime = CurTime()
	end

	self:DrawShadow(false)
	self:EnableCustomCollisions(true)

	self:SetHoldType(self.HoldType)

	self.LastThink = CurTime()

	self:SetZoomIndex(1)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "FireDuration")
	self:NetworkVar("Float", 1, "FinishReload")

	self:NetworkVar("Int", 0, "ZoomIndex")
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

function SWEP:GetDelay()
	return self.Delay
end

function SWEP:PrimaryAttack()
	if not self:CanAttack() then
		return
	end

	if self.Primary.ClipSize > 0 and self:Clip1() <= 0 then
		self:EmitSound("voxel/empty.wav")
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	local ply = self.Owner

	if not self:IsFiring() and IsFirstTimePredicted() then
		self:SetFireDuration(0)
		self:StartFiring()
	end

	if ply:IsPlayer() then
		math.randomseed(ply:GetCurrentCommand():CommandNumber())
	end

	if IsFirstTimePredicted() and self.MuzzleEffect then
		local ed = EffectData()

		ed:SetEntity(self)
		ed:SetScale(1)
		ed:SetOrigin(self:GetPos())

		util.Effect(self.MuzzleEffect, ed)
	end

	if self.FireAnimation then
		ply:SetAnimation(PLAYER_ATTACK1)
	end

	self:FireWeapon(ply)
	self:TakePrimaryAmmo(1)

	if ply:IsPlayer() then
		self:DoRecoil()
	end

	self:SetNextPrimaryFire(CurTime() + self:GetDelay())
end

function SWEP:FireWeapon(ply)
	local cone = self:GetSpread()
	local aimcone = Angle(math.Rand(-cone, cone) * 25, 0, 0)

	aimcone:RotateAroundAxis(Vector(1, 0, 0), math.Rand(0, 360))

	self:FireBullets({
		Src = ply:GetShootPos(),
		Dir = (self:GetAimAngle() + aimcone):Forward(),
		Attacker = self.Owner,
		Spread = Vector(0, 0, 0),
		TracerName = self.TracerEffect,
		Tracer = 1,
		Damage = self.Damage,
		Callback = function(attacker, tr, dmg)
			dmg:SetDamageType(self.DamageType)
		end
	})

	self:PlaySound(self.Sound.Fire)
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

	self:PlaySound(self.Sound.Reload)
	self:SetFinishReload(CurTime() + self.ReloadTime)
end

function SWEP:Think()
	local delta = CurTime() - self.LastThink

	if self:ShouldLower() then
		self:SetHoldType(self.HoldTypeLower)
	else
		self:SetHoldType(self.HoldType)
	end

	if SERVER then
		local duration = self:GetFireDuration()

		if duration != -1 and self.Owner:KeyDown(IN_ATTACK) and self:CanAttack() then
			self:SetFireDuration(duration + delta)
		else
			if duration != -1 then
				self:StopFiring()
			end

			self:SetFireDuration(-1)
		end
	end

	self:ReloadThink(delta)
	self:ScopeThink()

	self.LastThink = CurTime()
end

function SWEP:ReloadThink(delta)
	local finish = self:GetFinishReload()

	if finish != 0 and finish <= CurTime() then
		self:SetFinishReload(0)

		local clip = self:Clip1()
		local ammo = math.min(self.Primary.ClipSize - clip, self:GetReserveAmmo())

		self:SetClip1(clip + ammo)

		self.Owner:RemoveAmmo(ammo, self:GetPrimaryAmmoType())
	end
end

function SWEP:ScopeThink()
	if not self.Scope.Enabled then
		return
	end

	if self:AimingDownSights() and istable(self.Scope.Zoom) and (not game.SinglePlayer() or SERVER) then
		local cmd = self.Owner:GetCurrentCommand()
		local wheel = math.Clamp(cmd:GetMouseWheel(), -1, 1)

		if wheel != 0 then
			local index = self:GetZoomIndex() + wheel

			if index > 0 and index <= #self.Scope.Zoom then
				self:SetZoomIndex(index)
			end
		end
	end

	if CLIENT then
		if not self:AimingDownSights() or self:IsReloading() then
			self.Scoped = false
		elseif not self.Scoped and self:GetADSFactor() > 0.9 then
			self.Scoped = true
		end
	end
end

function SWEP:StartFiring()
end

function SWEP:StopFiring()
end

if CLIENT then
	local fov = GetConVar("fov_desired")
	local ratio = GetConVar("zoom_sensitivity_ratio")

	function SWEP:AdjustMouseSensitivity()
		return (LocalPlayer():GetFOV() / fov:GetFloat()) * ratio:GetFloat()
	end
end

function SWEP:GetZoomLevel()
	local zoom = self.Scope.Zoom

	if istable(zoom) then
		zoom = zoom[self:GetZoomIndex()]
	end

	return zoom
end

function SWEP:TranslateFOV(fov)
	if not self.Scope.Enabled then
		return fov
	end

	if (CLIENT and self.Scoped) or (SERVER and self:AimingDownSights()) then
		return fov / self:GetZoomLevel()
	end
end

function SWEP:SetupMove(ply, mv)
	if self:IsReloading() then
		mv:SetMaxClientSpeed(ply:GetWalkSpeed())
	elseif self:AimingDownSights() then
		mv:SetMaxClientSpeed(ply:GetWalkSpeed() * 0.6)
	end
end

function SWEP:TranslateActivity(act)
	local ply = self.Owner

	if ply:IsNPC() then
		return self.ActivityTranslateAI[act] or -1
	end

	local holdtype = self:GetHoldType()
	local overrides = self.ActivityOverrides[holdtype]

	if overrides and overrides[act] then
		return overrides[act]
	end

	return self.ActivityTranslate[act] or -1
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