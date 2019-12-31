EFFECT.Mat = Material("models/effects/splodearc_sheet")

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

	local normal = (self.Start - self.End):Angle():Forward()

	self:SetRenderBoundsWS(self.Start, self.End)

	self.DieTime = CurTime() + 0.1

	self.Color = Color(97, 245, 194)

	local dynlight = DynamicLight(0)
	dynlight.Pos = self.End + normal * 10
	dynlight.Size = 100
	dynlight.Brightness = 1
	dynlight.Decay = 3000
	dynlight.R = self.Color.r
	dynlight.G = self.Color.g
	dynlight.B = self.Color.b
	dynlight.DieTime = CurTime() + 0.1

	dynlight = DynamicLight(0)
	dynlight.Pos = self.Start
	dynlight.Size = 100
	dynlight.Brightness = 1
	dynlight.Decay = 3000
	dynlight.R = self.Color.r
	dynlight.G = self.Color.g
	dynlight.B = self.Color.b
	dynlight.DieTime = CurTime() + 0.1
end

function EFFECT:GetStartPos(ent)
	if ent:IsCarriedByLocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then
		local pos, ang = ent:GetVMPos()
		local pos1 = ent:GetMuzzlePos(pos, ang)

		return translatefov(ent, pos1)
	else
		local pos, ang = ent:GetWorldPos()

		return ent:GetMuzzlePos(pos, ang)
	end
end

function EFFECT:Think()
	if not self.DieTime or CurTime() > self.DieTime then
		return false
	end

	return true
end

function EFFECT:Render()
	local start = self:GetStartPos(self.Ent)

	render.SetMaterial(self.Mat)
	render.DrawBeam(start, self.End, 10, 0, 0, self.Color)
end