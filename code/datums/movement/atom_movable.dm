// Static movement denial
/datum/movement_handler/no_move/MayMove()
	return GLOB.MOVEMENT_STOP

// Anchor check
/datum/movement_handler/anchored/MayMove()
	return host.anchored ? GLOB.MOVEMENT_STOP : GLOB.MOVEMENT_PROCEED

// Movement relay
/datum/movement_handler/move_relay/DoMove(direction, mover)
	var/atom/movable/AM = host.loc
	if(!istype(AM))
		return
	. = AM.DoMove(direction, mover, FALSE)
	if(!(. & GLOB.MOVEMENT_HANDLED) && !(direction & (UP|DOWN)))
		AM.relaymove(mover, direction)
	return GLOB.MOVEMENT_HANDLED

// Movement delay
/datum/movement_handler/delay
	VAR_PROTECTED/delay = 1
	VAR_PROTECTED/next_move

/datum/movement_handler/delay/New(host, delay)
	..()
	src.delay = max(1, delay)

/datum/movement_handler/delay/DoMove()
	next_move = world.time + delay

/datum/movement_handler/delay/MayMove()
	return world.time >= next_move ? GLOB.MOVEMENT_PROCEED : GLOB.MOVEMENT_STOP

// Relay self
/datum/movement_handler/move_relay_self/DoMove(direction, mover)
	host.relaymove(mover, direction)
	return GLOB.MOVEMENT_HANDLED
