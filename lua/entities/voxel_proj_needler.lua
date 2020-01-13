AddCSLuaFile()

ENT.RenderGroup 			= RENDERGROUP_BOTH

ENT.Base 					= "voxel_proj_base"

ENT.Author 					= "TankNut"

ENT.Spawnable 				= false
ENT.AdminSpawnable 			= false

ENT.AutomaticFrameAdvance	= true

ENT.Velocity 				= 2794

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
	function ENT:OnHit(tr)
		self:FireBullets({
			Src = self:GetPos(),
			Dir = self:GetForward(),
			Attacker = self:GetOwner(),
			Spread = Vector(0, 0, 0),
			Tracer = 0,
			Damage = 6,
			Callback = function(attacker, trace, dmg)
				dmg:SetDamageType(DMG_ENERGYBEAM)
			end
		})

		self:SetPos(tr.HitPos)
		self:SetStopPos(tr.HitPos)

		local ent = tr.Entity

		if ent != game.GetWorld() then
			self:SetParent(ent)

			ent.Needles = ent.Needles or {}
			ent.Needles[self] = true

			if table.Count(ent.Needles) > 6 and not ent.BlockSuperCombine then
				ent.BlockSuperCombine = true

				self.SuperCombine = true
			end
		end

		self:NextThink(CurTime() + (self.SuperCombine and 0.35 or 4))
	end

	function ENT:Think()
		if self:GetStopPos() != vector_origin then
			local parent = self:GetParent()

			if IsValid(parent) then
				parent.Needles[self] = nil

				if self.SuperCombine then
					for k in pairs(parent.Needles) do
						if k != self then
							parent.Needles[k] = nil
							k:Remove()
						end
					end

					self:EmitSound("voxel/needler_explode.wav")

					util.BlastDamage(self, self:GetOwner(), self:GetPos(), 30, 350)

					parent.BlockSuperCombine = nil
				end
			end

			if not self.SuperCombine then
				self:EmitSound("voxel/needler_shatter" .. math.random(1, 3) .. ".wav")
			end

			self:Remove()

			return
		end

		self.BaseClass.Think(self)

		return true
	end
end

if CLIENT then
	local sprite = Material("sprites/light_glow02_add")
	local color = Color(220, 0, 255)

	function ENT:Draw()
		render.SetLightingMode(2)
			self:DrawModel()
		render.SetLightingMode(0)
	end

	function ENT:DrawTranslucent()
		local pos = self:GetPos()

		render.SetMaterial(sprite)

		render.DrawSprite(pos, 8, 8, color)
		render.DrawSprite(pos, 8, 8, color)
	end

	function ENT:GetRenderMesh()
		local data = voxel.Models.needle
		local matrix = Matrix()

		matrix:SetAngles(Angle(0, 90, 90))
		matrix:SetScale(Vector(0.5, 0.5, 0.5))

		return {
			Mesh = data.Mesh,
			Material = Material("!voxel_needle"),
			Matrix = matrix
		}
	end
end