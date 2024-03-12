/mob/living/carbon/slime/examine(mob/user)
	. = ..()
	if (src.stat == DEAD)
		. += SPAN_CLASS("deadsay", "It is limp and unresponsive.")
	else
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 40)
				. += SPAN_WARNING("It has some punctures in its flesh!")
			else
				. += SPAN_WARNING("<B>It has severe punctures and tears in its flesh!</B>")

		switch(powerlevel)

			if(2 to 3)
				. += SPAN_NOTICE("It is flickering gently with a little electrical activity.")

			if(4 to 5)
				. += SPAN_NOTICE("It is glowing gently with moderate levels of electrical activity.")

			if(6 to 9)
				. += SPAN_WARNING("It is glowing brightly with high levels of electrical activity.")

			if(10)
				. += SPAN_WARNING("<B>It is radiating with massive levels of electrical activity!</B>")

	. += SPAN_NOTICE("*---------*")
