/datum/asset/simple/nanoui_templates/register()
	for(var/filename in flist(NANO_TEMPLATES_PATH))
		if(copytext(filename, length(filename)) == "/")
			continue

		assets[filename] = fcopy_rsc("[NANO_TEMPLATES_PATH][filename]")

	. = ..()
