AddCSLuaFile()

ENT.RenderGroup 			= RENDERGROUP_OPAQUE

ENT.Base 					= "base_anim"
ENT.Type 					= "anim"

ENT.Author 					= "TankNut"

ENT.Spawnable 				= true
ENT.AdminSpawnable			= true

ENT.Model 					= false
ENT.Scale 					= 1

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")

	for k in SortedPairs(voxel.Models) do
		self:SetVoxelModel(k)

		break
	end

	self:SetupPhysics()

	if SERVER then
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end
	end

	self:DrawShadow(false)
	self:EnableCustomCollisions(true)
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "VoxelModel")
end

function ENT:SetupPhysics()
	local mins, maxs = voxel.GetHull(self:GetVoxelModel(), self.Scale)

	self.PhysCollide = CreatePhysCollideBox(mins, maxs)
	self:SetCollisionBounds(mins, maxs)

	if SERVER then
		self:PhysicsInitBox(mins, maxs)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	if CLIENT then
		self:SetRenderBounds(mins, maxs)
	end
end

if SERVER then
	util.AddNetworkString("nSetVoxelModel")

	net.Receive("nSetVoxelModel", function(_, ply)
		local ent = net.ReadEntity()

		if ply != ent.Editing then
			return
		end

		ent:SetVoxelModel(net.ReadString())
		ent:SetupPhysics()
	end)

	function ENT:Use(ply)
		self.Editing = ply

		net.Start("nSetVoxelModel")
			net.WriteEntity(self)
		net.Send(ply)
	end

	function ENT:OnTakeDamage(dmg)
		debugoverlay.Cross(dmg:GetDamagePosition(), 1)
	end
end

if CLIENT then
	net.Receive("nSetVoxelModel", function()
		local ent = net.ReadEntity()
		local dmenu = DermaMenu()

		for _, v in SortedPairsByValue(table.GetKeys(voxel.Models)) do
			dmenu:AddOption(v, function()
				net.Start("nSetVoxelModel")
					net.WriteEntity(ent)
					net.WriteString(v)
				net.SendToServer()
			end)

			dmenu:Open()
		end
	end)

	function ENT:Draw()
		self:DrawModel()

		if LocalPlayer():GetActiveWeapon():GetClass() != "gmod_camera" then
			voxel.DrawDebug(self:GetVoxelModel(), self:GetPos(), self:GetAngles(), self.Scale, self)
		end
	end

	function ENT:GetRenderMesh()
		local model = self:GetVoxelModel()
		local data = voxel.Models[model]
		local matrix = Matrix()

		matrix:SetAngles(data.Angle)
		matrix:SetScale(Vector(self.Scale, self.Scale, self.Scale))

		return {
			Mesh = data.Mesh,
			Material = Material("!voxel_" .. model),
			Matrix = matrix
		}
	end

	function ENT:OnReloaded()
		self:SetRenderBounds(voxel.GetHull(self:GetVoxelModel(), self.Scale))
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