local override = Material("engine/occlusionproxy")
local aimpoint = Material("reticles/eotech_reddot")

function SWEP:DrawAimpoint(pos, ang, scale)
	if halo.RenderedEntity() == self then
		return
	end

	render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(15)

		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		render.SetStencilCompareFunction(STENCIL_ALWAYS)

		local attpos, attang = voxel.GetPos(self.Model, pos, ang, scale, "Aimpoint")

		render.SetColorMaterial()
		render.DrawQuadEasy(attpos, -attang:Forward(), scale, scale, ColorAlpha(color_white, 0))

		render.SetStencilCompareFunction(STENCIL_EQUAL)

		render.SetMaterial(aimpoint)
		render.DrawQuadEasy(attpos + (attang:Forward() * 200), -EyeAngles():Forward(), 5, 5, Color(255, 0, 0), -ang.r)
	render.SetStencilEnable(false)
	render.ClearStencil()
end

function SWEP:DrawVoxelModel(pos, ang, scale)
	voxel.Draw(self.Model, pos, ang, scale)

	if voxel.HasAttachment(self.Model, "Aimpoint") then
		self:DrawAimpoint(pos, ang, scale)
	end

	self:DrawAttachments(pos, ang, scale)
end

function SWEP:DrawAttachments(pos, ang, scale)
	for _, v in pairs(self.Attachments) do
		local drawpos, drawang = voxel.GetPos(self.Model, pos, ang, scale, v.Attachment, v.Pos, v.Ang)

		voxel.Draw(v.Model, drawpos, drawang, scale * (v.Scale or 1))
	end
end

function SWEP:GetMuzzlePos(pos, ang)
	return voxel.GetPos(self.Model, pos, ang, self.VMOffset.Scale, "Muzzle")
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

	self:DrawVoxelModel(pos, ang, self.VMOffset.Scale)
end

function SWEP:DrawWorldModel()
	render.ModelMaterialOverride(override)
	self:DrawModel()
	render.ModelMaterialOverride()

	local pos, ang = self:GetWorldPos()

	self:DrawVoxelModel(pos, ang, self.VMOffset.Scale)
end