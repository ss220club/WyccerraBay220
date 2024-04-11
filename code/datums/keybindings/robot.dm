/datum/keybinding/robot
	category = KEYBIND_CATEGORY_ROBOT

/datum/keybinding/robot/can_use(client/user)
	return isrobot(user.mob)

/datum/keybinding/robot/moduleone
	name = "module_one"
	full_name = "Toggle Module 1"
	description = "Equips or unequips the first module"
	hotkey_keys = list("1")

/datum/keybinding/robot/moduleone/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.toggle_module(1)
	return TRUE

/datum/keybinding/robot/moduletwo
	name = "module_two"
	full_name = "Toggle Module 2"
	description = "Equips or unequips the second module"
	hotkey_keys = list("2")

/datum/keybinding/robot/moduletwo/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.toggle_module(2)
	return TRUE

/datum/keybinding/robot/modulethree
	name = "module_three"
	full_name = "Toggle Module 3"
	description = "Equips or unequips the third module"
	hotkey_keys = list("3")

/datum/keybinding/robot/modulethree/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.toggle_module(3)
	return TRUE

/datum/keybinding/robot/intent_cycle
	name = "cycle_intent"
	full_name = "Cycle Intent Left"
	description = "Cycles the intent left"
	hotkey_keys = list("4")

/datum/keybinding/robot/intent_cycle/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/robot/module_cycle
	name = "cycle_modules"
	full_name = "Cycle Modules"
	description = "Cycles your modules"
	hotkey_keys = list("X")

/datum/keybinding/robot/module_cycle/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.cycle_modules()
	return TRUE

/datum/keybinding/robot/unequip_module
	name = "unequip_module"
	full_name = "Unequip Module"
	description = "Unequips the active module"
	hotkey_keys = list("Q")

/datum/keybinding/robot/unequip_module/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	if(R.module)
		R.uneq_active()
	return TRUE
