/turf/proc/ReplaceWithLattice(material)
	var base_turf = get_base_turf_by_area(src, TRUE)
	if(type != base_turf)
		ChangeTurf(get_base_turf_by_area(src, TRUE))

	if(!locate(/obj/structure/lattice) in src)
		new /obj/structure/lattice(src, material)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)
// Called after turf replaces old one
/turf/proc/post_change()
	levelupdate()
	if (above)
		above.update_mimic()

//Creates a new turf
/turf/proc/ChangeTurf(turf/replacement_turf, tell_universe = TRUE, force_lighting_update = FALSE, keep_air = FALSE)
	if(!replacement_turf)
		return

	if(isturf(replacement_turf) && !replacement_turf.flooded && replacement_turf.flood_object)
		QDEL_NULL(flood_object)

	// This makes sure that turfs are not changed to space when one side is part of a zone
	if(ispath(replacement_turf, /turf/space))
		var/turf/below = GetBelow(src)
		if(istype(below) && !isspaceturf(below))
			replacement_turf = /turf/simulated/open

	var/old_density = density
	var/old_air = air
	var/old_hotspot = hotspot
	var/old_turf_fire = null
	var/old_opacity = opacity
	var/old_dynamic_lighting = TURF_IS_DYNAMICALLY_LIT_UNSAFE(src)
	var/old_affecting_lights = affecting_lights
	var/old_lighting_overlay = lighting_overlay
	var/old_corners = corners
	var/old_ao_neighbors = ao_neighbors
	var/old_above = above
	var/old_permit_ao = permit_ao
	var/old_zflags = z_flags

	if(isspaceturf(replacement_turf) || isopenspace(replacement_turf))
		QDEL_NULL(turf_fire)
	else
		old_turf_fire = turf_fire

	changing_turf = TRUE

	if(connections)
		connections.erase_all()

	ClearOverlays()
	underlays.Cut()
	if(issimulatedturf(src))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		if(S.zone)
			S.zone.rebuild()

	if(ambient_bitflag) //Should remove everything about current bitflag, let it be recalculated by SS later
		SSambient_lighting.clean_turf(src)

	// Run the Destroy() chain.
	qdel(src)
	var/turf/simulated/new_turf = new replacement_turf(src, added_to_area_cache)

	if (permit_ao)
		regenerate_ao()

	if (keep_air)
		new_turf.air = old_air

	if(ispath(replacement_turf, /turf/simulated))
		if(old_hotspot)
			hotspot = old_hotspot
		if (istype(new_turf,/turf/simulated/floor))
			new_turf.RemoveLattice()
	else if(hotspot)
		qdel(hotspot)


	if(tell_universe)
		GLOB.universe.OnTurfChange(new_turf)

	SSair.mark_for_update(src) //handle the addition of the new turf.

	for(var/turf/space/space_turf in RANGE_TURFS(new_turf,1))
		space_turf.update_starlight()

	new_turf.above = old_above

	new_turf.post_change()
	. = new_turf

	new_turf.ao_neighbors = old_ao_neighbors
	// lighting stuff

	if(SSlighting.initialized)
		recalc_atom_opacity()
		lighting_overlay = old_lighting_overlay
		affecting_lights = old_affecting_lights
		corners = old_corners
		if (old_opacity != opacity || dynamic_lighting != old_dynamic_lighting || force_lighting_update)
			reconsider_lights()
			updateVisibility(src)

		if (dynamic_lighting != old_dynamic_lighting)
			if (TURF_IS_DYNAMICALLY_LIT_UNSAFE(src))
				lighting_build_overlay()
			else
				lighting_clear_overlay()

	new_turf.setup_local_ambient()
	if(z_flags != old_zflags)
		new_turf.rebuild_zbleed()
	// end of lighting stuff

	for(var/turf/T as anything in RANGE_TURFS(src, 1))
		T.update_icon()

	if(density != old_density)
		GLOB.density_set_event.raise_event(src, old_density, density)

	if(!density)
		turf_fire = old_turf_fire
	else if(old_turf_fire)
		QDEL_NULL(old_turf_fire)

	if(density != old_density || permit_ao != old_permit_ao)
		regenerate_ao()

	GLOB.turf_changed_event.raise_event(src, old_density, density, old_opacity, opacity)
	updateVisibility(src, FALSE)

/turf/proc/transport_properties_from(turf/other)
	if(!istype(other, type))
		return FALSE

	src.set_dir(other.dir)
	src.icon_state = other.icon_state
	src.icon = other.icon
	CopyOverlays(other)
	src.underlays = other.underlays.Copy()
	if(other.decals)
		src.decals = other.decals.Copy()
		src.update_icon()

	return TRUE

//I would name this copy_from() but we remove the other turf from their air zone for some reason
/turf/simulated/transport_properties_from(turf/simulated/other)
	if(!..())
		return 0

	if(other.zone)
		if(!src.air)
			src.make_air()
		src.air.copy_from(other.zone.air)
		other.zone.remove(other)
	return 1

/turf/simulated/wall/transport_properties_from(turf/simulated/wall/other)
	if(!..())
		return 0
	paint_color = other.paint_color
	return 1

//No idea why resetting the base appearence from New() isn't enough, but without this it doesn't work
/turf/simulated/shuttle/wall/corner/transport_properties_from(turf/simulated/other)
	. = ..()
	reset_base_appearance()
