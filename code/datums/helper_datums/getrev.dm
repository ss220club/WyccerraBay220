GLOBAL_DATUM_INIT(revdata, /datum/getrev, new)

/datum/getrev
	var/branch
	var/revision
	var/date
	var/showinfo

/datum/getrev/New()
	var/list/head_branch = file2list(".git/HEAD", "\n")
	if(length(head_branch))
		branch = copytext(head_branch[1], 17)

	revision = rustg_git_revparse("HEAD")
	date = rustg_git_commit_date("HEAD")

	to_world_log("Running revision:")
	to_world_log(branch)
	to_world_log(date)
	to_world_log(revision)

/client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	set desc = "Check the current server code revision"

	to_chat(src, "<b>Client Version:</b> [byond_version]")
	if(GLOB.revdata.revision)
		var/server_revision = GLOB.revdata.revision
		if(config.source_url)
			server_revision = "<a href='[config.source_url]/commit/[server_revision]'>[server_revision]</a>"
		to_chat(src, "<b>Server Revision:</b> [server_revision] - [GLOB.revdata.branch] - [GLOB.revdata.date]")
	else
		to_chat(src, "<b>Server Revision:</b> Revision Unknown")
	to_chat(src, "Game ID: <b>[GLOB.game_id]</b>")
	to_chat(src, "Current map: [GLOB.using_map.full_name]")
