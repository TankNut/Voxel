AddCSLuaFile()

ENT.RenderGroup 			= RENDERGROUP_OPAQUE

ENT.Base 					= "base_anim"
ENT.Type 					= "anim"

ENT.Author 					= "TankNut"

ENT.Spawnable 				= true
ENT.AdminSpawnable			= true

ENT.Model 					= "smg"
ENT.Scale 					= 1

function ENT:Initialize()
	local mins, maxs = voxel.GetHull(self.Model, self.Scale)

	self.PhysCollide = CreatePhysCollideBox(mins, maxs)
	self:SetCollisionBounds(mins, maxs)

	if SERVER then
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")

		self:PhysicsInitBox(mins, maxs)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end
	end

	if CLIENT then
		self:SetRenderBounds(mins, maxs)
	end

	self:DrawShadow(false)

	self:EnableCustomCollisions(true)
	--self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

if SERVER then
	function ENT:OnTakeDamage(dmg)
		debugoverlay.Cross(dmg:GetDamagePosition(), 1)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

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
			Matrix = matrix
		}
	end

	function ENT:OnReloaded()
		self:SetRenderBounds(voxel.GetHull(self.Model, self.Scale))
	end
end

function ENT:TestCollision(start, delta, isbox, extends)
	if not IsValid(self.PhysCollide) then
		return
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), start, start + delta, min, max)

	if not hit then
		return
	end

	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac
	}
end