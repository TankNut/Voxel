AddCSLuaFile()

function SWEP:GetBaseCone()
	return 0
end

function SWEP:CrouchModifier()
	return self:AimingDownSights() and 0.9 or 0.75
end