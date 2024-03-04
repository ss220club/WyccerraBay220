/obj/item/stock_parts/circuitboard/rdconsole
	name = "circuit board (R&D control console)"
	build_path = /obj/machinery/computer/rdconsole/core

/obj/item/stock_parts/circuitboard/rdconsole/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	user.visible_message(SPAN_NOTICE("\The [user] adjusts the jumper on \the [src]'s access protocol pins."), SPAN_NOTICE("You adjust the jumper on the access protocol pins."))
	if(build_path == /obj/machinery/computer/rdconsole/core)
		SetName("circuit board (RD Console - Robotics)")
		build_path = /obj/machinery/computer/rdconsole/robotics
		to_chat(user, SPAN_NOTICE("Access protocols set to robotics."))
	else
		SetName("circuit board (RD Console)")
		build_path = /obj/machinery/computer/rdconsole/core
		to_chat(user, SPAN_NOTICE("Access protocols set to default."))
