/datum/gear/passport/resomi
	display_name = "(Resomi) registration document"
	path = /obj/item/passport/xeno/resomi
	sort_category = "Xenowear"
	flags = 0
	whitelisted = list(SPECIES_RESOMI)
	custom_setup_proc = /obj/item/passport/proc/set_info
	cost = 0


/datum/gear/uniform/resomi
	display_name = "(Resomi) smock, grey"
	path = /obj/item/clothing/under/resomi
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)

/datum/gear/uniform/resomi/New()
	..()
	var/uniform = list()
	uniform["rainbow smock"] 	 =  /obj/item/clothing/under/resomi/rainbow
	uniform["engineering smock"] =	/obj/item/clothing/under/resomi/yellow
	uniform["robotics smock"] 	 = 	/obj/item/clothing/under/resomi/robotics
	uniform["security smock"] 	 = 	/obj/item/clothing/under/resomi/red
	gear_tweaks += new/datum/gear_tweak/path(uniform)

/datum/gear/uniform/resomi/white
	display_name = "(Resomi) smock, colored"
	path = /obj/item/clothing/under/resomi/white
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/resomi/dress
	display_name = "(Resomi) dresses selection"
	path = /obj/item/clothing/under/resomi/dress
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/resomi/utility
	display_name = "(Resomi) uniform selection"
	path = /obj/item/clothing/under/resomi/utility
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/resomi/sport
	display_name = "(Resomi) uniform, Sport"
	path = /obj/item/clothing/under/resomi/sport

/datum/gear/uniform/resomi/med
	display_name = "(Resomi) uniform, Medical"
	path = /obj/item/clothing/under/resomi/medical

/datum/gear/uniform/resomi/science
	display_name = "(Resomi) uniform, Science"
	path = /obj/item/clothing/under/resomi/science

/datum/gear/uniform/resomi/dark_worksmock
	display_name = "(Resomi) work uniform, dark"
	path = /obj/item/clothing/under/resomi/work_black
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/resomi/light_worksmock
	display_name = "(Resomi) work uniform, light"
	path = /obj/item/clothing/under/resomi/work_white
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/resomi/white/New()
	return
/datum/gear/uniform/resomi/dress/New()
	return
/datum/gear/uniform/resomi/utility/New()
	return
/datum/gear/uniform/resomi/sport/New()
	return
/datum/gear/uniform/resomi/med/New()
	return
/datum/gear/uniform/resomi/science/New()
	return
/datum/gear/uniform/resomi/dark_worksmock/New()
	return
/datum/gear/uniform/resomi/light_worksmock/New()
	return

/datum/gear/eyes/resomi
	display_name = "(Resomi) sun lenses"
	path = /obj/item/clothing/glasses/sunglasses/lenses
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)

/datum/gear/eyes/resomi/lenses_sec
	display_name = "(Resomi) sun sechud lenses"
	path = /obj/item/clothing/glasses/sunglasses/sechud/lenses

/datum/gear/eyes/resomi/lenses_med
	display_name = "(Resomi) sun medhud lenses"
	path = /obj/item/clothing/glasses/hud/health/lenses

/datum/gear/accessory/resomi_mantle
	display_name = "(Resomi) small mantle"
	path = /obj/item/clothing/accessory/scarf/resomi
	flags = GEAR_HAS_COLOR_SELECTION
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)

/datum/gear/suit/resomi_cloak
	display_name = "(Resomi) small cloak"
	path = /obj/item/clothing/suit/storage/toggle/Resomicoat
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)

/datum/gear/suit/resomi_cloak/New()
	..()
	var/resomi = list()
	resomi["black cloak"] = /obj/item/clothing/suit/storage/toggle/Resomicoat
	resomi["white cloak"] = /obj/item/clothing/suit/storage/toggle/Resomicoat/white
	gear_tweaks += new/datum/gear_tweak/path(resomi)

/datum/gear/shoes/resomi
	display_name = "(Resomi) small workboots"
	path = /obj/item/clothing/shoes/workboots/resomi
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)

/datum/gear/shoes/resomi/footwraps
	display_name = "(Resomi) foots clothwraps"
	flags = GEAR_HAS_COLOR_SELECTION
	path = /obj/item/clothing/shoes/footwraps

/datum/gear/shoes/resomi/socks
	display_name = "(Resomi) koishi"
	flags = GEAR_HAS_COLOR_SELECTION
	path = /obj/item/clothing/shoes/footwraps/socks_resomi

/datum/gear/suit/resomicloak
	display_name = "(Resomi) standard/job cloaks"
	sort_category = "Xenowear"
	path = /obj/item/clothing/suit/storage/resomicloak
	whitelisted = list(SPECIES_RESOMI)
	flags = GEAR_HAS_SUBTYPE_SELECTION

/datum/gear/suit/resomicloak_alt
	display_name = "(Resomi) alt cloaks"
	sort_category = "Xenowear"
	path = /obj/item/clothing/suit/storage/resomicloak_alt
	whitelisted = list(SPECIES_RESOMI)
	flags = GEAR_HAS_SUBTYPE_SELECTION

/datum/gear/suit/resomicloak_belted
	display_name = "(Resomi) belted cloaks"
	sort_category = "Xenowear"
	path = /obj/item/clothing/suit/storage/resomicloak_belted
	whitelisted = list(SPECIES_RESOMI)
	flags = GEAR_HAS_SUBTYPE_SELECTION

/datum/gear/suit/resomicloak
	display_name = "(Resomi) Hooded Cloak"
	sort_category = "Xenowear"
	path = /obj/item/clothing/suit/storage/hooded/resomi
	whitelisted = list(SPECIES_RESOMI)
	flags = GEAR_HAS_SUBTYPE_SELECTION


/datum/gear/suit/resomi_labcoat
	display_name = "(Resomi) small labcoat"
	path = /obj/item/clothing/suit/storage/toggle/Resomilabcoat
	flags = GEAR_HAS_COLOR_SELECTION
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)
