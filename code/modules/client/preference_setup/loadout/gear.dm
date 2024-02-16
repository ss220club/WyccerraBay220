/datum/gear
	/// Name/index. Must be unique
	var/display_name
	/// Description of this gear. If left blank will default to the description of the pathed item
	var/description
	/// Path to item
	var/path
	/// Number of points used. Items in general cost 1 point, storage/armor/gloves/special use costs 2 points
	var/cost = 1
	/// Slot to equip to
	var/slot
	/// Roles that can spawn with this item
	var/list/allowed_roles
	/// Service branches that can spawn with it
	var/list/allowed_branches
	/// Skills required to spawn with this item
	var/list/allowed_skills
	/// Factions required to spawn with this item
	var/list/allowed_factions
	/// Term to check the whitelist for.
	var/whitelisted
	/// Category that will be used to properly sort gear
	var/sort_category = "General"
	/// Special tweaks in New
	var/flags
	/// Special tweak in New
	var/custom_setup_proc
	/// Category that will be used to properly group the gear
	var/category
	/// Donation tier the player should have to access this gear
	var/donation_tier = DONATION_TIER_NONE
	/// List of datums which will alter the item after it has been spawned
	var/list/gear_tweaks = list()

/datum/gear/New()
	if(HAS_FLAGS(flags, GEAR_HAS_TYPE_SELECTION|GEAR_HAS_SUBTYPE_SELECTION))
		CRASH("May not have both type and subtype selection tweaks")

	if(!description)
		var/obj/O = path
		description = initial(O.desc)

	if(flags & GEAR_HAS_COLOR_SELECTION)
		gear_tweaks += gear_tweak_free_color_choice()

	if(!(flags & GEAR_HAS_NO_CUSTOMIZATION))
		gear_tweaks += gear_tweak_free_name(display_name)
		gear_tweaks += gear_tweak_free_desc(description)

	if(flags & GEAR_HAS_TYPE_SELECTION)
		gear_tweaks += new/datum/gear_tweak/path/type(path)

	if(flags & GEAR_HAS_SUBTYPE_SELECTION)
		gear_tweaks += new/datum/gear_tweak/path/subtype(path)

	if(custom_setup_proc)
		gear_tweaks += new/datum/gear_tweak/custom_setup(custom_setup_proc)

/datum/gear/proc/get_description(metadata)
	. = description
	for(var/datum/gear_tweak/gt in gear_tweaks)
		. = gt.tweak_description(., metadata["[gt]"])

/datum/gear/proc/is_allowed_to_equip(client/client_to_check)
	client_to_check = resolve_client(client_to_check)
	ASSERT(client_to_check)
	ASSERT(client_to_check.donator_info)

	return !donation_tier || client_to_check.donator_info.donation_tier_available(donation_tier)

/datum/gear/proc/spawn_as_accessory_on_mob(mob/living/carbon/human/H, metadata)
	return H.equip_to_slot_or_del(spawn_item(H, H, metadata), slot_tie)

/datum/gear/proc/spawn_item(mob/user, atom/location, metadata)
	var/datum/gear_data/gd = new(path, location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_gear_data(metadata && metadata["[gt]"], gd)

	var/item = new gd.path(gd.location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_item(user, item, metadata && metadata["[gt]"])

	return item

/datum/gear/proc/spawn_on_mob(mob/living/carbon/human/H, metadata)
	var/obj/item/item_to_equip = spawn_item(H, H, metadata)
	if(H.equip_to_slot_if_possible(spawn_item(H, H, metadata), slot, TRYEQUIP_REDRAW | TRYEQUIP_DESTROY | TRYEQUIP_FORCE))
		return item_to_equip

	return null

/datum/gear/proc/spawn_in_storage_or_drop(mob/living/carbon/human/subject, metadata)
	var/obj/item/item = spawn_item(subject, subject, metadata)
	item.add_fingerprint(subject)
	if (istype(item, /obj/item/organ/internal/augment))
		var/obj/item/organ/internal/augment/augment = item
		var/obj/item/organ/external/parent = augment.get_valid_parent_organ(subject)
		if (!parent)
			to_chat(subject, SPAN_WARNING("Failed to find a valid organ to install \the [augment] into!"))
			qdel(augment)
			return

		var/surgery_step = GET_SINGLETON(/singleton/surgery_step/internal/replace_organ)
		if (augment.surgery_configure(subject, subject, parent, null, surgery_step))
			to_chat(subject, SPAN_WARNING("Failed to set up \the [augment] for installation in your [parent.name]!"))
			qdel(augment)
			return

		augment.forceMove(subject)
		augment.replaced(subject, parent)
		augment.onRoundstart()
		return

	var/atom/container = subject.equip_to_storage(item)
	if (subject.equip_to_appropriate_slot(item))
		to_chat(subject, SPAN_NOTICE("Placing \the [item] in your inventory!"))
	else if (container)
		to_chat(subject, SPAN_NOTICE("Placing \the [item] in your [container.name]!"))
	else if (subject.put_in_hands(item))
		to_chat(subject, SPAN_NOTICE("Placing \the [item] in your hands!"))
	else
		to_chat(subject, SPAN_WARNING("Dropping \the [item] on the ground!"))

/datum/gear_data
	var/path
	var/location

/datum/gear_data/New(path, location)
	src.path = path
	src.location = location

/// Objects that represents single gear slot in preference.
/// Includes slot number and list of gear.
/datum/gear_slot
	VAR_PRIVATE/slot_number = 1
	/// Assoc list of `gear_name` => `gear_tweaks_list`
	VAR_PRIVATE/list/gear_entries = list()

/datum/gear_slot/New(slot_number, list/gear_entries)
	ASSERT(slot_number > 0)

	src.slot_number = slot_number
	if(!gear_entries)
		return

	for(var/entry in gear_entries)
		var/list/tweaks = gear_entries[entry]
		if(!islist(tweaks))
			tweaks = list()

		src.gear_entries[entry] = tweaks

/// Get copy of `get_gear_entries` list
/datum/gear_slot/proc/get_gear_entries()
	return gear_entries.Copy()

/// Updates content of slot. Valid list must be passed
/datum/gear_slot/proc/remove_gear(list/gear_to_remove)
	if(!length(gear_to_remove))
		return

	gear_entries -= gear_to_remove

/// Return list of tweaks applied to desired gear. Return `null` if no tweaks or no gear by name found
/datum/gear_slot/proc/get_gear_tweaks(gear_name)
	if(!gear_name)
		return list()

	var/list/tweaks = gear_entries[gear_name]
	return tweaks?.Copy() || list()

/// Calculate total cost of the gear this slot has
/datum/gear_slot/proc/get_total_gear_cost()
	var/total_cost = 0
	for(var/gear_name in gear_entries)
		var/datum/gear/gear_datum = gear_datums[gear_name]
		if(!gear_datum)
			continue

		total_cost += gear_datum.cost

	return total_cost

/// Returns slot number this gear slot has
/datum/gear_slot/proc/get_slot_number()
	return slot_number

/// Returns whether this slot contains specific gear
/datum/gear_slot/proc/contains(gear_name)
	return !!gear_entries[gear_name]

/// Clears `gear_entries` list
/datum/gear_slot/proc/clear()
	gear_entries.Cut()

/// Add gear to slot
/datum/gear_slot/proc/add_gear(gear_name, list/tweaks)
	gear_entries[gear_name] = islist(tweaks) ? tweaks.Copy() : list()

/// Simple objects that represents all gear slots the player has in preferences.
/datum/gear_slots_container
	/// Max size of the container. New gear slots are added to `gear_slots` when required
	VAR_PRIVATE/size = 1
	/// The gear slot that is currently displayed in preferences
	VAR_PRIVATE/picked_gear_slot = 1
	/// The flat list of gear slots, where index of slot in the list is slot number
	VAR_PRIVATE/list/gear_slots = list()

/datum/gear_slots_container/New(size = config.loadout_slots, picked_gear_slot = 1, list/gear_slots)
	ASSERT(size > 0)
	ASSERT(picked_gear_slot > 0)

	src.size = sanitize_integer(size, 1, config.loadout_slots, config.loadout_slots)
	src.picked_gear_slot = sanitize_integer(picked_gear_slot, 1, size, 1)
	if(!length(gear_slots))
		fill_with_slots()
		return

	LIST_RESIZE(gear_slots, size)
	for(var/slot_index = 1 to length(gear_slots))
		var/list/gear_entries = gear_slots[slot_index]
		if(!islist(gear_entries))
			stack_trace("[gear_entries.type] is not supported type. `/list` expected")
			continue

		src.gear_slots += new /datum/gear_slot(slot_index, gear_entries)

/// Get currently picked gear slot. If no valid slot picked, we pick the first one
/datum/gear_slots_container/proc/get_picked_gear_slot()
	return gear_slots[get_picked_gear_slot_number()]

/// Get currently picked gear slot number.
/datum/gear_slots_container/proc/get_picked_gear_slot_number()
	picked_gear_slot = sanitize_integer(picked_gear_slot, 1, config.loadout_slots, initial(picked_gear_slot))
	return picked_gear_slot

/// Trims `gear_slots` to desired size. `trim_size` must be greater or equal to 0.
/datum/gear_slots_container/proc/set_size(new_size)
	ASSERT(new_size > 0)

	if(size == new_size)
		return

	var/old_size = size
	size = new_size
	if(size > old_size)
		fill_with_slots()
	else
		LIST_RESIZE(gear_slots, new_size)

/// Get copy of `get_gear_slots` list
/datum/gear_slots_container/proc/get_gear_slots()
	if(!gear_slots)
		stack_trace("`gear_slots` in `/datum/gear_slots_container` is null")
		gear_slots = list()

	return gear_slots.Copy()

/// Returs the size of the container
/datum/gear_slots_container/proc/get_size()
	return size

/// Sets `picked_gear_slot` to the `picked_gear_slot + 1`, or to 1 if overflowed
/datum/gear_slots_container/proc/cycle_slot_right()
	if(size <= 1)
		return

	picked_gear_slot = sanitize_integer(picked_gear_slot + 1, 1, size, 1)

/// Sets `picked_gear_slot` to the `picked_gear_slot - 1`, or to length(gear_slots) if new slot is <= 0
/datum/gear_slots_container/proc/cycle_slot_left()
	if(size <= 1)
		return

	picked_gear_slot = sanitize_integer(picked_gear_slot - 1, 1, size, size)

/// Create new `/datum/gear_slot` until `gear_slots` length wil be equal to `size`.
/// If the `gear_slots` is already of desired size, no changes will happen
/datum/gear_slots_container/proc/fill_with_slots(list/new_slots)
	var/slots_amount = length(gear_slots)
	if(slots_amount == size)
		return

	for(var/slot_index = slots_amount + 1 to size)
		gear_slots.Insert(slot_index, new /datum/gear_slot(slot_index))
