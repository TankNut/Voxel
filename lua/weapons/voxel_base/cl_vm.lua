function SWEP:GetRoll()
	local ply = self.Owner
	local vel = ply:GetVelocity()
	local len = vel:Length()
	local walk = ply:GetWalkSpeed()

	return math.Clamp((vel:Dot(EyeAngles():Right()) * 0.04) * len / walk, -5, 5)
end

function SWEP:GetBaseVMPos()
	local roll = self:GetRoll()

	if self:ShouldLower() then
		return self.VMLower.Pos, self.VMLower.Ang + Angle(0, 0, roll)
	end

	if self.Owner:KeyDown(IN_ATTACK2) then
		local offset = self.VMOffset
		local pos, ang = voxel.GetAttachment(self.Model, Vector(), Angle(0, 0, roll), 1, "Aim")

		return -offset.Pos - pos + Vector(10, 0, 0), ang
	end

	return Vector(), Angle(0, 0, roll)
end

SWEP.OldEye = Angle()
SWEP.EyeDelta = Angle()

function SWEP:GetVMSway(dt)
	local eye = EyeAngles()

	self.EyeDelta = Angle(eye.p, eye.y, 0) - self.OldEye

	self.EyeDelta:Normalize()

	self.EyeDelta.p = math.Clamp(self.EyeDelta.p, -5, 5)
	self.EyeDelta.y = math.Clamp(self.EyeDelta.y, -5, 5)

	self.OldEye.p = eye.p
	self.OldEye.y = eye.y

	return self.EyeDelta
end

SWEP.RunTime = 0

function SWEP:GetVMOffset(dt)
	local ct = UnPredictedCurTime()

	local ply = self.Owner

	local vel = ply:GetVelocity()
	local len = vel:Length()

	local walk = ply:GetWalkSpeed()
	local threshold = walk * 1.2

	local pos = Vector()
	local ang = Angle()

	if len < threshold or not ply:OnGround() then
		local mult = 1

		if ply:KeyDown(IN_ATTACK2) then
			mult = 0.2
		end

		local sin = math.sin(ct) * mult
		local cos = math.cos(ct) * mult
		local tan = math.atan(sin * cos, sin * cos) * mult

		ang.p = ang.p + tan * 1.15
		ang.y = ang.y + cos * 0.4

		pos.z = pos.z - tan * 0.2
	end

	if len > 10 and len < threshold then
		local mod = 6 + (walk / 200)
		local mult = math.Clamp(len / walk, 0, 1)
		local mult2 = Vector(1, 1, 1)

		if ply:KeyDown(IN_ATTACK2) then
			mult2 = Vector(0.3, 0.2, 0.25)
		end

		local sin = math.sin(ct * mod) * mult
		local cos = math.cos(ct * mod) * mult
		local tan = math.atan(sin * cos, sin * cos) * mult

		ang.p = ang.p + (tan * 0.8) * mult2.x
		ang.y = ang.y + (cos * 0.4) * mult2.y
		ang.z = ang.z + (sin * 0.4) * mult2.z

		pos.x = pos.x + (sin * 0.08) * mult2.x
		pos.y = pos.y + (cos * 0.4) * mult2.y
		pos.z = pos.z - (tan * 0.08) * mult2.z
	end

	if self:IsSprinting() then
		local run = ply:GetRunSpeed()
		local mult = math.Clamp(len / run, 0, 1)

		self.RunTime = self.RunTime + dt * (7.5 + math.Clamp(len / 200, 0, 5))

		local sin = math.sin(self.RunTime) * mult
		local cos = math.cos(self.RunTime) * mult
		local tan = math.atan(sin * cos, sin * cos) * mult

		ang.p = ang.p + tan * mult * 0.4
		ang.y = ang.y - sin * mult * -4
		ang.r = ang.r + cos * mult * 1.6

		pos.x = pos.x - cos * mult * 0.4
		pos.y = pos.y + sin * mult * 2
		pos.z = pos.z + tan * mult * 0.8
	end

	return pos, ang
end

SWEP.StorePos = Vector()
SWEP.StoreAng = Angle()

SWEP.LastVMTime = 0

function SWEP:GetVMPos()
	local dt = CurTime() - self.LastVMTime
	local pos, ang = Vector(), Angle()

	local basepos, baseang = self:GetBaseVMPos()
	local offpos, offang = self:GetVMOffset(dt)

	pos = pos + basepos + offpos
	ang = ang + baseang + offang

	self.StorePos = LerpVector(math.Clamp(dt * 10, 0, 1), self.StorePos, pos)
	self.StoreAng = LerpAngle(math.Clamp(dt * 10, 0, 1), self.StoreAng, ang)

	local sway = self:GetVMSway(dt)

	self.StorePos = self.StorePos + Vector(0, -sway.y * 0.05, sway.p * 0.05)
	self.StoreAng = self.StoreAng + Angle(sway.p * 0.05, sway.y * 0.05, 0)

	self.LastVMTime = CurTime()

	local offset = self.VMOffset

	return LocalToWorld((self.StorePos * offset.Scale) + (offset.Pos * offset.Scale), self.StoreAng, EyePos(), EyeAngles())
end

function SWEP:GetViewModelPosition()
	return self:GetVMPos()
end

function SWEP:PreDrawViewModel()
	render.ModelMaterialOverride(self.MatOverride)
end

local mat = Material("reticles/eotech_reddot")

function SWEP:PostDrawViewModel()
	render.ModelMaterialOverride()

	local pos, ang = self:GetVMPos()
	local offset = self.VMOffset

	voxel.Draw(self.Model, pos, ang, offset.Scale)

	render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(15)

		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		render.SetStencilCompareFunction(STENCIL_ALWAYS)

		local attpos, attang = voxel.GetAttachment(self.Model, pos, ang, offset.Scale, "Aim")

		render.SetColorMaterial()
		render.DrawQuadEasy(attpos, -attang:Forward(), offset.Scale, offset.Scale, ColorAlpha(color_white, 0))

		render.SetStencilCompareFunction(STENCIL_EQUAL)

		render.SetMaterial(mat)
		render.DrawQuadEasy(attpos + (attang:Forward() * 200), -EyeAngles():Forward(), 5, 5, Color(255, 0, 0), -ang.r)
	render.SetStencilEnable(false)
	render.ClearStencil()
end

function SWEP:GetWorldPos()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	if IsValid(self.Owner) then
		local index = self.Owner:LookupAttachment("anim_attachment_RH")
		local att = self.Owner:GetAttachment(index)

		if istable(att) then
			pos = att.Pos
			ang = att.Ang + Angle(-10, 0, -5)
		end
	end

	return pos, ang
end

function SWEP:DrawWorldModel()
	render.ModelMaterialOverride(self.MatOverride)
	self:DrawModel()
	render.ModelMaterialOverride()

	local pos, ang = self:GetWorldPos()

	voxel.Draw(self.Model, pos, ang, self.VMOffset.Scale)
end