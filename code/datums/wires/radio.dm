/datum/wires/radio
	holder_type = /obj/item/device/radio
	wire_count = 3
	descriptions = list(
		new /datum/wire_description(GLOB.WIRE_SIGNAL, "This wire connects several radio components."),
		new /datum/wire_description(GLOB.WIRE_RECEIVE, "This wire runs to the radio reciever.", SKILL_EXPERIENCED),
		new /datum/wire_description(GLOB.WIRE_TRANSMIT, "This wire runs to the radio transmitter.")
	)

GLOBAL_VAR_CONST(WIRE_SIGNAL, 1)
GLOBAL_VAR_CONST(WIRE_RECEIVE, 2)
GLOBAL_VAR_CONST(WIRE_TRANSMIT, 4)

/datum/wires/radio/CanUse(mob/living/L)
	var/obj/item/device/radio/R = holder
	if(R.b_stat)
		return 1
	return 0

/datum/wires/radio/GetInteractWindow(mob/user)
	var/obj/item/device/radio/R = holder
	. += ..()
	if(R.cell)
		. += "<BR><A href='?src=\ref[R];remove_cell=1'>Remove cell</A><BR>"

/datum/wires/radio/UpdatePulsed(index)
	var/obj/item/device/radio/R = holder
	switch(index)
		if(GLOB.WIRE_SIGNAL)
			R.listening = !R.listening && !IsIndexCut(GLOB.WIRE_RECEIVE)
			R.broadcasting = R.listening && !IsIndexCut(GLOB.WIRE_TRANSMIT)

		if(GLOB.WIRE_RECEIVE)
			R.listening = !R.listening && !IsIndexCut(GLOB.WIRE_SIGNAL)

		if(GLOB.WIRE_TRANSMIT)
			R.broadcasting = !R.broadcasting && !IsIndexCut(GLOB.WIRE_SIGNAL)
	SSnano.update_uis(holder)

/datum/wires/radio/UpdateCut(index, mended)
	var/obj/item/device/radio/R = holder
	switch(index)
		if(GLOB.WIRE_SIGNAL)
			R.listening = mended && !IsIndexCut(GLOB.WIRE_RECEIVE)
			R.broadcasting = mended && !IsIndexCut(GLOB.WIRE_TRANSMIT)

		if(GLOB.WIRE_RECEIVE)
			R.listening = mended && !IsIndexCut(GLOB.WIRE_SIGNAL)

		if(GLOB.WIRE_TRANSMIT)
			R.broadcasting = mended && !IsIndexCut(GLOB.WIRE_SIGNAL)
	SSnano.update_uis(holder)
