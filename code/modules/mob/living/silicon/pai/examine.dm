/mob/living/silicon/pai/examine(mob/user, distance, is_adjacent)
	. = ..(user, distance, is_adjacent, infix = ", personal AI")
	switch(stat)
		if(CONSCIOUS)
			if(!client)
				. += SPAN_NOTICE("It appears to be in stand-by mode.")
		if(UNCONSCIOUS)
			. += SPAN_WARNING("It doesn't seem to be responding.")
		if(DEAD)
			. += SPAN_CLASS("deadsay", "It looks completely unsalvageable.")

	if(print_flavor_text())
		. += SPAN_NOTICE("[print_flavor_text()]")

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		. += SPAN_NOTICE("It is [pose]")
