/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/shipping_crates.dmi'
	icon_state = "densecrate"
	density = TRUE
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_CLIMBABLE
	health_max = 100
	health_min_damage = 4

/obj/structure/largecrate/Initialize()
	. = ..()
	for(var/obj/I in src.loc)
		if(I.density || I.anchored || I == src || !I.simulated)
			continue
		I.forceMove(src)

/obj/structure/largecrate/attack_hand(mob/user as mob)
	if (user.a_intent == I_HURT)
		return ..()
	to_chat(user, SPAN_NOTICE("You need a crowbar to pry this open!"))

/obj/structure/largecrate/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	var/obj/item/stack/material/wood/A = new(loc)
	transfer_fingerprints_to(A)
	dump_contents()
	user.visible_message(
		SPAN_NOTICE("[user] pries [src] open with [tool]."),
		SPAN_NOTICE("You pry [src] open with [tool]."),
		SPAN_ITALIC("You hear splitting wood.")
	)
	qdel(src)

/obj/structure/largecrate/on_death()
	var/obj/item/stack/material/wood/A = new(loc)
	transfer_fingerprints_to(A)
	dump_contents()
	qdel_self()

/obj/structure/largecrate/mule
	name = "MULE crate"

/obj/structure/largecrate/animal
	icon_state = "mulecrate"
	var/held_count = 1
	var/held_type

/obj/structure/largecrate/animal/New()
	..()
	if(held_type)
		for(var/i = 1;i<=held_count;i++)
			new held_type(src)

/obj/structure/largecrate/animal/mulebot
	name = "Mulebot crate"
	held_type = /mob/living/bot/mulebot

/obj/structure/largecrate/animal/corgi
	name = "corgi carrier"
	held_type = /mob/living/simple_animal/passive/corgi

/obj/structure/largecrate/animal/cow
	name = "cow crate"
	held_type = /mob/living/simple_animal/passive/cow

/obj/structure/largecrate/animal/goat
	name = "goat crate"
	held_type = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/largecrate/animal/goose
	name = "goose containment unit"
	held_type = /mob/living/simple_animal/hostile/retaliate/goose

/obj/structure/largecrate/animal/cat
	name = "cat carrier"
	held_type = /mob/living/simple_animal/passive/cat

/obj/structure/largecrate/animal/cat/bones
	held_type = /mob/living/simple_animal/passive/cat/fluff/bones

/obj/structure/largecrate/animal/chick
	name = "chicken crate"
	held_count = 5
	held_type = /mob/living/simple_animal/passive/chick
