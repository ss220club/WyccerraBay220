/datum/gear/head/surgical
	allowed_roles = STERILE_ROLES

/datum/gear/head/hardhat
	allowed_roles = TECHNICAL_ROLES

/datum/gear/head/welding
	allowed_roles = TECHNICAL_ROLES

/datum/gear/head/beret_selection
	display_name = "contractor beret selection"
	description = "A list of berets used by various organizations and corporights."
	path = /obj/item/clothing/head/beret
	allowed_roles = SECURITY_ROLES

/datum/gear/head/beret_selection/New()
	..()
	var/beret_selection_type = list()
	beret_selection_type["white-blue corporight security beret"] = /obj/item/clothing/head/beret/guard
	beret_selection_type["white-red corporight security beret"] = /obj/item/clothing/head/beret/sec/corporate/whitered
	beret_selection_type["SAARE beret"] = /obj/item/clothing/head/beret/sec/corporate/saare
	beret_selection_type["PCRC beret"] = /obj/item/clothing/head/beret/sec/corporate/pcrc
	beret_selection_type["ZPCI beret"] = /obj/item/clothing/head/beret/sec/corporate/zpci
	gear_tweaks += new/datum/gear_tweak/path(beret_selection_type)

/datum/gear/suit/unathi/security_cap
	allowed_roles = SECURITY_ROLES

/datum/gear/head/skrell_helmet
	allowed_roles = ARMORED_ROLES

/datum/gear/head/skrell_helmet/New()
	..()
	var/list/helmets = list()
	helmets["black skrellian helmet"] = /obj/item/clothing/head/helmet/skrell
	helmets["navy skrellian helmet"] = /obj/item/clothing/head/helmet/skrell/navy
	helmets["green skrellian helmet"] = /obj/item/clothing/head/helmet/skrell/green
	helmets["tan skrellian helmet"] = /obj/item/clothing/head/helmet/skrell/tan
	gear_tweaks += new/datum/gear_tweak/path(helmets)
