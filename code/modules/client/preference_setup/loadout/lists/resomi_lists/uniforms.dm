
/datum/gear/uniform/resomi
	display_name = "(Resomi) uniform, colored"
	path = /obj/item/clothing/under/resomi/white
	whitelisted = list(SPECIES_RESOMI)
	flags = GEAR_HAS_COLOR_SELECTION


/datum/gear/uniform/resomi/smock
	display_name = "(Resomi) uniform, standart"
	path = /obj/item/clothing/under/resomi
	flags = 0

/datum/gear/uniform/resomi/smock/New()
	..()
	var/uniform = list()
	uniform["rainbow smock"]	 =	/obj/item/clothing/under/resomi/rainbow
	uniform["sport uniform"]	 =	/obj/item/clothing/under/resomi/sport
	uniform["black utility uniform"]	 =	/obj/item/clothing/under/resomi/utility
	uniform["grey utility uniform"]	 =	/obj/item/clothing/under/resomi/utility/black
	uniform["engineering smock"] =	/obj/item/clothing/under/resomi/yellow
	uniform["robotics smock"]	 =	/obj/item/clothing/under/resomi/robotics
	uniform["security smock"]	 =	/obj/item/clothing/under/resomi/red
	uniform["medical uniform"]	 =	/obj/item/clothing/under/resomi/medical
	uniform["science uniform"]	 =	/obj/item/clothing/under/resomi/science
	gear_tweaks += new/datum/gear_tweak/path(uniform)


/datum/gear/uniform/resomi/expedition
	display_name = "(Resomi) uniform, expeditionary"
	path = /obj/item/clothing/under/solgov
	flags = 0

/datum/gear/uniform/resomi/expedition/New()
	..()
	var/uniform = list()
	uniform["standart uniform"]	 =	/obj/item/clothing/under/solgov/utility/expeditionary/resomi
	uniform["pt smock"]			 =	/obj/item/clothing/under/solgov/pt/expeditionary/resomi
	uniform["officer's uniform"] =	/obj/item/clothing/under/solgov/utility/expeditionary/officer/resomi
	uniform["dress uniform"]	 =	/obj/item/clothing/under/solgov/mildress/expeditionary/resomi
	gear_tweaks += new/datum/gear_tweak/path(uniform)


/datum/gear/uniform/resomi/dress
	display_name = "(Resomi) uniform, dress"
	path = /obj/item/clothing/under/resomi/dress
	flags = GEAR_HAS_TYPE_SELECTION


/datum/gear/uniform/resomi/worksmock
	display_name = "(Resomi) uniform, work"
	path = /obj/item/clothing/under/resomi/work
	flags = GEAR_HAS_TYPE_SELECTION


/datum/gear/uniform/resomi/undercoat
	display_name = "(Resomi) uniform, undercoat"
	path = /obj/item/clothing/under/resomi/undercoat
	flags = GEAR_HAS_TYPE_SELECTION
