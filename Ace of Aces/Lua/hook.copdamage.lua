Hooks:PostHook(CopDamage, "damage_simple", "AA_Graze_Taser_Effect", function(self, attack_data)
	if self._dead or self._invulnerable then
		return
	end
	if not managers.player:has_category_upgrade("snp", "graze_taser_effect") then
		return
	end
	if not attack_data or not attack_data.variant or attack_data.variant ~= "graze" or not attack_data.attacker_unit or not alive(attack_data.attacker_unit) or attack_data.attacker_unit ~= managers.player:player_unit() then
		return
	end
	local col_ray = {
		ray = (attack_data.attacker_unit:position() - self._unit:position()):normalized(),
		position = self._unit:position()
	}
	attack_data.damage = 0
	attack_data.weapon_unit = attack_data.attacker_unit:inventory():equipped_unit()
	attack_data.armor_piercing = true
	attack_data.col_ray = col_ray
	attack_data.attack_dir = col_ray.ray
	attack_data.variant = "heavy"
	self:damage_tase(attack_data)
end)

Hooks:PostHook(CopDamage, "convert_to_criminal", "AA_joker_temp_invulnerable_init", function(self)
	if managers.player:has_category_upgrade("temporary", "joker_temp_invulnerable") then
		self._is_joker_temp_invulnerable = true
		self._time_joker_temp_invulnerable = nil
	end
end)

Hooks:PostHook(CopDamage, "_apply_damage_to_health", "AA_joker_temp_invulnerable_run", function(self, damage)
	if self._is_joker_temp_invulnerable and not self._time_joker_temp_invulnerable then
		self._time_joker_temp_invulnerable = managers.player:upgrade_value("temporary", "joker_temp_invulnerable", 0)
		self:set_invulnerable(true)
	end
end)