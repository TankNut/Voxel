AddCSLuaFile()

ENT.RenderGroup 			= RENDERGROUP_TRANSLUCENT

ENT.Base 					= "voxel_proj_base"

ENT.Author 					= "TankNut"

ENT.Spawnable 				= false
ENT.AdminSpawnable 			= false

ENT.AutomaticFrameAdvance	= true

ENT.Velocity 				= 6608

ENT.UseGravity 				= false

ENT.Length 					= 64

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:DrawShadow(false)

	if CLIENT then
		local pos = self:GetPos()
		local mins, maxs = pos, pos + (self:GetForward() * -self.Length)

		OrderVectors(mins, maxs)

		self:SetRenderBoundsWS(mins, maxs)
	end
end

if SERVER then
	function ENT:OnHit()
		self:FireBullets({
			Src = self:GetPos(),
			Dir = self:GetForward(),
			Attacker = self:GetOwner(),
			Spread = Vector(0, 0, 0),
			Tracer = 0,
			Damage = 16,
			Callback = function(attacker, tr, dmg)
				dmg:SetDamageType(DMG_ENERGYBEAM)
			end
		})
	end
end

if CLIENT then
	local mat = Material("effects/voxel/plasma_bolt")
	local sprite = Material("effects/energyball")

	function ENT:DrawTranslucent()
		if self.StopRender then
			return
		end

		local origin = self:GetPos()

		if origin:Distance(self:GetOwner():GetShootPos()) < self.Length * 2 then
			return
		end

		local length = self.Length
		local stop = self:GetStopPos()

		if stop != vector_origin and stop == origin then
			self.StopRender = true
		end

		render.SetMaterial(mat)
		render.DrawBeam(origin, origin + (self:GetForward() * -length), 8, 0, 1)

		local pos = origin + (self:GetForward() * -16)

		render.SetMaterial(sprite)
		render.DrawSprite(pos, 8, 8)
		render.DrawSprite(pos, 8, 8)
	end
end