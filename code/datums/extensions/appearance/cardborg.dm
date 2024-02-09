/datum/extension/appearance/cardborg
	expected_type = /obj/item
	appearance_handler_type = /singleton/appearance_handler/cardborg
	item_equipment_proc = type_proc_ref(/singleton/appearance_handler/cardborg, item_equipped)
	item_removal_proc = type_proc_ref(/singleton/appearance_handler/cardborg, item_removed)
