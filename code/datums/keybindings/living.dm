/datum/keybinding/living
	category = KEYBIND_CATEGORY_HUMAN

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/rest
	name = "rest"
	full_name = "Rest"
	description = "You lay down/get up"
	hotkey_keys = list("ShiftB")

/datum/keybinding/living/rest/down(client/user)
	var/mob/living/L = user.mob
	L.lay_down()
	return TRUE

/datum/keybinding/living/resist
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffed? On fire? Resist!"
	hotkey_keys = list("B")

/datum/keybinding/living/resist/down(client/user)
	var/mob/living/L = user.mob
	L.resist()
	return TRUE

/datum/keybinding/living/drop_item
	name = "drop_item"
	full_name = "Drop Item"
	description = ""
	hotkey_keys = list("Q", "Northwest") // HOME

/datum/keybinding/living/drop_item/down(client/user)
	var/mob/living/L = user.mob
	L.drop_item()
	return TRUE
/datum/keybinding/living/pixel_shift
	name = "pixel_shift"
	full_name = "Pixel Shift"
	description = "Hold to pixel shift with movement keys"
	hotkey_keys = list("B")

/datum/keybinding/living/pixel_shift/down(client/user)
	if(!(SEND_SIGNAL(user.mob, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN) & COMSIG_KB_ACTIVATED))
		user.mob.AddComponent(/datum/component/pixel_shift)

/datum/keybinding/living/pixel_shift/up(client/user)
	SEND_SIGNAL(user.mob, COMSIG_KB_MOB_PIXEL_SHIFT_UP)
