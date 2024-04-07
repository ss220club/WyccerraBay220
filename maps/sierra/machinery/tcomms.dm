/obj/machinery/telecomms/relay/preset/charon
	id = "Charon Relay"
	toggled = 0
	autolinkers = list("s_relay")

/datum/map/sierra/default_internal_channels()
	return list(
		num2text(PUB_FREQ)   = list(),
		num2text(AI_FREQ)    = list(GLOB.access_synth),
		num2text(ENT_FREQ)   = list(),
		num2text(ERT_FREQ)   = list(GLOB.access_cent_specops),
		num2text(COMM_FREQ)  = list(GLOB.access_heads),
		num2text(ENG_FREQ)   = list(GLOB.access_engine_equip, GLOB.access_atmospherics),
		num2text(MED_FREQ)   = list(GLOB.access_medical_equip),
		num2text(MED_I_FREQ) = list(GLOB.access_medical_equip),
		num2text(SEC_FREQ)   = list(GLOB.access_security),
		num2text(SEC_I_FREQ) = list(GLOB.access_security),
		num2text(SCI_FREQ)   = list(GLOB.access_tox, GLOB.access_robotics, GLOB.access_xenobiology, access_el),
		num2text(SUP_FREQ)   = list(GLOB.access_cargo),
		num2text(SRV_FREQ)   = list(GLOB.access_janitor, GLOB.access_hydroponics),
		num2text(EXP_FREQ)   = list(GLOB.access_explorer, GLOB.access_rd)
	)

/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "c_relay", "s_relay", "m_relay", "r_relay", "b_relay", "1_relay", "2_relay", "3_relay", "4_relay", "5_relay", "s_relay", "science", "medical",
	"supply", "service", "common", "command", "engineering", "security", "unused", "m_relay_a",
	"receiverA", "broadcasterA")
