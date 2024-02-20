GLOBAL_DATUM_INIT(iconCache, /savefile, new("data/iconCache.sav"))
GLOBAL_DATUM_INIT(is_http_protocol, /regex, regex("^https?://"))


// Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(icon/icon, iconKey = "misc")
	if (!isicon(icon))
		return FALSE
	to_save(GLOB.iconCache[iconKey], icon)
	var/iconData = GLOB.iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext(partial[2], 3, -5), "\n", "")

/proc/register_icon_asset(icon/thing, icon_state = "", dir = SOUTH, frame = 1, moving = FALSE, realsize = FALSE, class = null)
	if (!thing)
		return null

	if (!isicon(thing))
		if (isfile(thing))
			var/name = "[generate_asset_name(thing)].png"
			SSassets.transport.register_asset(name, thing)
			return name

		if (ispath(thing))
			var/atom/A = thing
			if (!(icon_state))
				icon_state = initial(A.icon_state)

			thing = initial(A.icon)

		else
			var/atom/A = thing
			if (isnull(dir))
				dir = A.dir
			if (isnull(icon_state))
				icon_state = A.icon_state
			thing = A.icon
			if (ishuman(thing)) // Shitty workaround for a BYOND issue.
				var/icon/temp = thing
				thing = icon()
				thing.Insert(temp, dir = SOUTH)
				dir = SOUTH

	thing = icon(thing, icon_state, dir, frame, moving)

	var/key = "[generate_asset_name(thing)].png"
	SSassets.transport.register_asset(key, thing)
	return key

/proc/icon2html(icon/thing, target, icon_state = "", dir = SOUTH, frame = 1, moving = FALSE, realsize = FALSE, class = null)
	if (!thing || !target)
		return

	var/list/targets
	if(target == world)
		targets = GLOB.clients

	else if (islist(target))
		targets = target

	else
		targets = list(target)

	if(!length(targets))
		return

	if (!isicon(thing))
		if (isfile(thing))
			var/name = "[generate_asset_name(thing)].png"
			SSassets.transport.register_asset(name, thing)
			for (var/thing2 in targets)
				SSassets.transport.send_assets(thing2, name)
			return "<img class='icon icon-misc [class]' src='[SSassets.transport.get_asset_url(name)]'>"

		if (ispath(thing))
			var/atom/A = thing
			if (isnull(dir))
				dir = SOUTH
			if (isnull(icon_state))
				icon_state = initial(A.icon_state)
			thing = initial(A.icon)

		else
			var/atom/A = thing
			if (isnull(dir))
				dir = A.dir
			if (isnull(icon_state))
				icon_state = A.icon_state
			thing = A.icon
			if (ishuman(thing)) // Shitty workaround for a BYOND issue.
				var/icon/temp = thing
				thing = icon()
				thing.Insert(temp, dir = SOUTH)
				dir = SOUTH

	thing = icon(thing, icon_state, dir, frame, moving)

	var/key = "[generate_asset_name(thing)].png"
	SSassets.transport.register_asset(key, thing)
	for (var/thing2 in targets)
		SSassets.transport.send_assets(thing2, key)

	if(realsize)
		return "<img class='icon icon-[icon_state] [class]' style='width:[thing.Width()]px;height:[thing.Height()]px;min-height:[thing.Height()]px' src='[SSassets.transport.get_asset_url(key)]'>"

	return "<img class='icon icon-[icon_state] [class]' src='[SSassets.transport.get_asset_url(key)]'>"

/proc/icon2base64html(thing)
	if (!thing)
		return

	var/static/list/bicon_cache = list()
	if (isicon(thing))
		var/icon/I = thing
		var/icon_base64 = icon2base64(I)

		if (I.Height() > world.icon_size || I.Width() > world.icon_size)
			var/icon_md5 = md5(icon_base64)
			icon_base64 = bicon_cache[icon_md5]
			if (!icon_base64) // Doesn't exist yet, make it.
				bicon_cache[icon_md5] = icon_base64 = icon2base64(I)

		return "<img class='icon icon-misc' src='data:image/png;base64,[icon_base64]'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = thing
	var/key = "[istype(A.icon, /icon) ? "\ref[A.icon]" : A.icon]:[A.icon_state]"


	if (!bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I = icon(A.icon, A.icon_state, SOUTH, 1)
		if (ishuman(thing)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)

		bicon_cache[key] = icon2base64(I, key)

	return "<img class='icon icon-[A.icon_state]' src='data:image/png;base64,[bicon_cache[key]]'>"

// Costlier version of icon2html() that uses getFlatIcon() to account for overlays, underlays, etc. Use with extreme moderation, ESPECIALLY on mobs.
/proc/costly_icon2html(thing, target)
	if (!thing)
		return

	if (isicon(thing))
		return icon2html(thing, target)

	var/icon/I = getFlatIcon(thing)
	return icon2html(I, target)
