LinkLuaModifier("modifier_item_bracer_of_chaos_resist_discrease", "items/item_bracer_of_chaos", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bracer_of_chaos_slow", "items/item_bracer_of_chaos", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_bracer_of_chaos", "items/item_bracer_of_chaos", LUA_MODIFIER_MOTION_NONE)

item_bracer_of_chaos = class({
	GetIntrinsicModifierName = function() return "modifier_item_bracer_of_chaos" end,
})

if IsServer() then
	function item_bracer_of_chaos:OnSpellStart()
		local target = self:GetCursorTarget()
		if not target:TriggerSpellAbsorb(self) then
			target:TriggerSpellReflect(self)
			target:AddNewModifier(self:GetCaster(), self, "modifier_item_bracer_of_chaos_resist_discrease", {duration = self:GetSpecialValueFor("discrease_duration")})
		end
	end
end

modifier_item_bracer_of_chaos = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_bracer_of_chaos:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_bracer_of_chaos:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end
function modifier_item_bracer_of_chaos:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
function modifier_item_bracer_of_chaos:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_bracer_of_chaos:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_bracer_of_chaos:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

modifier_item_bracer_of_chaos_resist_discrease = class({
	IsDebuff = function() return true end,
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
	IsPurgable    = function() return false end,
})

function modifier_item_bracer_of_chaos_resist_discrease:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_item_bracer_of_chaos_resist_discrease:OnCreated()
	self.ArmorReduction = self:GetAbility():GetSpecialValueFor("armor_reduction_pct") * self:GetParent():GetPhysicalArmorValue() * 0.01
end

function modifier_item_bracer_of_chaos_resist_discrease:GetModifierPhysicalArmorBonus() 
	return self.ArmorReduction
end

function modifier_item_bracer_of_chaos_resist_discrease:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("resist_reduction_pct")
end

if IsServer() then
	function modifier_item_bracer_of_chaos:OnCreated()
		self:GetParent():UpdateAttackProjectile()
	end

	function modifier_item_bracer_of_chaos:OnDestroy()
		self:GetParent():UpdateAttackProjectile()
	end

	function modifier_item_bracer_of_chaos:OnAttackLanded(keys)
		local target = keys.target
		local attacker = keys.attacker
		if attacker == self:GetParent() then
			local ability = self:GetAbility()
			if not (target.IsBoss and target:IsBoss()) then
				target:AddNewModifier(attacker, ability, "modifier_item_bracer_of_chaos_slow", {duration = ability:GetSpecialValueFor("slow_duration")})
			end
		end
	end
end


modifier_item_bracer_of_chaos_slow = class({
	IsDebuff =            function() return true end,
	GetStatusEffectName = function() return "particles/status_fx/status_effect_frost_lich.vpcf" end,
})

function modifier_item_bracer_of_chaos_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_item_bracer_of_chaos_slow:GetModifierAttackSpeedBonus_Constant()
	return -self:GetAbility():GetSpecialValueFor("attack_speed_slow")
end

function modifier_item_bracer_of_chaos_slow:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("movement_slow_pct")
end