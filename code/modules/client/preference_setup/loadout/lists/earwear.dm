// Stuff worn on the ears. Items here go in the "ears" category but they must not use
// the slot_r_ear or slot_l_ear as the slot, or else players will spawn with no headset.
/datum/gear/ears
	display_name = "earmuffs"
	path = /obj/item/clothing/ears/earmuffs
	category = GEAR_CATEGORY_EARWEAR

/datum/gear/headphones
	display_name = "headphones"
	path = /obj/item/clothing/ears/headphones
	category = GEAR_CATEGORY_EARWEAR

/datum/gear/earrings
	display_name = "earrings"
	path = /obj/item/clothing/ears/earring
	category = GEAR_CATEGORY_EARWEAR

/datum/gear/earrings/New()
	..()
	var/earrings = list()
	earrings["stud, pearl"] = /obj/item/clothing/ears/earring/stud
	earrings["stud, glass"] = /obj/item/clothing/ears/earring/stud/glass
	earrings["stud, wood"] = /obj/item/clothing/ears/earring/stud/wood
	earrings["stud, iron"] = /obj/item/clothing/ears/earring/stud/iron
	earrings["stud, steel"] = /obj/item/clothing/ears/earring/stud/steel
	earrings["stud, silver"] = /obj/item/clothing/ears/earring/stud/silver
	earrings["stud, gold"] = /obj/item/clothing/ears/earring/stud/gold
	earrings["stud, platinum"] = /obj/item/clothing/ears/earring/stud/platinum
	earrings["stud, diamond"] = /obj/item/clothing/ears/earring/stud/diamond
	earrings["dangle, glass"] = /obj/item/clothing/ears/earring/dangle/glass
	earrings["dangle, wood"] = /obj/item/clothing/ears/earring/dangle/wood
	earrings["dangle, iron"] = /obj/item/clothing/ears/earring/dangle/iron
	earrings["dangle, steel"] = /obj/item/clothing/ears/earring/dangle/steel
	earrings["dangle, silver"] = /obj/item/clothing/ears/earring/dangle/silver
	earrings["dangle, gold"] = /obj/item/clothing/ears/earring/dangle/gold
	earrings["dangle, platinum"] = /obj/item/clothing/ears/earring/dangle/platinum
	earrings["dangle, diamond"] = /obj/item/clothing/ears/earring/dangle/diamond
	gear_tweaks += new/datum/gear_tweak/path(earrings)

/datum/gear/ears/skrell
	category = GEAR_CATEGORY_EARWEAR
	abstract_type = /datum/gear/ears/skrell
	whitelisted = list(SPECIES_SKRELL)

/datum/gear/ears/skrell/chains
	display_name = "headtail chain selection (Skrell)"
	path = /obj/item/clothing/ears/skrell/chain
	flags = GEAR_HAS_SUBTYPE_SELECTION

/datum/gear/ears/skrell/colored/chain
	display_name = "colored headtail chain, colour select (Skrell)"
	path = /obj/item/clothing/ears/skrell/colored/chain
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/ears/skrell/bands
	display_name = "headtail band selection (Skrell)"
	path = /obj/item/clothing/ears/skrell/band
	flags = GEAR_HAS_SUBTYPE_SELECTION

/datum/gear/ears/skrell/colored/band
	display_name = "headtail bands, colour select (Skrell)"
	path = /obj/item/clothing/ears/skrell/colored/band
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/ears/skrell/cloth/male
	display_name = "male headtail cloth (Skrell)"
	path = /obj/item/clothing/ears/skrell/cloth_male
	flags = GEAR_HAS_COLOR_SELECTION


/datum/gear/ears/skrell/cloth/female
	display_name = "female headtail cloth (Skrell)"
	path = /obj/item/clothing/ears/skrell/cloth_female
	flags = GEAR_HAS_COLOR_SELECTION
