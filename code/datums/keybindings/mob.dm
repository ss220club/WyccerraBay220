/datum/keybinding/mob
	category = KEYBIND_CATEGORY_HUMAN

/datum/keybinding/mob/can_use(client/user)
	return ismob(user.mob) ? TRUE : FALSE

/datum/keybinding/mob/cycle_intent_right
	name = "cycle_intent_right"
	full_name = "Сycle Intent: Right"
	description = ""
	hotkey_keys = list("G")

/datum/keybinding/mob/cycle_intent_right/down(client/user)
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE

/datum/keybinding/mob/cycle_intent_left
	name = "cycle_intent_left"
	full_name = "Сycle Intent: Left"
	description = ""
	hotkey_keys = list("F")

/datum/keybinding/mob/cycle_intent_left/down(client/user)
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/mob/activate_inhand
	name = "activate_inhand"
	full_name = "Activate In-Hand"
	description = "Uses whatever item you have inhand"
	hotkey_keys = list("Z")

/datum/keybinding/mob/activate_inhand/down(client/user)
	var/mob/M = user.mob
	M.mode()
	return TRUE

/datum/keybinding/mob/target_head_cycle
	name = "target_head_cycle"
	full_name = "Target: Cycle Head"
	description = ""
	hotkey_keys = list("Numpad8")

/datum/keybinding/mob/target_head_cycle/down(client/user)
	user.body_toggle_head()
	return TRUE

/datum/keybinding/mob/target_r_arm
	name = "target_r_arm"
	full_name = "Target: Right Arm"
	description = ""
	hotkey_keys = list("Numpad4")

/datum/keybinding/mob/target_r_arm/down(client/user)
	user.body_r_arm()
	return TRUE

/datum/keybinding/mob/target_body_chest
	name = "target_body_chest"
	full_name = "Target: Body"
	description = ""
	hotkey_keys = list("Numpad5")

/datum/keybinding/mob/target_body_chest/down(client/user)
	user.body_chest()
	return TRUE

/datum/keybinding/mob/target_left_arm
	name = "target_left_arm"
	full_name = "Target: Left Arm"
	description = ""
	hotkey_keys = list("Numpad6")

/datum/keybinding/mob/target_left_arm/down(client/user)
	user.body_l_arm()
	return TRUE

/datum/keybinding/mob/target_right_leg
	name = "target_right_leg"
	full_name = "Target: Right leg"
	description = ""
	hotkey_keys = list("Numpad1")

/datum/keybinding/mob/target_right_leg/down(client/user)
	user.body_r_leg()
	return TRUE

/datum/keybinding/mob/target_body_groin
	name = "target_body_groin"
	full_name = "Target: Groin"
	description = ""
	hotkey_keys = list("Numpad2")

/datum/keybinding/mob/target_body_groin/down(client/user)
	user.body_groin()
	return TRUE

/datum/keybinding/mob/target_left_leg
	name = "target_left_leg"
	full_name = "Target: Left Leg"
	description = ""
	hotkey_keys = list("Numpad3")

/datum/keybinding/mob/target_left_leg/down(client/user)
	user.body_l_leg()
	return TRUE

/datum/keybinding/mob/move_up
	name = "move_up"
	full_name = "Move Up"
	description = "Makes you go up"
	hotkey_keys = list(",", "=")

/datum/keybinding/mob/move_up/down(client/user)
	var/mob/M = user.mob
	M.move_up()

/datum/keybinding/mob/move_down
	name = "move_down"
	full_name = "Move Down"
	description = "Makes you go down"
	hotkey_keys = list(".", "-")

/datum/keybinding/mob/move_down/down(client/user)
	var/mob/M = user.mob
	M.down()

/datum/keybinding/mob/toggle_gun_mode
	name = "toggle_gun_mode"
	full_name = "Toggle Gun Mode"
	hotkey_keys = list("J")

/datum/keybinding/mob/toggle_gun_mode/down(client/user)
	var/mob/M = user.mob
	M.toggle_gun_mode()
