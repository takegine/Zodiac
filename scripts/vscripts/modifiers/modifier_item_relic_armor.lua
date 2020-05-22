LinkLuaModifier( "modifier_my_relic_armor", "modifiers/modifier_item_relic_armor", LUA_MODIFIER_MOTION_NONE )

modifier_item_relic_armor = class({})
--------------------------------------------------------------------------------

function modifier_item_relic_armor:IsHidden() 
	return false
end

--------------------------------------------------------------------------------

function modifier_item_relic_armor:IsPurgable()
	return false
end

function modifier_item_relic_armor:GetTexture ()
    return "custom/relic_armor"
end

----------------------------------------

function modifier_item_relic_armor:OnCreated( kv )
    self.needupwawe = true
    if self:GetAbility() ~= nil then
        self.bonus_damage_for_wawe = self:GetAbility():GetSpecialValueFor( "bonus_armor_for_wawe" )
    end
	if IsServer() then
        self:OnWaweChange(_G.GAME_ROUND)
    end
end

----------------------------------------

function modifier_item_relic_armor:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

----------------------------------------

function modifier_item_relic_armor:OnWaweChange( wawe )
	if IsServer() then
        self.wave = wawe
        local damag = 0
        if self:GetCaster().lvl_item_relic_armor ~= nil then
            if self:GetCaster().lvl_item_relic_armor >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_armor)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_armor = 1
        end
    end
end

function modifier_item_relic_armor:GetModifierPhysicalArmorBonus( params )
	if IsServer() then
        local damag = 0
        if self:GetCaster().lvl_item_relic_armor ~= nil then
            if self:GetCaster().lvl_item_relic_armor >= 20 then
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * 20)
            else
                damag = math.floor(self.bonus_damage_for_wawe * self.wave * self:GetCaster().lvl_item_relic_armor)
            end
            if damag ~= self:GetStackCount() then
                self:SetStackCount(damag)
            end
        else
            self:GetCaster().lvl_item_relic_armor = 1
        end
    end
    return self:GetStackCount()
end

function modifier_item_relic_armor:OnTakeDamage( params )
	if IsServer() then
        if params.unit == self:GetParent() then
            if self.taken_damage == nil then
                self.taken_damage = 0
            end
            self.taken_damage = self.taken_damage + params.damage
            local maax = self:GetParent():GetMaxHealth()/10
            if self.taken_damage >= maax and ( not self:GetParent():IsIllusion() ) then
                self.taken_damage = 0
                local heroes = HeroList:GetAllHeroes()
                local list = {}
                for i=1, #heroes do
                    if heroes[i]:IsAlive() then
                        table.insert( list, heroes[i] )
                    end
                end
                list[RandomInt( 1, #list )]:AddNewModifier(self:GetCaster(), nil, "modifier_my_relic_armor", {duration = 5})
            end
        end
	end

	return 0
end

modifier_my_relic_armor = class({})
function modifier_my_relic_armor:IsHidden() return false end
function modifier_my_relic_armor:IsDebuff() return false end
function modifier_my_relic_armor:IsPurgable() return false end
function modifier_my_relic_armor:RemoveOnDeath() return false end
function modifier_my_relic_armor:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_armor_friend_shield.vpcf"
end
function modifier_my_relic_armor:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_my_relic_armor:GetTexture ()
    return "custom/relic_armor"
end

function modifier_my_relic_armor:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_my_relic_armor:GetModifierPhysicalArmorBonus()
	return 3
end