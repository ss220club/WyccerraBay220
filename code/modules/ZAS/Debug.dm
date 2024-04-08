GLOBAL_VAR(image/assigned = image('icons/Testing/Zone.dmi', icon_state = "assigned"))
GLOBAL_VAR(image/created = image('icons/Testing/Zone.dmi', icon_state = "created"))
GLOBAL_VAR(image/merged = image('icons/Testing/Zone.dmi', icon_state = "merged"))
GLOBAL_VAR(image/invalid_zone = image('icons/Testing/Zone.dmi', icon_state = "invalid"))
GLOBAL_VAR(image/air_blocked = image('icons/Testing/Zone.dmi', icon_state = "block"))
GLOBAL_VAR(image/zone_blocked = image('icons/Testing/Zone.dmi', icon_state = "zoneblock"))
GLOBAL_VAR(image/blocked = image('icons/Testing/Zone.dmi', icon_state = "fullblock"))
GLOBAL_VAR(image/mark = image('icons/Testing/Zone.dmi', icon_state = "mark"))

/connection_edge/var/dbg_out = 0

/turf/var/dbg_img
/turf/proc/dbg(image/img, d = 0)
	if(d > 0) img.dir = d
	CutOverlays(dbg_img)
	AddOverlays(img)
	dbg_img = img

/proc/soft_assert(thing,fail)
	if(!thing) message_admins(fail)
