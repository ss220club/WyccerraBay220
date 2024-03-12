/mob/living/silicon/robot/examine(mob/user, distance, is_adjacent)
	var/custom_infix = custom_name ? ", [modtype] [braintype]" : ""
	. = ..(user, distance, is_adjacent, infix = custom_infix)
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			. += SPAN_WARNING("It looks slightly dented.")
		else
			. += SPAN_WARNING("<B>It looks severely dented!</B>")
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			. += SPAN_WARNING("It looks slightly charred.")
		else
			. += SPAN_WARNING("<B>It looks severely burnt and heat-warped!</B>")

	if(opened)
		. += SPAN_WARNING("Its cover is open and the power cell is [cell ? "installed" : "missing"].")
	else
		. += SPAN_NOTICE("Its cover is closed.")

	if(!has_power)
		. += SPAN_WARNING("It appears to be running on backup power.")

	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)
				. += SPAN_NOTICE("It appears to be in stand-by mode.")
		if(UNCONSCIOUS)
			. += SPAN_WARNING("It doesn't seem to be responding.")
		if(DEAD)
			. += SPAN_CLASS("deadsay", "It looks completely unsalvageable.")
	. += SPAN_NOTICE("*---------*")

	if(print_flavor_text())
		. += SPAN_NOTICE("[print_flavor_text()]")

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		. += SPAN_NOTICE("It [pose]")
	user.showLaws(src)
	return
