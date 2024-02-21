/datum/gear/suit/fancy_jackets
	display_name = "fancy jackets selection"
	path = /obj/item/clothing/suit

/datum/gear/suit/fancy_jackets/New()
	..()
	var/fancy_jackets = list()
	fancy_jackets += /obj/item/clothing/suit/storage/drive_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/toggle/the_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/brand_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/brand_orange_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/brand_rjacket
	fancy_jackets += /obj/item/clothing/suit/storage/hooded/faln_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/leon_jacket
	fancy_jackets += /obj/item/clothing/suit/storage/toggle/longjacket
	fancy_jackets += /obj/item/clothing/suit/storage/tgbomber
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(fancy_jackets)

/datum/gear/suit/old_pullover
	display_name = "old pullover sweater"
	path = /obj/item/clothing/suit/storage/old_pullover

/datum/gear/suit/fancy_coats
	display_name = "coats selection"
	path = /obj/item/clothing/suit

/datum/gear/suit/fancy_coats/New()
	..()
	var/fancy_coats = list()
	fancy_coats += /obj/item/clothing/suit/storage/long_coat
	fancy_coats += /obj/item/clothing/suit/storage/gentlecoat
	fancy_coats += /obj/item/clothing/suit/storage/tailcoat
	fancy_coats += /obj/item/clothing/suit/storage/jensencoat
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(fancy_coats)

/datum/gear/suit/kimono
	display_name = "kimono selection"
	path = /obj/item/clothing/suit/storage/kimono

/datum/gear/suit/kimono/New()
	..()
	var/kim = list()
	kim += /obj/item/clothing/suit/storage/kimono
	kim += /obj/item/clothing/suit/storage/kimono/blue
	kim += /obj/item/clothing/suit/storage/kimono/red_short
	kim += /obj/item/clothing/suit/storage/kimono/black
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(kim)

/datum/gear/suit/sierra_medcoat
	display_name = "medical suit selection"
	path = /obj/item/clothing/suit
	flags = GEAR_HAS_NO_CUSTOMIZATION

/datum/gear/suit/sierra_medcoat/New()
	..()
	var/medicoats = list()
	medicoats["first responder jacket"] = /obj/item/clothing/suit/storage/toggle/fr_jacket
	medicoats["first responder jacket (high-visibility)"] = /obj/item/clothing/suit/storage/toggle/fr_jacket/highvis
	medicoats["EMS jacket"] = /obj/item/clothing/suit/storage/toggle/fr_jacket/ems
	medicoats["surgical apron"] = /obj/item/clothing/suit/surgicalapron
	medicoats["medical jacket"] = /obj/item/clothing/suit/storage/toggle/fr_jacket/emrs
	gear_tweaks += new/datum/gear_tweak/path(medicoats)

/datum/gear/suit/unathi/officer_uniform
	display_name = "(Unathi) large security uniform"
	path = /obj/item/clothing/under/security/officer
	slot = slot_w_uniform

/datum/gear/suit/unathi/desert_uniform
	display_name = "(Unathi) desert uniform"
	path = /obj/item/clothing/under/security/desert
	slot = slot_w_uniform

/datum/gear/suit/unathi/paramedic_uniform
	display_name = "(Unathi) first responder uniform"
	path = /obj/item/clothing/under/medic/paramedic
	slot = slot_w_uniform

/datum/gear/suit/unathi/security_cap
	display_name = "(Unathi) big security cap"
	path = /obj/item/clothing/head/cap/sec
	slot = slot_head

/datum/gear/suit/unathi/desert_cap
	display_name = "(Unathi) suncap"
	path = /obj/item/clothing/head/cap/desert
	slot = slot_head

/datum/gear/suit/unathi/security_jacket
	display_name = "(Unathi) security jacket"
	path = /obj/item/clothing/suit/storage/security
	slot = slot_wear_suit

/datum/gear/suit/unathi/footwraps
	display_name = "(Unathi) big footwraps"
	path = /obj/item/clothing/shoes/loadout_unathi
	slot = slot_shoes
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/suit/unathi/sandals
	display_name = "(Unathi) unathi sandals"
	path = /obj/item/clothing/shoes/loadout_unathi/sandals
	slot = slot_shoes
	flags = GEAR_HAS_COLOR_SELECTION
