/// Bitflag. Machine's base status. Can include `MACHINE_STAT_BROKEN`, `MACHINE_STAT_NOPOWER`, etc.
/obj/machinery/var/stat = EMPTY_BITFIELD

/// Bitflag. Reason the machine is 'broken'. Can be any combination of `MACHINE_BROKEN_*`. Do not modify directly - Use `set_broken()` instead.
/obj/machinery/var/reason_broken = EMPTY_BITFIELD

/// Bitflag. The machine will never set stat to these flags.
/obj/machinery/var/stat_immune = MACHINE_STAT_NOSCREEN | MACHINE_STAT_NOINPUT


/**
 * Sets the machine's broken state, modfying both `stat` and `reason_broken` accordingly.
 *
 * If the resulting `reason_broken` is empty, `MACHINE_STAT_BROKEN` is unset. Otherwise, the broken stat is set.
 *
 * **Parameters**:
 * - `new_state` (boolean) - The new state of the flag - 'On' or 'Off'.
 * - `cause` (bitfield - One of `MACHINE_BROKEN_*`) - The `reason_broken` flag to set.
 *
 * Returns boolean - Whether or not the state was changed.
 */
/obj/machinery/proc/set_broken(new_state, cause = MACHINE_BROKEN_GENERIC)
	if(!new_state == !(reason_broken & cause))
		return FALSE
	var/old_reason = stat
	reason_broken ^= cause
	on_set_broken(cause, old_reason)

/obj/machinery/proc/on_set_broken(cause, old_reason)
	update_is_operational()

/**
 * Allows setting or unsetting a stat flag.
 *
 * **Parameters**:
 * - `statflag` (bitfield - One of `MACHINE_STAT_*`) - The stat flag to set.
 * - `new_state` (boolean) - The new state of the flag - 'On' or 'Off'.
 *
 * Returns boolean - Whether or not the stat was updated.
 */
/obj/machinery/proc/set_stat(statflag, new_state)
	if (stat_immune & statflag)
		return
	if (new_state == !!HAS_FLAGS(stat, statflag))
		return
	var/old_stat = stat
	stat ^= statflag
	on_set_stat(statflag, old_stat)


/obj/machinery/proc/on_set_stat(statflag, old_stat)
	update_is_operational()

/obj/machinery/proc/update_is_operational()
	if(!MACHINE_IS_BROKEN(src) && !(stat & (MACHINE_STAT_NOPOWER|MACHINE_STAT_MAINT)))
		set_is_operational(TRUE)
		return
	set_is_operational(FALSE)

///Called when we want to change the value of the `is_operational` variable. Boolean.
/obj/machinery/proc/set_is_operational(new_value)
	if(new_value == is_operational)
		return
	. = is_operational
	is_operational = new_value
	on_set_is_operational(.)


///Called when the value of `is_operational` changes, so we can react to it.
/obj/machinery/proc/on_set_is_operational(old_value)
	//From off to on.
	if(!old_value && is_operational)
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		return
	//From on to off.
	STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)


/**
 * Updates the machine's stat immunity. This also updates the stat flag itself, if it's set and you're turning on immunity.
 *
 * **Parameters**:
 * - `statflag` (bitfield, One of `MACHINE_STAT_*`) - The stat flag to set immunity of.
 * - `new_state` (boolean, default `TRUE`) - The new state of the stat immunity flag.
 *
 * Returns boolean. Whether or not `stat` was updated during the operation.
 */
/obj/machinery/proc/set_stat_immunity(statflag, new_state = TRUE)
	if (new_state == !!HAS_FLAGS(stat_immune, statflag))
		return FALSE
	if (new_state)
		SET_FLAGS(stat_immune, statflag)
		if (HAS_FLAGS(stat, statflag))
			CLEAR_FLAGS(stat, statflag)
			return TRUE
		return FALSE
	CLEAR_FLAGS(stat_immune, statflag)
	return FALSE


/**
 * Toggles a stat flag.
 *
 * **Parameters**:
 * - `statflag` (bitfield - One of `MACHINE_STAT_*`) - The stat flag to toggle.
 *
 * Returns boolean or null. Null if the machine is immune to the state, otherwise, boolean based on the new state of the flag.
 */
/obj/machinery/proc/toggle_stat(statflag)
	if (stat_immune & statflag)
		return
	stat ^= statflag
	return !!GET_FLAGS(stat, statflag)


/**
 * Whether or not the machine is considered 'powered'. By default this translates directly to `!stat_check(MACHINE_STAT_NOPOWER)`.
 *
 * Returns boolean.
 */
/obj/machinery/proc/is_powered(additional_flags = EMPTY_BITFIELD)
	return !GET_FLAGS(stat, MACHINE_STAT_NOPOWER | additional_flags)


/// Inverse of `inoperable()`.
/obj/machinery/proc/operable(additional_flags = EMPTY_BITFIELD)
	return !inoperable(additional_flags)


/// Checks whether or not the machine's state variable has the `MACHINE_STAT_BROKEN` or `MACHINE_STAT_NOPOWER` flags, or any of the provided `additional_flags`. Returns `TRUE` if any of the flags match.
/obj/machinery/proc/inoperable(additional_flags = EMPTY_BITFIELD)
	return (GET_FLAGS(stat, MACHINE_STAT_NOPOWER | additional_flags) || reason_broken)
