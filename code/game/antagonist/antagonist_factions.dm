/mob/living/proc/convert_to_rev(mob/M as mob in able_mobs_in_oview(src))
	set name = "Вербовать во фракцию"
	set category = "Способности"
	if(!M.mind || !M.client)
		return
	convert_to_faction(M.mind, GLOB.revs)

/mob/living/proc/convert_to_faction(datum/mind/player, datum/antagonist/faction)

	if(!player || !faction || !player.current)
		return

	if(!faction.faction_verb || !faction.faction_descriptor || !faction.faction_verb)
		return

	if(player_is_antag(player))
		to_chat(src, SPAN_WARNING("У [player.current] лояльность, похоже, находится в другом месте..."))
		log_debug("[src] пытался завербовать [player.current] в [faction], но не смог: Игрок уже антагонист.")
		return

	var/result = faction.can_become_antag_detailed(player, TRUE)
	if(result)
		to_chat(src, SPAN_WARNING("[player.current] не может быть [faction.faction_role_text]!"))
		log_debug("[src] пытался завербовать [player.current] в [faction], но не смог: [result]")
		return

	if(world.time < player.rev_cooldown)
		to_chat(src, SPAN_DANGER("Вы должны ждать пять секунд между попытками."))
		return

	to_chat(src, SPAN_DANGER("Вы пробуете завербовать [player.current]..."))
	log_admin("[src]([src.ckey]) попробовал завербовать [player.current] в [faction.faction_role_text] фракцию.")
	message_admins(SPAN_DANGER("[src]([src.ckey]) пробовал завербовать [player.current] в [faction.faction_role_text] фракцию."))

	player.rev_cooldown = world.time + 5 SECONDS
	if (!faction.is_antagonist(player))
		var/choice = alert(player.current,"Спросил [src]: Хотите ли вы вступить в [faction.faction_descriptor]?","Присоединяйся к [faction.faction_descriptor]?","Нет!","Да!")
		if(choice == "Да!" && faction.add_antagonist_mind(player, 0, faction.faction_role_text, faction.faction_welcome))
			to_chat(src, SPAN_NOTICE("[player.current] вступает в [faction.faction_descriptor]!"))
			log_debug("[src] удачно завербован [player.current] в [faction].")
			return
		else
			to_chat(player, SPAN_DANGER("Вы отвергаете это предательское дело!"))
	to_chat(src, SPAN_DANGER("[player.current] не поддерживает [faction.faction_descriptor]!"))
	log_debug("[src] пробовал завербовать \the [player.current] в [faction], но не смог: Игрок отказался присоединиться, или фракции не удалось добавить его.")

/mob/living/proc/convert_to_loyalist(mob/M as mob in able_mobs_in_oview(src))
	set name = "Завербовать"
	set category = "Способности"
	if(!M.mind || !M.client)
		return
	convert_to_faction(M.mind, GLOB.loyalists)
