/*
General Explination:
The research datum is the "folder" where all the research information is stored in a R&D console. It's also a holder for all the
various procs used to manipulate it. It has four variables and seven procs:

Variables:
- possible_tech is a list of all the /datum/tech that can potentially be researched by the player. The refresh_research() proc
(explained later) only goes through those when refreshing what you know. Generally, possible_tech contains ALL of the existing tech
but it is possible to add tech to the game that DON'T start in it (example: Xeno tech). Generally speaking, you don't want to mess
with these since they should be the default version of the datums. They're actually stored in a list rather then using typesof to
refer to them since it makes it a bit easier to search through them for specific information.
- know_tech is the companion list to possible_tech. It's the tech you can actually research and improve. Until it's added to this
list, it can't be improved. All the tech in this list are visible to the player.
- possible_designs is functionally identical to possbile_tech except it's for /datum/design.
- known_designs is functionally identical to known_tech except it's for /datum/design

Procs:
- TechHasReqs: Used by other procs (specifically refresh_research) to see whether all of a tech's requirements are currently in
known_tech and at a high enough level.
- design_available: Same as TechHasReqs but for /datum/design and known_design.
- add_tech_to_known: Adds a /datum/tech to known_tech. It checks to see whether it already has that tech (if so, it just replaces it). If
it doesn't have it, it adds it. Note: It does NOT check possible_tech at all. So if you want to add something strange to it (like
a player made tech?) you can.
- add_design_to_known: Same as add_tech_to_known except for /datum/design and known_designs.
- refresh_research: This is the workhorse of the R&D system. It updates the /datum/research holder and adds any unlocked tech paths
and designs you have reached the requirements for. It only checks through possible_tech and possible_designs, however, so it won't
accidentally add "secret" tech to it.
- update_tech is used as part of the actual researching process. It takes an ID and finds techs with that same ID in known_tech. When
it finds it, it checks to see whether it can improve it at all. If the known_tech's level is less then or equal to
the inputted level, it increases the known tech's level to the inputted level -1 or know tech's level +1 (whichever is higher).

The tech datums are the actual "tech trees" that you improve through researching. Each one has five variables:
- Name:		Pretty obvious. This is often viewable to the players.
- Desc:		Pretty obvious. Also player viewable.
- ID:		This is the unique ID of the tech that is used by the various procs to find and/or maniuplate it.
- Level:	This is the current level of the tech. All techs start at 1 and have a max of 20. Devices and some techs require a certain
level in specific techs before you can produce them.
- Req_tech:	This is a list of the techs required to unlock this tech path. If left blank, it'll automatically be loaded into the
research holder datum.

*/
/***************************************************************
**						Master Types						  **
**	Includes all the helper procs and basic tech processing.  **
***************************************************************/

//Holder for all the existing, archived, and known tech. Individual to console.
/datum/research
	/// List of available designs as: design_id => design. For faster lookup
	var/list/known_designs_lookup = list()
	/// Designs sorted by `sort_string`.
	var/list/known_designs = list()
	/// List of locally known tech as: tech.id => /datum/tech. For faster lookup
	var/list/known_tech_lookup = list()
	/// List of locally known techs. For faster iteration
	var/list/known_tech = list()
	/// List of all existing designs.
	var/static/list/possible_designs = list()

//Insert techs into possible_tech here. Known_tech automatically updated.
/datum/research/New()
	if(!length(possible_designs))
		for(var/design_path in subtypesof(/datum/design))
			possible_designs += new design_path(src)

	initialize_tech()
	refresh_research()

/datum/research/proc/initialize_tech()
	for(var/tech_path in subtypesof(/datum/tech))
		var/datum/tech/new_tech = new tech_path(src)
		known_tech_lookup[new_tech.id] = new_tech
		known_tech += new_tech

/datum/research/techonly/New()
	initialize_tech()
	refresh_research()

/// Checks to see if design has all the required pre-reqs.
/// Input: datum/design; Output: TRUE/FALSE
/datum/research/proc/design_available(datum/design/design_to_check)
	if(!length(design_to_check.req_tech))
		return TRUE

	for(var/required_tech_id in design_to_check.req_tech)
		var/datum/tech/known_tech_item = known_tech_lookup[required_tech_id]
		var/known_tech_level = known_tech_item.level
		if(!known_tech_level || known_tech_level < design_to_check.req_tech[required_tech_id])
			return FALSE

	return TRUE

//Adds a tech to known_tech list. Checks to make sure there aren't duplicates and updates existing tech's levels if needed.
//Input: datum/tech; Output: Null
/datum/research/proc/add_tech_to_known(datum/tech/tech_to_add)
	ASSERT(istype(tech_to_add))

	var/datum/tech/known_tech_item = known_tech_lookup[tech_to_add.id]
	if(!known_tech_item)
		known_tech_lookup[tech_to_add.id] = tech_to_add
		known_tech += tech_to_add
		return

	if(tech_to_add.level > known_tech_item.level)
		known_tech_item.level = tech_to_add.level

/datum/research/proc/add_design_to_known(datum/design/design_to_add)
	if(!istype(design_to_add))
		return

	var/datum/design/existing_design = known_designs_lookup[design_to_add.id]
	if(existing_design)
		return

	known_designs_lookup[design_to_add.id] = design_to_add
	BINARY_INSERT(design_to_add, known_designs, /datum/design, design_to_add, sort_string, COMPARE_KEY)

/datum/research/proc/remove_design(design_id)
	ASSERT(design_id)

	var/datum/design/design_to_remove = known_designs_lookup[design_id]
	if(!design_to_remove)
		return FALSE

	known_designs_lookup -= design_id
	known_designs -= design_to_remove

	return TRUE

/datum/research/proc/reset_tech(tech_id)
	ASSERT(tech_id)

	var/datum/tech/tech_to_reset = known_tech_lookup[tech_id]
	if(!tech_to_reset)
		return FALSE

	if(tech_to_reset.level <= 0)
		return FALSE

	tech_to_reset.level = 1
	return TRUE

//Refreshes known_tech and known_designs list
//Input/Output: n/a
/datum/research/proc/refresh_research()
	for(var/datum/design/possible_design as anything in possible_designs)
		if(design_available(possible_design))
			add_design_to_known(possible_design)

	for(var/datum/tech/tech_to_refresh as anything in known_tech)
		tech_to_refresh.level = clamp(tech_to_refresh.level, 0, 20)

//Refreshes the levels of a given tech.
//Input: Tech's ID and Level; Output: null
/datum/research/proc/update_tech(tech_id, level)
	ASSERT(tech_id)
	ASSERT(level)

	// If a "brain expansion" event is active, we gain 1 extra level
	if(SSevent.is_event_of_type_active(/datum/event/brain_expansion))
		level++

	var/datum/tech/tech_to_update = known_tech_lookup[tech_id]
	if(!tech_to_update)
		stack_trace("Tech with id `[tech_id]` being update, while not present in research tree")
		return

	if(tech_to_update.level > level)
		return

	tech_to_update.level = max(tech_to_update.level + 1, level - 1)
