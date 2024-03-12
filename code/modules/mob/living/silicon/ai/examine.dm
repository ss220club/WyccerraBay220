/mob/living/silicon/ai/examine(mob/user)
	. = ..()
	if (stat == DEAD)
		. += "[SPAN_CLASS("deadsay", "It appears to be powered-down.")]"
	else
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				. += SPAN_WARNING("It looks slightly dented.")
			else
				. += SPAN_WARNING("<B>It looks severely dented!</B>")
		if (getFireLoss())
			if (getFireLoss() < 30)
				. += SPAN_WARNING("It looks slightly charred.")
			else
				. += SPAN_WARNING("<B>Its casing is melted and heat-warped!</B>")
		if (!has_power())
			if (getOxyLoss() > 175)
				. += SPAN_WARNING("<B>It seems to be running on backup power. Its display is blinking a \"BACKUP POWER CRITICAL\" warning.</B>")
			else if(getOxyLoss() > 100)
				. += SPAN_WARNING("<B>It seems to be running on backup power. Its display is blinking a \"BACKUP POWER LOW\" warning.</B>")
			else
				. += SPAN_WARNING("It seems to be running on backup power.")

		if (stat == UNCONSCIOUS)
			. += SPAN_WARNING("It is non-responsive and displaying the text: \"RUNTIME: Sensory Overload, stack 26/3\".")
	. += SPAN_NOTICE("*---------*")
	if(hardware && (hardware.owner == src))
		. += SPAN_NOTICE(hardware.get_examine_desc())
	user.showLaws(src)

/mob/proc/showLaws(mob/living/silicon/S)
	return

/mob/observer/ghost/showLaws(mob/living/silicon/S)
	if(antagHUD || isadmin(src))
		S.laws.show_laws(src)
