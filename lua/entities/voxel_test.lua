AddCSLuaFile()

ENT.RenderGroup 			= RENDERGROUP_BOTH

ENT.Base 					= "base_anim"
ENT.Type 					= "anim"

ENT.Author 					= "TankNut"

ENT.Spawnable 				= true
ENT.AdminSpawnable			= true

ENT.Model 					= "smg"
ENT.Scale 					= 1

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/props_junk/PopCan01a.mdl")

		self:PhysicsInitConvex(voxel.GetConvexHull(self.Model, self.Scale))
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:EnableCustomCollisions(true)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end
	end

	if CLIENT then
		self:SetRenderBounds(voxel.GetRenderBounds(self.Model, self.Scale))
	end

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

if CLIENT then
	function ENT:Draw()
		--render.OverrideDepthEnable(true, true)
		self:DrawModel()
		--render.OverrideDepthEnable(false, true)

		voxel.DrawDebug(self.Model, self:GetPos(), self:GetAngles(), self.Scale, self)
	end

	function ENT:GetRenderMesh()
		local data = voxel.Models[self.Model]
		local matrix = Matrix()

		matrix:SetAngles(data.Angle)
		matrix:SetScale(Vector(self.Scale, self.Scale, self.Scale))

		return {
			Mesh = data.Mesh,
			Material = Material("!voxel_" .. self.Model),
			--Material = Material("models/props_c17/FurnitureFabric003a"),
			Matrix = matrix
		}
	end

	function ENT:OnReloaded()
		self:SetRenderBounds(voxel.GetRenderBounds(self.Model, self.Scale))
	end
end