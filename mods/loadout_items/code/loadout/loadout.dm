/datum/gear
	var/list/allowed_factions //Background factions required to spawn with this item.

/datum/gear/plush_toy
	var/list/toy_list = list(
		"diona nymph plush" = /obj/item/toy/plushie/nymph
		"mouse plush" = /obj/item/toy/plushie/mouse
		"kitten plush" = /obj/item/toy/plushie/kitten
		"lizard plush" = /obj/item/toy/plushie/lizard
		"crow plush" = /obj/item/toy/plushie/crow
		"spider plush" = /obj/item/toy/plushie/spider
		"farwa plush" = /obj/item/toy/plushie/farwa
		"golden carp plush" = /obj/item/toy/plushie/carp_gold
		"purple carp plush" = /obj/item/toy/plushie/carp_purple
		"pink carp plush" = /obj/item/toy/plushie/carp_pink
		"corgi plush" = /obj/item/toy/plushie/corgi
		"corgi plush with bow" = /obj/item/toy/plushie/corgi_bow
		"deer plush" = /obj/item/toy/plushie/deer
		"blue squid plush" = /obj/item/toy/plushie/squid_blue
		"orange squid plush" = /obj/item/toy/plushie/squid_orange
	)

/datum/gear/plush_toy/New()
	gear_tweaks += gear_tweak_free_name(display_name)
	gear_tweaks += gear_tweak_free_desc(description)
	var/list/completed_list
	for(var/plush_name in toy_list)
		completed_list[plush_name] = toy_list[plush_name]
	gear_tweaks += new /datum/gear_tweak/path(completed_list)
