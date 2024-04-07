/datum/antagonist/vox/default_access = list(GLOB.access_voxship)

/datum/antagonist/vox/create_radio(freq, mob/living/carbon/human/player)
	var/obj/item/device/radio/R = new/obj/item/device/radio/headset/map_preset/voxship(player)
	player.equip_to_slot_or_del(R, slot_l_ear)
	return R
