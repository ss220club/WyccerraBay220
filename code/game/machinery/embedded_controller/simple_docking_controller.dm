/obj/machinery/embedded_controller/radio/simple_docking_controller
	name = "docking hatch controller"
	var/tag_door
	var/datum/computer/file/embedded_program/docking/simple/docking_program

/obj/machinery/embedded_controller/radio/simple_docking_controller/Initialize()
	. = ..()
	docking_program = new/datum/computer/file/embedded_program/docking/simple(src)
	program = docking_program

/obj/machinery/embedded_controller/radio/simple_docking_controller/tgui_state(mob/user)
	return GLOB.tgui_default_state

/obj/machinery/embedded_controller/radio/simple_docking_controller/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SimpleDockingConsole", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/embedded_controller/radio/simple_docking_controller/tgui_data(mob/user)
	var/list/data = list()
	data["docking_status"] = docking_program.get_docking_status()
	data["override_enabled"] = docking_program.override_enabled
	data["door_state"] = docking_program.memory["door_status"]["state"]
	data["door_lock"] = docking_program.memory["door_status"]["lock"]
	return data

/obj/machinery/embedded_controller/radio/simple_docking_controller/tgui_act(action, params)
	if(..())
		return FALSE

	. = TRUE

	switch(action)
		if("force_door")
			if(docking_program.override_enabled)
				if(docking_program.memory["door_status"]["state"] == "open")
					docking_program.close_door()
				else
					docking_program.open_door()
		if("toggle_override")
			if(docking_program.override_enabled)
				docking_program.disable_override()
			else
				docking_program.enable_override()
		else
			return FALSE

// A docking controller program for a simple door based docking port
/datum/computer/file/embedded_program/docking/simple
	var/tag_door

/datum/computer/file/embedded_program/docking/simple/New(obj/machinery/embedded_controller/M)
	..(M)
	memory["door_status"] = list(state = "closed", lock = "locked")		//assume closed and locked in case the doors dont report in

	if (istype(M, /obj/machinery/embedded_controller/radio/simple_docking_controller))
		var/obj/machinery/embedded_controller/radio/simple_docking_controller/controller = M

		tag_door = controller.tag_door? controller.tag_door : "[id_tag]_hatch"

		spawn(10)
			signal_door("update")		//signals connected doors to update their status


/datum/computer/file/embedded_program/docking/simple/receive_signal(datum/signal/signal, receive_method, receive_param)
	var/receive_tag = signal.data["tag"]

	if(!receive_tag) return

	if(receive_tag==tag_door)
		memory["door_status"]["state"] = signal.data["door_status"]
		memory["door_status"]["lock"] = signal.data["lock_status"]

	..(signal, receive_method, receive_param)

/datum/computer/file/embedded_program/docking/simple/proc/signal_door(command)
	var/datum/signal/signal = new
	signal.data["tag"] = tag_door
	signal.data["command"] = command
	post_signal(signal)

///datum/computer/file/embedded_program/docking/simple/proc/signal_mech_sensor(var/command)
//	signal_door(command)
//	return

/datum/computer/file/embedded_program/docking/simple/proc/open_door()
	if(memory["door_status"]["state"] == "closed")
		//signal_mech_sensor("enable")
		signal_door("secure_open")
	else if(memory["door_status"]["lock"] == "unlocked")
		signal_door("lock")

/datum/computer/file/embedded_program/docking/simple/proc/close_door()
	if(memory["door_status"]["state"] == "open")
		signal_door("secure_close")
		//signal_mech_sensor("disable")
	else if(memory["door_status"]["lock"] == "unlocked")
		signal_door("lock")

//tell the docking port to start getting ready for docking - e.g. pressurize
/datum/computer/file/embedded_program/docking/simple/prepare_for_docking()
	return		//don't need to do anything

//are we ready for docking?
/datum/computer/file/embedded_program/docking/simple/ready_for_docking()
	return 1	//don't need to do anything

//we are docked, open the doors or whatever.
/datum/computer/file/embedded_program/docking/simple/finish_docking()
	open_door()

//tell the docking port to start getting ready for undocking - e.g. close those doors.
/datum/computer/file/embedded_program/docking/simple/prepare_for_undocking()
	close_door()

//are we ready for undocking?
/datum/computer/file/embedded_program/docking/simple/ready_for_undocking()
	return (memory["door_status"]["state"] == "closed" && memory["door_status"]["lock"] == "locked")

/*** DEBUG VERBS ***

/obj/machinery/embedded_controller/radio/simple_docking_controller/verb/view_state()
	set category = "Debug"
	set src in view(1)
	src.program:print_state()

/obj/machinery/embedded_controller/radio/simple_docking_controller/verb/spoof_signal(command as text, sender as text)
	set category = "Debug"
	set src in view(1)
	var/datum/signal/signal = new
	signal.data["tag"] = sender
	signal.data["command"] = command
	signal.data["recipient"] = id_tag

	src.program:receive_signal(signal)

/obj/machinery/embedded_controller/radio/simple_docking_controller/verb/debug_init_dock(target as text)
	set category = "Debug"
	set src in view(1)
	src.program:initiate_docking(target)

/obj/machinery/embedded_controller/radio/simple_docking_controller/verb/debug_init_undock()
	set category = "Debug"
	set src in view(1)
	src.program:initiate_undocking()

*/
