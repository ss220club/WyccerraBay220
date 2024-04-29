/obj/structure/bed/sofa
	name = "sofa"
	desc = "A wide and comfy sofa - no one assistant was ate by it due production! It's made of wood and covered with synthetic leather."
	icon = 'mods/fancy_sofas/icons/furniture.dmi'
	icon_state = "sofa_preview"
	base_icon = "sofa"
	buckle_dir = FALSE
	buckle_stance = BUCKLE_FORCE_STAND
	obj_flags = OBJ_FLAG_ROTATABLE

/obj/structure/bed/sofa/do_simple_ranged_interaction(mob/user)
	if(!buckled_mob && user)
		rotate(user)
	return TRUE

/obj/structure/bed/sofa/set_dir()
	..()
	if(buckled_mob)
		buckled_mob.set_dir(dir)

/obj/structure/bed/sofa/post_buckle_mob()
	update_icon()
	return ..()

/obj/structure/bed/sofa/on_update_icon()
	..()

	var/cache_key = "[base_icon]-[material.name]-over"
	if(isnull(GLOB.stool_cache[cache_key]))
		var/image/I = image('mods/fancy_sofas/icons/furniture.dmi', "[base_icon]_over")
		if(material_alteration & MATERIAL_ALTERATION_COLOR)
			I.color = material.icon_colour
		I.layer = ABOVE_HUMAN_LAYER
		GLOB.stool_cache[cache_key] = I
	AddOverlays(GLOB.stool_cache[cache_key])
	// Padding overlay.
	if(padding_material)
		var/padding_cache_key = "[base_icon]-padding-[padding_material.name]-over"
		if(isnull(GLOB.stool_cache[padding_cache_key]))
			var/image/I =  image(icon, "[base_icon]_padding_over")
			if(material_alteration & MATERIAL_ALTERATION_COLOR)
				I.color = padding_material.icon_colour
			I.layer = ABOVE_HUMAN_LAYER
			GLOB.stool_cache[padding_cache_key] = I
		AddOverlays(GLOB.stool_cache[padding_cache_key])

	if(buckled_mob)
		cache_key = "[base_icon]-armrest-[material.name]"
		if(isnull(GLOB.stool_cache[cache_key]))
			var/image/I = image(icon, "[base_icon]_armrest")
			I.layer = ABOVE_HUMAN_LAYER
			if(material_alteration & MATERIAL_ALTERATION_COLOR)
				I.color = material.icon_colour
			GLOB.stool_cache[cache_key] = I
		AddOverlays(GLOB.stool_cache[cache_key])
		if(padding_material)
			cache_key = "[base_icon]-padding-armrest-[padding_material.name]"
			if(isnull(GLOB.stool_cache[cache_key]))
				var/image/I = image(icon, "[base_icon]_padding_armrest")
				I.layer = ABOVE_HUMAN_LAYER
				if(material_alteration & MATERIAL_ALTERATION_COLOR)
					I.color = padding_material.icon_colour
				GLOB.stool_cache[cache_key] = I
			AddOverlays(GLOB.stool_cache[cache_key])

/obj/structure/bed/sofa/m/rotate(mob/user)
	if(!CanPhysicallyInteract(user) || anchored)
		to_chat(user, SPAN_NOTICE("You can't interact with \the [src] right now!"))
		return

	set_dir(turn(dir, 45))
	update_icon()

/obj/structure/bed/sofa/rotate(mob/user)
	if(!CanPhysicallyInteract(user) || anchored)
		to_chat(user, SPAN_NOTICE("You can't interact with \the [src] right now!"))
		return

	set_dir(turn(dir, 90))
	update_icon()

/obj/structure/bed/sofa/m/red/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_CARPET)

/obj/structure/bed/sofa/m/brown/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_LEATHER_GENERIC)

/obj/structure/bed/sofa/m/teal/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "teal")

/obj/structure/bed/sofa/m/black/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "black")

/obj/structure/bed/sofa/m/green/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "green")

/obj/structure/bed/sofa/m/purple/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "purple")

/obj/structure/bed/sofa/m/blue/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "blue")

/obj/structure/bed/sofa/m/beige/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "beige")

/obj/structure/bed/sofa/m/lime/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "lime")

/obj/structure/bed/sofa/m/yellow/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "yellow")

/obj/structure/bed/sofa/m/light/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_CLOTH)

/obj/structure/bed/sofa/r
	name = "sofa"
	desc = "A wide and comfy sofa - no one assistant was ate by it due production! It's made of wood and covered with synthetic leather."
	icon_state = "sofa_r_preview"
	base_icon = "sofa_r"

/obj/structure/bed/sofa/r/red/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_CARPET)

/obj/structure/bed/sofa/r/brown/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_LEATHER_GENERIC)

/obj/structure/bed/sofa/r/teal/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "teal")

/obj/structure/bed/sofa/r/black/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "black")

/obj/structure/bed/sofa/r/green/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "green")

/obj/structure/bed/sofa/r/purple/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "purple")

/obj/structure/bed/sofa/r/blue/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "blue")

/obj/structure/bed/sofa/r/beige/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "beige")

/obj/structure/bed/sofa/r/lime/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "lime")

/obj/structure/bed/sofa/r/yellow/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "yellow")

/obj/structure/bed/sofa/r/light/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_CLOTH)

/obj/structure/bed/sofa/l
	name = "sofa"
	desc = "A wide and comfy sofa - no one assistant was ate by it due production! It's made of wood and covered with synthetic leather."
	icon_state = "sofa_l_preview"
	base_icon = "sofa_l"

/obj/structure/bed/sofa/l/red/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_CARPET)

/obj/structure/bed/sofa/l/brown/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_LEATHER_GENERIC)

/obj/structure/bed/sofa/l/teal/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "teal")

/obj/structure/bed/sofa/l/black/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "black")

/obj/structure/bed/sofa/l/green/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "green")

/obj/structure/bed/sofa/l/purple/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "purple")

/obj/structure/bed/sofa/l/blue/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "blue")

/obj/structure/bed/sofa/l/beige/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "beige")

/obj/structure/bed/sofa/l/lime/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "lime")

/obj/structure/bed/sofa/l/yellow/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, "yellow")

/obj/structure/bed/sofa/l/light/New(newloc, newmaterial = MATERIAL_WOOD)
	..(newloc, newmaterial, MATERIAL_CLOTH)



//SOFA RECIPE
/datum/stack_recipe/furniture/sofa
	title = "sofa"
	result_type = /obj/structure/bed/sofa
	time = 10
	var/list/modifiers

/datum/stack_recipe/furniture/sofa/display_name()
	return modifiers ? jointext(modifiers + ..(), " ") : ..()

/datum/stack_recipe/furniture/sofa/m
	title = "middle sofa"
	req_amount = 3

#define MIDDLE_SOFA(color) /datum/stack_recipe/furniture/sofa/m/##color{\
	result_type = /obj/structure/bed/sofa/m/##color;\
	modifiers = list(#color, "middle")\
	}
MIDDLE_SOFA(beige)
MIDDLE_SOFA(black)
MIDDLE_SOFA(brown)
MIDDLE_SOFA(blue)
MIDDLE_SOFA(lime)
MIDDLE_SOFA(teal)
MIDDLE_SOFA(red)
MIDDLE_SOFA(purple)
MIDDLE_SOFA(green)
MIDDLE_SOFA(yellow)
MIDDLE_SOFA(light)
#undef MIDDLE_SOFA

/datum/stack_recipe/furniture/sofa/l
	title = "left sofa"
	req_amount = 3

#define LEFT_SOFA(color) /datum/stack_recipe/furniture/sofa/l/##color{\
	result_type = /obj/structure/bed/sofa/l/##color;\
	modifiers = list(#color, "left")\
	}
LEFT_SOFA(beige)
LEFT_SOFA(black)
LEFT_SOFA(brown)
LEFT_SOFA(blue)
LEFT_SOFA(lime)
LEFT_SOFA(teal)
LEFT_SOFA(red)
LEFT_SOFA(purple)
LEFT_SOFA(green)
LEFT_SOFA(yellow)
LEFT_SOFA(light)
#undef LEFT_SOFA

/datum/stack_recipe/furniture/sofa/r
	title = "right sofa"
	req_amount = 3

#define RIGHT_SOFA(color) /datum/stack_recipe/furniture/sofa/r/##color{\
	result_type = /obj/structure/bed/sofa/r/##color;\
	modifiers = list(#color, "right")\
	}
RIGHT_SOFA(beige)
RIGHT_SOFA(black)
RIGHT_SOFA(brown)
RIGHT_SOFA(blue)
RIGHT_SOFA(lime)
RIGHT_SOFA(teal)
RIGHT_SOFA(red)
RIGHT_SOFA(purple)
RIGHT_SOFA(green)
RIGHT_SOFA(yellow)
RIGHT_SOFA(light)
#undef RIGHT_SOFA
