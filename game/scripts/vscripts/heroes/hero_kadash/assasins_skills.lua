LinkLuaModifier("modifier_kadash_assasins_skills", "heroes/hero_kadash/assasins_skills.lua", LUA_MODIFIER_MOTION_NONE)

kadash_assasins_skills = class({GetIntrinsicModifierName = function() return "modifier_kadash_assasins_skills" end})

modifier_kadash_assasins_skills = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	} end
})

if IsServer() then
	function modifier_kadash_assasins_skills:GetModifierDamageOutgoing_Percentage()
		return self:GetAbility():GetSpecialValueFor("all_damage_bonus_pct")
	end
	
	function modifier_kadash_assasins_skills:OnAttackLanded(keys)
		if self.order_strike then 
			local attacker = keys.attacker
			local target = keys.target
			if attacker == self:GetCaster() then
				local ability = self:GetAbility()
				
				attacker:EmitSound("Arena.Hero_Kadash.AssasinsSkills.Critical")
				local particle = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_kadash/assasins_skills_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN, attacker)
				ParticleManager:SetParticleControlEnt(particle, 0, attacker, PATTACH_POINT_FOLLOW, "attach_attack1", attacker:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particle)
				self.order_strike = false
			end
		end
	end
	
	function modifier_kadash_assasins_skills:GetModifierPreAttack_CriticalStrike()
		self.order_strike = RandomInt(0, 100) <= self:GetAbility():GetSpecialValueFor("crit_chance")
		if self.order_strike then
			return self:GetAbility():GetSpecialValueFor("crit_mult")
		end
	end
end
