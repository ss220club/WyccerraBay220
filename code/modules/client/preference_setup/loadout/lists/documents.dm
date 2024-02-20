/datum/gear/document
	category = GEAR_CATEGORY_DOCUMENTS
	abstract_type = /datum/gear/document

/datum/gear/document/passport
	display_name = "passports selection - independent"
	description = "A selection of independent regions passports."
	path = /obj/item/passport/independent
	flags = GEAR_HAS_SUBTYPE_SELECTION
	custom_setup_proc = TYPE_PROC_REF(/obj/item/passport, set_info)
	cost = 0

/datum/gear/document/union_card
	display_name = "union membership"
	path = /obj/item/card/union

/datum/gear/document/union_card/spawn_on_mob(mob/living/carbon/human/H, metadata)
	. = ..()
	if(.)
		var/obj/item/card/union/card = .
		card.signed_by = H.real_name

/datum/gear/document/workvisa
	display_name = "work visa"
	description = "A work visa issued by the Sol Central Government for the purpose of work."
	path = /obj/item/paper/workvisa

/datum/gear/document/travelvisa
	display_name = "travel visa"
	description = "A travel visa issued by the Sol Central Government for the purpose of recreation."
	path = /obj/item/paper/travelvisa
