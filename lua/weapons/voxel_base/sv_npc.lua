function SWEP:GetNPCBulletSpread(prof)
	return 15
end

function SWEP:GetNPCBurstSettings()
	return 3, 6, self.Delay
end

function SWEP:GetNPCRestTimes()
	return 0.3, 0.6
end