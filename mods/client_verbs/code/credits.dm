/client/verb/credits()
	set name = "Credits"
	set category = "OOC"

	var/datum/asset/credits_asset = get_asset_datum(/datum/asset/simple/credits)
	credits_asset.send(src)

	show_browser(src, 'mods/client_verbs/html/credits.html', "window=credits;size=675x650")
