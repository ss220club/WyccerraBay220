/client/verb/credits()
	set name = "Credits"
	set category = "OOC"

	var/static/credits_users = list()
	var/datum/tgui_module/credits/credits = credits_users[usr]
	if(!credits)
		credits = new(src)
		credits_users[usr] = credits
	credits.tgui_interact(usr)

/datum/tgui_module/credits
	name = "Авторы"

/datum/tgui_module/credits/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/tgui_module/credits/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Credits", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/tgui_module/credits/tgui_static_data(mob/user)
	var/list/data = list()

	var/list/credits = list()
	for(var/path in subtypesof(/datum/credits))
		var/datum/credits/build = new path
		credits += list(list(
			"name" = build.name,
			"coders" = build.coders,
			"mappers" = build.mappers,
			"spriters" = build.spriters,
			"ui_designers" = build.ui_designers,
			"special" = build.special,
			"linkContributors" = build.contributors,
		))
	data["credits"] = credits

	return data

/datum/tgui_module/credits/tgui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("openContributors")
			var/buildPage = params["buildPage"]
			var/buildName = params["buildName"]
			if(tgui_alert(usr, "Это откроет страницу с контрибьюторами проекта [buildName]. Вы уверены?", "Контрибьютеры", list("Да", "Нет")) != "Да")
				return
			var/url = "[buildPage]"
			to_target(usr, link(url))
			return TRUE
		if("openGitHub")
			if(tgui_alert(usr, "Это откроет страницу нашего GitHub. Вы уверены?", "GitHub", list("Да", "Нет")) != "Да")
				return
			to_target(usr, link("https://github.com/ss220club/WyccerraBay220"))
			return TRUE
		if("openWiki")
			if(tgui_alert(usr, "Это откроет страницу с нашей вики. Вы уверены?", "Wiki", list("Да", "Нет")) != "Да")
				return
			to_target(usr, link("https://sierra.ss220.club"))
			return TRUE
		if("openDiscord")
			if(tgui_alert(usr, "Это откроет страницу с ссылкой на приглашение в наш дискорд. Вы уверены?", "Discord", list("Да", "Нет")) != "Да")
				return
			to_target(usr, link("https://discord.gg/ss220"))
			return TRUE
