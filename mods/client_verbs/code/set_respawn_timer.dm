/datum/admins/proc/set_respawn_timer()
	set name = "Set Respawn Timer"
	set category = "Server"

	if(!check_rights(R_ADMIN))
		return

	var/delay = input(usr, "Enter new respawn delays in minutes", "Respawn timer configuration") as null|num
	if(!isnull(delay))
		delay = clamp(delay, 0, INFINITY)
		config.respawn_delay = delay
		log_and_message_admins("changed respawn delay to [delay] minutes.")
