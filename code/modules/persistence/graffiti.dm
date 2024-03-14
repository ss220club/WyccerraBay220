/obj/decal/writing
	name = "graffiti"
	icon_state = "writing1"
	icon = 'icons/effects/writing.dmi'
	desc = "It looks like someone has scratched something here."
	gender = PLURAL
	blend_mode = BLEND_MULTIPLY
	color = "#000000"
	alpha = 120
	anchored = TRUE

	var/message
	var/graffiti_age = 0
	var/author = "unknown"

/obj/decal/writing/New(newloc, _age, _message, _author)
	..(newloc)
	if(!isnull(_age))
		graffiti_age = _age
	message = _message
	if(!isnull(author))
		author = _author

/obj/decal/writing/Initialize()
	var/list/random_icon_states = ICON_STATES(icon)
	for(var/obj/decal/writing/W in loc)
		random_icon_states.Remove(W.icon_state)
	if(length(random_icon_states))
		icon_state = pick(random_icon_states)
	SSpersistence.track_value(src, /datum/persistent/graffiti)
	. = ..()

/obj/decal/writing/Destroy()
	SSpersistence.forget_value(src, /datum/persistent/graffiti)
	. = ..()

/obj/decal/writing/examine(mob/user)
	. = ..(user)
	to_chat(user,  "It reads \"[message]\".")

/obj/decal/writing/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.tool_start_check(user, 1))
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts burning away [src] with [tool]."),
		SPAN_NOTICE("You start burning away [src] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 1 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	user.visible_message(
		SPAN_NOTICE("[user] clears away [src] with [tool]."),
		SPAN_NOTICE("You clear away [src] with [tool].")
	)
	qdel(src)

/obj/decal/writing/use_tool(obj/item/tool, mob/user, list/click_params)
	// Sharp Item - Engrave additional message
	if (is_sharp(tool))
		var/turf/target = get_turf(src)
		target.try_graffiti(user, tool)
		return TRUE
	. = ..()
