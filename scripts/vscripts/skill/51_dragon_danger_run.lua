dragon_danger_run = class({})
LinkLuaModifier( "modifier_dragon_danger_run", "modifiers/modifier_dragon_danger_run", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function dragon_danger_run:OnAbilityPhaseStart()
	if IsServer() then
		self.channel_duration = self:GetSpecialValueFor( "channel_duration" )
		local fImmuneDuration = self.channel_duration + self:GetCastPoint()
        
        self.nPreviewFX = ParticleManager:CreateParticle( "particles/darkmoon_creep_warning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControl( self.nPreviewFX, 1, Vector( 250, 250, 250 ) )
		ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 176, 224, 230 ) )
	end

	return true
end

--------------------------------------------------------------------------------

function dragon_danger_run:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end 
end

-----------------------------------------------------------------------------

function dragon_danger_run:OnSpellStart()
	if IsServer() then	
		ParticleManager:DestroyParticle( self.nPreviewFX, false )

		self.effect_radius = self:GetSpecialValueFor( "effect_radius" )
		self.interval = self:GetSpecialValueFor( "interval" )
		self:GetCaster().castult = true
		--self.flNextCast = 0.0

		EmitSoundOn( "TempleGuardian.Wrath.Cast", self:GetCaster() )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_omninight_guardian_angel", {} )
        
		--local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
		--ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.effect_radius, self.channel_duration, 0.0 ) )
		--ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

-----------------------------------------------------------------------------

function dragon_danger_run:OnChannelThink( flInterval )
	if IsServer() then
		--self.flNextCast = self.flNextCast + flInterval
		--if self.flNextCast >= self.interval  then

			-- Try not to overlap wrath_thinker locations, but use the last position attempted if we spend too long in the loop
		--for i=1, 2 do
			
			local nMaxAttempts = 10
			local nAttempts = 0
			local vPos = nil

			repeat
				vPos = self:GetCaster():GetOrigin() + RandomVector( RandomInt( 50, self.effect_radius ) )
				local hThinkersNearby = Entities:FindAllByClassnameWithin( "npc_dota_thinker", vPos, 800 )
				local hOverlappingWrathThinkers = {}

				for _, hThinker in pairs( hThinkersNearby ) do
					if ( hThinker:HasModifier( "modifier_dragon_danger_run" ) ) then
						table.insert( hOverlappingWrathThinkers, hThinker )
					end
				end
				nAttempts = nAttempts + 1
				if nAttempts >= nMaxAttempts then
					break
				end
			until ( #hOverlappingWrathThinkers == 0 )

			CreateModifierThinker( self:GetCaster(), self, "modifier_dragon_danger_run", {}, vPos, self:GetCaster():GetTeamNumber(), false )

		--end
		--	self.flNextCast = self.flNextCast - self.interval
		--end
		
	end
end

-----------------------------------------------------------------------------

function dragon_danger_run:OnChannelFinish( bInterrupted )
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_omninight_guardian_angel" )
	end
end

-----------------------------------------------------------------------------