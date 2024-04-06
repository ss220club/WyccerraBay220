/obj/item/clothing/gloves/daft_punk
	name = "Daft Punk gloves"
	desc = "DJs' most comfortable gloves."
	icon = 'maps/sierra/icons/obj/clothing/obj_hands.dmi'
	icon_override = 'maps/sierra/icons/mob/onmob/onmob_hands.dmi'
	icon_state = "daft_gloves"
	item_state = null

/obj/item/clothing/gloves/wristwatch
	name = "watch"
	desc = "A wristwatch. This one is silver and EMP-resistance."
	icon = 'maps/sierra/icons/obj/clothing/obj_hands.dmi'
	item_icons = list(slot_gloves_str = 'maps/sierra/icons/mob/onmob/onmob_hands.dmi')
	icon_state = "watch_black"
	item_state = "watch_black"

/obj/item/clothing/gloves/wristwatch/gold
	name = "gold watch"
	desc = "A wristwatch. This one is golden and in makes you feel like a boss."
	icon_state = "watch_gold"
	item_state = "watch_gold"

/obj/item/clothing/gloves/wristwatch/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It displays [stationtime2text()]")
