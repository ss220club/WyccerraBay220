// In case upstream decides to make lobby use assets
/datum/asset/group/lobby
	children = list(
		/datum/asset/simple/lobby,
		/datum/asset/simple/namespaced/fontawesome
	)

/datum/asset/simple/lobby
	keep_local_name = TRUE
	assets = list(
		"courierprime-code.woff" = 'html/fonts/courierprime-code.woff',
		"round-control.woff"     = 'html/fonts/round-control.woff',
		"light_left.png"  = 'html/lobby_screen/light_left.png',
		"light_right.png" = 'html/lobby_screen/light_right.png',
		"smallbutton.png" = 'html/lobby_screen/smallbutton.png',
		"buttons.mp4"     = 'html/lobby_screen/buttons.mp4'
	)

/datum/asset/simple/lobby_loop
	keep_local_name = TRUE
	assets = list("loop.mp4" = 'html/lobby_screen/loop.mp4')
