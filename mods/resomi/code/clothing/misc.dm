
/*
/obj/item/clothing/mask/gas/explorer_resomi
	name = "exploratory mask"
	desc = "It looks like a tracker's mask. Too small for tall humanoids."
	icon = CUSTOM_ITEM_OBJ
	item_icons = list(slot_wear_mask_str = CUSTOM_ITEM_MOB)
	icon_state = "explorer_mask"
	item_state = "explorer_mask"
	species_restricted = list(SPECIES_RESOMI)
	sprite_sheets = list(SPECIES_RESOMI = CUSTOM_ITEM_MOB)
*/

/obj/item/clothing/accessory/necklace/collar/New()
	sprite_sheets += list(SPECIES_RESOMI = 'mods/resomi/icons/clothing/misc.dmi')
	. = ..()

/obj/item/clothing/accessory/scarf/resomi
	name = "small mantle"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	icon = 'packs/infinity/icons/obj/clothing/species/resomi/obj_accessories_resomi.dmi'
	icon_state = "small_mantle"
	species_restricted = list(SPECIES_RESOMI)

/obj/item/toy/plushie/resomi
	name = "resomi plush"
	desc = "This is a plush resomi. Very soft, with a pompom on the tail. The toy is made well, as if alive. Looks like she is sleeping. Shhh!"
	icon = 'packs/infinity/icons/obj/toy.dmi'
	icon_state = "resomiplushie"
