// Construction frames

/singleton/machine_construction/frame/unwrenched/state_is_valid(obj/machinery/machine)
	return !machine.anchored

/singleton/machine_construction/frame/unwrenched/validate_state(obj/machinery/constructable_frame/machine)
	. = ..()
	if(!.)
		if(machine.circuit)
			try_change_state(machine, /singleton/machine_construction/frame/awaiting_parts)
		else
			try_change_state(machine, /singleton/machine_construction/frame/wrenched)

/singleton/machine_construction/frame/unwrenched/attackby(obj/item/I, mob/user, obj/machinery/machine)
	if(isWrench(I))
		playsound(machine.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, (I.toolspeed * 2) SECONDS, machine, DO_REPAIR_CONSTRUCT))
			TRANSFER_STATE(/singleton/machine_construction/frame/wrenched)
			to_chat(user, SPAN_NOTICE("Вы закрутили [machine] на место."))
			machine.anchored = TRUE
	if(isWelder(I))
		var/obj/item/weldingtool/WT = I
		if(!WT.can_use(3, user))
			return TRUE
		playsound(machine.loc, 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, (I.toolspeed * 2) SECONDS, machine, DO_REPAIR_CONSTRUCT))
			if (!WT.remove_fuel(3, user))
				return TRUE
			TRANSFER_STATE(/singleton/machine_construction/default/deconstructed)
			to_chat(user, SPAN_NOTICE("Вы разобрали [machine]."))
			machine.dismantle()


/singleton/machine_construction/frame/unwrenched/mechanics_info()
	. = list()
	. += "Используйте сварочный аппарат, чтобы разобрать раму на части."
	. += "Используйте гаечный ключ, чтобы закрепить раму на месте."

/singleton/machine_construction/frame/wrenched/state_is_valid(obj/machinery/constructable_frame/machine)
	return machine.anchored && !machine.circuit

/singleton/machine_construction/frame/wrenched/validate_state(obj/machinery/constructable_frame/machine)
	. = ..()
	if(!.)
		if(machine.circuit)
			try_change_state(machine, /singleton/machine_construction/frame/awaiting_parts)
		else
			try_change_state(machine, /singleton/machine_construction/frame/unwrenched)

/singleton/machine_construction/frame/wrenched/attackby(obj/item/I, mob/user, obj/machinery/machine)
	if(isWrench(I))
		playsound(machine.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, (I.toolspeed * 2) SECONDS, machine, DO_REPAIR_CONSTRUCT))
			TRANSFER_STATE(/singleton/machine_construction/frame/unwrenched)
			to_chat(user, SPAN_NOTICE("Вы раскрутили \the [machine]."))
			machine.anchored = FALSE
			return
	if(isCoil(I))
		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 5)
			to_chat(user, SPAN_WARNING("Вам понадобится пять отрезков кабеля, чтобы добавить их к [machine]."))
			return TRUE
		playsound(machine.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("Вы начинаете добавлять кабели к раме."))
		if(do_after(user, 2 SECONDS, machine, DO_REPAIR_CONSTRUCT) && C.use(5))
			TRANSFER_STATE(/singleton/machine_construction/frame/awaiting_circuit)
			to_chat(user, SPAN_NOTICE("Вы добавляете кабели к раме."))
		return TRUE


/singleton/machine_construction/frame/wrenched/mechanics_info()
	. = list()
	. += "С помощью гаечного ключа открепите раму от пола и подготовьте ее к демонтажу."
	. += "Добавьте кабели, чтобы подготовить его к подключению."

/singleton/machine_construction/frame/awaiting_circuit/state_is_valid(obj/machinery/constructable_frame/machine)
	return machine.anchored && !machine.circuit

/singleton/machine_construction/frame/awaiting_circuit/validate_state(obj/machinery/constructable_frame/machine)
	. = ..()
	if(!.)
		if(machine.circuit)
			try_change_state(machine, /singleton/machine_construction/frame/awaiting_parts)
		else
			try_change_state(machine, /singleton/machine_construction/frame/unwrenched)

/singleton/machine_construction/frame/awaiting_circuit/attackby(obj/item/I, mob/user, obj/machinery/constructable_frame/machine)
	if(istype(I, /obj/item/stock_parts/circuitboard))
		var/obj/item/stock_parts/circuitboard/circuit = I
		if(circuit.board_type == machine.expected_machine_type)
			if(!user.canUnEquip(I))
				return FALSE
			TRANSFER_STATE(/singleton/machine_construction/frame/awaiting_parts)
			user.unEquip(I, machine)
			playsound(machine.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			to_chat(user, SPAN_NOTICE("Вы добавляете печатную плату в [machine]."))
			machine.circuit = I
			return
		else
			to_chat(user, SPAN_WARNING("Эта рама не подходит для печатных плат такого типа!"))
			return TRUE
	if(isWirecutter(I))
		TRANSFER_STATE(/singleton/machine_construction/frame/wrenched)
		playsound(machine.loc, 'sound/items/Wirecutter.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("Вы отсоединяете кабели."))
		new /obj/item/stack/cable_coil(machine.loc, 5)

/singleton/machine_construction/frame/awaiting_circuit/mechanics_info()
	. = list()
	. += "Вставьте печатную плату, чтобы приступить к сборке машины."
	. += "Используйте кусачки для отсоединения кабелей."

/singleton/machine_construction/frame/awaiting_parts/state_is_valid(obj/machinery/constructable_frame/machine)
	return machine.anchored && machine.circuit

/singleton/machine_construction/frame/awaiting_parts/validate_state(obj/machinery/constructable_frame/machine)
	. = ..()
	if(!.)
		if(machine.anchored)
			try_change_state(machine, /singleton/machine_construction/frame/wrenched)
		else
			try_change_state(machine, /singleton/machine_construction/frame/unwrenched)

/singleton/machine_construction/frame/awaiting_parts/attackby(obj/item/I, mob/user, obj/machinery/constructable_frame/machine)
	if(isCrowbar(I))
		TRANSFER_STATE(/singleton/machine_construction/frame/awaiting_circuit)
		playsound(machine.loc, 'sound/items/Crowbar.ogg', 50, 1)
		machine.circuit.dropInto(machine.loc)
		machine.circuit = null
		to_chat(user, SPAN_NOTICE("Вы снимаете печатную плату."))
		return
	if(isScrewdriver(I))
		playsound(machine.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		var/obj/machinery/new_machine = new machine.circuit.build_path(machine.loc, machine.dir, FALSE)
		machine.circuit.construct(new_machine)
		new_machine.install_component(machine.circuit, refresh_parts = FALSE)
		new_machine.apply_component_presets()
		new_machine.RefreshParts()
		if(new_machine.construct_state)
			new_machine.construct_state.post_construct(new_machine)
		else
			crash_with("Устройство типа [new_machine.type] был собран из схемы и рамы, но не имел установленного состояния строительства.")
		qdel(machine)
		return TRUE

/singleton/machine_construction/frame/awaiting_parts/mechanics_info()
	. = list()
	. += "Используйте лом, чтобы снять печатную плату и все установленные детали."
	. += "Используйте отвертку, чтобы собрать машину."
