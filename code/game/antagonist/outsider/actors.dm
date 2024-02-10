GLOBAL_DATUM_INIT(actor, /datum/antagonist/actor, new)

/datum/antagonist/actor
	id = MODE_ACTOR
	role_text = "Актер"
	role_text_plural = "Актеры"
	welcome_text = "Вас наняли развлекать людей с помощью телевидения!"
	landmark_id = "ActorSpawn"
	id_type = /obj/item/card/id/syndicate

	flags = ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB | ANTAG_SET_APPEARANCE | ANTAG_CHOOSE_NAME | ANTAG_RANDOM_EXCEPTED

	hard_cap = 7
	hard_cap_round = 10
	initial_spawn_req = 1
	initial_spawn_target = 1
	show_objectives_on_creation = 0 //actors are not antagonists and do not need the antagonist greet text
	required_language = LANGUAGE_HUMAN_EURO

/datum/antagonist/actor/greet(datum/mind/player)
	if(!..())
		return

	player.current.show_message("Вы работаете на [GLOB.using_map.company_name], занимаетесь производством и трансляцией развлекательных программ на все свои активы.")
	player.current.show_message("Развлекайте съемочную группу! Старайтесь не слишком отрывать их от работы и напоминайте им, какая великая [GLOB.using_map.company_name] is!")

/datum/antagonist/actor/equip(mob/living/carbon/human/player)
	player.equip_to_slot_or_del(new /obj/item/clothing/under/chameleon(src), slot_w_uniform)
	player.equip_to_slot_or_del(new /obj/item/clothing/shoes/chameleon(src), slot_shoes)
	player.equip_to_slot_or_del(new /obj/item/device/radio/headset/entertainment(src), slot_l_ear)
	var/obj/item/card/id/centcom/ERT/C = new(player.loc)
	C.assignment = "Actor"
	player.set_id_info(C)
	player.equip_to_slot_or_del(C,slot_wear_id)

	return 1

/mob/observer/ghost/verb/join_as_actor()
	set category = "Ghost"
	set name = "Присоединиться за Актера"
	set desc = "Присоединяйтесь как актер, чтобы развлечь экипаж по телевидению!"

	if(!MayRespawn(1) || !GLOB.actor.can_become_antag(usr.mind, 1))
		return

	var/choice = alert("Вы уверены, что хотите присоединиться за Актера?", "Подтверждение","Да", "Нет")
	if(choice != "Да")
		return

	if(isghostmind(usr.mind) || isnewplayer(usr))
		if(length(GLOB.actor.current_antagonists) >= GLOB.actor.hard_cap)
			to_chat(usr, "Больше актеров не может появиться в настоящее время.")
			return
		GLOB.actor.create_default(usr)
		return

	to_chat(usr, "Вы должны наблюдать или стать новым игроком, чтобы появиться в роли актера.")
