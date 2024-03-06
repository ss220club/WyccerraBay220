/obj/structure/table
	name = "table frame"
	icon = 'icons/obj/structures/tables.dmi'
	icon_state = "frame"
	desc = "It's a table, for putting things on. Or standing on, if you really want to."
	density = TRUE
	anchored = TRUE
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_CLIMBABLE
	layer = TABLE_LAYER
	throwpass = 1
	mob_offset = 12
	health_max = 10
	obj_flags = OBJ_FLAG_RECEIVE_TABLE
	var/flipped = 0

	// For racks.
	var/can_reinforce = 1
	var/can_plate = 1

	var/manipulating = 0
	var/material/reinforced = null

	// Gambling tables. I'd prefer reinforced with carpet/felt/cloth/whatever, but AFAIK it's either harder or impossible to get /obj/item/stack/material of those.
	// Convert if/when you can easily get stacks of these.
	var/carpeted = 0

	connections = list("nw0", "ne0", "sw0", "se0")

/obj/structure/table/New()
	if(istext(material))
		material = SSmaterials.get_material_by_name(material)
	if(istext(reinforced))
		reinforced = SSmaterials.get_material_by_name(reinforced)
	..()

/obj/structure/table/proc/update_material()
	var/new_health = 0
	if(!material)
		new_health = 10
		damage_hitsound = initial(damage_hitsound)
		health_min_damage = 0
	else
		new_health = material.integrity / 2
		health_min_damage = material.hardness
		if(reinforced)
			new_health += reinforced.integrity / 2
			health_min_damage += reinforced.hardness
		health_min_damage = round(health_min_damage / 10)
		damage_hitsound = material.hitsound
	set_max_health(new_health)

/obj/structure/table/damage_health(damage, damage_type, damage_flags = EMPTY_BITFIELD, severity, skip_can_damage_check = FALSE)
	// If the table is made of a brittle material, and is *not* reinforced with a non-brittle material, damage is multiplied by TABLE_BRITTLE_MATERIAL_MULTIPLIER
	if (material?.is_brittle())
		if (reinforced)
			if (reinforced.is_brittle())
				damage *= TABLE_BRITTLE_MATERIAL_MULTIPLIER
		else
			damage *= TABLE_BRITTLE_MATERIAL_MULTIPLIER

	. = ..()

/obj/structure/table/on_death()
	visible_message(SPAN_WARNING("[src] breaks down!"))
	break_to_parts()

/obj/structure/table/Initialize()
	. = ..()

	// One table per turf.
	for(var/obj/structure/table/T in loc)
		if(T != src)
			// There's another table here that's not us, break to metal.
			// break_to_parts calls qdel(src)
			break_to_parts(full_return = 1)
			return

	// reset color/alpha, since they're set for nice map previews
	color = "#ffffff"
	alpha = 255
	update_connections(1)
	update_icon()
	update_desc()
	update_material()

/obj/structure/table/Destroy()
	material = null
	reinforced = null
	update_connections(1) // Update tables around us to ignore us (material=null forces no connections)
	for(var/obj/structure/table/T in oview(src, 1))
		T.update_icon()
	. = ..()

/obj/structure/table/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(user.a_intent == I_HURT)
		if(!carpeted)
			USE_FEEDBACK_FAILURE("[src] has no carpeting to remove.")
			return
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		new /obj/item/stack/tile/carpet(loc)
		carpeted = FALSE
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] removes the carpeting from [src] with [tool]."),
			SPAN_NOTICE("You remove the carpeting from [src] with [tool].")
		)

/obj/structure/table/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(user.a_intent == I_HURT)
		if (!reinforced)
			USE_FEEDBACK_FAILURE("[src] has no reinforcements to remove.")
			return
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		remove_reinforced(tool, user)
		if (!reinforced)
			update_desc()
			update_icon()
			update_material()

/obj/structure/table/wrench_act(mob/living/user, obj/item/tool)
	if(user.a_intent == I_HURT)
		. = ITEM_INTERACT_SUCCESS
		if(!material)
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			dismantle(tool, user)
			return
		if(reinforced)
			USE_FEEDBACK_FAILURE("[src]'s reinforcements need to be removed before you can remove the plating.")
			return
		if(carpeted)
			USE_FEEDBACK_FAILURE("[src]'s carpeting needs to be removed before you can remove the plating.")
			return
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		remove_material(tool, user)
		if (!material)
			update_connections(TRUE)
			update_icon()
			for (var/obj/structure/table/table in oview(src, 1))
				table.update_icon()
			update_desc()
			update_material()
		return

	if(can_plate && !material)
		. = ITEM_INTERACT_SUCCESS
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		dismantle(tool, user)

/obj/structure/table/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!health_damaged())
		USE_FEEDBACK_FAILURE("[src] isn't damaged.")
		return
	if(!tool.tool_use_check(user, 1))
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts repairing [src] with [tool]."),
		SPAN_NOTICE("You start repairing [src] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 2 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	restore_health(get_max_health() / 5) // 20% repair per application
	user.visible_message(
		SPAN_NOTICE("[user] repairs some of [src]'s damage with [tool]."),
		SPAN_NOTICE("You repair some of [src]'s damage with [tool].")
	)

/obj/structure/table/use_weapon(obj/item/weapon, mob/user, list/click_params)
	// Carpet - Add carpeting
	if (istype(weapon, /obj/item/stack/tile/carpet))
		if (carpeted)
			USE_FEEDBACK_FAILURE("[src] is already carpeted.")
			return TRUE
		if (!material)
			USE_FEEDBACK_FAILURE("[src] needs plating before you can carpet it.")
			return TRUE
		var/obj/item/stack/tile/carpet/carpet = weapon
		if (!carpet.use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(carpet, 1, "to pad [src].")
			return TRUE
		carpeted = TRUE
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] pads [src] with [weapon]."),
			SPAN_NOTICE("You pad [src] with [weapon].")
		)
		return TRUE

	// Energy Blade, Psiblade
	if (istype(weapon, /obj/item/melee/energy/blade) || istype(weapon, /obj/item/psychic_power/psiblade/master/grand/paramount))
		var/datum/effect/spark_spread/spark_system = new(src)
		spark_system.set_up(5, EMPTY_BITFIELD, loc)
		spark_system.start()
		playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE)
		playsound(loc, "sparks", 50, TRUE)
		user.visible_message(
			SPAN_WARNING("[user] slices [src] apart with [weapon]."),
			SPAN_WARNING("You slice [src] apart with [weapon].")
		)
		break_to_parts()
		return TRUE

	// Material - Plate table
	if (istype(weapon, /obj/item/stack/material))
		if (!material)
			return FALSE // Handled by `use_tool()`
		reinforce_table(weapon, user)
		return TRUE

	return ..()


/obj/structure/table/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	// Unfinished table - Construction stuff
	if (can_plate && !material)
		// Material - Plate table
		if (istype(tool, /obj/item/stack/material))
			material = common_material_add(tool, user, "plat")
			if (material)
				update_connections(TRUE)
				update_icon()
				update_desc()
				update_material()
			return TRUE
		// Anything else - Can't put it on an unfinished table
		USE_FEEDBACK_FAILURE("[src] needs to be plated before you can put [tool] on it.")
		return TRUE
	// Put things on table
	if (!user.unEquip(tool, loc))
		FEEDBACK_UNEQUIP_FAILURE(user, tool)
		return TRUE
	auto_align(tool, click_params)
	return TRUE

/obj/structure/table/MouseDrop_T(atom/dropped, mob/user)
	// Place held objects on table
	if (isitem(dropped) && user.IsHolding(dropped))
		if (!user.use_sanity_check(src, dropped, SANITY_CHECK_DEFAULT | SANITY_CHECK_TOOL_UNEQUIP))
			return TRUE
		user.unEquip(dropped, get_turf(src))
		return TRUE

	return ..()


/obj/structure/table/proc/reinforce_table(obj/item/stack/material/S, mob/user)
	if(reinforced)
		to_chat(user, SPAN_WARNING("[src] is already reinforced!"))
		return

	if(!can_reinforce)
		to_chat(user, SPAN_WARNING("[src] cannot be reinforced!"))
		return

	if(!material)
		to_chat(user, SPAN_WARNING("Plate [src] before reinforcing it!"))
		return

	if(flipped)
		to_chat(user, SPAN_WARNING("Put [src] back in place before reinforcing it!"))
		return

	reinforced = common_material_add(S, user, "reinforc")
	if(reinforced)
		update_desc()
		update_icon()
		update_material()

/obj/structure/table/proc/update_desc()
	if(material)
		name = "[material.display_name] table"
	else
		name = "table frame"

	if(reinforced)
		name = "reinforced [name]"
		desc = "[initial(desc)] This one seems to be reinforced with [reinforced.display_name]."
	else
		desc = initial(desc)

// Returns the material to set the table to.
/obj/structure/table/proc/common_material_add(obj/item/stack/material/S, mob/user, verb) // Verb is actually verb without 'e' or 'ing', which is added. Works for 'plate'/'plating' and 'reinforce'/'reinforcing'.
	var/material/M = S.get_material()
	if(!istype(M))
		to_chat(user, SPAN_WARNING("You cannot [verb]e [src] with [S]."))
		return null

	if(manipulating) return M
	manipulating = 1
	to_chat(user, SPAN_NOTICE("You begin [verb]ing [src] with [M.display_name]."))
	if(!do_after(user, 2 SECONDS, src, DO_REPAIR_CONSTRUCT) || !S.use(1))
		manipulating = 0
		return null
	user.visible_message(SPAN_NOTICE("[user] [verb]es [src] with [M.display_name]."), SPAN_NOTICE("You finish [verb]ing [src]."))
	manipulating = 0
	return M

// Returns the material to set the table to.
/obj/structure/table/proc/common_material_remove(mob/user, material/M, delay, what, type_holding, sound)
	if(!M.stack_type)
		to_chat(user, SPAN_WARNING("You are unable to remove the [what] from this table!"))
		return M

	if(manipulating) return M
	manipulating = 1
	user.visible_message(SPAN_NOTICE("[user] begins removing the [type_holding] holding [src]'s [M.display_name] [what] in place."),
	               SPAN_NOTICE("You begin removing the [type_holding] holding [src]'s [M.display_name] [what] in place."))
	if(sound)
		playsound(src.loc, sound, 50, 1)
	if(!do_after(user, delay, src, DO_REPAIR_CONSTRUCT))
		manipulating = 0
		return M
	user.visible_message(SPAN_NOTICE("[user] removes the [M.display_name] [what] from [src]."),
	               SPAN_NOTICE("You remove the [M.display_name] [what] from [src]."))
	M.place_sheet(src.loc)
	manipulating = 0
	return null

/obj/structure/table/proc/remove_reinforced(obj/item/S, mob/user)
	reinforced = common_material_remove(user, reinforced, (S.toolspeed * 4) SECONDS, "reinforcements", "screws", 'sound/items/Screwdriver.ogg')

/obj/structure/table/proc/remove_material(obj/item/W, mob/user)
	material = common_material_remove(user, material, (W.toolspeed * 2) SECONDS, "plating", "bolts", 'sound/items/Ratchet.ogg')

/obj/structure/table/proc/dismantle(obj/item/W, mob/user)
	reset_mobs_offset()
	if(manipulating) return
	manipulating = 1
	user.visible_message(SPAN_NOTICE("[user] begins dismantling [src]."),
								SPAN_NOTICE("You begin dismantling [src]."))
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(!do_after(user, (W.toolspeed * 2) SECONDS, src, DO_REPAIR_CONSTRUCT))
		manipulating = 0
		return
	user.visible_message(SPAN_NOTICE("[user] dismantles [src]."),
								SPAN_NOTICE("You dismantle [src]."))
	new /obj/item/stack/material/steel(src.loc)
	qdel(src)
	return

// Returns a list of /obj/item/material/shard objects that were created as a result of this table's breakage.
// Used for !fun! things such as embedding shards in the faces of tableslammed people.

// The repeated
//   S = [x].place_shard(loc)
//   if(S) shards += S
// is to avoid filling the list with nulls, as place_shard won't place shards of certain materials (holo-wood, holo-steel)

/obj/structure/table/proc/break_to_parts(full_return = 0)
	reset_mobs_offset()
	var/list/shards = list()
	var/obj/item/material/shard/S = null
	if(reinforced)
		if(reinforced.stack_type && (full_return || prob(20)))
			reinforced.place_sheet(loc)
		else
			S = reinforced.place_shard(loc)
			if(S) shards += S
	if(material)
		if(material.stack_type && (full_return || prob(20)))
			material.place_sheet(loc)
		else
			S = material.place_shard(loc)
			if(S) shards += S
	if(carpeted && (full_return || prob(50))) // Higher chance to get the carpet back intact, since there's no non-intact option
		new /obj/item/stack/tile/carpet(src.loc)
	if(full_return || prob(20))
		new /obj/item/stack/material/steel(src.loc)
	else
		var/material/M = SSmaterials.get_material_by_name(MATERIAL_STEEL)
		S = M.place_shard(loc)
		if(S) shards += S
	qdel(src)
	return shards

/obj/structure/table/on_update_icon()
	if(!flipped)
		mob_offset = initial(mob_offset)
		icon_state = "blank"
		ClearOverlays()

		var/image/I

		// Base frame shape. Mostly done for glass/diamond tables, where this is visible.
		for(var/i = 1 to 4)
			I = image(icon, dir = SHIFTL(1, i - 1), icon_state = connections[i])
			AddOverlays(I)

		// Standard table image
		if(material)
			for(var/i = 1 to 4)
				I = image(icon, "[material.table_icon_base]_[connections[i]]", dir = SHIFTL(1, i - 1))
				if(material.icon_colour) I.color = material.icon_colour
				I.alpha = 255 * material.opacity
				AddOverlays(I)

		// Reinforcements
		if(reinforced)
			for(var/i = 1 to 4)
				I = image(icon, "[material.table_icon_reinf]_[connections[i]]", dir = SHIFTL(1, i - 1))
				I.color = reinforced.icon_colour
				I.alpha = 255 * reinforced.opacity
				AddOverlays(I)

		if(carpeted)
			for(var/i = 1 to 4)
				I = image(icon, "carpet_[connections[i]]", dir = SHIFTL(1, i - 1))
				AddOverlays(I)
	else
		mob_offset = 0
		ClearOverlays()
		var/type = 0
		var/tabledirs = 0
		for(var/direction in list(turn(dir,90), turn(dir,-90)) )
			var/obj/structure/table/T = locate(/obj/structure/table ,get_step(src,direction))
			if (T && T.flipped == 1 && T.dir == src.dir && material && T.material && T.material.name == material.name)
				type++
				tabledirs |= direction

		type = "[type]"
		if (type=="1")
			if (tabledirs & turn(dir,90))
				type += "-"
			if (tabledirs & turn(dir,-90))
				type += "+"

		icon_state = "flip[type]"
		if(material)
			var/image/I = image(icon, "[material.table_icon_base]_flip[type]")
			I.color = material.icon_colour
			I.alpha = 255 * material.opacity
			AddOverlays(I)
			name = "[material.display_name] table"
		else
			name = "table frame"

		if(reinforced)
			var/image/I = image(icon, "[material.table_icon_reinf]_flip[type]")
			I.color = reinforced.icon_colour
			I.alpha = 255 * reinforced.opacity
			AddOverlays(I)

		if(carpeted)
			AddOverlays("carpet_flip[type]")

/obj/structure/table/proc/can_connect()
	return TRUE

// set propagate if you're updating a table that should update tables around it too, for example if it's a new table or something important has changed (like material).
/obj/structure/table/update_connections(propagate=0)
	if(!material)
		connections = list("0", "0", "0", "0")

		if(propagate)
			for(var/obj/structure/table/T in oview(src, 1))
				T.update_connections()
		return

	var/list/blocked_dirs = list()
	for(var/obj/structure/window/W in get_turf(src))
		if(W.is_fulltile())
			connections = list("0", "0", "0", "0")
			return
		blocked_dirs |= W.dir

	for(var/D in list(NORTH, SOUTH, EAST, WEST) - blocked_dirs)
		var/turf/T = get_step(src, D)
		for(var/obj/structure/window/W in T)
			if(W.is_fulltile() || W.dir == GLOB.reverse_dir[D])
				blocked_dirs |= D
				break
			else
				if(W.dir != D) // it's off to the side
					blocked_dirs |= W.dir|D // blocks the diagonal

	for(var/D in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST) - blocked_dirs)
		var/turf/T = get_step(src, D)

		for(var/obj/structure/window/W in T)
			if(W.is_fulltile() || (W.dir & GLOB.reverse_dir[D]))
				blocked_dirs |= D
				break

	// Blocked cardinals block the adjacent diagonals too. Prevents weirdness with tables.
	for(var/x in list(NORTH, SOUTH))
		for(var/y in list(EAST, WEST))
			if((x in blocked_dirs) || (y in blocked_dirs))
				blocked_dirs |= x|y

	var/list/connection_dirs = list()

	for(var/obj/structure/table/T in orange(src, 1))
		if(!T.can_connect()) continue
		var/T_dir = get_dir(src, T)
		if(T_dir in blocked_dirs) continue
		if(material && T.material && material.name == T.material.name && flipped == T.flipped)
			connection_dirs |= T_dir
		if(propagate)
			spawn(0)
				T.update_connections()
				T.update_icon()

	connections = dirs_to_corner_states(connection_dirs)

#define CORNER_NONE 0
#define CORNER_COUNTERCLOCKWISE 1
#define CORNER_DIAGONAL 2
#define CORNER_CLOCKWISE 4

/*
	turn() is weird:
		turn(icon, angle) turns icon by angle degrees clockwise
		turn(matrix, angle) turns matrix by angle degrees clockwise
		turn(dir, angle) turns dir by angle degrees counter-clockwise
*/

/proc/dirs_to_corner_states(list/dirs)
	RETURN_TYPE(/list)
	if(!istype(dirs)) return

	var/list/ret = list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST)

	for(var/i = 1 to length(ret))
		var/dir = ret[i]
		. = CORNER_NONE
		if(dir in dirs)
			. |= CORNER_DIAGONAL
		if(turn(dir,45) in dirs)
			. |= CORNER_COUNTERCLOCKWISE
		if(turn(dir,-45) in dirs)
			. |= CORNER_CLOCKWISE
		ret[i] = "[.]"

	return ret

#undef CORNER_NONE
#undef CORNER_COUNTERCLOCKWISE
#undef CORNER_DIAGONAL
#undef CORNER_CLOCKWISE
