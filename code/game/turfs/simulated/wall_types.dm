//Commonly used
/turf/simulated/wall/prepainted
	paint_color = COLOR_GUNMETAL

/turf/simulated/wall/r_wall/prepainted
	paint_color = COLOR_GUNMETAL

/turf/simulated/wall/r_wall
	icon_state = "r_generic"

/turf/simulated/wall/r_wall/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_STEEL, MATERIAL_PLASTEEL)

/turf/simulated/wall/r_wall/hull
	name = "hull"
	color = COLOR_SOL

/turf/simulated/wall/r_wall/hull/vox
	initial_gas = list("nitrogen" = 101.38)
	color = COLOR_GREEN_GRAY

/turf/simulated/wall/prepainted
	paint_color = COLOR_WALL_GUNMETAL
/turf/simulated/wall/r_wall/prepainted
	paint_color = COLOR_WALL_GUNMETAL

/turf/simulated/wall/r_wall/hull/Initialize(mapload, added_to_area_cache, materialtype, rmaterialtype)
	. = ..()
	paint_color = color
	color = null //color is just for mapping
	if(prob(40))
		var/spacefacing = FALSE
		for(var/direction in GLOB.cardinal)
			var/turf/T = get_step(src, direction)
			var/area/A = get_area(T)
			if(A && (A.area_flags & AREA_FLAG_EXTERNAL))
				spacefacing = TRUE
				break
		if(spacefacing)
			var/bleach_factor = rand(10,50)
			paint_color = adjust_brightness(paint_color, bleach_factor)
	update_icon()

/turf/simulated/wall/titanium
	icon_state = "titanium"

/turf/simulated/wall/titanium/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_TITANIUM)

/turf/simulated/wall/r_titanium
	icon_state = "r_titanium"

/turf/simulated/wall/r_titanium/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_TITANIUM, MATERIAL_TITANIUM)

/turf/simulated/wall/ocp_wall
	icon_state = "r_ocp"

/turf/simulated/wall/ocp_wall/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_OSMIUM_CARBIDE_PLASTEEL, MATERIAL_OSMIUM_CARBIDE_PLASTEEL)

//Material walls

/turf/simulated/wall/r_wall/rglass_wall/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache,  MATERIAL_GLASS, MATERIAL_STEEL)
	icon_state = "r_generic"

/turf/simulated/wall/iron/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_IRON)

/turf/simulated/wall/uranium/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_URANIUM)

/turf/simulated/wall/diamond/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_DIAMOND)

/turf/simulated/wall/gold/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_GOLD)

/turf/simulated/wall/silver/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_SILVER)

/turf/simulated/wall/phoron/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_PHORON)

/turf/simulated/wall/sandstone/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_SANDSTONE)

/turf/simulated/wall/rutile/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_RUTILE)

/turf/simulated/wall/wood
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)
	icon_state = "woodneric"

/turf/simulated/wall/wood/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_WOOD)

/turf/simulated/wall/mahogany
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)
	icon_state = "woodneric"

/turf/simulated/wall/mahogany/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_MAHOGANY)

/turf/simulated/wall/maple
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)
	icon_state = "woodneric"

/turf/simulated/wall/maple/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_MAPLE)

/turf/simulated/wall/ebony
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)
	icon_state = "woodneric"

/turf/simulated/wall/ebony/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_EBONY)

/turf/simulated/wall/walnut
	blend_turfs = list(/turf/simulated/wall/cult, /turf/simulated/wall)
	icon_state = "woodneric"

/turf/simulated/wall/walnut/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_WALNUT)

/turf/simulated/wall/ironphoron/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_IRON,MATERIAL_PHORON)

/turf/simulated/wall/golddiamond/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_GOLD,MATERIAL_DIAMOND)

/turf/simulated/wall/silvergold/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_SILVER,MATERIAL_GOLD)

/turf/simulated/wall/sandstone/diamond/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_SANDSTONE,MATERIAL_DIAMOND)

/turf/simulated/wall/crystal/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_CRYSTAL)

/turf/simulated/wall/voxshuttle
	atom_flags = ATOM_FLAG_NO_TOOLS

/turf/simulated/wall/voxshuttle/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache,  MATERIAL_VOX)

/turf/simulated/wall/growth/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache,  MATERIAL_GROWTH)

/turf/simulated/wall/concrete/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_CONCRETE)

//Alien metal walls
/turf/simulated/wall/alium
	icon_state = "jaggy"
	floor_type = /turf/simulated/floor/fixed/alium
	blend_objects = newlist()

/turf/simulated/wall/alium/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, MATERIAL_ALIENALLOY)

//Cult wall
/turf/simulated/wall/cult
	icon_state = "cult"
	blend_turfs = list(/turf/simulated/wall)

/turf/simulated/wall/cult/Initialize(mapload, added_to_area_cache, reinforce = FALSE)
	. = ..(mapload, added_to_area_cache, MATERIAL_CULT, reinforce ? MATERIAL_REINFORCED_CULT : null)

/turf/simulated/wall/cult/reinf/Initialize(mapload, added_to_area_cache)
	. = ..(mapload, added_to_area_cache, TRUE)

/turf/simulated/wall/cult/dismantle_wall()
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)
	..()

/turf/simulated/wall/cult/can_join_with(turf/simulated/wall/W)
	if(material && W.material && material.wall_icon_base == W.material.wall_icon_base)
		return 1
	else if(istype(W, /turf/simulated/wall))
		return 1
	return 0
