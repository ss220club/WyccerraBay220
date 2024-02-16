/datum/component/pixel_shift
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Whether the mob is pixel shifted or not
	var/is_shifted = FALSE
	/// If we are in the shifting setting.
	var/shifting = TRUE
	/// Takes the four cardinal direction defines. Any atoms moving into this atom's tile will be allowed to from the added directions.
	var/passthroughable = NONE
	var/maximum_pixel_shift = 12
	var/passable_shift_threshold = 8

/datum/component/pixel_shift/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_shift/RegisterWithParent()
	RegisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN, PROC_REF(pixel_shift_down))
	RegisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_UP, PROC_REF(pixel_shift_up))
	RegisterSignals(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_UPDATE_LYING_BUCKLED_VERBSTATUS), PROC_REF(unpixel_shift))
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(pre_move_check))
	RegisterSignal(parent, COMSIG_MOB_CAN_PASS, PROC_REF(check_passable))

/datum/component/pixel_shift/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN)
	UnregisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_UP)
	UnregisterSignal(parent, COMSIG_MOB_UPDATE_LYING_BUCKLED_VERBSTATUS)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE)
	UnregisterSignal(parent, COMSIG_MOB_CAN_PASS)

/datum/component/pixel_shift/proc/pre_move_check(mob/source, new_loc, direct)
	SIGNAL_HANDLER
	if(shifting)
		pixel_shift(source, direct)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/datum/component/pixel_shift/proc/check_passable(mob/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	// Make sure to not allow projectiles of any kind past where they normally wouldn't.
	if(!istype(mover, /obj/item/projectile) && !mover.throwing && passthroughable & get_dir(parent, mover))
		return COMPONENT_MOB_PASSABLE

/datum/component/pixel_shift/proc/pixel_shift_down()
	SIGNAL_HANDLER
	shifting = TRUE
	return COMSIG_KB_ACTIVATED

/datum/component/pixel_shift/proc/pixel_shift_up()
	SIGNAL_HANDLER
	shifting = FALSE

/datum/component/pixel_shift/proc/unpixel_shift()
	SIGNAL_HANDLER
	passthroughable = NONE
	if(is_shifted)
		var/mob/living/owner = parent
		owner.pixel_x = owner.default_pixel_x
		owner.pixel_y = owner.default_pixel_y
	qdel(src)

/datum/component/pixel_shift/proc/pixel_shift(mob/source, direct)
	var/mob/living/owner = parent
	if(owner.incapacitated(INCAPACITATION_ALL) || length(owner.pulledby) || length(owner.grabbed_by))
		return
	passthroughable = NONE
	switch(direct)
		if(NORTH)
			if(owner.pixel_y <= maximum_pixel_shift + owner.default_pixel_y)
				owner.pixel_y++
				is_shifted = TRUE
		if(EAST)
			if(owner.pixel_x <= maximum_pixel_shift + owner.default_pixel_x)
				owner.pixel_x++
				is_shifted = TRUE
		if(SOUTH)
			if(owner.pixel_y >= -maximum_pixel_shift + owner.default_pixel_y)
				owner.pixel_y--
				is_shifted = TRUE
		if(WEST)
			if(owner.pixel_x >= -maximum_pixel_shift + owner.default_pixel_x)
				owner.pixel_x--
				is_shifted = TRUE

	// Yes, I know this sets it to true for everything if more than one is matched.
	// Movement doesn't check diagonals, and instead just checks EAST or WEST, depending on where you are for those.
	if(owner.pixel_y > passable_shift_threshold)
		passthroughable |= EAST | SOUTH | WEST
	else if(owner.pixel_y < -passable_shift_threshold)
		passthroughable |= NORTH | EAST | WEST
	if(owner.pixel_x > passable_shift_threshold)
		passthroughable |= NORTH | SOUTH | WEST
	else if(owner.pixel_x < -passable_shift_threshold)
		passthroughable |= NORTH | EAST | SOUTH
