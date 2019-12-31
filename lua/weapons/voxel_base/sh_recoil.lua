AddCSLuaFile()

function SWEP:GetSpread()
	if self.Owner:IsNPC() or self:AimingDownSights() then
		return self.Spread
	end

	return self.Spread * 2
end

function SWEP:GetRecoilModifier()
	local ply = self.Owner
	local horz, vert = 0.5, 0.5

	if (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) and not self:AimingDownSights() then
		horz = horz * 2
		vert = vert * 2
	end

	if not ply:OnGround() then
		horz = horz * 2
		vert = vert * 2
	elseif ply:Crouching() then
		horz = horz * 0.5
		vert = vert * 0.5
	end

	horz = horz * math.sqrt(1 - math.pow(ply:GetAimVector().z, 4))

	return horz, vert
end

function SWEP:DoRecoil()
	local ply = self.Owner
	local dir = ply:GetAimVector()
	local recoil = self.Recoil

	local limit = Vector(dir.x, dir.y, 0):Dot(dir) - 0.03

	local horz, vert = self:GetRecoilModifier()
	local ang = ply:EyeAngles()

	local p = math.min(recoil.x, math.max(0, limit)) * vert
	local y = recoil.y * math.Rand(-1, 1) * horz

	dir = dir + (ang:Up() * p)
	dir = dir + (ang:Right() * y)

	ply:ViewPunch(Angle(-p, -y, 0) * 50)
	ply:SetEyeAngles(dir:Angle())

	self:SetVMRecoil()
end

function SWEP:SetVMRecoil()
	if game.SinglePlayer() and SERVER then
		self:CallOnClient("SetVMRecoil")
	elseif CLIENT then
		self.RecoilFactor = self.ConstantRecoil and 0.5 or 1
	end
end