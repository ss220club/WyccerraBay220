/datum/keybinding/movement
	category = KEYBIND_CATEGORY_MOVEMENT

/datum/keybinding/movement/north
	name = "North"
	full_name = "Move North"
	description = "Moves your character north"
	hotkey_keys = list("W", "North")

/datum/keybinding/movement/south
	name = "South"
	full_name = "Move South"
	description = "Moves your character south"
	hotkey_keys = list("S", "South")

/datum/keybinding/movement/west
	hotkey_keys = list("A", "West")
	name = "West"
	full_name = "Move West"
	description = "Moves your character left"

/datum/keybinding/movement/east
	hotkey_keys = list("D", "East")
	name = "East"
	full_name = "Move East"
	description = "Moves your character east"

/datum/keybinding/movement/move_quickly
	hotkey_keys = list("Shift")
	name = "moving_quickly"
	full_name = "Move Quickly"
	description = "Makes you move quickly"

/datum/keybinding/movement/move_quickly/down(client/user)
	user.setmovingquickly()
	return TRUE

/datum/keybinding/movement/move_quickly/up(client/user)
	user.setmovingslowly()
	return TRUE

/datum/keybinding/movement/prevent_movement
	name = "block_movement"
	full_name = "Block movement"
	description = "Prevents you from moving"
	hotkey_keys = list("Ctrl")

/datum/keybinding/movement/prevent_movement/down(client/user)
	user.movement_locked = TRUE
	return TRUE

/datum/keybinding/movement/prevent_movement/up(client/user)
	user.movement_locked = FALSE
	return TRUE
