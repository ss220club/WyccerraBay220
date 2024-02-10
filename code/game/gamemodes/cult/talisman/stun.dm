/obj/item/paper/talisman/stun
	talisman_name = "ошеломление"
	talisman_desc = "временно оглушает выбранного моба ослепляющей и дезориентирующей вспышкой света"
	talisman_sound = 'sound/weapons/flash.ogg'
	valid_target_type = list(
		/mob/living/carbon,
		/mob/living/silicon,
		/mob/living/simple_animal
	)


/obj/item/paper/talisman/stun/get_antag_info()
	. = ..()
	. += {"
		<p>Эффекты оглушающего талисмана, аналогично вспышке можно заблокировать или смягчить определенной защитой глаз и лица.</p>
	"}


/obj/item/paper/talisman/stun/invoke(mob/living/target, mob/user)
	var/obj/item/device/flash/flash = new(src)
	flash.do_flash(target)
	qdel(flash)
