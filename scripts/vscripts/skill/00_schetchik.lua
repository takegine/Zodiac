my_schetchik = class({})
LinkLuaModifier( "mod_schetchik", "skill/00_schetchik", LUA_MODIFIER_MOTION_NONE )

function my_schetchik:GetIntrinsicModifierName()
	return "mod_schetchik"
end

----------------------------------------------------------------------

mod_schetchik = class({})

function mod_schetchik:IsHidden()  return true end

function mod_schetchik:IsPurgable()	return false end

function mod_schetchik:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function mod_schetchik:OnTakeDamage(event)--记录伤害用的
    
    local atthero = event.attacker:IsRealHero() and event.attacker or event.attacker:GetPlayerOwnerID() and PlayerResource:GetSelectedHeroEntity(event.attacker:GetPlayerOwnerID())

    if  atthero and atthero ~= event.unit and not event.unit:IsIllusion() then
        atthero.damage_schetchik = ( atthero.damage_schetchik or 0 ) + event.damage
    end

    atthero.fist_dam_time = atthero.fist_dam_time or GameRules:GetGameTime()

    atthero.dam_dps = atthero.damage_schetchik/(GameRules:GetGameTime()-atthero.fist_dam_time+1)
end