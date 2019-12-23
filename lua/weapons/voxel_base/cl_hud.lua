SWEP.CrossAmount = 0
SWEP.CrossAlpha = 255

function SWEP:CrosshairVisible()
	if self:ShouldLower() then
		return false
	end

	if self:AimingDownSights() then
		return false
	end

	return true
end

function SWEP:DoDrawCrosshair(x, y)
	local FT = FrameTime()
	local ply = self.Owner

	if ply:ShouldDrawLocalPlayer() then
		return true
	end

	if self:CrosshairVisible() then
		self.CrossAlpha = Lerp(FT * 15, self.CrossAlpha, 255)
	else
		self.CrossAlpha = Lerp(FT * 15, self.CrossAlpha, 0)
	end

	local cone = self:GetSpread()

	self.CrossAmount = Lerp(FT * 10, self.CrossAmount, (cone * 300) * (90 / math.Clamp(GetConVar("fov_desired"):GetInt(), 75, 90)))

	surface.SetDrawColor(0, 0, 0, self.CrossAlpha * 0.75) -- background

	surface.DrawRect(x - 13 - self.CrossAmount, y - 1, 12, 3) -- left
	surface.DrawRect(x + 3 + self.CrossAmount, y - 1, 12, 3) -- right
	surface.DrawRect(x - 1, y - 13 - self.CrossAmount, 3, 12) -- up
	surface.DrawRect(x - 1, y + 3 + self.CrossAmount, 3, 12) -- down

	surface.SetDrawColor(255, 255, 255, self.CrossAlpha) -- Foreground

	surface.DrawRect(x - 12 - self.CrossAmount, y, 10, 1) -- left
	surface.DrawRect(x + 4 + self.CrossAmount, y, 10, 1) -- right
	surface.DrawRect(x, y - 12 - self.CrossAmount, 1, 10) -- up
	surface.DrawRect(x, y + 4 + self.CrossAmount, 1, 10) -- down

	return true
end