/datum/browser
	var/mob/user
	var/title
	var/window_id // window_id is used as the window name for browse and onclose
	var/width = 0
	var/height = 0
	var/weakref/ref = null
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // window option is set using window_id
	var/list/stylesheets = list()
	var/list/scripts = list()
	var/title_image
	var/head_elements
	var/body_elements
	var/head_content = ""
	var/content = ""
	var/title_buttons = ""


/datum/browser/Destroy()
	if (user)
		user.unset_machine()
		user = null
	ref = null
	return ..()


/datum/browser/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, datum/nref = null)

	user = nuser
	window_id = nwindow_id
	if (ntitle)
		title = format_text(ntitle)
	if (nwidth)
		width = nwidth
	if (nheight)
		height = nheight
	if (nref)
		ref = weakref(nref)
	add_stylesheet("common", 'html/browser/common.css') // this CSS sheet is common to all UIs

/datum/browser/proc/set_title(ntitle)
	title = format_text(ntitle)

/datum/browser/proc/add_head_content(nhead_content)
	head_content = nhead_content

/datum/browser/proc/set_title_buttons(ntitle_buttons)
	title_buttons = ntitle_buttons

/datum/browser/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

/datum/browser/proc/add_stylesheet(name, file)
	stylesheets[name] = file

/datum/browser/proc/add_script(name, file)
	scripts[name] = file

/datum/browser/proc/set_content(ncontent)
	content = ncontent

/datum/browser/proc/add_content(ncontent)
	content += ncontent

/datum/browser/proc/get_header()
	var/key
	var/filename
	for (key in stylesheets)
		filename = "[ckey(key)].css"
		send_rsc(user, stylesheets[key], filename)
		head_content += "<link rel='stylesheet' type='text/css' href='[filename]'>"

	for (key in scripts)
		filename = "[ckey(key)].js"
		send_rsc(user, scripts[key], filename)
		head_content += "<script type='text/javascript' src='[filename]'></script>"

	var/title_attributes = "class='uiTitle'"
	if (title_image)
		title_attributes = "class='uiTitle icon' style='background-image: url([title_image]);'"

	return {"<!DOCTYPE html>
<html>
	<meta charset="UTF-8">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		[head_content]
	</head>
	<body scroll=auto>
		<div class='uiWrapper'>
			[title ? "<div class='uiTitleWrapper'><div [title_attributes]><tt>[title]</tt></div><div class='uiTitleButtons'>[title_buttons]</div></div>" : ""]
			<div class='uiContent'>
	"}

/datum/browser/proc/get_footer()
	return {"
			</div>
		</div>
	</body>
</html>"}

/datum/browser/proc/get_content()
	return {"
	[get_header()]
	[content]
	[get_footer()]
	"}

/datum/browser/proc/open(use_onclose = TRUE)
	var/window_size = ""
	if (width && height)
		window_size = "size=[width]x[height];"
	show_browser(user, get_content(), "window=[window_id];[window_size][window_options]")
	if (use_onclose)
		onclose(user, window_id, ref ? ref.resolve() : null)

/datum/browser/proc/update(force_open = FALSE, use_onclose = TRUE)
	if(force_open)
		open(use_onclose)
	else
		send_output(user, get_content(), "[window_id].browser")

/datum/browser/proc/close()
	close_browser(user, "window=[window_id]")

// Registers the on-close verb for a browse window (client/verb/.windowclose)
// this will be called when the close-button of a window is pressed.
//
// This is usually only needed for devices that regularly update the browse window,
// e.g. canisters, timers, etc.
//
// windowid should be the specified window name
// e.g. code is	: show_browser(user, text, "window=fred")
// then use 	: onclose(user, "fred")
//
// Optionally, specify the "ref" parameter as the controlled datum (usually src)
// to pass a "close=1" parameter to the datum's Topic() proc for special handling.
// Otherwise, the user mob's machine var will be reset directly.
//
/proc/onclose(mob/user, windowid, datum/ref = null)
	if(!user || !user.client)
		return

	var/param = "null"
	if(ref)
		param = ref(ref)

	spawn(2)
		if(!user.client)
			return

		winset(user, windowid, "on-close=\".windowclose [param]\"")

// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid datum reference is supplied, call the datum's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
/client/verb/windowclose(datum_ref as text)
	set hidden = TRUE					// hide this verb from the user's panel
	set name = ".windowclose"			// no autocomplete on cmd line

	if(datum_ref != "null")				// if passed a real datum
		var/hsrc = locate(datum_ref)	// find the reffed datum
		if(hsrc)
			usr = src.mob
			src.Topic("close=1", list("close"="1"), hsrc)	// this will direct to the datum's
			return

	// no atomref specified (or not found)
	// so just reset the user mob's machine var
	if(src && src.mob)
		src.mob.unset_machine()
