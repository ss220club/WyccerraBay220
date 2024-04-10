/atom/movable
	appearance_flags = TILE_BOUND | PIXEL_SCALE | LONG_GLIDE

// You might be wondering why this isn't client level. If focus is null, we don't want you to move.
// Only way to do that is to tie the behavior into the focus's keyLoop().
/atom/movable/keyLoop(client/user)
	var/movement_dir = 0
	for(var/_key in user.keys_held)
		movement_dir = movement_dir | user.movement_keys[_key]
	if(user.next_move_dir_add)
		movement_dir |= user.next_move_dir_add
	if(user.next_move_dir_sub)
		movement_dir &= ~user.next_move_dir_sub
	// Sanity checks in case you hold left and right and up to make sure you only go up
	if((movement_dir & NORTH) && (movement_dir & SOUTH))
		movement_dir &= ~(NORTH|SOUTH)
	if((movement_dir & EAST) && (movement_dir & WEST))
		movement_dir &= ~(EAST|WEST)

	if(movement_dir) //If we're not moving, don't compensate, as byond will auto-fill dir otherwise
		movement_dir = turn(movement_dir, -dir2angle(user.dir)) //By doing this we ensure that our input direction is offset by the client (camera) direction

		if(user.movement_locked)
			keybind_face_direction(movement_dir)
		else
			user.Move(get_step(src, movement_dir), movement_dir)

	user.next_move_dir_add = 0
	user.next_move_dir_sub = 0

/**
* A wrapper for setDir that should only be able to fail by living mobs.
*
* Called from [/atom/movable/proc/keyLoop], this exists to be overwritten by living mobs with a check to see if we're actually alive enough to change directions
*/
/atom/movable/proc/keybind_face_direction(direction)
	return

/mob/keybind_face_direction(direction)
	facedir(direction)
