local override = Material("engine/occlusionproxy")
local aimpoint = Material("reticles/eotech_reddot")

function SWEP:DrawAimpoint(pos, ang, scale)
	render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(15)

		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		render.SetStencilCompareFunction(STENCIL_ALWAYS)

		local attpos, attang = voxel.GetAttachment(self.Model, pos, ang, scale, "Aimpoint")

		render.SetColorMaterial()
		render.DrawQuadEasy(attpos, -attang:Forward(), scale, scale, ColorAlpha(color_white, 0))

		render.SetStencilCompareFunction(STENCIL_EQUAL)

		render.SetMaterial(aimpoint)
		render.DrawQuadEasy(attpos + (attang:Forward() * 200), -EyeAngles():Forward(), 5, 5, Color(255, 0, 0), -ang.r)
	render.SetStencilEnable(false)
	render.ClearStencil()
end

function SWEP:GetViewModelPosition()
	return self:GetVMPos()
end

function SWEP:PreDrawViewModel()
	render.ModelMaterialOverride(override)
end

function SWEP:PostDrawViewModel()
	render.ModelMaterialOverride()

	local pos, ang = self:GetVMPos()
	local offset = self.VMOffset

	voxel.Draw(self.Model, pos, ang, offset.Scale)

	if voxel.HasAttachment(self.Model, "Aimpoint") then
		self:DrawAimpoint(pos, ang, offset.Scale)
	end
end

function SWEP:GetWorldPos()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	if IsValid(self.Owner) then
		local index = self.Owner:LookupAttachment("anim_attachment_RH")
		local att = self.Owner:GetAttachment(index)

		if istable(att) then
			pos = att.Pos + self.WMOffset
			ang = att.Ang + Angle(-10, 0, -5)
		end
	end

	return pos, ang
end

function SWEP:DrawWorldModel()
	render.ModelMaterialOverride(override)
	self:DrawModel()
	render.ModelMaterialOverride()

	local pos, ang = self:GetWorldPos()

	voxel.Draw(self.Model, pos, ang, self.VMOffset.Scale)
end