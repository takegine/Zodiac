item_relic_armors = class({})


function item_relic_armors:GetIntrinsicModifierName()
	return "modifier_item_relic_armors"
end

--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_item_relic_armors","items/item_relic_armors", LUA_MODIFIER_MOTION_NONE )
modifier_item_relic_armors = class({})
--------------------------------------------------------------------------------

function modifier_item_relic_armors:IsHidden() return false end
function modifier_item_relic_armors:IsPurgable()	return false end
function modifier_item_relic_armors:GetTexture () return "custom/relic_armor" end

----------------------------------------

function modifier_item_relic_armors:OnCreated( kv )
    self.needupwawe = true
    if self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_armor_for_wawe" )
    end
	if IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

function modifier_item_relic_armors:OnWaweChange( wawe )
	if  not IsServer() then return end
    self.wave = wawe

    local level = self:GetCaster().lvl_item_relic_damage or 1
    local count = math.ceil(self.bonus_damage_for_wawe * self.wave * Clamp(level, 1, 20)  )
    self:SetStackCount(count)
end
----------------------------------------

function modifier_item_relic_armors:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

----------------------------------------

function modifier_item_relic_armors:GetModifierPhysicalArmorBonus( params )
    return self:GetStackCount()
end

function modifier_item_relic_armors:OnTakeDamage( params )
    if IsServer()
    and params.unit == self:GetParent() 
    and not self:GetParent():IsIllusion()
    then
        self.taken_damage = params.damage + ( self.taken_damage or 0 )
        if  self.taken_damage >= self:GetParent():GetMaxHealth()/10 then
            self.taken_damage = 0
            local heroes = HeroList:GetAllHeroes()
            for i = #heroes, 1, -1 do
                if not heroes[i]:IsAlive() then
                    table.remove( heroes, i)
                end
            end
            heroes[RandomInt( 1, #heroes )]:AddNewModifier(self:GetCaster(), nil, "modifier_my_relic_armor", {duration = 5})
        end
    end
	return 0
end

----------------------------------------
LinkLuaModifier( "modifier_my_relic_armor", "items/item_relic_armors", LUA_MODIFIER_MOTION_NONE )
modifier_my_relic_armor = class({})
function modifier_my_relic_armor:IsHidden() return false end
function modifier_my_relic_armor:IsDebuff() return false end
function modifier_my_relic_armor:IsPurgable() return false end
function modifier_my_relic_armor:RemoveOnDeath() return false end
function modifier_my_relic_armor:GetTexture () return "custom/relic_armor" end

function modifier_my_relic_armor:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_armor_friend_shield.vpcf"
end

function modifier_my_relic_armor:GetEffectAttachType() 
    return PATTACH_OVERHEAD_FOLLOW 
end

function modifier_my_relic_armor:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_my_relic_armor:GetModifierPhysicalArmorBonus()
	return 3
end