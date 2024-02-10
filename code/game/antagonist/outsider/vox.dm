GLOBAL_DATUM_INIT(vox_raiders, /datum/antagonist/vox, new)
GLOBAL_LIST_EMPTY(vox_artifact_spawners)

/datum/antagonist/vox
	id = MODE_VOXRAIDER
	role_text = "Пираты Воксы"
	role_text_plural = "Пираты Воксы"
	landmark_id = "Vox-Spawn"
	welcome_text = "В последнее время металлолом найти сложно, а Шрауд требует запасных частей. Не разочаровывайте своих родственников."
	flags = ANTAG_VOTABLE | ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB | ANTAG_CLEAR_EQUIPMENT | ANTAG_CHOOSE_NAME | ANTAG_SET_APPEARANCE
	antaghud_indicator = "hudraider"

	hard_cap = 5
	hard_cap_round = 10
	initial_spawn_req = 3
	initial_spawn_target = 4

	id_type = /obj/item/card/id/syndicate

	base_to_load = /datum/map_template/ruin/antag_spawn/vox_raider
	var/pending_item_spawn = TRUE
	faction = "vox raider"
	no_prior_faction = TRUE

/datum/antagonist/vox/add_antagonist(datum/mind/player, ignore_role, do_not_equip, move_to_spawn, do_not_announce, preserve_appearance)
	if(pending_item_spawn)
		for(var/obj/voxartifactspawner/S as anything in GLOB.vox_artifact_spawners)
			S.spawn_artifact()
		pending_item_spawn = FALSE
	..()

/datum/antagonist/vox/build_candidate_list(datum/game_mode/mode, ghosts_only)
	candidates = list()
	for(var/datum/mind/player in mode.get_players_for_role(id))
		if (ghosts_only && !(isghostmind(player) || isnewplayer(player.current)))
			log_debug("[key_name(player)] не имеет права стать [role_text]: Только призраки могут присоединиться к этой роли.!")
			continue
		if (player.special_role)
			log_debug("[key_name(player)] не имеет права стать [role_text]: У них уже есть особая роль ([player.special_role])!")
			continue
		if (player in pending_antagonists)
			log_debug("[key_name(player)] не имеет права стать [role_text]: Они уже отобраны на эту роль.!")
			continue
		if (player_is_antag(player))
			log_debug("[key_name(player)] не имеет права стать [role_text]: Они уже антагонисты!")
			continue
		if(!is_alien_whitelisted(player.current, all_species[SPECIES_VOX]))
			log_debug("[player.current.ckey] не внесен в белый список")
			continue
		var/result = can_become_antag_detailed(player)
		if (result)
			log_debug("[key_name(player)] не имеет права стать [role_text]: [result]")
			continue
		candidates |= player

	return candidates

/datum/antagonist/vox/get_potential_candidates(datum/game_mode/mode, ghosts_only)
	var/candidates = list()

	for(var/datum/mind/player in mode.get_players_for_role(id))
		if(ghosts_only && !(isghostmind(player) || isnewplayer(player.current)))
		else if(config.use_age_restriction_for_antags && player.current.client.player_age < minimum_player_age)
		else if(player.special_role)
		else if (player in pending_antagonists)
		else if(!can_become_antag(player))
		else if(player_is_antag(player))
		else if(!is_alien_whitelisted(player.current, all_species[SPECIES_VOX]))
		else
			candidates |= player

	return candidates

/datum/antagonist/vox/can_become_antag_detailed(datum/mind/player, ignore_role)
	if(!is_alien_whitelisted(player.current, all_species[SPECIES_VOX]))
		return "У игрока нет белого списка Vox"
	..()

/datum/antagonist/vox/equip(mob/living/carbon/human/vox/player)
	if(!..())
		return FALSE

	player.set_species(SPECIES_VOX)
	var/singleton/hierarchy/outfit/vox_raider = outfit_by_type(/singleton/hierarchy/outfit/vox_raider)
	vox_raider.equip(player)


	return TRUE


/obj/structure/voxuplink
	name = "Мелководный маяк"
	desc = "Пульсирующая масса плоти и стали."
	icon = 'maps/antag_spawn/vox/vox.dmi'
	icon_state = "printer"
	anchored = TRUE
	density = TRUE
	var/favors = 0
	var/working = FALSE
	var/ignore_wl = FALSE
	var/rewards = list(
		"Slug Launcher - 2" = list(2, /obj/item/gun/launcher/alien/slugsling),
		"Soundcannon - 2" = list(2, /obj/item/gun/energy/sonic),
		"Flux Cannon - 4" = list(4, /obj/item/gun/energy/darkmatter),
		"Lightly Armored Suit - 3" =list(3, /obj/item/clothing/head/helmet/space/vox/carapace, /obj/item/clothing/suit/space/vox/carapace),
		"Raider Suit - 6" = list(6, /obj/item/clothing/head/helmet/space/vox/raider, /obj/item/clothing/suit/space/vox/raider),
		"Arkmade Hardsuit - 8" = list(8, /obj/item/rig/vox),
		"Makeshift Armored Vest - 1" = list(1, /obj/item/clothing/suit/armor/vox_scrap),
		"Request medical supplies from Shoal - 1" = list(1, /obj/random/firstaid),
		"Request equipment from Shoal - 1" = list(1, /obj/random/loot),
		"Protein Source - 1" = list(1, /mob/living/simple_animal/passive/meatbeast)
		)

/obj/structure/voxuplink/attack_hand(mob/living/carbon/human/user)
	var/obj/item/organ/internal/voxstack/stack = user.internal_organs_by_name[BP_STACK]
	if(istype(stack) || ignore_wl)
		if(!working)
			var/choice = input(user, "Что бы вы хотели запросить у Апекса? Осталось [favors] одолжений!", "Мелководный маяк") as null|anything in rewards
			if(choice && !working)
				if(rewards[choice][1] <= favors)
					working = TRUE
					on_update_icon()
					to_chat(user, SPAN_NOTICE("Апекс дарует вам [choice]."))
					sleep(20)
					working = FALSE
					on_update_icon()
					favors -= rewards[choice][1]
					for(var/I in rewards[choice])
						if(!isnum(I))
							new I(get_turf(src))
				else
					to_chat(user, SPAN_WARNING("Вы не достойны [choice]!"))
		else
			to_chat(user, SPAN_WARNING("[src.name] еще работает!"))
	else
		to_chat(user, SPAN_WARNING("Вы не знаете, что делать с [src.name]."))
	..()

/obj/structure/voxuplink/use_tool(obj/item/I, mob/user)
	if(istype(I, /obj/item/voxartifact))
		var/obj/item/voxartifact/A = I
		favors += A.favor_value
		qdel(A)
		user.visible_message(
			SPAN_NOTICE("[user] вставляет \a [A] в \the [src]."),
			SPAN_NOTICE("Вы вернули [A] назад Апексу [src].")
		)
		return TRUE
	if(istype(I, /obj/item/bluecrystal))
		var/obj/item/bluecrystal/A = I
		favors += A.favor_value
		qdel(A)
		user.visible_message(
			SPAN_NOTICE("[user] вставляет [A] в [src]."),
			SPAN_NOTICE("Вы предложили [A.name] Апексу.")
		)
		return TRUE
	return ..()

/obj/structure/voxuplink/MouseDrop_T(obj/structure/voxartifactbig/I, mob/user)
	if(istype(I, /obj/structure/voxartifactbig))
		favors += I.favor_value
		qdel(I)
		user.visible_message(
			SPAN_NOTICE("[user] вставляет [A] в [src]."),
			SPAN_NOTICE("Вы вернули [A] назад Апексу [src].")
		)
		return TRUE
	return ..()

/obj/structure/voxuplink/on_update_icon()
	if(working)
		icon_state = "printer-working"
	else
		icon_state = "printer"

/obj/item/voxartifact
	name = "Осколок Апекса"
	desc = "Странный на вид кусок органики. Внутри слышно слабое гудение."
	icon = 'icons/obj/urn.dmi'
	icon_state = "urn"
	var/favor_value = 4
	var/open_chance = 1
	var/icons = list(
	"unknown2",
	"Green lump",
	"ano112",
	"ano72"
	)

/obj/item/voxartifact/Initialize()
	. = ..()
	icon_state = pick(icons)

/obj/item/voxartifact/attack_self(mob/living/carbon/human/user)
	user.visible_message(
		SPAN_NOTICE("[user] начинает возиться с [src.name]."),
		SPAN_NOTICE("Вы начинаете анализировать [src.name]."),
	)
	var/obj/item/organ/internal/voxstack/stack = user.internal_organs_by_name[BP_STACK]
	if (istype(stack))
		if (do_after(user, 2 SECONDS, src, DO_PUBLIC_UNIQUE | DO_BAR_OVER_USER))
			to_chat(user, SPAN_NOTICE("[src.name] исчезает через мгновение, оставляя что-то после себя.\nВам удалось отправить его обратно на ковчег, но Апекс не оценил ваших действий."))
			var/datum/effect/spark_spread/s = new /datum/effect/spark_spread
			s.set_up(3, 1, src)
			s.start()
			activate()
	else
		if (do_after(user, 60 SECONDS, src, DO_PUBLIC_UNIQUE | DO_BAR_OVER_USER))
			if(rand(open_chance))
				to_chat(user, SPAN_NOTICE("После возни с [src.name] на какое-то время он внезапно исчезает, оставляя после себя что-то!"))
				var/datum/effect/spark_spread/s = new /datum/effect/spark_spread
				s.set_up(10, 1, src)
				s.start()
				activate()
			else
				to_chat(user, SPAN_NOTICE("Вы не можете узнать ничего полезного о [src.name]."))

/obj/item/voxartifact/proc/activate()
	new /obj/random/loot(get_turf(src))
	new /obj/item/bluecrystal(get_turf(src))
	qdel(src)

/obj/structure/voxartifactbig
	name = "биопод"
	desc = "Причудливая структура, сделанная из хитиноподобного материала."
	icon = 'maps/antag_spawn/vox/vox.dmi'
	icon_state = "pod_big"
	density = TRUE
	var/favor_value = 12

/obj/voxartifactspawner
	name = "посадочная метка"
	icon = 'icons/effects/landmarks.dmi'
	icon_state = "x2"
	anchored = TRUE
	unacidable = TRUE
	simulated = FALSE
	invisibility = INVISIBILITY_ABSTRACT

/obj/voxartifactspawner/Initialize(mapload)
	GLOB.vox_artifact_spawners += src
	return ..()

/obj/voxartifactspawner/Destroy()
	GLOB.vox_artifact_spawners -= src
	return ..()

/obj/voxartifactspawner/proc/spawn_artifact()
	var/item_list = list(
	/obj/item/voxartifact = 3,
	/obj/structure/voxartifactbig = 1,
	)
	var/to_spawn = pickweight(item_list)
	new to_spawn(get_turf(src))
	qdel(src)

/obj/item/bluecrystal
	name = "БлюСпейс кристалл"
	desc = "Необычно выглядящий кристалл с жутковатым темно-синим мерцанием, держа его в руке, чувствуешь, будто твоя рука погружается в него."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "ansible_crystal"
	w_class = ITEM_SIZE_TINY
	var/favor_value = 1

/obj/structure/voxanalyzer
	name = "анализатор странностей"
	desc = "Старая пыльная машина, предназначенная для анализа различных БлюСпейс аномалий и отправки исследовательских данных непосредственно в обсерваторию SCGEC."
	icon = 'icons/obj/machines/research/xenoarcheology_scanner.dmi'
	icon_state = "scanner"
	anchored = FALSE
	density = TRUE
	var/points = 0
	var/crystal_value = 4
	var/working = FALSE
	var/activated = FALSE
	obj_flags = OBJ_FLAG_ANCHORABLE

	var/rewards = list(
		"Stasis Bag - 2" = list(2, /obj/item/bodybag/cryobag),
		"Coagulant Autoinjector - 1" = list(1, /obj/item/reagent_containers/hypospray/autoinjector/coagulant),
		"Iatric monitor - 1" = list(1, /obj/item/organ/internal/augment/active/iatric_monitor),
		"Internal Air System - 1" = list(1, /obj/item/organ/internal/augment/active/internal_air_system),
		"Adaptive Binoculars - 1" = list(1, /obj/item/organ/internal/augment/active/item/adaptive_binoculars),
		"Advanced Armored Vest - 4" = list(4, /obj/item/clothing/suit/armor/pcarrier/merc, /obj/item/clothing/head/helmet/merc),
		"Nerve Dampeners - 6" = list(6, /obj/item/organ/internal/augment/active/nerve_dampeners),
		"Hazard Hardsuit - 12" = list(12, /obj/item/rig/hazard),
		)

/obj/structure/voxanalyzer/attack_hand(mob/living/carbon/human/user)
	if(activated)
		if(!working)
			visible_message(SPAN_NOTICE("<b>[src]</b> микрофон передает, \"Хорошая находка! Мы можем выслать вам несколько наших прототипов в обмен на данные об этих кристаллах.\""))
			var/choice = input(user, "Выберите прототип.\n [points] кристары отправлены.", "Анализатор Странностей") as null|anything in rewards
			if (choice)
				if((rewards[choice][1] <= points) && choice)
					points -= rewards[choice][1]
					for(var/I in rewards[choice])
						if(!isnum(I))
							new I(get_turf(src))
				else
					to_chat(user, SPAN_WARNING("[src.name] не отвечает, может, в следующий раз стоит быть менее жадным?"))
		else
			to_chat(user, SPAN_WARNING("[src.name] используется кем-то!"))
	else
		to_chat(user, SPAN_WARNING("[src.name] выглядит обесточеным."))
	..()

/obj/structure/voxanalyzer/use_tool(obj/item/I, mob/user)
	if(istype(I, /obj/item/bluecrystal))
		if(!activated)
			to_chat(user, SPAN_INFO("Как только вы подносите [I] ближе к [src], он взрывается ливнем искр!."))
			var/datum/effect/spark_spread/s = new /datum/effect/spark_spread
			s.set_up(3, 1, src)
			s.start()
			activated = TRUE
			return TRUE
		user.visible_message(
			SPAN_NOTICE("[user] начинает анализировать [I.name]."),
			SPAN_NOTICE("Вы начинаете анализировать [I.name]."),
		)
		working = TRUE
		on_update_icon()
		if (do_after(user, 1 SECONDS, src, DO_PUBLIC_UNIQUE | DO_BAR_OVER_USER))
			points += crystal_value
			qdel(I)
			to_chat(user, SPAN_NOTICE("Анализ закончен \the [I.name]."))
		working = FALSE
		on_update_icon()
		return TRUE
	return ..()

/obj/structure/voxanalyzer/on_update_icon()
	if(working)
		icon_state = "scanner_active"
	else
		icon_state = "scanner"
