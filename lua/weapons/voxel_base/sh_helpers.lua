AddCSLuaFile()

function SWEP:PlaySound(snd)
	if not snd then
		return
	end

	if istable(snd) then
		snd = table.Random(snd)
	end

	self:EmitSound(snd)
end

function SWEP:GetReserveAmmo()
	return self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
end

function SWEP:GetAimAngle()
	local ply = self.Owner

	if ply:IsNPC() then
		return ply:GetAimVector():Angle()
	end

	return ply:EyeAngles() + ply:GetViewPunchAngles()
end

function SWEP:AimingDownSights()
	local ply = self.Owner

	if not voxel.HasAttachment(self.Model, "Aim") then
		return false
	end

	if self:ShouldLower() then
		return false
	end

	return ply:KeyDown(IN_ATTACK2)
end

function SWEP:ShouldLower()
	local ply = self.Owner

	if ply:IsPlayer() and self:IsSprinting() or not ply:OnGround() then
		return true
	end

	return false
end

function SWEP:IsFiring()
	return self:GetFireDuration() != -1
end

function SWEP:IsReloading()
	return self:GetFinishReload() > CurTime()
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

if CLIENT then
	function SWEP:GetADSFactor()
		local target = self:GetADSTarget()

		return 1 - (self.StorePos:Distance(target) / target:Length())
	end
end