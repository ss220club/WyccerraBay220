/datum/gear/suit/resomi
	display_name = "(Resomi) cloaks, alt"
	path = /obj/item/clothing/suit/storage/resomicloak_alt
	whitelisted = list(SPECIES_RESOMI)
	flags = GEAR_HAS_SUBTYPE_SELECTION

/datum/gear/suit/resomi/standart
	display_name = "(Resomi) cloaks, standart"
	path = /obj/item/clothing/suit/storage/resomicloak
	flags = GEAR_HAS_TYPE_SELECTION


/datum/gear/suit/resomi/belted
	display_name = "(Resomi) cloaks, belted"
	path = /obj/item/clothing/suit/storage/resomicloak_belted


/datum/gear/suit/resomi/hood
	display_name = "(Resomi) cloaks, hooded"
	path = /obj/item/clothing/suit/storage/hooded/resomi


/datum/gear/suit/resomi/labcoat
	display_name = "(Resomi) small labcoat"
	path = /obj/item/clothing/suit/storage/toggle/resomilabcoat
	flags = GEAR_HAS_COLOR_SELECTION


/datum/gear/suit/resomi_coat
	display_name = "(Resomi) coats selection"
	path = /obj/item/clothing/suit/storage/toggle/resomicoat
	whitelisted = list(SPECIES_RESOMI)

/datum/gear/suit/resomi_coat/New()
	..()
	var/resomi = list()
	resomi["black coat"] = /obj/item/clothing/suit/storage/toggle/resomicoat
	resomi["white coat"] = /obj/item/clothing/suit/storage/toggle/resomicoat/white
	gear_tweaks += new/datum/gear_tweak/path(resomi)
