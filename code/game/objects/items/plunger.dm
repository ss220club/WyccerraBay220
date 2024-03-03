/obj/item/clothing/mask/plunger
	name = "plunger"
	desc = "This is possibly the least sanitary object around."
	icon_state = "plunger_black"
	item_state = "plunger_black"
	icon = 'icons/obj/tools/plunger.dmi'
	attack_verb = list("plunged")
	force = 1
	w_class = 3
	item_flags = null
	slot_flags = SLOT_HEAD | SLOT_MASK
	hitsound = 'sound/effects/plunger.ogg'
	matter = list("steel" = 5000)

/obj/item/clothing/mask/plunger/equipped(M, slot)
	..()
	sprite_sheets[SPECIES_RESOMI] = (slot == slot_head ? 'icons/mob/species/resomi/onmob_head_resomi.dmi' : 'icons/mob/species/resomi/onmob_mask_resomi.dmi')

/obj/item/device/plunger/robot
	name = "plunger"
	desc = "a plunger. It unclogs things."
	icon_state = "plunger_black"
	item_state = "plunger_black"
	icon = 'icons/obj/tools/plunger.dmi'
	attack_verb = list("plunged")
	force = 1
	w_class = 3
	hitsound = 'sound/effects/plunger.ogg'
