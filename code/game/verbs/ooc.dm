/client/verb/ooc(message = "" as text)
	set name = "OOC"
	set category = "OOC"

	if(!message)
		message = input(mob, "", "ooc \"text\"") as text|null
	sanitize_and_communicate(/singleton/communication_channel/ooc, src, message)

/client/verb/looc(message = "" as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view. Remember: Just because you see someone that doesn't mean they see you."
	set category = "OOC"

	if(!message)
		message = input(mob, "", "looc \"text\"") as text|null
	sanitize_and_communicate(/singleton/communication_channel/ooc/looc, src, message)
