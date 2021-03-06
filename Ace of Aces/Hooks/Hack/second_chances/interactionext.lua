SpecialHackLock_interact = SpecialHackLock_interact or UseInteractionExt.interact
SpecialHackLock_interact_start = SpecialHackLock_interact_start or UseInteractionExt.interact_start
SpecialHackLock_post_event = SpecialHackLock_post_event or UseInteractionExt._post_event
SpecialHackLock_selected = SpecialHackLock_selected or UseInteractionExt.selected
SpecialHackLock_can_select = SpecialHackLock_can_select or UseInteractionExt.can_select
SpecialHackLock_can_interact = SpecialHackLock_can_interact or UseInteractionExt.can_interact

AceAces.UseHackKeycard = AceAces.UseHackKeycard or true

function SpecialHackLock_SkillAA()
	return managers.player:has_category_upgrade("player", "pick_lock_so_hard")
end

function SpecialHackLock_ChancgeList(id)
	if tweak_data.interaction and type(tweak_data.interaction[id]) == "table" and type(tweak_data.interaction[id].special_equipment) == "string" and tweak_data.interaction[id].special_equipment == "bank_manager_key" then
		return true
	end
	return false
end

function SpecialHackLock_CheckList(id)
	return SpecialHackLock_ChancgeList(id)
end

function SpecialHackLock_can_hack_keycard(them)
	if not AceAces.UseHackKeycard then
		return false
	end
	if type(them) == "table" and them.tweak_data and SpecialHackLock_CheckList(them.tweak_data) then
		return SpecialHackLock_SkillAA()
	end
	return false
end

function UseInteractionExt:can_select(...)
	if SpecialHackLock_can_hack_keycard(self) then
		return true
	end
	return SpecialHackLock_can_select(self, ...)
end

function UseInteractionExt:_timer_value()
	if SpecialHackLock_can_hack_keycard(self) then
		return tweak_data.interaction.hack_keycard.timer
	end
	return self._tweak_data.timer
end

function UseInteractionExt:interact_start(player, ...)
	if SpecialHackLock_can_hack_keycard(self) then
		local blocked, skip_hint, custom_hint = self:_interact_blocked(player)
		local tweak_timer = tweak_data.interaction.hack_keycard.timer or 0
		local has_equipment = not self._tweak_data.special_equipment and true or managers.player:has_special_equipment(self._tweak_data.special_equipment)
		if blocked then
			if not skip_hint and (custom_hint or self._tweak_data.blocked_hint) then
				managers.hint:show_hint(custom_hint or self._tweak_data.blocked_hint)
			end
			return false
		end
		if tweak_timer > 0 and not has_equipment then
			if not self:can_interact(player) then
				if self._tweak_data.blocked_hint then
					managers.hint:show_hint(self._tweak_data.blocked_hint)
				end
				return false
			end
			local run_time = self:_get_timer()
			if run_time > 0 then
				self:_at_interact_start(player, run_time)
				self._tweak_data_at_interact_start = tweak_data.interaction.hack_keycard
				return false, run_time
			end
		end
	end
	return SpecialHackLock_interact_start(self, player, ...)
end

function UseInteractionExt:selected(...)
	if SpecialHackLock_can_hack_keycard(self) then
		local has_equipment = not self._tweak_data.special_equipment and true or managers.player:has_special_equipment(self._tweak_data.special_equipment)
		if not has_equipment then
			managers.hud:show_interact({
				text = managers.localization:text(tweak_data.interaction.hack_keycard.text_id),
				icon = self.no_equipment_icon or self._tweak_data.no_equipment_icon or self._tweak_data.icon
			})
		end
	end
	return SpecialHackLock_selected(self, ...)
end

function UseInteractionExt:_post_event(...)
	if SpecialHackLock_can_hack_keycard(self) then
		return
	end
	return SpecialHackLock_post_event(self, ...)
end

Hooks:PostHook(UseInteractionExt, "_at_interact_start", 'SpecialHackLock_at_interact_start', function(self, player)
	if SpecialHackLock_can_hack_keycard(self) then
		player:base():set_detection_multiplier("hack_keycard", 0.5)
	end
end)

Hooks:PostHook(UseInteractionExt, "_at_interact_interupt", 'SpecialHackLock_interact_interupt', function(self, player)
	if SpecialHackLock_can_hack_keycard(self) then
		player:base():set_detection_multiplier("hack_keycard", 0.5)
	end
end)

function UseInteractionExt:interact(player, ...)
	if SpecialHackLock_can_hack_keycard(self) then
		if not self:can_interact(player) then
			return
		end
		if self.tweak_data == "hack_keycard" then
			if self._unit and alive(self._unit) and self._unit:base() then
				self._unit:base():device_completed("key")
				return true
			end
		elseif SpecialHackLock_ChancgeList(self.tweak_data) then
			self:remove_interact()
			if self._unit:damage() then
				self._unit:damage():run_sequence_simple("interact", {unit = player})
			end
			managers.network:session():send_to_peers_synched("sync_interacted", self._unit, -2, self.tweak_data, 1)
			if self._global_event then
				managers.mission:call_global_event(self._global_event, player)
			end
			self:set_active(false)
			return true
		end
	end
	return SpecialHackLock_interact(self, player, ...)
end

function UseInteractionExt:can_interact(player, ...)
	if SpecialHackLock_can_hack_keycard(self) then
		if self._host_only and not Network:is_server() then
			return false
		end
		if self._disabled then
			return false
		end
		if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
			return false
		end
		if not self:_has_required_deployable() then
			return false
		end
		if not self:_is_in_required_state(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
			return false
		end
		return true
	end
	return SpecialHackLock_can_interact(self, player, ...)
end