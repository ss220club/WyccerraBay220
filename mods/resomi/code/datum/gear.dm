/datum/gear/passport/resomi
	display_name = "(Resomi) registration document"
	path = /obj/item/passport/xeno/resomi
	sort_category = "Xenowear"
	flags = 0
	whitelisted = list(SPECIES_RESOMI)
	custom_setup_proc = /obj/item/passport/proc/set_info
	cost = 0


/datum/gear/uniform/resomi
	display_name = "(Resomi) uniform, Sport"
	path = /obj/item/clothing/under/resomi/sport
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)


/datum/gear/uniform/resomi/smock
	display_name = "(Resomi) smocks selection"
	path = /obj/item/clothing/under/resomi

/datum/gear/uniform/resomi/smock/New()
	..()
	var/uniform = list()
	uniform["rainbow smock"]	 =	/obj/item/clothing/under/resomi/rainbow
	uniform["engineering smock"] =	/obj/item/clothing/under/resomi/yellow
	uniform["robotics smock"]	 =	/obj/item/clothing/under/resomi/robotics
	uniform["security smock"]	 =	/obj/item/clothing/under/resomi/red
	gear_tweaks += new/datum/gear_tweak/path(uniform)


/datum/gear/uniform/resomi/color
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

/datum/gear/uniform/resomi/dark_worksmock
	display_name = "(Resomi) work uniform, dark"
	path = /obj/item/clothing/under/resomi/work_black
	flags = GEAR_HAS_TYPE_SELECTION


/datum/gear/uniform/resomi/light_worksmock
	display_name = "(Resomi) work uniform, light"
	path = /obj/item/clothing/under/resomi/work_white
	flags = GEAR_HAS_TYPE_SELECTION


/datum/gear/uniform/resomi/med
	display_name = "(Resomi) uniform, Medical"
	path = /obj/item/clothing/under/resomi/medical


/datum/gear/uniform/resomi/science
	display_name = "(Resomi) uniform, Science"
	path = /obj/item/clothing/under/resomi/science


/datum/gear/eyes/resomi
	display_name = "(Resomi) sun lenses"
	path = /obj/item/clothing/glasses/sunglasses/lenses
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)


/datum/gear/eyes/security/resomi
	display_name = "(Resomi) sun sechud lenses"
	path = /obj/item/clothing/glasses/sunglasses/sechud/lenses
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)


/datum/gear/eyes/medical/resomi
	display_name = "(Resomi) sun medhud lenses"
	path = /obj/item/clothing/glasses/hud/health/lenses
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)


/datum/gear/accessory/resomi_mantle
	display_name = "(Resomi) small mantle"
	path = /obj/item/clothing/accessory/scarf/resomi
	flags = GEAR_HAS_COLOR_SELECTION
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)


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


/datum/gear/suit/resomi
	display_name = "(Resomi) standard/job cloaks"
	path = /obj/item/clothing/suit/storage/resomicloak
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)
	flags = GEAR_HAS_SUBTYPE_SELECTION


/datum/gear/suit/resomi/cloak
	display_name = "(Resomi) small cloak"
	path = /obj/item/clothing/suit/storage/toggle/Resomicoat
	flags = GEAR_HAS_TYPE_SELECTION


/datum/gear/suit/resomi/alt
	display_name = "(Resomi) alt cloaks"
	path = /obj/item/clothing/suit/storage/resomicloak_alt


/datum/gear/suit/resomi/belted
	display_name = "(Resomi) belted cloaks"
	path = /obj/item/clothing/suit/storage/resomicloak_belted


/datum/gear/suit/resomi/hood
	display_name = "(Resomi) Hooded Cloak"
	path = /obj/item/clothing/suit/storage/hooded/resomi


/datum/gear/suit/resomi/labcoat
	display_name = "(Resomi) small labcoat"
	path = /obj/item/clothing/suit/storage/toggle/Resomilabcoat
	flags = GEAR_HAS_COLOR_SELECTION
