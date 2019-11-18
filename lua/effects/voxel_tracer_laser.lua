EFFECT.Mat = Material("trails/laser")
EFFECT.Speed = 5000

local function translatefov(ent, pos, inverse)
	local worldx = math.tan(LocalPlayer():GetFOV() * (math.pi / 360))
	local viewx = math.tan(ent.ViewModelFOV * (math.pi / 360))

	local factor = Vector(worldx / viewx, worldx / viewx, 0)
	local tmp = pos - EyePos()

	local eye = EyeAngles()
	local transformed = Vector(eye:Right():Dot(tmp), eye:Up():Dot(tmp), eye:Forward():Dot(tmp))

	if inverse then
		transformed.x = transformed.x / factor.x
		transformed.y = transformed.y / factor.y
	else
		transformed.x = transformed.x * factor.x
		transformed.y = transformed.y * factor.y
	end

	local out = (eye:Right() * transformed.x) + (eye:Up() * transformed.y) + (eye:Forward() * transformed.z)

	return EyePos() + out
end

function EFFECT:Init(data)
	self.Ent = data:GetEntity()

	self.Start = self:GetStartPos(self.Ent)
	self.End = data:GetOrigin()

	self:SetRenderBoundsWS(self.Start, self.End)

	self.Color = Color(150, 100, 255)
	self.Alpha = 150
end

function EFFECT:GetStartPos(ent)
	local offset = ent.VMOffset

	if ent:IsCarriedByLocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then
		local pos, ang = ent:GetVMPos()
		local pos1 = voxel.GetAttachment(ent.Model, pos, ang, offset.Scale, "Muzzle")

		return translatefov(ent, pos1)
	else
		local pos, ang = ent:GetWorldPos()

		return voxel.GetAttachment(ent.Model, pos, ang, offset.Scale, "Muzzle")
	end
end

function EFFECT:Think()
	self.Alpha = self.Alpha - FrameTime() * 2048

	if self.Alpha < 0 then
		return false
	end

	return true
end

function EFFECT:Render()
	if self.Alpha < 1 then
		return
	end

	local length = (self.Start - self.End):Length()
	local texcoord = math.Rand(0, 1)

	local start = self:GetStartPos(self.Ent)

	render.SetMaterial(self.Mat)
	render.DrawBeam(start, self.End, 8, texcoord, texcoord + length / 128, self.Color)
end