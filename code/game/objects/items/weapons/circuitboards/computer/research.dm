/obj/item/stock_parts/circuitboard/rdconsole
	name = "circuit board (R&D control console)"
	build_path = /obj/machinery/computer/rdconsole/core

/obj/item/stock_parts/circuitboard/rdconsole/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	if(build_path == /obj/machinery/computer/rdconsole/core)
		SetName("circuit board (RD Console - Robotics)")
		build_path = /obj/machinery/computer/rdconsole/robotics
		balloon_alert(user, "плата для робототехники")
	else
		SetName("circuit board (RD Console)")
		build_path = /obj/machinery/computer/rdconsole/core
		balloon_alert(user, "плата для РНД")
