/obj/item/paper/talisman/emp
	talisman_name = "ЭМИ"
	talisman_desc = "вызывает локализованный эффект ЭМИ на цель. Можно использовать на технике или мобах."
	talisman_sound = 'sound/effects/EMPulse.ogg'
	valid_target_type = list(
		/mob,
		/obj/machinery
	)


/obj/item/paper/talisman/emp/invoke(atom/target, mob/user)
	target.emp_act(1)
